/*  Oryx AC: collects and analyzes statistics to find some cheaters in CS:S, CS:GO, and TF2 bunnyhop.
 *  Copyright (C) 2018  Nolan O.
 *  Copyright (C) 2018  shavit.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include <sourcemod>
#include <sdktools>
#include <oryx>
#include <dhooks>

#undef REQUIRE_PLUGIN
#include <shavit>

#pragma newdecls required
#pragma semicolon 1

#define DESC1 "Acute TR formatter"
#define DESC2 "+left/right bypasser"
// #define DESC3 "Angle snapping" // Left unimplemented before forking..?
#define DESC4 "Prestrafe tool"
#define DESC5 "Possible AC bypass attempt via +left/right forging"
#define DESC6 "Average strafe too close to 0"
#define DESC7 "Too many perfect strafes"

// Decrease this to make the strafe anticheat more sensitive.
// Samples will be taken from the last X strafes' data.
#define SAMPLE_SIZE 30

char gS_LogPath[PLATFORM_MAX_PATH];

int gI_PerfAngleStreak[MAXPLAYERS+1];
int gI_SteadyAngleStreak[MAXPLAYERS+1];
int gI_SteadyAngleStreakPre[MAXPLAYERS+1];
int gI_KeyTransitionTick[MAXPLAYERS+1];
int gI_AngleTransitionTick[MAXPLAYERS+1];
bool gB_KeyChanged[MAXPLAYERS+1];
bool gB_DirectionChanged[MAXPLAYERS+1];
int gI_BASHTriggerCountdown[MAXPLAYERS+1];
int gI_LastTeleportTick[MAXPLAYERS+1];
int gI_CurrentStrafe[MAXPLAYERS+1];
ArrayList gA_StrafeHistory[MAXPLAYERS+1];

float gF_PreviousOptimizedAngle[MAXPLAYERS+1];
float gF_PreviousAngle[MAXPLAYERS+1];
float gF_PreviousDeltaAngleAbs[MAXPLAYERS+1];
float gF_PreviousDeltaAngle[MAXPLAYERS+1];

int gI_AbsTicks[MAXPLAYERS+1];
int gI_PreviousButtons[MAXPLAYERS+1];

bool gB_LeftThisJump[MAXPLAYERS+1];
bool gB_RightThisJump[MAXPLAYERS+1];

bool gB_Shavit = false;
Handle gH_Teleport = null;

public Plugin myinfo = 
{
	name = "ORYX strafe module",
	author = "Rusty, shavit",
	description = "Detects suspicious strafe behavior.",
	version = ORYX_VERSION,
	url = "https://github.com/shavitush/Oryx-AC"
}

public void OnPluginStart()
{
	RegConsoleCmd("strafe_stats", Command_PrintStrafeStats);

	LoadTranslations("common.phrases");

	gB_Shavit = LibraryExists("shavit");
	
	BuildPath(Path_SM, gS_LogPath, PLATFORM_MAX_PATH, "logs/oryx-strafe-stats.log");

	if(LibraryExists("dhooks"))
	{
		OnLibraryAdded("dhooks");
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

public MRESReturn DHook_Teleport(int pThis, Handle hReturn)
{
	gI_LastTeleportTick[pThis] = gI_AbsTicks[pThis];

	return MRES_Ignored;
}

public void OnClientPutInServer(int client)
{
	gI_PerfAngleStreak[client] = 0;
	gI_SteadyAngleStreak[client] = 0;
	gI_SteadyAngleStreakPre[client] = 0;
	gI_KeyTransitionTick[client] = 0;
	gI_AngleTransitionTick[client] = 0;
	gB_KeyChanged[client] = false;
	gB_DirectionChanged[client] = false;
	gI_BASHTriggerCountdown[client] = 0;
	gI_AbsTicks[client] = 0;
	gI_LastTeleportTick[client] = 0;
	gI_CurrentStrafe[client] = 0;
	gA_StrafeHistory[client] = new ArrayList();

	if(gH_Teleport != null)
	{
		DHookEntity(gH_Teleport, true, client);
	}
}

public void OnClientDisconnect(int client)
{
	delete gA_StrafeHistory[client];
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "shavit"))
	{
		gB_Shavit = true;
	}

	else if(StrEqual(name, "dhooks"))
	{
		Handle hGameData = LoadGameConfigFile("sdktools.games");

		if(hGameData != null)
		{
			int iOffset = GameConfGetOffset(hGameData, "Teleport");

			if(iOffset != -1)
			{
				gH_Teleport = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHook_Teleport);

				DHookAddParam(gH_Teleport, HookParamType_VectorPtr);
				DHookAddParam(gH_Teleport, HookParamType_ObjectPtr);
				DHookAddParam(gH_Teleport, HookParamType_VectorPtr);

				if(GetEngineVersion() == Engine_CSGO)
				{
					DHookAddParam(gH_Teleport, HookParamType_Bool);
				}
			}

			else
			{
				SetFailState("Couldn't get the offset for \"Teleport\" - make sure your SDKTools gamedata is updated!");
			}
		}

		delete hGameData;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if(StrEqual(name, "shavit"))
	{
		gB_Shavit = false;
	}

	else if(StrEqual(name, "dhooks"))
	{
		gH_Teleport = null;
	}
}

bool IsSurfing(int client)
{
	float fPosition[3];
	GetClientAbsOrigin(client, fPosition);

	float fEnd[3];
	fEnd = fPosition;
	fEnd[2] -= 64.0;

	float fMins[3];
	GetEntPropVector(client, Prop_Send, "m_vecMins", fMins);

	float fMaxs[3];
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", fMaxs);

	Handle hTR = TR_TraceHullFilterEx(fPosition, fEnd, fMins, fMaxs, MASK_PLAYERSOLID, TRFilter_NoPlayers, client);

	if(TR_DidHit(hTR))
	{
		float fNormal[3];
		TR_GetPlaneNormal(hTR, fNormal);

		delete hTR;

		// If the plane normal's Z axis is 0.7 or below (alternatively, -0.7 when upside-down) then it's a surf ramp.
		// https://mxr.alliedmods.net/hl2sdk-css/source/game/server/physics_main.cpp#1059

		return (-0.7 <= fNormal[2] <= 0.7);
	}

	delete hTR;

	return false;
}

public bool TRFilter_NoPlayers(int entity, int mask, any data)
{
	return (entity != view_as<int>(data) || (entity < 1 || entity > MaxClients));
}

int GetSampledStrafes(int client)
{
	if(gA_StrafeHistory[client] == null)
	{
		return 0;
	}

	int iSize = gA_StrafeHistory[client].Length;
	int iEnd = (iSize >= SAMPLE_SIZE)? (iSize - SAMPLE_SIZE):0;

	return (iSize - iEnd);
}

public Action Command_PrintStrafeStats(int client, int args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "Usage: strafe_stats <target>");

		return Plugin_Handled;
	}
	
	char[] sArgs = new char[MAX_TARGET_LENGTH];
	GetCmdArgString(sArgs, MAX_TARGET_LENGTH);

	int target = FindTarget(client, sArgs);

	if(target == -1)
	{
		return Plugin_Handled;
	}

	if(GetSampledStrafes(target) == 0)
	{
		ReplyToCommand(client, "\x03%N\x01 does not have recorded strafe stats.", target);

		return Plugin_Handled;
	}

	char[] sStrafeStats = new char[256];
	FormatStrafeStats(target, sStrafeStats, 256);

	ReplyToCommand(client, "Strafe stats for %N: %s", target, sStrafeStats);

	return Plugin_Handled;
}

void FormatStrafeStats(int client, char[] buffer, int maxlength)
{
	FormatEx(buffer, maxlength, "%d sampled strafes: {", GetSampledStrafes(client));

	int iSize = gA_StrafeHistory[client].Length;
	int iEnd = (iSize >= SAMPLE_SIZE)? (iSize - SAMPLE_SIZE):0;

	for(int i = iSize - 1; i >= iEnd; i--)
	{
		Format(buffer, maxlength, "%s %d,", buffer, gA_StrafeHistory[client].Get(i));
	}

	// Beautify the text output so that the stats are separated inside the curly braces, without irrelevant commas.
	int iPos = strlen(buffer) - 1;

	if(buffer[iPos] == ',')
	{
		buffer[iPos] = ' ';
	}

	StrCat(buffer, maxlength, "}");
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
	if(gB_Shavit || !IsPlayerAlive(client) || IsFakeClient(client))
	{
		return Plugin_Continue;
	}

	return SetupMove(client, buttons, angles, vel);
}

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style)
{
	return SetupMove(client, buttons, angles, vel);
}

Action SetupMove(int client, int &buttons, float angles[3], float vel[3])
{
	if(Oryx_CanBypass(client))
	{
		return Plugin_Continue;
	}

	float fDeltaAngle = angles[1] - gF_PreviousAngle[client];
	gF_PreviousAngle[client] = angles[1];

	// This is here so we have a correct previous anglew for the next tick with a legal movetype.
	if(!IsLegalMoveType(client))
	{
		return Plugin_Continue;
	}

	// 60 ticks delay after teleports before we start testing again.
	if(++gI_AbsTicks[client] - gI_LastTeleportTick[client] < (SAMPLE_SIZE * 2))
	{
		return Plugin_Continue;
	}

	if(fDeltaAngle > 180.0)
	{
		fDeltaAngle -= 360.0;
	}

	else if(fDeltaAngle < -180.0)
	{
		fDeltaAngle += 360.0;
	}

	float fDeltaAngleAbs = FloatAbs(fDeltaAngle);
	
	if(fDeltaAngleAbs < 0.015625)
	{
		return Plugin_Continue;
	}

	int iFlags = GetEntityFlags(client);
	
	/*
	* BASH remake
	* Some of the logic may seem redundant, but it probably isn't.
	*/
	if((iFlags & (FL_ONGROUND | FL_INWATER)) == 0)
	{
		// WARNING: UGLY CODE.
		if((buttons & (IN_MOVELEFT | IN_MOVERIGHT)) != (IN_MOVELEFT | IN_MOVERIGHT) &&
			(buttons & (IN_FORWARD | IN_BACK)) != (IN_FORWARD | IN_BACK))
		{
			if( // A/D
				((((buttons & IN_MOVELEFT) > 0 && (gI_PreviousButtons[client] & IN_MOVELEFT) == 0) ||
				((buttons & IN_MOVERIGHT) > 0 && (gI_PreviousButtons[client] & IN_MOVERIGHT) == 0)) ||
				((gI_PreviousButtons[client] & IN_MOVERIGHT) > 0 && (gI_PreviousButtons[client] & IN_MOVELEFT) > 0)) ||

				// S/W
				((((buttons & IN_FORWARD) > 0 && (gI_PreviousButtons[client] & IN_FORWARD) == 0) ||
				((buttons & IN_BACK) > 0 && (gI_PreviousButtons[client] & IN_BACK) == 0)) ||
				((gI_PreviousButtons[client] & IN_BACK) > 0 && (gI_PreviousButtons[client] & IN_FORWARD) > 0)))
			{
				gB_KeyChanged[client] = true;
				gI_KeyTransitionTick[client] = gI_AbsTicks[client];
			}
		}

		if(!gB_DirectionChanged[client] &&
			(fDeltaAngleAbs != 0.0 &&
			((fDeltaAngle < 0.0 && gF_PreviousDeltaAngle[client] > 0.0) ||
			(fDeltaAngle > 0.0 && gF_PreviousDeltaAngle[client] < 0.0) ||
			gF_PreviousDeltaAngleAbs[client] == 0.0)))
		{
			gB_DirectionChanged[client] = true;
			gI_AngleTransitionTick[client] = gI_AbsTicks[client];
		}
		
		if(gB_KeyChanged[client] && gB_DirectionChanged[client])
		{
			gB_KeyChanged[client] = false;
			gB_DirectionChanged[client] = false;

			int iTick = gI_KeyTransitionTick[client] - gI_AngleTransitionTick[client];
			
			if(-25 <= iTick <= 25)
			{
				gA_StrafeHistory[client].Push(iTick);
				gI_CurrentStrafe[client]++;

				if((gI_CurrentStrafe[client] % SAMPLE_SIZE) == 0)
				{
					AnalyzeBASHStats(client);
				}
			}

			if(gI_BASHTriggerCountdown[client] > 0)
			{
				gI_BASHTriggerCountdown[client]--;
			}
		}
		
		// This isn't for BASH.
		if((buttons & IN_LEFT) > 0)
		{
			gB_LeftThisJump[client] = true;
		}

		if((buttons & IN_RIGHT) > 0)
		{
			gB_RightThisJump[client] = true;
		}

		if(gB_LeftThisJump[client] && gB_RightThisJump[client])
		{
			vel[0] = 0.0;
			vel[1] = 0.0;
		}
	}

	else
	{
		gB_KeyChanged[client] = false;
		gB_DirectionChanged[client] = false;
		
		// This isn't for BASH.
		gB_LeftThisJump[client] = false;
		gB_RightThisJump[client] = false;
	}

	float fAbsVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);

	float fSpeed = (SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0)));
	
	// Perfect turn rate formatter.
	if(Oryx_WithinThreshold(fDeltaAngleAbs, gF_PreviousOptimizedAngle[client], (gF_PreviousOptimizedAngle[client] / 128.0)) && fSpeed < 2560.0)
	{
		if(++gI_PerfAngleStreak[client] == 10)
		{
			Oryx_Trigger(client, TRIGGER_LOW, DESC1);
		}

		else if(gI_PerfAngleStreak[client] == 33)
		{
			Oryx_Trigger(client, TRIGGER_MEDIUM, DESC1);
		}

		else if(gI_PerfAngleStreak[client] == 48)
		{
			Oryx_Trigger(client, TRIGGER_HIGH, DESC1);
		}
	}

	else
	{
		gI_PerfAngleStreak[client] = 0;
	}

	int iLR = (buttons & (IN_LEFT | IN_RIGHT));

	if(iLR == (IN_LEFT | IN_RIGHT) || iLR == 0)
	{
		// +left/right
		if(Oryx_WithinThreshold(fDeltaAngleAbs, gF_PreviousDeltaAngleAbs[client], (gF_PreviousDeltaAngleAbs[client] / 128.0)))
		{
			if((iFlags & FL_ONGROUND) == 0 && !IsSurfing(client))
			{
				gI_SteadyAngleStreak[client]++;

				if(gI_SteadyAngleStreak[client] == 50)
				{
					Oryx_Trigger(client, TRIGGER_LOW, DESC2);

					gI_SteadyAngleStreak[client] = 0;
				}
			}
		}

		else
		{
			gI_SteadyAngleStreak[client] = 0;
		}

		// Basically +left/right check but on the ground.
		if((iFlags & FL_ONGROUND) > 0 && Oryx_WithinThreshold(fDeltaAngleAbs, 1.2, 0.03))
		{
			gI_SteadyAngleStreakPre[client]++;

			if(gI_SteadyAngleStreakPre[client] == 20)
			{
				Oryx_Trigger(client, TRIGGER_LOW, DESC4);
			}

			else if(gI_SteadyAngleStreakPre[client] == 30)
			{
				Oryx_Trigger(client, TRIGGER_MEDIUM, DESC4);
			}

			else if(gI_SteadyAngleStreakPre[client] == 45)
			{
				Oryx_Trigger(client, TRIGGER_HIGH, DESC4);

				gI_SteadyAngleStreakPre[client] = 0;
			}
		}

		else
		{
			gI_SteadyAngleStreakPre[client] = 0;
		}
	}
	
	gI_PreviousButtons[client] = buttons;
	gF_PreviousOptimizedAngle[client] = ArcSine(30.0 / fSpeed) * 57.29577951308;
	gF_PreviousDeltaAngleAbs[client] = fDeltaAngleAbs;
	gF_PreviousDeltaAngle[client] = fDeltaAngle;

	return Plugin_Continue;
}

