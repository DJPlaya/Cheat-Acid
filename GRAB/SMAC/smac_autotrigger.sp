/*
    SourceMod Anti-Cheat
    Copyright (C) 2011-2016 SMAC Development Team
    Copyright (C) 2007-2011 CodingDirect LLC
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#pragma semicolon 1

/* SM Includes */
#include <sourcemod>
#include <sdktools>
#include <smac>
#undef REQUIRE_PLUGIN
#tryinclude <updater>

/* Plugin Info */
public Plugin:myinfo =
{
	name = "SMAC AutoTrigger Detector",
	author = SMAC_AUTHOR,
	description = "Detects cheats that automatically press buttons for players",
	version = SMAC_VERSION,
	url = SMAC_URL
};

/* Globals */
#define UPDATE_URL	"http://smac.sx/updater/smac_autotrigger.txt"

#define TRIGGER_DETECTIONS	20		// Amount of detections needed to perform action.
#define MIN_JUMP_TIME		0.500	// Minimum amount of air-time for a jump to count.

// Detection methods.
#define METHOD_BUNNYHOP		0
#define METHOD_AUTOFIRE		1
#define METHOD_MAX			2

new Handle:g_hCvarBan = INVALID_HANDLE;
new g_iDetections[METHOD_MAX][MAXPLAYERS+1];
new g_iAttackMax = 66;

/* Plugin Functions */
public OnPluginStart()
{
	LoadTranslations("smac.phrases");
	
	// Convars.
	g_hCvarBan = SMAC_CreateConVar("smac_autotrigger_ban", "0", "Automatically ban players on auto-trigger detections.", 0, true, 0.0, true, 1.0);
	
	// Initialize.
	g_iAttackMax = RoundToNearest(1.0 / GetTickInterval() / 3.0);
	CreateTimer(4.0, Timer_DecreaseCount, _, TIMER_REPEAT);
	
#if defined _updater_included
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
#endif
}

public OnLibraryAdded(const String:name[])
{
#if defined _updater_included
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
#endif
}

public OnClientDisconnect_Post(client)
{
	for (new i = 0; i < METHOD_MAX; i++)
	{
		g_iDetections[i][client] = 0;
	}
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
	
	/* BunnyHop */
	static Float:fCheckTime[MAXPLAYERS+1];

	// Player didn't jump immediately after the last jump.
	if (!(buttons & IN_JUMP) && (GetEntityFlags(client) & FL_ONGROUND) && fCheckTime[client] > 0.0)
	{
		fCheckTime[client] = 0.0;
	}
	
	// Ignore this jump if the player is in a tight space or stuck in the ground.
	if ((buttons & IN_JUMP) && !(iPrevButtons[client] & IN_JUMP))
	{
		// Player is on the ground and about to trigger a jump.
		if (GetEntityFlags(client) & FL_ONGROUND)
		{
			new Float:fGameTime = GetGameTime();
			
			// Player jumped on the exact frame that allowed it.
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
	
	/* Auto-Fire */
	static iAttackAmt[MAXPLAYERS+1];
	static bool:bResetNext[MAXPLAYERS+1];
	
	if (((buttons & IN_ATTACK) && !(iPrevButtons[client] & IN_ATTACK)) || 
		(!(buttons & IN_ATTACK) && (iPrevButtons[client] & IN_ATTACK)))
	{
		if (++iAttackAmt[client] >= g_iAttackMax)
		{
			AutoTrigger_Detected(client, METHOD_AUTOFIRE);
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
	if (!IsFakeClient(client) && IsPlayerAlive(client) && ++g_iDetections[method][client] >= TRIGGER_DETECTIONS)
	{
		decl String:sMethod[32];

		switch (method)
		{
			case METHOD_BUNNYHOP:
			{
				strcopy(sMethod, sizeof(sMethod), "BunnyHop");
			}
			case METHOD_AUTOFIRE:
			{
				strcopy(sMethod, sizeof(sMethod), "Auto-Fire");
			}
		}
		
		new Handle:info = CreateKeyValues("");
		KvSetString(info, "method", sMethod);
		
		if (SMAC_CheatDetected(client, Detection_AutoTrigger, info) == Plugin_Continue)
		{
			SMAC_PrintAdminNotice("%t", "SMAC_AutoTriggerDetected", client, sMethod);
			
			if (GetConVarBool(g_hCvarBan))
			{
				SMAC_LogAction(client, "was banned for using auto-trigger cheat: %s", sMethod);
				SMAC_Ban(client, "AutoTrigger Detection: %s", sMethod);
			}
			else
			{
				SMAC_LogAction(client, "is suspected of using auto-trigger cheat: %s", sMethod);
			}
		}
		
		CloseHandle(info);
		
		g_iDetections[method][client] = 0;
	}
}
