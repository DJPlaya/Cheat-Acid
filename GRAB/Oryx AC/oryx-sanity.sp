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
#include <oryx>
#include <dhooks>

#undef REQUIRE_PLUGIN
#include <shavit>

#pragma newdecls required
#pragma semicolon 1

#define DESC1 "Unsynchronised movement"
#define DESC2 "Invalid wish velocity"
#define DESC3 "Wish velocity is too high"
#define DESC4 "Raw input discrepancy"
#define DESC5 "Invalid buttons/wishspeeds"

// Amount of ticks in a row where raw input can have discrepancies before acting.
#define SAMPLE_SIZE 60

EngineVersion gEV_Type = Engine_Unknown;

float gF_FullPress = 0.0;
float gF_PreviousAngle[MAXPLAYERS+1];
int gI_BadInputStreak[MAXPLAYERS+1];

bool gB_Shavit = false;
Handle gH_Teleport = null;

bool gB_TriggeredRawInput[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = "ORYX sanity module",
	author = "Rusty, shavit",
	description = "Sanity checks on movement or angle tampering.",
	version = ORYX_VERSION,
	url = "https://github.com/shavitush/Oryx-AC"
}

public void OnPluginStart()
{
	gEV_Type = GetEngineVersion();

	// cl_forwardspeed's and cl_sidespeed's default setting.
	if(gEV_Type == Engine_CSS)
	{
		gF_FullPress = 400.0;
	}

	else if(gEV_Type == Engine_CSGO || gEV_Type == Engine_TF2)
	{
		gF_FullPress = 450.0;
	}
	
	gB_Shavit = LibraryExists("shavit");

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
	if(1 <= pThis <= MaxClients)
	{
		gI_BadInputStreak[pThis] = 0;
	}

	return MRES_Ignored;
}

public void OnClientPutInServer(int client)
{
	gI_BadInputStreak[client] = 0;
	gB_TriggeredRawInput[client] = false;

	if(gH_Teleport != null)
	{
		DHookEntity(gH_Teleport, true, client);
	}
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

				if(gEV_Type == Engine_CSGO)
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

// Pretend we're using C++.
bool std__signbit(any num)
{
	return ((num >>> 31) == 1);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(gB_Shavit || !IsPlayerAlive(client) || IsFakeClient(client))
	{
		return Plugin_Continue;
	}

	return SetupMove(client, buttons, mouse[0], angles[1], vel[0], vel[1]);
}

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style, any stylesettings[STYLESETTINGS_SIZE], int mouse[2])
{
	return SetupMove(client, buttons, mouse[0], angles[1], vel[0], vel[1]);
}

Action SetupMove(int client, int buttons, int mousedx, float yaw, float forwardmove, float sidemove)
{
	if(Oryx_CanBypass(client))
	{
		return Plugin_Continue;
	}

	bool bBadInput = false;
	bool bUnsure = false;

	int iLR = (buttons & (IN_LEFT | IN_RIGHT));
	float fDeltaAngle = yaw - gF_PreviousAngle[client];
	gF_PreviousAngle[client] = yaw;

	// Only pass if mouse movement isn't being tampered by +left/right.
	// TODO: Don't allow cl_yawspeed 0?
	// TODO: check onyl when tickcount + 1
	if(!gB_TriggeredRawInput[client] && IsLegalMoveType(client) && mousedx != 0 && (iLR == (IN_LEFT | IN_RIGHT) || iLR == 0))
	{
		if(fDeltaAngle > 180.0)
		{
			fDeltaAngle -= 360.0;
			bUnsure = true;
		}

		else if(fDeltaAngle < -180.0)
		{
			fDeltaAngle += 360.0;
			bUnsure = true;
		}

		// Mouse has moved, but the yaw delta stayed the same.
		if(fDeltaAngle == 0.0)
		{
			bBadInput = true;
		}

		else if((mousedx < 0 && fDeltaAngle < 0.0) || (mousedx > 0 && fDeltaAngle > 0.0))
		{
			bBadInput = true;
		}

		// Idea from NoCheatZ-4.
		// Compare the signbit of mousedx/yaw delta.
		else if(FloatAbs(fDeltaAngle) > 0.05 && std__signbit(mousedx) == std__signbit(fDeltaAngle))
		{
			bBadInput = true;
		}

		if(bUnsure)
		{
			bBadInput = false;
		}

		// TODO: m_yaw, sens, filter etc sanity checks
	}

	if(bBadInput)
	{
		if(++gI_BadInputStreak[client] >= SAMPLE_SIZE)
		{
			char[] sReason = new char[32];
			FormatEx(sReason, 32, DESC4 ... " (d%.03f x%d u%d)", fDeltaAngle, mousedx, bUnsure);

			Oryx_Trigger(client, TRIGGER_MEDIUM, sReason);

			gI_BadInputStreak[client] = 0;
			gB_TriggeredRawInput[client] = true;
		}
	}

	else
	{
		gI_BadInputStreak[client] = 0;
	}
	
	// Invalid usercmd->forwardmove or usercmd->sidemove.
	// cl_forwardspeed and cl_sidespeed are the fully-pressed move values.
	// The game will never apply them unless the buttons are added into the usercmd too.
	// Also, the the move values cannot be anything other than: 0, speed * 0.25, speed * 0.5, speed * 0.75, and speed.
	//
	// https://mxr.alliedmods.net/hl2sdk-css/source/game/client/in_main.cpp#557
	// https://mxr.alliedmods.net/hl2sdk-css/source/game/client/in_main.cpp#842

	if((forwardmove == gF_FullPress && (buttons & IN_FORWARD) == 0) ||
	   (sidemove == -gF_FullPress && (buttons & IN_MOVELEFT) == 0) ||
	   (forwardmove == -gF_FullPress && (buttons & IN_BACK) == 0) ||
	   (sidemove == gF_FullPress && (buttons & IN_MOVERIGHT) == 0))
	{
		InvalidMoveTrigger(client, DESC1, buttons, forwardmove, sidemove);
	}

	else if(FloatAbs(forwardmove) > gF_FullPress || FloatAbs(sidemove) > gF_FullPress)
	{
		InvalidMoveTrigger(client, DESC2, buttons, forwardmove, sidemove);
	}
	
	else if(!IsValidMove(forwardmove) || !IsValidMove(sidemove))
	{
		InvalidMoveTrigger(client, DESC3, buttons, forwardmove, sidemove);
	}

	else if(!DoButtonsMatchUp(buttons, forwardmove, sidemove))
	{
		InvalidMoveTrigger(client, DESC5, buttons, forwardmove, sidemove);
	}

	return Plugin_Continue;
}

