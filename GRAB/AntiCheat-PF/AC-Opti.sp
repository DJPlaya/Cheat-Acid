#include <sourcemod>
#include <AC-Helper>

#pragma newdecls required
#pragma semicolon 1

#define DESC1 "Perfect AirPath" // idk if im able to detect this how i think i will
#define DESC2 "Inhuman Mouse Accel" // Should detect if someone is acceling mouse at insane rates
#define DESC3 "Inhuman DPTS" // Distance per tick per strafe

// This module completly ignores Key presses and only looks at mouse movements...
// see AC-Strafe for Key pressed detections

// ticks to sample
// 98 is 1 jump with no binds/bugs
// 200 is ~2 jumps
#define SAMPLE_SIZE 200

//char g_szLogPath[PLATFORM_MAX_PATH];

// g_fPreviousDistTick[MAXPLAYERS+1]?
float g_fPreviousAngle[MAXPLAYERS+1]
		, g_fPreviousDeltaAngle[MAXPLAYERS+1]
		, g_fPreviousDeltaAngleAbs[MAXPLAYERS+1]
		, g_fPreviousTurningAngle[MAXPLAYERS+1];

int g_iCurrentTick[MAXPLAYERS+1]
	, g_iAngleTransitionTick[MAXPLAYERS+1]
	, g_iAbsTicks[MAXPLAYERS+1];

bool g_bDirectionChanged[MAXPLAYERS+1]
	 , g_bCanCheck[MAXPLAYERS+1];

ArrayList g_aAirPathHistory[MAXPLAYERS+1];
ArrayList g_aDPTHistory[MAXPLAYERS+1];
ArrayList g_aMouseAccelHist[MAXPLAYERS+1];

public Plugin myinfo = {
	name = "",
	author = "",
	description = "",
	version = "",
	url = ""
}

public void OnPluginStart() {
	RegConsoleCmd("sm_airpath", Client_PrintAirpath);
	RegConsoleCmd("sm_dpt", Client_PrintDPT);
	RegConsoleCmd("sm_mousecheck", Client_PrintAccel);

	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i))
			OnClientPutInServer(i);
	}
}

public void OnClientPutInServer(int client) {
	g_iCurrentTick[client] = 0;
	g_iAngleTransitionTick[client] = 0;

	g_bDirectionChanged[client] = false;

	g_aAirPathHistory[client] = new ArrayList();
	g_aDPTHistory[client] = new ArrayList();
	g_aMouseAccelHist[client] = new ArrayList();
}

public void OnClientDisconnect(int client) {
	delete g_aAirPathHistory[client];
	delete g_aDPTHistory[client];
	delete g_aMouseAccelHist[client];
}

int GetAirpathSamples(int client) {
	if(g_aAirPathHistory[client] == null)
		return 0;

	int iSize = g_aAirPathHistory[client].Length;
	int iEnd = (iSize >= SAMPLE_SIZE) ? (iSize - SAMPLE_SIZE):0;

	return (iSize - iEnd);
}

int GetDPTSamples(int client) {
	if(g_aDPTHistory[client] == null)
		return 0;

	int iSize = g_aDPTHistory[client].Length;
	int iEnd = (iSize >= SAMPLE_SIZE) ? (iSize - SAMPLE_SIZE):0;

	return (iSize - iEnd);
}

int GetAccelSamples(int client) {
	if(g_aMouseAccelHist[client] == null)
		return 0;

	int iSize = g_aMouseAccelHist[client].Length;
	int iEnd = (iSize >= SAMPLE_SIZE) ? (iSize - SAMPLE_SIZE):0;

	return (iSize - iEnd);
}

public Action Client_PrintAirpath(int client, int args) {
	if(args < 1) {
		ReplyToCommand(client, "Proper Formatting: sm_airpath <target>");
		return Plugin_Handled;
	}

	char[] szArgs = new char[MAX_TARGET_LENGTH];
	GetCmdArgString(szArgs, MAX_TARGET_LENGTH);

	int target = FindTarget(client, szArgs);

	if(target == -1)
		return Plugin_Handled;

	if(GetAirpathSamples(target) == 0) {
		ReplyToCommand(client, "%N does not have any Airpath stats.", target);
		return Plugin_Handled;
	}

	char[] szAirpathStats = new char[512];
	FormatAirpath(target, szAirpathStats, 512);

	ReplyToCommand(client, "Airpath stats for %N: %s", target, szAirpathStats);

	return Plugin_Handled;
}

