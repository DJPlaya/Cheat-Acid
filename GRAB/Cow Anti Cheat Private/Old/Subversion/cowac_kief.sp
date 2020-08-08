#pragma newdecls optional

#define PLUGIN_VERSION "1.0-KiefEdition"

#include <sdktools>
#include <smlib/clients>

native void SBPP_BanPlayer(int iAdmin, int iTarget, int iTime, const char[] sReason); // #include <sourcebanspp> // Too lazy for includes

ConVar g_hDealWith_Macro, g_hDealWith_AutoHotKey, g_hWarn_TriggerAimBot;
float prev_sidemove[MAXPLAYERS + 1], g_fJumpPos[MAXPLAYERS + 1];
int g_iprev_buttons[MAXPLAYERS + 1], g_iCmdNum[MAXPLAYERS + 1], g_iPerfectStrafes[MAXPLAYERS + 1], g_iJumpsSent[MAXPLAYERS + 1], g_iBhop[MAXPLAYERS + 1], g_iSilentStrafe[MAXPLAYERS + 1], g_iMacro[MAXPLAYERS + 1], g_iMousedx_Value[MAXPLAYERS + 1], g_iMousedx_Count[MAXPLAYERS + 1], g_iAutoHotKey[MAXPLAYERS + 1], g_iTicksOnPlayer[MAXPLAYERS + 1], g_iPrev_TicksOnPlayer[MAXPLAYERS + 1], g_iTriggerBotCount[MAXPLAYERS + 1];
bool g_bTurn[MAXPLAYERS + 1], g_bOnGround[MAXPLAYERS + 1], g_bAutoBhopEnabled[MAXPLAYERS + 1];


public Plugin myinfo = 
{
	name = "CowAC Kief Edition", 
	description = "Anti-Cheat System focused on Eye Hacks aswell as Movement Scripts and similar, special Edition made for the 'ZeitZumKiffen' Community", 
	author = "Cow (Playa Edit)", 
	version = PLUGIN_VERSION, 
	url = "FunForBattle"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, err_max)
{
	MarkNativeAsOptional("SBPP_BanPlayer");
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	RequestFrame(getSettings);
	
	CreateConVar("cowac_version", PLUGIN_VERSION, "Cow Anti Cheat (Kief Edition) Plugin Version (do not touch)", FCVAR_NOTIFY | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_UNLOGGED); // "notify" - So that we appear on Server Tracking Sites, "sponly" because we do not want Chat Messages about this CVar caused by "notify", "dontrecord" - So that we don't get saved to the Auto cfg, "unlogged" - Because changes of this CVar dosent need to be logged
	g_hDealWith_Macro = CreateConVar("cowac_deal_with_macro", "1.0", "What todo when a possible Macro Cheat is detected (0 = Deactivated, 1 = Print to Admins, 2 = Log only, 3 = Log and Print to Admins)", _, true, 0.0, true, 1.0);
	g_hDealWith_AutoHotKey = CreateConVar("cowac_deal_with_autohotkey", "1.0", "What todo when a possible AutoHotKey Cheat is detected (0 = Deactivated, 1 = Print to Admins, 2 = Log only, 3 = Log and Print to Admins)", _, true, 0.0, true, 1.0);
	g_hWarn_TriggerAimBot = CreateConVar("cowac_warn_triggeraimbot", "1.0", "Tell Admins once an Aim- or Triggerbot is detected (0 = Deactivated, 1 = Print to Admins)", _, true, 0.0, true, 1.0);
	AutoExecConfig(true, "CowAC_Kief");
}

public void OnClientPutInServer(int client)
{
	g_iprev_buttons[client] = 0;
	g_iCmdNum[client] = 0;
	g_bTurn[client] = true;
	g_iPerfectStrafes[client] = 0;
	g_bOnGround[client] = true;
	g_iJumpsSent[client] = 0;
	g_iBhop[client] = 0;
	g_bAutoBhopEnabled[client] = false;
	prev_sidemove[client] = 0.0;
	g_iSilentStrafe[client] = 0;
	g_fJumpPos[client] = 0.0;
	g_iMacro[client] = 0;
	g_iMousedx_Value[client] = 0;
	g_iMousedx_Count[client] = 0;
	g_iAutoHotKey[client] = 0;
	g_iTicksOnPlayer[client] = 0;
	g_iPrev_TicksOnPlayer[client] = 0;
	g_iTriggerBotCount[client] = 0;
	return;
}

public void getSettings()
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (Client_IsValid(i, true))
		{
			QueryClientConVar(i, "sv_autobunnyhopping", ConVar_QueryClient, i);
			i++;
		}
		
		i++;
	}
	
	return;
}

