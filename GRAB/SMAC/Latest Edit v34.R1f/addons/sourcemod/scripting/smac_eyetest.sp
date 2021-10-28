#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <smac>

/* Plugin Info */
public Plugin:myinfo =
{
	name = "SMAC: Eye Angle Test",
	author = SMAC_AUTHOR,
	description = "Detects eye angle violations used in cheats",
	version = SMAC_VERSION,
	url = SMAC_URL
};

enum ResetStatus {
	State_Okay = 0,
	State_Resetting,
	State_Reset
};


new Handle:g_hCvarBan = INVALID_HANDLE;
new Float:g_fDetectedTime[MAXPLAYERS+1];

new bool:g_bPrevAlive[MAXPLAYERS+1];
new g_iPrevButtons[MAXPLAYERS+1] = {-1, ...};
new g_iPrevCmdNum[MAXPLAYERS+1] = {-1, ...};
new g_iPrevTickCount[MAXPLAYERS+1] = {-1, ...};
new g_iCmdNumOffset[MAXPLAYERS+1] = {1, ...};

new ResetStatus:g_TickStatus[MAXPLAYERS+1];

public OnPluginStart()
{
	LoadTranslations("smac.phrases");
	
	// Convars.
	g_hCvarBan = SMAC_CreateConVar("smac_eyetest_ban", "1", "Automatically ban players on eye test detections.", _, true, 0.0, true, 1.0);
	RequireFeature(FeatureType_Capability, FEATURECAP_PLAYERRUNCMD_11PARAMS, "This module requires a newer version of SourceMod.");
	
}

public OnClientDisconnect(client)
{
	// Clients don't actually disconnect on map change. They start sending the new cmdnums before _Post fires.
	g_bPrevAlive[client] = false;
	g_iPrevButtons[client] = -1;
	g_iPrevCmdNum[client] = -1;
	g_iPrevTickCount[client] = -1;
	g_iCmdNumOffset[client] = 1;
	g_TickStatus[client] = State_Okay;
}

