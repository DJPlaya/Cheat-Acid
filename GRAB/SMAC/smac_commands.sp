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
#include <smac>
#undef REQUIRE_PLUGIN
#tryinclude <updater>

/* Plugin Info */
public Plugin:myinfo =
{
	name = "SMAC Command Monitor",
	author = SMAC_AUTHOR,
	description = "Blocks general command exploits",
	version = SMAC_VERSION,
	url = SMAC_URL
};

/* Globals */
#define UPDATE_URL	"http://smac.sx/updater/smac_commands.txt"

#define MAX_CMD_NAME_LEN PLATFORM_MAX_PATH

enum ActionType {
	Action_Block = 0,
	Action_Ban,
	Action_Kick
};

new Handle:g_hBlockedCmds = INVALID_HANDLE;
new Handle:g_hIgnoredCmds = INVALID_HANDLE;
new g_iCmdSpamLimit = 30;
new g_iCmdCount[MAXPLAYERS+1] = {0, ...};
new Handle:g_hCvarCmdSpam = INVALID_HANDLE;

/* Plugin Functions */
public OnPluginStart()
{
	LoadTranslations("smac.phrases");
	
	// Convars.
	g_hCvarCmdSpam = SMAC_CreateConVar("smac_antispam_cmds", "30", "Amount of commands allowed per second. (0 = Disabled)", 0, true, 0.0);
	OnSettingsChanged(g_hCvarCmdSpam, "", "");
	HookConVarChange(g_hCvarCmdSpam, OnSettingsChanged);

	// Hooks.
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
	
	switch (SMAC_GetGameType())
	{
		case Game_INSMOD:
		{
			AddCommandListener(Command_Say, "say2");
		}
		case Game_ND:
		{
			AddCommandListener(Command_Say, "say_squad");
		}
	}
	
	// Exploitable needed commands.  Sigh....
	AddCommandListener(Command_BlockEntExploit, "ent_create");
	AddCommandListener(Command_BlockEntExploit, "ent_fire");
	
	// L4D2 uses this for confogl.
	if (SMAC_GetGameType() != Game_L4D2)
	{
		AddCommandListener(Command_BlockEntExploit, "give");
	}
	
	// Init...
	g_hBlockedCmds = CreateTrie();
	g_hIgnoredCmds = CreateTrie();
	
	// Add commands to block list.
	SetTrieValue(g_hBlockedCmds, "ai_test_los", Action_Block);
	SetTrieValue(g_hBlockedCmds, "cl_fullupdate", Action_Block);
	SetTrieValue(g_hBlockedCmds, "dbghist_addline", Action_Block);
	SetTrieValue(g_hBlockedCmds, "dbghist_dump", Action_Block);
	SetTrieValue(g_hBlockedCmds, "drawcross", Action_Block);
	SetTrieValue(g_hBlockedCmds, "drawline", Action_Block);
	SetTrieValue(g_hBlockedCmds, "dump_entity_sizes", Action_Block);
	SetTrieValue(g_hBlockedCmds, "dump_globals", Action_Block);
	SetTrieValue(g_hBlockedCmds, "dump_panels", Action_Block);
	SetTrieValue(g_hBlockedCmds, "dump_terrain", Action_Block);
	SetTrieValue(g_hBlockedCmds, "dumpcountedstrings", Action_Block);
	SetTrieValue(g_hBlockedCmds, "dumpentityfactories", Action_Block);
	SetTrieValue(g_hBlockedCmds, "dumpeventqueue", Action_Block);
	SetTrieValue(g_hBlockedCmds, "dumpgamestringtable", Action_Block);
	SetTrieValue(g_hBlockedCmds, "editdemo", Action_Block);
	SetTrieValue(g_hBlockedCmds, "endround", Action_Block);
	SetTrieValue(g_hBlockedCmds, "groundlist", Action_Block);
	SetTrieValue(g_hBlockedCmds, "listdeaths", Action_Block);
	SetTrieValue(g_hBlockedCmds, "listmodels", Action_Block);
	SetTrieValue(g_hBlockedCmds, "map_showspawnpoints", Action_Block);
	SetTrieValue(g_hBlockedCmds, "mem_dump", Action_Block);
	SetTrieValue(g_hBlockedCmds, "mp_dump_timers", Action_Block);
	SetTrieValue(g_hBlockedCmds, "npc_ammo_deplete", Action_Block);
	SetTrieValue(g_hBlockedCmds, "npc_heal", Action_Block);
	SetTrieValue(g_hBlockedCmds, "npc_speakall", Action_Block);
	SetTrieValue(g_hBlockedCmds, "npc_thinknow", Action_Block);
	SetTrieValue(g_hBlockedCmds, "physics_budget", Action_Block);
	SetTrieValue(g_hBlockedCmds, "physics_debug_entity", Action_Block);
	SetTrieValue(g_hBlockedCmds, "physics_highlight_active", Action_Block);
	SetTrieValue(g_hBlockedCmds, "physics_report_active", Action_Block);
	SetTrieValue(g_hBlockedCmds, "physics_select", Action_Block);
	SetTrieValue(g_hBlockedCmds, "report_entities", Action_Block);
	SetTrieValue(g_hBlockedCmds, "report_simthinklist", Action_Block);
	SetTrieValue(g_hBlockedCmds, "report_touchlinks", Action_Block);
	SetTrieValue(g_hBlockedCmds, "respawn_entities", Action_Block);
	SetTrieValue(g_hBlockedCmds, "rr_reloadresponsesystems", Action_Block);
	SetTrieValue(g_hBlockedCmds, "scene_flush", Action_Block);
	SetTrieValue(g_hBlockedCmds, "snd_digital_surround", Action_Block);
	SetTrieValue(g_hBlockedCmds, "snd_restart", Action_Block);
	SetTrieValue(g_hBlockedCmds, "soundlist", Action_Block);
	SetTrieValue(g_hBlockedCmds, "soundscape_flush", Action_Block);
	SetTrieValue(g_hBlockedCmds, "sv_benchmark_force_start", Action_Block);
	SetTrieValue(g_hBlockedCmds, "sv_findsoundname", Action_Block);
	SetTrieValue(g_hBlockedCmds, "sv_soundemitter_filecheck", Action_Block);
	SetTrieValue(g_hBlockedCmds, "sv_soundemitter_flush", Action_Block);
	SetTrieValue(g_hBlockedCmds, "sv_soundscape_printdebuginfo", Action_Block);
	SetTrieValue(g_hBlockedCmds, "wc_update_entity", Action_Block);
	
	SetTrieValue(g_hBlockedCmds, "changelevel", Action_Ban);
	
	SetTrieValue(g_hBlockedCmds, "speed.toggle", Action_Kick);
	
	// Add game specific commands to block list.
	switch (SMAC_GetGameType())
	{
		case Game_L4D:
		{
			SetTrieValue(g_hBlockedCmds, "demo_returntolobby", Action_Block);
			
			SetTrieValue(g_hIgnoredCmds, "choose_closedoor", true);
			SetTrieValue(g_hIgnoredCmds, "choose_opendoor", true);
		}
		case Game_L4D2:
		{
			SetTrieValue(g_hIgnoredCmds, "choose_closedoor", true);
			SetTrieValue(g_hIgnoredCmds, "choose_opendoor", true);
		}
		case Game_ND:
		{
			SetTrieValue(g_hIgnoredCmds, "bitcmd", true);
			SetTrieValue(g_hIgnoredCmds, "sg", true);
		}
	}

	// Add commands to ignore list.
	SetTrieValue(g_hIgnoredCmds, "buy", true);
	SetTrieValue(g_hIgnoredCmds, "buyammo1", true);
	SetTrieValue(g_hIgnoredCmds, "buyammo2", true);
	SetTrieValue(g_hIgnoredCmds, "setpause", true);
	SetTrieValue(g_hIgnoredCmds, "spec_mode", true);
	SetTrieValue(g_hIgnoredCmds, "spec_next", true);
	SetTrieValue(g_hIgnoredCmds, "spec_prev", true);
	SetTrieValue(g_hIgnoredCmds, "unpause", true);
	SetTrieValue(g_hIgnoredCmds, "use", true);
	SetTrieValue(g_hIgnoredCmds, "vban", true);
	SetTrieValue(g_hIgnoredCmds, "vmodenable", true);
	
	CreateTimer(1.0, Timer_ResetCmdCount, _, TIMER_REPEAT);
	
	AddCommandListener(Command_CommandListener);

	RegAdminCmd("smac_addcmd", Command_AddCmd, ADMFLAG_ROOT, "Block a command.");
	RegAdminCmd("smac_addignorecmd", Command_AddIgnoreCmd, ADMFLAG_ROOT, "Ignore a command.");
	RegAdminCmd("smac_removecmd", Command_RemoveCmd, ADMFLAG_ROOT, "Unblock a command.");
	RegAdminCmd("smac_removeignorecmd", Command_RemoveIgnoreCmd, ADMFLAG_ROOT, "Unignore a command.");
	
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

public Action:Command_AddCmd(client, args)
{
	if (args == 2)
	{
		decl String:sCommand[MAX_CMD_NAME_LEN], String:sAction[8];
		
		GetCmdArg(1, sCommand, sizeof(sCommand));
		StringToLower(sCommand);
		
		GetCmdArg(2, sAction, sizeof(sAction));
		
		new ActionType:cAction = Action_Block;
		
		switch (StringToInt(sAction))
		{
			case 1:
			{
				cAction = Action_Ban;
			}
			case 2:
			{
				cAction = Action_Kick;
			}
		}
		
		SetTrieValue(g_hBlockedCmds, sCommand, cAction);
		ReplyToCommand(client, "%s has been added.", sCommand);
		
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "Usage: smac_addcmd <cmd> <action>");
	return Plugin_Handled;
}

public Action:Command_AddIgnoreCmd(client, args)
{
	if (args == 1)
	{
		decl String:sCommand[MAX_CMD_NAME_LEN];
		
		GetCmdArg(1, sCommand, sizeof(sCommand));
		StringToLower(sCommand);
		
		SetTrieValue(g_hIgnoredCmds, sCommand, true);
		ReplyToCommand(client, "%s has been added.", sCommand);
		
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "Usage: smac_addignorecmd <cmd>");
	return Plugin_Handled;
}

public Action:Command_RemoveCmd(client, args)
{
	if (args == 1)
	{
		decl String:sCommand[MAX_CMD_NAME_LEN];
		
		GetCmdArg(1, sCommand, sizeof(sCommand));
		StringToLower(sCommand);

		if (RemoveFromTrie(g_hBlockedCmds, sCommand))
		{
			ReplyToCommand(client, "%s has been removed.", sCommand);
		}
		else
		{
			ReplyToCommand(client, "%s was not found.", sCommand);
		}
		
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "Usage: smac_removecmd <cmd>");
	return Plugin_Handled;
}

public Action:Command_RemoveIgnoreCmd(client, args)
{
	if (args == 1)
	{
		decl String:sCommand[MAX_CMD_NAME_LEN];
		
		GetCmdArg(1, sCommand, sizeof(sCommand));
		StringToLower(sCommand);
		
		if (RemoveFromTrie(g_hIgnoredCmds, sCommand))
		{
			ReplyToCommand(client, "%s has been removed.", sCommand);
		}
		else
		{
			ReplyToCommand(client, "%s was not found.", sCommand);
		}
		
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "Usage: smac_removeignorecmd <cmd>");
	return Plugin_Handled;
}

public Action:Command_Say(client, const String:command[], args)
{
	if (!IS_CLIENT(client))
		return Plugin_Continue;

	new iSpaceNum;
	decl String:sMsg[256], String:sChar;
	new iLen = GetCmdArgString(sMsg, sizeof(sMsg));
	
	for (new i = 0; i < iLen; i++)
	{
		sChar = sMsg[i];
		
		if (sChar == ' ')
		{
			if (iSpaceNum++ >= 64)
			{
				PrintToChat(client, "%t", "SMAC_SayBlock");
				return Plugin_Stop;
			}
		}
			
		if (sChar < 32 && !IsCharMB(sChar))
		{
			PrintToChat(client, "%t", "SMAC_SayBlock");
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}

public Action:Command_BlockEntExploit(client, const String:command[], args)
{
	if (!IS_CLIENT(client))
		return Plugin_Continue;
	
	if (!IsClientInGame(client))
		return Plugin_Stop;
	
	decl String:sArgString[512];
	
	if (GetCmdArgString(sArgString, sizeof(sArgString)) > 500)
		return Plugin_Stop;
	
	if (StrContains(sArgString, "admin") != -1 || 
	    StrContains(sArgString, "alias", false) != -1 || 
	    StrContains(sArgString, "logic_auto") != -1 || 
	    StrContains(sArgString, "logic_autosave") != -1 || 
	    StrContains(sArgString, "logic_branch") != -1 || 
	    StrContains(sArgString, "logic_case") != -1 || 
	    StrContains(sArgString, "logic_collision_pair") != -1 || 
	    StrContains(sArgString, "logic_compareto") != -1 || 
	    StrContains(sArgString, "logic_lineto") != -1 || 
	    StrContains(sArgString, "logic_measure_movement") != -1 || 
	    StrContains(sArgString, "logic_multicompare") != -1 || 
	    StrContains(sArgString, "logic_navigation") != -1 || 
	    StrContains(sArgString, "logic_relay") != -1 || 
	    StrContains(sArgString, "logic_timer") != -1 || 
	    StrContains(sArgString, "ma_") != -1 || 
	    StrContains(sArgString, "meta") != -1 || 
	    StrContains(sArgString, "mp_", false) != -1 || 
	    StrContains(sArgString, "point_clientcommand") != -1 || 
	    StrContains(sArgString, "point_servercommand") != -1 || 
	    StrContains(sArgString, "quit", false) != -1 || 
	    StrContains(sArgString, "quti") != -1 || 
	    StrContains(sArgString, "rcon", false) != -1 || 
	    StrContains(sArgString, "restart", false) != -1 || 
	    StrContains(sArgString, "sm") != -1 || 
	    StrContains(sArgString, "sv_", false) != -1 || 
	    StrContains(sArgString, "taketimer") != -1)
	{
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Command_CommandListener(client, const String:command[], argc)
{
	if (!IS_CLIENT(client) || (IsClientConnected(client) && IsFakeClient(client)))
		return Plugin_Continue;
		
	if (!IsClientInGame(client))
		return Plugin_Stop;

	// NOTE: InternalDispatch automatically lower cases "command".
	new ActionType:cAction = Action_Block;
	
	if (GetTrieValue(g_hBlockedCmds, command, cAction))
	{
		if (cAction != Action_Block)
		{
			decl String:sArgString[192];
			GetCmdArgString(sArgString, sizeof(sArgString));
			
			new Handle:info = CreateKeyValues("");
			KvSetString(info, "command", command);
			KvSetString(info, "argstring", sArgString);
			KvSetNum(info, "action", _:cAction);
			
			if (SMAC_CheatDetected(client, Detection_BannedCommand, info) == Plugin_Continue)
			{
				if (cAction == Action_Ban)
				{
					SMAC_PrintAdminNotice("%N was banned for command: %s %s", client, command, sArgString);
					SMAC_LogAction(client, "was banned for command: %s %s", command, sArgString);
					SMAC_Ban(client, "Command %s violation", command);
				}
				else if (cAction == Action_Kick)
				{
					SMAC_PrintAdminNotice("%N was kicked for command: %s %s", client, command, sArgString);
					SMAC_LogAction(client, "was kicked for command: %s %s", command, sArgString);
					KickClient(client, "Command %s violation", command);
				}
			}
			
			CloseHandle(info);
		}
		
		return Plugin_Stop;
	}
	
	if (g_iCmdSpamLimit && !GetTrieValue(g_hIgnoredCmds, command, cAction) && ++g_iCmdCount[client] > g_iCmdSpamLimit)
	{
		decl String:sArgString[192];
		GetCmdArgString(sArgString, sizeof(sArgString));
		
		new Handle:info = CreateKeyValues("");
		KvSetString(info, "command", command);
		KvSetString(info, "argstring", sArgString);
		
		if (SMAC_CheatDetected(client, Detection_CommandSpamming, info) == Plugin_Continue)
		{
			SMAC_PrintAdminNotice("%N was kicked for spamming: %s %s", client, command, sArgString);
			SMAC_LogAction(client, "was kicked for spamming: %s %s", command, sArgString);
			KickClient(client, "%t", "SMAC_CommandSpamKick");
		}
		
		CloseHandle(info);
		
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action:Timer_ResetCmdCount(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		g_iCmdCount[i] = 0;
	}
	
	return Plugin_Continue;
}

public OnSettingsChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_iCmdSpamLimit = GetConVarInt(convar);
}