public void ConVar_QueryClient(QueryCookie cookie, int client, ConVarQueryResult result, char[] cvarName, char[] cvarValue)
{
	if (Client_IsValid(client, true))
	{
		if (result)
		{
		}
		
		else
		{
			if (StrEqual("sv_autobunnyhopping", cvarName, true))
			{
				if (0 < StringToInt(cvarValue, 10))
				{
					g_bAutoBhopEnabled[client] = true;
				}
				
				g_bAutoBhopEnabled[client] = false;
			}
		}
	}
	
	return;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (Client_IsValid(client, true) && IsPlayerAlive(client))
	{
		int flags = GetEntityFlags(client);
		if (flags & 1)
		{
			float pos[3];
			GetClientAbsOrigin(client, pos);
			g_fJumpPos[client] = pos[2];
		}
		
		float vOrigin[3];
		float AnglesVec[3];
		float EndPoint[3];
		float Distance = 1232348144.0;
		GetClientEyePosition(client, vOrigin);
		GetAngleVectors(angles, AnglesVec, NULL_VECTOR, NULL_VECTOR);
		EndPoint[0] = vOrigin[0] + AnglesVec[0] * Distance;
		EndPoint[1] = vOrigin[1] + AnglesVec[1] * Distance;
		EndPoint[2] = vOrigin[2] + AnglesVec[2] * Distance;
		Handle trace = TR_TraceRayFilterEx(vOrigin, EndPoint, 1174421507, RayType_EndPoint, TraceEntityFilterPlayer, client);
		PerfectStrafe(client, buttons, flags, mouse[0]);
		if (!g_bAutoBhopEnabled[client])
			Bhop(client, buttons, flags);
			
		SilentStrafe(client, flags, vel[2]);
		Macro(client, buttons, flags);
		AutoHotKey(client, mouse[0]);
		CheckTriggerBot(client, buttons, trace);
		g_iprev_buttons[client] = buttons;
		prev_sidemove[client] = vel[2];
		g_iCmdNum[client]++;
		CloseHandle(trace);
		trace = null;
	}
	
	return;
}

public void PerfectStrafe(int client, int buttons, int flags, int mousedx)
{
	if (flags != 1)
	{
		if (mousedx > 0)
		{
			if (g_iprev_buttons[client] != 1024)
				g_iPerfectStrafes[client]++;
				
			else
				g_iPerfectStrafes[client] = 0;
				
			g_bTurn[client] = false;
		}
		
		if (mousedx < 0)
		{
			if (g_iprev_buttons[client] != 512)
				g_iPerfectStrafes[client]++;
				
			else
				g_iPerfectStrafes[client] = 0;
				
			g_bTurn[client] = true;
		}
	}
	
	if (g_iPerfectStrafes[client] >= 16)
	{
		g_iPerfectStrafes[client] = 0;
		CowAC_Ban(client, "Strafe Hack");
	}
	
	return;
}

public void Bhop(int client, int buttons, int flags)
{
	if (flags != 1)
	{
		g_bOnGround[client] = false;
		if (g_iprev_buttons[client] != 2)
			g_iJumpsSent[client]++;
	}
	
	else
	{
		if (flags & 1)
		{
			if (g_iJumpsSent[client] <= 1)
				g_iBhop[client]++;
				
			g_iJumpsSent[client] = 0;
			g_bOnGround[client] = true;
			if (g_iBhop[client] >= 10)
			{
				g_iBhop[client] = 0;
				CowAC_Ban(client, "Bhop Assistance");
			}
		}
		
		g_iBhop[client] = 0;
	}
	
	return;
}

public void SilentStrafe(int client, int flags, float sidemove)
{
	if (flags != 1)
	{
		if (450 == sidemove)
			g_iSilentStrafe[client]++;
			
		else
		{
			if (-450 == sidemove)
				g_iSilentStrafe[client]++;
				
			g_iSilentStrafe[client] = 0;
		}
	}
	
	else
		if (flags & 1)
			g_iSilentStrafe[client] = 0;
			
	if (g_iSilentStrafe[client] >= 10)
	{
		g_iSilentStrafe[client] = 0;
		CowAC_Ban(client, "Silent Strafe");
	}
	
	return;
}

