#include <sourcemod>
#include <sdktools>
#include <smac>

/* Plugin Info */
public Plugin:myinfo =
{
	name = "SMAC: Spinhack Detector",
	author = SMAC_AUTHOR,
	description = "Monitors players to detect the use of spinhacks",
	version = SMAC_VERSION,
	url = SMAC_URL
};

#define SPIN_DETECTIONS		15		// Seconds of non-stop spinning before spinhack is detected
#define SPIN_ANGLE_CHANGE	1440.0	// Max angle deviation over one second before being flagged
#define SPIN_SENSITIVITY	6		// Ignore players with a higher mouse sensitivity than this

new Float:g_fPrevAngle[MAXPLAYERS+1];
new Float:g_fAngleDiff[MAXPLAYERS+1];
new Float:g_fAngleBuffer;
new Float:g_fSensitivity[MAXPLAYERS+1];

new g_iSpinCount[MAXPLAYERS+1];

/* Plugin Functions */
public OnPluginStart()
{
	LoadTranslations("smac.phrases");	
	CreateTimer(1.0, Timer_CheckSpins, _, TIMER_REPEAT);
}


public OnClientDisconnect(client)
{
	g_iSpinCount[client] = 0;
	g_fSensitivity[client] = 0.0;
}

public Action:Timer_CheckSpins(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
		{
			continue;
		}
		
		if (g_fAngleDiff[i] > SPIN_ANGLE_CHANGE && IsPlayerAlive(i))
		{
			g_iSpinCount[i]++;
			
			if (g_iSpinCount[i] == 1)
			{
				QueryClientConVar(i, "sensitivity", Query_MouseCheck, GetClientUserId(i));
			}
				
			if (g_iSpinCount[i] == SPIN_DETECTIONS && g_fSensitivity[i] <= SPIN_SENSITIVITY)
			{
				Spinhack_Detected(i);
			}
		}
		else
		{
			g_iSpinCount[i] = 0;
		}
		
		g_fAngleDiff[i] = 0.0;
	}
	
	return Plugin_Continue;
}

public Query_MouseCheck(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[], any:userid)
{
	if (result == ConVarQuery_Okay && GetClientOfUserId(userid) == client)
	{
		g_fSensitivity[client] = StringToFloat(cvarValue);
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!(buttons & IN_LEFT || buttons & IN_RIGHT))
	{
		// Only checking the Z axis here.
		g_fAngleBuffer = FloatAbs(angles[1] - g_fPrevAngle[client]);
		g_fAngleDiff[client] += (g_fAngleBuffer > 180.0) ? (g_fAngleBuffer - 360.0) * -1.0 : g_fAngleBuffer;
		g_fPrevAngle[client] = angles[1];
	}
	
	return Plugin_Continue;
}

Spinhack_Detected(client)
{
	if (SMAC_CheatDetected(client, Detection_Spinhack, INVALID_HANDLE) == Plugin_Continue)
	{
		SMAC_PrintAdminNotice("%t", "SMAC_SpinhackDetected", client);
		SMAC_LogAction(client, "is suspected of using a spinhack.");
	}
}