int Abs(int num)
{
	return (num > 0)? num:-num;
}

void AnalyzeBASHStats(int client)
{
	int iTickDifference = 0;
	int iZeroes = 0;

	for(int i = (gI_CurrentStrafe[client] - SAMPLE_SIZE); i < gI_CurrentStrafe[client] - 1; i++)
	{
		int iTick = Abs(gA_StrafeHistory[client].Get(i));
		iTickDifference += iTick;

		if(iTick == 0)
		{
			iZeroes++;
		}
	}
	
	// Average tick difference.
	if(iTickDifference < 9)
	{
		Oryx_Trigger(client, TRIGGER_MEDIUM, DESC6);
		gI_BASHTriggerCountdown[client] = 35;
	}

	else if(iTickDifference < 15)
	{
		Oryx_Trigger(client, TRIGGER_LOW, DESC6);
		gI_BASHTriggerCountdown[client] = 35;
	}

	// Don't trigger twice in one tick.
	if(gI_BASHTriggerCountdown[client] > 0)
	{
		char[] sStrafeStats = new char[256];
		FormatStrafeStats(client, sStrafeStats, 256);

		Oryx_PrintToAdminsConsole("%s", sStrafeStats);
		LogToFileEx(gS_LogPath, "%L - (%d tick difference, %d zeroes) %s", client, iTickDifference, iZeroes, sStrafeStats);

		return;
	}
	
	// Too many zeroes?
	if(iZeroes > 25)
	{
		Oryx_Trigger(client, TRIGGER_HIGH, DESC7);
		gI_BASHTriggerCountdown[client] = 35;
	}

	else if(iZeroes > 22)
	{
		Oryx_Trigger(client, TRIGGER_MEDIUM, DESC7);
		gI_BASHTriggerCountdown[client] = 35;
	}

	else if(iZeroes > 18)
	{
		Oryx_Trigger(client, TRIGGER_LOW, DESC7);
		gI_BASHTriggerCountdown[client] = 35;
	}
	
	if(gI_BASHTriggerCountdown[client] > 0)
	{
		char[] sStrafeStats = new char[256];
		FormatStrafeStats(client, sStrafeStats, 256);

		Oryx_PrintToAdminsConsole("%s", sStrafeStats);
		LogToFileEx(gS_LogPath, "%L - (%d tick difference, %d zeroes) %s", client, iTickDifference, iZeroes, sStrafeStats);
	}
}