public OnClientDisconnect_Post(client)
{
	g_fDetectedTime[client] = 0.0;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2])
{
	// Ignore bots
	if (IsFakeClient(client))
		return Plugin_Continue;
	
	// NULL commands
	if (cmdnum <= 0)
		return Plugin_Handled;
	
	// Block old cmds after a client resets their tickcount.
	if (tickcount <= 0)
		g_TickStatus[client] = State_Resetting;
	
	// Fixes issues caused by client timeouts.
	new bool:bAlive = IsPlayerAlive(client);
	if (!bAlive || !g_bPrevAlive[client] || GetGameTime() <= g_fDetectedTime[client])
	{
		g_bPrevAlive[client] = bAlive;
		g_iPrevButtons[client] = buttons;
		
		if (g_iPrevCmdNum[client] >= cmdnum)
		{
			if (g_TickStatus[client] == State_Resetting)
				g_TickStatus[client] = State_Reset;
		
			g_iCmdNumOffset[client]++;
		}
		else
		{
			if (g_TickStatus[client] == State_Reset)
				g_TickStatus[client] = State_Okay;
			
			g_iPrevCmdNum[client] = cmdnum;
			g_iCmdNumOffset[client] = 1;
		}
		
		g_iPrevTickCount[client] = tickcount;
		
		return Plugin_Continue;
	}
	
	// Check for valid cmd values being sent. The command number cannot decrement.
	if (g_iPrevCmdNum[client] > cmdnum)
	{
		if (g_TickStatus[client] != State_Okay)
		{
			g_TickStatus[client] = State_Reset;
			return Plugin_Handled;
		}
	
		g_fDetectedTime[client] = GetGameTime() + 30.0;
		
		new Handle:info = CreateKeyValues("");
		KvSetNum(info, "cmdnum", cmdnum);
		KvSetNum(info, "prevcmdnum", g_iPrevCmdNum[client]);
		KvSetNum(info, "tickcount", tickcount);
		KvSetNum(info, "prevtickcount", g_iPrevTickCount[client]);
		KvSetNum(info, "gametickcount", GetGameTickCount());
		
		if (SMAC_CheatDetected(client, Detection_UserCmdReuse, info) == Plugin_Continue)
		{
			SMAC_PrintAdminNotice("%t", "SMAC_EyetestDetected", client);
			
			if (GetConVarBool(g_hCvarBan))
			{
				SMAC_LogAction(client, "was banned for reusing old movement commands. CmdNum: %d PrevCmdNum: %d | [%d:%d:%d]", cmdnum, g_iPrevCmdNum[client], g_iPrevTickCount[client], tickcount, GetGameTickCount());
				SMAC_Ban(client, "Eye Test Violation => UserCmdReuse");
			}
			else
			{
				SMAC_LogAction(client, "is suspected of reusing old movement commands. CmdNum: %d PrevCmdNum: %d | [%d:%d:%d]", cmdnum, g_iPrevCmdNum[client], g_iPrevTickCount[client], tickcount, GetGameTickCount());
			}
		}
		
		CloseHandle(info);
		return Plugin_Handled;
	}
	
	// Other than the incremented tickcount, nothing should have changed.
	if (g_iPrevCmdNum[client] == cmdnum)
	{
		if (g_TickStatus[client] != State_Okay)
		{
			g_TickStatus[client] = State_Reset;
			return Plugin_Handled;
		}
	
		// The tickcount should be incremented.
		if (g_iPrevTickCount[client]+1 != tickcount)
		{
			g_fDetectedTime[client] = GetGameTime() + 30.0;
			new Handle:info = CreateKeyValues("");
			KvSetNum(info, "cmdnum", cmdnum);
			KvSetNum(info, "tickcount", tickcount);
			KvSetNum(info, "prevtickcount", g_iPrevTickCount[client]);
			KvSetNum(info, "gametickcount", GetGameTickCount());
			if (SMAC_CheatDetected(client, Detection_UserCmdTamperingTickcount, info) == Plugin_Continue)
			{
				SMAC_PrintAdminNotice("%t", "SMAC_EyetestDetected", client);
				if (GetConVarBool(g_hCvarBan))
				{
					SMAC_LogAction(client, "was banned for tampering with an old movement command (tickcount). CmdNum: %d | [%d:%d:%d]", cmdnum, g_iPrevTickCount[client], tickcount, GetGameTickCount());
					SMAC_Ban(client, "Eye Test Violation => UserCmdTamperingTickcount");
				}
				else
				{
					SMAC_LogAction(client, "is suspected of tampering with an old movement command (tickcount). CmdNum: %d | [%d:%d:%d]", cmdnum, g_iPrevTickCount[client], tickcount, GetGameTickCount());
				}
			}
			
			CloseHandle(info);
			return Plugin_Handled;
		}
		
		// Check for specific buttons in order to avoid compatibility issues with server-side plugins.
		if (((g_iPrevButtons[client] ^ buttons) & (IN_FORWARD|IN_BACK|IN_MOVELEFT|IN_MOVERIGHT|IN_SCORE))) 
		//if (!GetConVarBool(g_hCvarCompat) && (AbsValue(g_iPrevButtons[client] - buttons) & (IN_FORWARD|IN_BACK|IN_MOVELEFT|IN_MOVERIGHT|IN_SCORE))) - new shit [b3 method]
		{
			g_fDetectedTime[client] = GetGameTime() + 30.0;
			
			new Handle:info = CreateKeyValues("");
			KvSetNum(info, "cmdnum", cmdnum);
			KvSetNum(info, "prevbuttons", g_iPrevButtons[client]);
			KvSetNum(info, "buttons", buttons);

			if (SMAC_CheatDetected(client, Detection_UserCmdTamperingButtons, info) == Plugin_Continue)
			{
				SMAC_PrintAdminNotice("%t", "SMAC_EyetestDetected", client);				
			}
			CloseHandle(info);
			return Plugin_Handled;
		}
		// Track so we can predict the next cmdnum.
		g_iCmdNumOffset[client]++;
	}
	else
	{
		// Passively block cheats from skipping to desired seeds.
		if ((buttons & IN_ATTACK) && g_iPrevCmdNum[client] + g_iCmdNumOffset[client] != cmdnum && g_iPrevCmdNum[client] > 0)
		{
			seed = GetURandomInt();
		}
		
		g_iCmdNumOffset[client] = 1;
	}
	
	g_iPrevButtons[client] = buttons;
	g_iPrevCmdNum[client] = cmdnum;
	g_iPrevTickCount[client] = tickcount;
	
	if (g_TickStatus[client] == State_Reset)
	{
		g_TickStatus[client] = State_Okay;
	}
		
	// ep1 SMAC CODE
	decl Float:vTemp[3];
	vTemp = angles;
	if (vTemp[0] > 180.0)	vTemp[0] -= 360.0;
	if (vTemp[2] > 180.0)	vTemp[2] -= 360.0;
	if (vTemp[0] >= -90.0 && vTemp[0] <= 90.0 && vTemp[2] >= -90.0 && vTemp[2] <= 90.0)
		return Plugin_Continue;
	
	/*
	// ep2 SMAC CODE
	if (angles[0] > -135.0 && angles[0] < 135.0 && angles[1] > -270.0 && angles[1] < 270.0)
		return Plugin_Continue;
	
	*/
	//return Plugin_Continue; //disable angle-check

	
	new flags = GetEntityFlags(client);
	if (flags & FL_FROZEN || flags & FL_ATCONTROLS)
	return Plugin_Continue;
	
	// The client failed all checks.
	g_fDetectedTime[client] = GetGameTime() + 30.0;
	
	// Strict bot checking - https://bugs.alliedmods.net/show_bug.cgi?id=5294
	decl String:sAuthID[MAX_AUTHID_LENGTH];
	
	new Handle:info = CreateKeyValues("");
	KvSetVector(info, "angles", angles);
	
	if (GetClientAuthId(client, AuthId_Engine, sAuthID, sizeof(sAuthID), false) && !StrEqual(sAuthID, "BOT") && SMAC_CheatDetected(client, Detection_Eyeangles, info) == Plugin_Continue)
	{
		SMAC_PrintAdminNotice("%t", "SMAC_EyetestDetected", client);
		
		if (GetConVarBool(g_hCvarBan))
		{
			SMAC_LogAction(client, "was banned for cheating with their eye angles. Eye Angles: %.0f %.0f %.0f", angles[0], angles[1], angles[2]);
			SMAC_Ban(client, "Eye Test Violation => Eye Angle");
		}
		else
		{
			SMAC_LogAction(client, "is suspected of cheating with their eye angles. Eye Angles: %.0f %.0f %.0f", angles[0], angles[1], angles[2]);
		}
	}
	
	CloseHandle(info);
	return Plugin_Continue;
}