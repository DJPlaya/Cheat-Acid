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

#undef REQUIRE_PLUGIN
#include <shavit>

#pragma newdecls required
#pragma semicolon 1

#define DESC1 "Movement config"
#define DESC2 "+klook usage"

// Minimum delay in ticks from last detection until a new one triggers.
#define KLOOK_DELAY 1000

ConVar gCV_KLookDetection = null;
bool gB_KLookUsed[MAXPLAYERS+1];
int gI_LastDetection[MAXPLAYERS+1];

int gI_PerfectConfigStreak[MAXPLAYERS+1];
int gI_PreviousButtons[MAXPLAYERS+1];
int gI_JumpsFromZone[MAXPLAYERS+1];

bool gB_Shavit = false;

public Plugin myinfo = 
{
	name = "ORYX movement config module",
	author = "Rusty, shavit",
	description = "Detects movement configs (null binds, \"k120 syndrome\", +klook LJ binds).",
	version = ORYX_VERSION,
	url = "https://github.com/shavitush/Oryx-AC"
}

public void OnPluginStart()
{
	RegAdminCmd("config_streak", Command_ConfigStreak, ADMFLAG_BAN, "Print the config stat buffer for a given player.");

	gCV_KLookDetection = CreateConVar("oryx-configcheck_klook", "0", "How to treat +klook usage?\n-1 - do not.\n0 - disable +klook.\n1 - disable + alert admins and log.\n2 - kick player.", 0, true, -1.0, true, 2.0);
	AutoExecConfig();

	LoadTranslations("common.phrases");

	gB_Shavit = LibraryExists("shavit");
}

public void OnClientPutInServer(int client)
{
	gB_KLookUsed[client] = false;
	gI_LastDetection[client] = 0;

	gI_PerfectConfigStreak[client] = 0;
	gI_JumpsFromZone[client] = 0;
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "shavit"))
	{
		gB_Shavit = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if(StrEqual(name, "shavit"))
	{
		gB_Shavit = false;
	}
}

public Action Command_ConfigStreak(int client, int args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "Usage: config_streak <target>");

		return Plugin_Handled;
	}
	
	char[] sArgs = new char[MAX_TARGET_LENGTH];
	GetCmdArgString(sArgs, MAX_TARGET_LENGTH);

	int target = FindTarget(client, sArgs);

	if(target == -1)
	{
		return Plugin_Handled;
	}

	char[] sAuth = new char[32];
	
	if(!GetClientAuthId(target, AuthId_Steam3, sAuth, 32))
	{
		strcopy(sAuth, 32, "ERR_GETTING_ID");
	}
		
	ReplyToCommand(client, "User \x03%N\x01 (\x05%s\x01) is on a config streak of \x04%d\x01.", target, sAuth, gI_PerfectConfigStreak[target]);
	
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3])
{
	if(gB_Shavit || !IsPlayerAlive(client) || IsFakeClient(client))
	{
		return Plugin_Continue;
	}

	return SetupMove(client, buttons, vel);
}

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style)
{
	return SetupMove(client, buttons, vel);
}

Action SetupMove(int client, int &buttons, float vel[3])
{
	if(Oryx_CanBypass(client))
	{
		return Plugin_Continue;
	}

	int iFlags = GetEntityFlags(client);
	int iDetect = gCV_KLookDetection.IntValue;

	if(iDetect > -1)
	{
		if((iFlags & FL_ONGROUND) == 0)
		{
			int iLR = (buttons & (IN_MOVELEFT | IN_MOVERIGHT));
			int iFB = (buttons & (IN_FORWARD | IN_BACK));

			if((vel[0] == 0.0 && iFB != 0 && iFB != (IN_FORWARD | IN_BACK)) ||
				(vel[1] == 0.0 && iLR != 0 && iLR != (IN_MOVELEFT | IN_MOVERIGHT)))
			{
				// Disable movement for the whole jump
				gB_KLookUsed[client] = true;
			}
		}

		else
		{
			gB_KLookUsed[client] = false;
		}

		if(gB_KLookUsed[client])
		{
			vel[0] = 0.0;
			vel[1] = 0.0;

			if(iDetect > 0)
			{
				int iTicks = GetGameTickCount();

				if(iTicks - gI_LastDetection[client] >= KLOOK_DELAY)
				{
					Oryx_Trigger(client, (iDetect == 1)? TRIGGER_HIGH_NOKICK:TRIGGER_DEFINITIVE, DESC2);
					gI_LastDetection[client] = iTicks;
				}
			}

			return Plugin_Changed;
		}
	}
	
	if(gB_Shavit)
	{
		if(Shavit_InsideZone(client, Zone_Start, -1))
		{
			gI_JumpsFromZone[client] = 0;

			return Plugin_Continue;
		}
		
		if((iFlags & FL_ONGROUND) > 0 && (buttons & IN_JUMP) > 0)
		{
			gI_JumpsFromZone[client]++;
		}
			
		if(gI_JumpsFromZone[client] < 2)
		{
			return Plugin_Continue;
		}
	}
	
	if((iFlags & FL_ONGROUND) == 0)
	{
		// Check for perfect transitions in W/A/S/D.
		if(((buttons & IN_MOVELEFT) == 0 && (buttons & IN_MOVERIGHT) > 0 && (gI_PreviousButtons[client] & IN_MOVERIGHT) == 0 && (gI_PreviousButtons[client] & IN_MOVELEFT) > 0) || 
			((buttons & IN_MOVERIGHT) == 0 && (buttons & IN_MOVELEFT) > 0 && (gI_PreviousButtons[client] & IN_MOVELEFT) == 0 && (gI_PreviousButtons[client] & IN_MOVERIGHT) > 0) ||
			((buttons & IN_FORWARD) == 0 && (buttons & IN_BACK) > 0 && (gI_PreviousButtons[client] & IN_BACK) == 0 && (gI_PreviousButtons[client] & IN_FORWARD) > 0) ||
			((buttons & IN_BACK) == 0 && (buttons & IN_FORWARD) > 0 && (gI_PreviousButtons[client] & IN_FORWARD) == 0 && (gI_PreviousButtons[client] & IN_BACK) > 0))
		{
			PerfectTransition(client);
		}

		// Are both moveleft/moveright pressed?
		else if(buttons & (IN_MOVELEFT | IN_MOVERIGHT) == (IN_MOVELEFT | IN_MOVERIGHT))
		{
			gI_PerfectConfigStreak[client] = 0;
		}
	}

	gI_PreviousButtons[client] = buttons;

	return Plugin_Continue;
}

void PerfectTransition(int client)
{
	if(++gI_PerfectConfigStreak[client] < 150)
	{
		return;
	}

	if(gI_PerfectConfigStreak[client] == 250)
	{
		Oryx_Trigger(client, TRIGGER_LOW, DESC1);
	}

	else if(gI_PerfectConfigStreak[client] == 330)
	{
		Oryx_Trigger(client, TRIGGER_MEDIUM, DESC1);
	}

	else if(gI_PerfectConfigStreak[client] % 510 == 0) // 510 or above (1020, 1530 etc)
	{
		Oryx_Trigger(client, TRIGGER_HIGH_NOKICK, DESC1);
	}
}