public Action Client_PrintDPT(int client, int args) {
	if(args < 1) {
		ReplyToCommand(client, "Proper Formatting: sm_dpt <target>");
		return Plugin_Handled;
	}

	char[] szArgs = new char[MAX_TARGET_LENGTH];
	GetCmdArgString(szArgs, MAX_TARGET_LENGTH);

	int target = FindTarget(client, szArgs);

	if(target == -1)
		return Plugin_Handled;

	if(GetDPTSamples(target) == 0) {
		ReplyToCommand(client, "%N does not have any DPT stats.", target);
		return Plugin_Handled;
	}

	char[] szDPTStats = new char[512];
	FormatDPTs(target, szDPTStats, 512);

	ReplyToCommand(client, "DPTs for %N: %s", target, szDPTStats);

	return Plugin_Handled;
}

public Action Client_PrintAccel(int client, int args) {
	if(args < 1) {
		ReplyToCommand(client, "Proper Formatting: sm_mousecheck <target>");
		return Plugin_Handled;
	}

	char[] szArgs = new char[MAX_TARGET_LENGTH];
	GetCmdArgString(szArgs, MAX_TARGET_LENGTH);

	int target = FindTarget(client, szArgs);

	if(target == -1)
		return Plugin_Handled;

	if(GetAccelSamples(target) == 0) {
		ReplyToCommand(client, "%N does not have any Accel stats.", target);
		return Plugin_Handled;
	}

	char[] szAccelStats = new char[512];
	FormatAccel(target, szAccelStats, 512);

	ReplyToCommand(client, "Accel stats for %N: %s", target, szAccelStats);

	return Plugin_Handled;
}

void FormatAirpath(int client, char[] buffer, int maxlength) {
	FormatEx(buffer, maxlength, "%i Ticks sampled: {", GetAirpathSamples(client));

	int iSize = g_aAirPathHistory[client].Length;
	int iEnd = (iSize >= SAMPLE_SIZE) ? (iSize - SAMPLE_SIZE):0;

	for(int i = iSize - 1; i >= iEnd; i--)
		Format(buffer, maxlength, "%s %i,", buffer, g_aAirPathHistory[client].Get(i));

	int iPos = strlen(buffer) - 1;

	if(buffer[iPos] == ',')
		buffer[iPos] = ' ';

	StrCat(buffer, maxlength, "}");
}

void FormatDPTs(int client, char[] buffer, int maxlength) {
	FormatEx(buffer, maxlength, "%i Ticks sampled: {", GetDPTSamples(client));

	int iSize = g_aDPTHistory[client].Length;
	int iEnd = (iSize >= SAMPLE_SIZE) ? (iSize - SAMPLE_SIZE):0;

	for(int i = iSize - 1; i >= iEnd; i--)
		Format(buffer, maxlength, "%s %i,", buffer, g_aDPTHistory[client].Get(i));

	int iPos = strlen(buffer) - 1;

	if(buffer[iPos] == ',')
		buffer[iPos] = ' ';

	StrCat(buffer, maxlength, "}");
}

void FormatAccel(int client, char[] buffer, int maxlength) {
	FormatEx(buffer, maxlength, "%i Ticks sampled: {", GetAccelSamples(client));

	int iSize = g_aMouseAccelHist[client].Length;
	int iEnd = (iSize >= SAMPLE_SIZE) ? (iSize - SAMPLE_SIZE):0;

	for(int i = iSize - 1; i >= iEnd; i--)
		Format(buffer, maxlength, "%s %i,", buffer, g_aMouseAccelHist[client].Get(i));

	int iPos = strlen(buffer) - 1;

	if(buffer[iPos] == ',')
		buffer[iPos] = ' ';

	StrCat(buffer, maxlength, "}");
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3]) {
	if(!IsValidClient(client) || !IsMoveTypeLeagl(client) || !AC_AllowDetect(client))
		return Plugin_Continue;
	return SetupMove(client, angles);
}

