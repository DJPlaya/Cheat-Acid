#include <sourcemod>
#include <sdktools>
#include <smac>

public Plugin:myinfo =
{
	name = "SMAC: AutoTrigger Detector",
	author = SMAC_AUTHOR,
	description = "Detects cheats that automatically press buttons for players",
	version = SMAC_VERSION,
	url = SMAC_URL
};

#define MIN_JUMP_TIME		0.500	// Minimum amount of air-time for a jump to count.
#define METHOD_BUNNYHOP		0
#define METHOD_AUTOSCROLL	1
#define METHOD_AUTOFIRE		2
#define METHOD_AUTOLEFT		3
#define METHOD_AUTORIGHT	4
#define METHOD_AUTODUCK		5
#define METHOD_MAX			6

new Handle:g_hCvarAction = INVALID_HANDLE;
new Handle:g_hCvarDetections = INVALID_HANDLE;
new g_iDetections[METHOD_MAX][MAXPLAYERS+1];
new g_iDetectionsMax;
new g_iAttackMax = 66;
new bool:g_bNoitice[MAXPLAYERS+1];

public OnPluginStart()
{
	LoadTranslations("smac.phrases");
	g_hCvarAction = SMAC_CreateConVar("smac_autotrigger_action", "1", "Action on auto-trigger detections.\n 0 - Notice Admin\n 1 - Kick\n 2 - Ban", _, true, 0.0, true, 50.0);
	g_hCvarDetections = SMAC_CreateConVar("smac_autotrigger_detections", "7", "Number of autotrigger detections before a player perform action.\nSMAC default - 20\n SMAC by Den4eGG - 3\n SMAC v34 beta - 10\n Recommended - 7", _, true, 0.0, true, 50.0);
	OnSettingsChanged(g_hCvarDetections, "", "");
	HookConVarChange(g_hCvarDetections, OnSettingsChanged);
	g_iAttackMax = RoundToNearest(1.0 / GetTickInterval() / 3.0);
	CreateTimer(4.0, Timer_DecreaseCount, _, TIMER_REPEAT);
}

public OnClientDisconnect_Post(client)
{
	for (new i = 0; i < METHOD_MAX; i++)
	{
		g_iDetections[i][client] = 0;
	}
	g_bNoitice[client] = false; 
}

