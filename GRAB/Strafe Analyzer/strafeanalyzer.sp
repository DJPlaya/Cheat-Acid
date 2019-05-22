#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <msharedutil/arrayvec>
#include <multicolors>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Strafe Analyzer", 
	author = "njd", 
	description = "Analyzes strafes sorta?", 
	version = "1.0", 
	url = "https://github.com/natejd/Strafe-Analyzer"
};

// Definitions
#define M_PI 3.14159265358979323846264338327950288

EngineVersion g_Engine;

bool g_bStrafeAnalyzer[MAXPLAYERS + 1];
float g_vecLastAngle[MAXPLAYERS + 1][3];
float g_fTotalNormalDelta[MAXPLAYERS + 1];
float g_fTotalPerfectDelta[MAXPLAYERS + 1];
int g_iLastFlags[MAXPLAYERS + 1];

char deltaColor[255];
char fasterSlower[255];

char g_cMsg[256];
Handle g_hMsg;

public void OnPluginStart()
{
	AutoExecConfig(true, "config", "strafeanalyzer");
	
	g_Engine = GetEngineVersion();
	
	if (g_Engine != (Engine_CSS | Engine_CSGO))
		SetFailState("Not supported");
	
	RegConsoleCmd("sm_analyzer", SM_StrafeAnalyzer);
	
	HookEvent("player_jump", OnPlayerJump);
	
	g_hMsg = FindConVar("strafeanalyzer");
	
	if (g_hMsg == INVALID_HANDLE)
	{
		g_hMsg = CreateConVar("strafeanalyzer_msg", "{orange}[{white}Strafe-Analyzer{orange}", "Messages prefix.");
	}
	GetConVarString(g_hMsg, g_cMsg, sizeof(g_cMsg));
	HookConVarChange(g_hMsg, OnFormatsChanged);
}

public void OnFormatsChanged(Handle cvar, const char[] oldValue, const char[] newValue)
{
	if (cvar == g_hMsg)
	{
		GetConVarString(g_hMsg, g_cMsg, sizeof(g_cMsg));
	}
}

stock bool isnan(float x)
{
	return x != x;
}

public Action SM_StrafeAnalyzer(int client, int args)
{
	if (IsFakeClient(client))
		return;
	
	g_bStrafeAnalyzer[client] = !g_bStrafeAnalyzer[client];
	
	if (g_bStrafeAnalyzer[client])
		MC_PrintToChat(client, "%s {white}Enabled.", g_cMsg);
	else
		MC_PrintToChat(client, "%s {white}Disabled.", g_cMsg);
}

public void OnPlayerJump(Handle event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);
	
	if (IsFakeClient(client))
		return;
	
	g_fTotalNormalDelta[client] = 0.0;
	g_fTotalPerfectDelta[client] = 0.0;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!g_bStrafeAnalyzer[client])
		return;
	
	if (IsValidUser(client, false, false))
	{
		float yaw = NormalizeAngle(angles[1] - g_vecLastAngle[client][1]);
		
		float g_vecAbsVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", g_vecAbsVelocity);
		float velocity = GetVectorLength(g_vecAbsVelocity);
		
		float wish_angle = FloatAbs(ArcSine(30.0 / velocity)) * 180 / M_PI;
		int flags = GetEntityFlags(client);
		
		if (!(flags & FL_ONGROUND))
		{
			g_fTotalNormalDelta[client] += FloatAbs(yaw);
			g_fTotalPerfectDelta[client] += wish_angle;
		}
		else if (!(g_iLastFlags[client] & FL_ONGROUND) && (flags & FL_ONGROUND))
		{
			float totalDelta = g_fTotalNormalDelta[client] - g_fTotalPerfectDelta[client];
			float totalPercent = ((g_fTotalNormalDelta[client] / g_fTotalPerfectDelta[client]) * 100.0);
			
			GetDeltaColor(totalPercent);
			GetStrafeHint(totalDelta);
			
			if (isnan(totalDelta) || isnan(totalPercent))
				return;
			
			MC_PrintToChat(client, "%s %s{white}. (Pct: %s%.2f%, AngleΔ: %s%.2f{white})", g_cMsg, fasterSlower, deltaColor, totalPercent, deltaColor, totalDelta);
		}
	}
	
	g_iLastFlags[client] = GetEntityFlags(client);
	g_vecLastAngle[client] = angles;
}

void GetStrafeHint(float x)
{
	if (x > 0.0)
		fasterSlower = "{white}Strafe {red}slower";
	else if (x < 0.0)
		fasterSlower = "{white}Strafe {green}faster";
}

void GetDeltaColor(float x)
{
	if (FloatAbs(x - 100.0) <= 10.0)
		deltaColor = "{green}";
	else if (FloatAbs(x - 100.0) <= 25.0)
		deltaColor = "{yellow}";
	else if (FloatAbs(x - 100.0) <= 40.0)
		deltaColor = "{orange}";
	else if (FloatAbs(x - 100.0) > 40.0)
		deltaColor = "{red}";
}

stock bool IsValidUser(int client, bool bAllowBots = false, bool bAllowDead = true)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
} 