Action SetupMove(int client, float angles[3]) {
	//setting up mouse direction detection
	float fDeltaAngle = angles[1] - g_fPreviousAngle[client];
	g_fPreviousAngle[client] = angles[1];

	g_iAbsTicks[client]++;

	if(fDeltaAngle > 180.0)
		fDeltaAngle -= 360.0;

	else if(fDeltaAngle < -180.0)
		fDeltaAngle += 360.0;

	//we dont like negatives in these cals
	float fDeltaAngleAbs = FloatAbs(fDeltaAngle);

	// movment small enough doesnt matter
	if(fDeltaAngleAbs < 0.015625)
		return Plugin_Continue;

	// prep for later
	// using abs here because we just need
	float fDPT = (fDeltaAngleAbs - g_fPreviousDeltaAngleAbs[client]);

	int iFlags = GetEntityFlags(client);

	// is the client in air?
	if((iFlags & (FL_ONGROUND | FL_INWATER)) == 0) {
		if(!g_bDirectionChanged[client] &&
				(fDeltaAngleAbs != 0.0 &&
				((fDeltaAngle < 0.0 && g_fPreviousDeltaAngle[client] > 0.0) ||
				(fDeltaAngle > 0.0 && g_fPreviousDeltaAngle[client] < 0.0) ||
				g_fPreviousDeltaAngleAbs[client] == 0.0))) {

			g_bDirectionChanged[client] = true;
			g_iAngleTransitionTick[client] = g_iAbsTicks[client];
			g_iCurrentTick[client]++;
			if((g_iCurrentTick[client] % SAMPLE_SIZE) == 0)
				// some checks maybe?
				g_bCanCheck[client] = true;
			else
				g_bCanCheck[client] = false;
		}

		if(g_bDirectionChanged[client]) {
			g_bDirectionChanged[client] = false;

			float fTurningAngle = fDeltaAngle;

			// Get the distance between previous direction switch and current direction switch
			float fAngDifference = FloatAbs(fTurningAngle - g_fPreviousTurningAngle[client]);

			// if the floats are the same dont update array
			//if(fTurningAngle != g_fPreviousTurningAngle[client])
			g_aAirPathHistory[client].Push(fAngDifference);

			// Start checking for perfect airpath
			if(g_bCanCheck[client]) {
				//preping for checks
				int iPerfectTick = 0;
				int iGreatTick = 0;
				int iGoodTick = 0;
				int iTick = 0;
				int iTickAverage = 0;

				for(int i = (g_iCurrentTick[client] - SAMPLE_SIZE); i < g_iCurrentTick[client] - 1; i++) {
					float fTickCheck = g_aAirPathHistory[client].Get(i);

					// Get array average ?
					iTickAverage += RoundFloat(fTickCheck);

					if(fTickCheck == 0.0)
						iPerfectTick++;
					else if(fTickCheck <= 2.0)
						iGreatTick++;
					else if(fTickCheck <= 5.0)
						iGoodTick++;
					iTick++;
				}

				// untested values
				char szInfo[256];
				Format(szInfo, 256, "Average Ticks: %i", iTickAverage);
				if(iTickAverage < 5) {
					AC_Trigger(client, T_DEF, DESC1);
					AC_NotifyDiscord(client, T_DEF, DESC1, szInfo);
				}
				else if(iTickAverage < 9) {
					AC_Trigger(client, T_HIGH, DESC1);
					AC_NotifyDiscord(client, T_HIGH, DESC1, szInfo);
				}
				else if(iTickAverage < 12) {
					AC_Trigger(client, T_MED, DESC1);
					AC_NotifyDiscord(client, T_MED, DESC1, szInfo);
				}
				else if(iTickAverage < 15) {
					AC_Trigger(client, T_LOW, DESC1);
					AC_NotifyDiscord(client, T_LOW, DESC1, szInfo);
				}
				if(iPerfectTick > (iTick / 2)) {
					AC_Trigger(client, T_DEF, DESC1);
					AC_NotifyDiscord(client, T_DEF, DESC1, szInfo);
				}
				//if(iGreatTick > someval)
			}

			g_fPreviousTurningAngle[client] = fDeltaAngle;
		}

		g_aDPTHistory[client].Push(fDPT);
	}

	char szInfo[256];
	Format(szInfo, 256, "Distance Per Tick: %.2f", fDPT);
	// client doesnt need to be in air for this to happen
	// we did the calcs while in air...
	// Do the DPT triggers here, not sure what values to use as this is my new method
/*	if(fDPT >= 1)
		AC_Trigger(client, T_DEF, DESC3, szInfo);
	else if(fDPT <= 5.0)
		AC_Trigger(client, T_HIGH, DESC3, szInfo);
	else if(fDPT <= 7.5)
		AC_Trigger(client, T_MED, DESC3, szInfo);
	else if(fDPT <= 10.0)
		AC_Trigger(client, T_LOW, DESC3, szInfo);
*/
	g_fPreviousDeltaAngleAbs[client] = fDeltaAngleAbs;

	return Plugin_Continue;
}

bool IsValidClient(int client) {
	return (0 < client <= MaxClients && IsClientInGame(client));
}