public Action:Timer_DecreaseCount(Handle:timer)
{
	for (new i = 0; i < METHOD_MAX; i++)
	{
		for (new j = 1; j <= MaxClients; j++)
		{
			if (g_iDetections[i][j])
			{
				g_iDetections[i][j]--;
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	static iPrevButtons[MAXPLAYERS+1];
	static Float:fCheckTime[MAXPLAYERS+1];
	if (!(buttons & IN_JUMP) && (GetEntityFlags(client) & FL_ONGROUND) && fCheckTime[client] > 0.0){fCheckTime[client] = 0.0;}
	if ((buttons & IN_JUMP) && !(iPrevButtons[client] & IN_JUMP))
	{
		if (GetEntityFlags(client) & FL_ONGROUND)
		{
			new Float:fGameTime = GetGameTime();
			if (fCheckTime[client] > 0.0 && fGameTime > fCheckTime[client])
			{
				AutoTrigger_Detected(client, METHOD_BUNNYHOP);
			}
			else
			{
				fCheckTime[client] = fGameTime + MIN_JUMP_TIME;
			}
		}
		else
		{
			fCheckTime[client] = 0.0;
		}
	}
	static iAttackAmt[MAXPLAYERS+1];
	static bool:bResetNext[MAXPLAYERS+1];
	if (((buttons & IN_JUMP) && !(iPrevButtons[client] & IN_JUMP)) || (!(buttons & IN_JUMP) && (iPrevButtons[client] & IN_JUMP)))
	{
		if (++iAttackAmt[client] >= g_iAttackMax)
		{
			AutoTrigger_Detected(client, METHOD_AUTOSCROLL);
			iAttackAmt[client] = 0;
		}
		
		bResetNext[client] = false;
	}
	else if (((buttons & IN_ATTACK) && !(iPrevButtons[client] & IN_ATTACK)) || (!(buttons & IN_ATTACK) && (iPrevButtons[client] & IN_ATTACK)))
	{
		if (++iAttackAmt[client] >= g_iAttackMax)
		{
			AutoTrigger_Detected(client, METHOD_AUTOFIRE);
			iAttackAmt[client] = 0;
		}
		
		bResetNext[client] = false;
	}
	else if (((buttons & IN_MOVELEFT) && !(iPrevButtons[client] & IN_MOVELEFT)) || (!(buttons & IN_MOVELEFT) && (iPrevButtons[client] & IN_MOVELEFT)))
	{
		if (++iAttackAmt[client] >= g_iAttackMax)
		{
			AutoTrigger_Detected(client, METHOD_AUTOLEFT);
			iAttackAmt[client] = 0;
		}
		
		bResetNext[client] = false;
	}
	else if (((buttons & IN_MOVERIGHT) && !(iPrevButtons[client] & IN_MOVERIGHT)) || (!(buttons & IN_MOVERIGHT) && (iPrevButtons[client] & IN_MOVERIGHT)))
	{
		if (++iAttackAmt[client] >= g_iAttackMax)
		{
			AutoTrigger_Detected(client, METHOD_AUTORIGHT);
			iAttackAmt[client] = 0;
		}
		
		bResetNext[client] = false;
	}
	/* Auto-Duck */
	else if (((buttons & IN_DUCK) && !(iPrevButtons[client] & IN_DUCK)) || (!(buttons & IN_DUCK) && (iPrevButtons[client] & IN_DUCK)))
	{
		if (++iAttackAmt[client] >= g_iAttackMax)
		{
			AutoTrigger_Detected(client, METHOD_AUTODUCK);
			iAttackAmt[client] = 0;
		}
		
		bResetNext[client] = false;
	}
	else if (bResetNext[client])
	{
		iAttackAmt[client] = 0;
		bResetNext[client] = false;
	}
	else
	{
		bResetNext[client] = true;
	}

	iPrevButtons[client] = buttons;

	return Plugin_Continue;
}

AutoTrigger_Detected(client, method)
{
	if (g_bNoitice[client]) return;
	if (!IsFakeClient(client) && IsPlayerAlive(client) && ++g_iDetections[method][client] >= g_iDetectionsMax)
	{
		decl String:sMethod[32];

		switch (method)
		{
			case METHOD_BUNNYHOP:	strcopy(sMethod, sizeof(sMethod), "BunnyHop");
			case METHOD_AUTOSCROLL:	strcopy(sMethod, sizeof(sMethod), "Auto-Scroll");
			case METHOD_AUTOFIRE:	strcopy(sMethod, sizeof(sMethod), "Auto-Fire");
			case METHOD_AUTOLEFT:	strcopy(sMethod, sizeof(sMethod), "Auto-Strafe");
			case METHOD_AUTORIGHT:	strcopy(sMethod, sizeof(sMethod), "Auto-Strafe");
			case METHOD_AUTODUCK:	strcopy(sMethod, sizeof(sMethod), "Auto-Duck");
		}
		
		new Handle:info = CreateKeyValues("");
		KvSetString(info, "method", sMethod);
		
		if (SMAC_CheatDetected(client, Detection_AutoTrigger, info) == Plugin_Continue)
		{	
			g_bNoitice[client] = true;
			SMAC_PrintAdminNotice("%t", "SMAC_AutoTriggerDetected", client, sMethod);
			SMAC_LogAction(client, "is suspected of using auto-trigger cheat: %s", sMethod);
			switch (GetConVarInt(g_hCvarAction))
			{
				case 1:{if(!IsClientInKickQueue(client)) KickClient(client, "AutoTrigger Detection: %s", sMethod);}
				case 2:{SMAC_Ban(client, "AutoTrigger Detection: %s", sMethod);}
			}
		}
		
		CloseHandle(info);
		g_iDetections[method][client] = 0;
	}
}


public OnSettingsChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	new iNewValue = GetConVarInt(convar);
	
	if (iNewValue < 6)
	{
		PrintToServer("SMAC Warning: smac_autotrigger_detections is lower than 6.\n SMAC Warning: Possible false bans for autotrigger module");
		g_iDetectionsMax = iNewValue;
	}
	else if (iNewValue > 30)
	{
		PrintToServer("SMAC Warning: smac_autotrigger_detections is higer than 30.\n SMAC Warning: Some Autotrigger cheats can be undetected.");
		g_iDetectionsMax = iNewValue;
	}
/*	else if (iNewValue == 1337)
	{
		PrintToServer("SMAC Warning: L33T HAXORZ IS COMING...");
		g_iDetectionsMax = 1337;
	}
*/
	else g_iDetectionsMax = iNewValue;
}