bool IsValidMove(float num)
{
	num = FloatAbs(num);

	// VERY minor optimization loss, but makes the code less annoying to read.
	float speed = gF_FullPress;

	return (num == 0.0 || num == speed || num == (speed * 0.75) || num == (speed * 0.50) || num == (speed * 0.25));
}

bool DoButtonsMatchUp(int buttons, float forwardmove, float sidemove)
{
	float fQuarter = (gF_FullPress * 0.25);
	float fHalf = (gF_FullPress * 0.5);
	float fThreeQuarters = (gF_FullPress * 0.75);
	int iAD = (buttons & (IN_MOVELEFT | IN_MOVERIGHT));

	if(iAD == 0 || iAD == (IN_MOVELEFT | IN_MOVERIGHT))
	{
		float abs = FloatAbs(sidemove);

		if(sidemove != 0.0 && abs != fQuarter && abs != fHalf && abs != fThreeQuarters)
		{
			return false;
		}
	}

	else if((iAD == IN_MOVELEFT && sidemove != -gF_FullPress && sidemove != -fHalf && sidemove != fThreeQuarters) ||
			(iAD == IN_MOVERIGHT && sidemove != gF_FullPress && sidemove != fHalf && sidemove != -fThreeQuarters))
	{
		return false;
	}

	int iSW = (buttons & (IN_FORWARD | IN_BACK));

	if(iSW == 0 || iSW == (IN_FORWARD | IN_BACK))
	{
		float abs = FloatAbs(forwardmove);

		if(forwardmove != 0.0 && abs != fQuarter && abs != fHalf && abs != fThreeQuarters)
		{
			return false;
		}
	}

	else if((iSW == IN_FORWARD && forwardmove != gF_FullPress && forwardmove != fHalf && forwardmove != fThreeQuarters) ||
			(iSW == IN_BACK && forwardmove != -gF_FullPress && forwardmove != -fHalf  && forwardmove != -fThreeQuarters))
	{
		return false;
	}

	return true;
}

void InvalidMoveTrigger(int client, const char[] sDescription, int buttons, float forwardmove, float sidemove)
{
	char[] sLogMessage = new char[300];
	FormatEx(sLogMessage, 300, "%L - %s: %c%c%c%c; forward %.2f; side %.2f",
		client, sDescription,
		((buttons & IN_FORWARD) > 0)? 'W':'-',
		((buttons & IN_MOVELEFT) > 0)? 'A':'-',
		((buttons & IN_BACK) > 0)? 'S':'-',
		((buttons & IN_MOVERIGHT) > 0)? 'D':'-',
		forwardmove, sidemove);

	Oryx_LogMessage("%s", sLogMessage);
	Oryx_PrintToAdminsConsole("%s", sLogMessage);
	Oryx_Trigger(client, TRIGGER_DEFINITIVE, sDescription);
}