public void Macro(int iClient, int buttons, int flags)
{
	if (flags != 1)
	{
		float pos[3];
		GetClientAbsOrigin(iClient, pos);
		if (pos[2] >= g_fJumpPos[iClient])
			g_iMacro[iClient]++;
	}
	
	else
		if (flags & 1)
			g_iMacro[iClient] = 0;
			
	if (g_iMacro[iClient] >= 30)
	{
		if(g_hDealWith_Macro.IntValue == 1 || g_hDealWith_Macro.IntValue == 3)
		{
			char message[128];
			Format(message, 128, "[\x02CowAC Kief Edition\x01] Possible Macro Detected from \x04%N", iClient);
			PrintToAdmins(message);
		}
		
		if(g_hDealWith_Macro.IntValue == 2 || g_hDealWith_Macro.IntValue == 3)
		{
			char cIP[64];
			GetClientIP(iClient, cIP, sizeof(cIP));
			CowAC_Log("[Warn] '%L'<%s> is possibly running an Macro related Cheat", iClient, cIP);
		}
		
		g_iMacro[iClient] = 0;
	}
	
	return;
}

public void AutoHotKey(int iClient, int mouse)
{
	float vec[3];
	GetClientAbsOrigin(iClient, vec);
	if (mouse >= 10)
	{
		g_iMousedx_Count[iClient] = 0;
		g_iAutoHotKey[iClient]++;
		if (g_iAutoHotKey[iClient] >= 10)
		{
			if(g_hDealWith_AutoHotKey.IntValue == 1 || g_hDealWith_AutoHotKey.IntValue == 3)
			{
				char message[128];
				Format(message, 128, "[\x02CowAC Kief Edition\x01] Possible AutoHotKey Cheat Detected from \x04%N", iClient);
				PrintToAdmins(message);
			}
			
			if(g_hDealWith_AutoHotKey.IntValue == 2 || g_hDealWith_AutoHotKey.IntValue == 3)
			{
				char cIP[64];
				GetClientIP(iClient, cIP, sizeof(cIP));
				CowAC_Log("[Warn] '%L'<%s> is possibly running an AutoHotKey related Cheat", iClient, cIP);
			}
			
			g_iAutoHotKey[iClient] = 0;
			
			return;
		}
		
		return;
	}
	
	return;
}

public void CheckTriggerBot(int client, int buttons, Handle trace)
{
	if (TR_DidHit(trace))
	{
		int target = TR_GetEntityIndex(trace);
		if (target > 0)
		{
			g_iTicksOnPlayer[client]++;
			if (buttons & 1)
				g_iTriggerBotCount[client]++;
				
			else
				if (buttons & 1)
					g_iTriggerBotCount[client] = 0;
		}
		
		else
		{
			if (0 < g_iTicksOnPlayer[client])
				g_iPrev_TicksOnPlayer[client] = g_iTicksOnPlayer[client];
				
			g_iTicksOnPlayer[client] = 0;
		}
	}
	
	else
	{
		if (0 < g_iTicksOnPlayer[client])
			g_iPrev_TicksOnPlayer[client] = g_iTicksOnPlayer[client];
			
		g_iTicksOnPlayer[client] = 0;
	}
	
	if (g_iTriggerBotCount[client] >= 5)
	{
		if(g_hWarn_TriggerAimBot.BoolValue)
		{
			char message[64];
			Format(message, 64, "[\x02CowAC Kief Edition\x01] Triggerbot/Aimbot Detected (\x04%N\x01) - \x14BAN", client);
			PrintToAdmins(message);
		}
		
		CowAC_Ban(client, "Triggerbot/Aimbot");
		g_iTriggerBotCount[client] = 0;
	}
	
	return;
}

// ********** Stocks **********

void CowAC_Ban(int iClient, char[] cReason)
{
	char message[128], cIP[64];
	Format(message, 128, "You have been kicked for using '%s'", cReason); // TODO: Change to "banned"
	if (LibraryExists("sourcebans++"))
		SBPP_BanPlayer(0, iClient, 1440, message); // 1 Day
		
	else
		BanClient(iClient, 1440, BANFLAG_AUTO, cReason, message, "CowACKief", 0); // 1 Day
		
	GetClientIP(iClient, cIP, sizeof(cIP));
	CowAC_Log("[Ban] '%L'<%s> was banned for '%s'", iClient, cIP, cReason);
	
	return;
}

/*
* Logs an Error Message
* 
* @param cText			Message to log.
* @param ...			Variable number of format parameters.
*/
void CowAC_Log(const char[] cText, any...)
{
	char cBuffer[256], cPath[256];
	VFormat(cBuffer, sizeof(cBuffer), cText, 2);
	BuildPath(Path_SM, cPath, sizeof(cPath), "logs/CowAC.log");
	LogMessage("%s", cBuffer);
	LogToFileEx(cPath, "%s", cBuffer);
}

bool TraceEntityFilterPlayer(int entity, int mask, any data)
{
	return entity != data;
}

void PrintToAdmins(char[] message)
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (Client_IsValid(i, true))
		{
			if (CheckCommandAccess(i, "anticheat_print_override", 2, false))
			{
				PrintToChat(i, message);
				i++;
			}
			
			i++;
		}
		
		i++;
	}
	
	return;
}