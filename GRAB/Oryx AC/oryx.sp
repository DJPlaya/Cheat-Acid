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

#undef REQUIRE_PLUGIN
#include <shavit>
#include <bTimes-tas>
#include <bTimes-timer_hack>

#pragma newdecls required
#pragma semicolon 1

enum
{
	Timer_None,
	Timer_Shavit,
	Timer_Blacky2,
	Timer_Blacky183
}

int gI_Timer = Timer_None;
char gS_SpecialString[128];

ConVar gCV_AllowBypass = null;

EngineVersion gEV_Type = Engine_Unknown;

Handle gH_Forwards_OnTrigger = null;

char gS_LogPath[PLATFORM_MAX_PATH];
char gS_BeepSound[PLATFORM_MAX_PATH];
bool gB_NoSound = false;

bool gB_Testing[MAXPLAYERS+1];
bool gB_Locked[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = "ORYX bunnyhop anti-cheat",
	author = "Rusty, shavit",
	description = "Cheat detection interface.",
	version = ORYX_VERSION,
	url = "https://github.com/shavitush/Oryx-AC"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("Oryx_CanBypass", Native_CanBypass);
	CreateNative("Oryx_Trigger", Native_OryxTrigger);
	CreateNative("Oryx_WithinThreshold", Native_WithinThreshold);
	CreateNative("Oryx_PrintToAdmins", Native_PrintToAdmins);
	CreateNative("Oryx_PrintToAdminsConsole", Native_PrintToAdminsConsole);
	CreateNative("Oryx_LogMessage", Native_LogMessage);

	// registers library, check "bool LibraryExists(const char[] name)" in order to use with other plugins
	RegPluginLibrary("oryx");

	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	// workaround
	if(gI_Timer == Timer_None &&
		GetFeatureStatus(FeatureType_Native, "GetClientStyle") == FeatureStatus_Available &&
		GetFeatureStatus(FeatureType_Native, "Style_GetConfig") == FeatureStatus_Available)
	{
		gI_Timer = Timer_Blacky183;
	}
}

public void OnPluginStart()
{
	gH_Forwards_OnTrigger = CreateGlobalForward("Oryx_OnTrigger", ET_Event, Param_Cell, Param_CellByRef, Param_String);

	gEV_Type = GetEngineVersion();

	gCV_AllowBypass = CreateConVar("oryx_allow_bypass", "1", "Allow specific styles to bypass Oryx? Refer to README.md for information.", 0, true, 0.0, true, 1.0);

	CreateConVar("oryx_version", ORYX_VERSION, "Plugin version.", (FCVAR_NOTIFY | FCVAR_DONTRECORD));
	
	RegAdminCmd("sm_otest", Command_OryxTest, ADMFLAG_BAN, "Enables the TRIGGER_TEST detection level.");
	RegAdminCmd("sm_lock", Command_LockPlayer, ADMFLAG_BAN, "Disables movement for a player.");

	LoadTranslations("common.phrases");
	
	BuildPath(Path_SM, gS_LogPath, PLATFORM_MAX_PATH, "logs/oryx-ac.log");

	if(LibraryExists("shavit"))
	{
		gI_Timer = Timer_Shavit;
	}

	else if(LibraryExists("tas"))
	{
		gI_Timer = Timer_Blacky2;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "shavit"))
	{
		gI_Timer = Timer_Shavit;
	}

	else if(StrEqual(name, "tas"))
	{
		gI_Timer = Timer_Blacky2;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if((StrEqual(name, "shavit") && gI_Timer == Timer_Shavit) ||
		(StrEqual(name, "tas") && gI_Timer == Timer_Blacky2))
	{
		gI_Timer = Timer_None;
	}
}

public void OnMapStart()
{
	// Beep sounds.
	Handle hConfig = LoadGameConfigFile("funcommands.games");

	if(hConfig == null)
	{
		SetFailState("Unable to load game config funcommands.games");

		return;
	}
	
	if(GameConfGetKeyValue(hConfig, "SoundBeep", gS_BeepSound, PLATFORM_MAX_PATH))
	{
		PrecacheSound(gS_BeepSound, true);
	}

	delete hConfig;
}

public void OnClientPutInServer(int client)
{
	gB_Locked[client] = false;
	gB_Testing[client] = false;
}

public Action Command_OryxTest(int client, int args)
{
	gB_Testing[client] = !gB_Testing[client];
	ReplyToCommand(client, "Testing is %s.", (gB_Testing[client])? "on":"off");

	return Plugin_Handled;
}

public Action Command_LockPlayer(int client, int args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "Usage: sm_lock <target>");

		return Plugin_Handled;
	}
	
	char[] sArgs = new char[MAX_TARGET_LENGTH];
	GetCmdArgString(sArgs, MAX_TARGET_LENGTH);

	int target = FindTarget(client, sArgs);

	if(target == -1)
	{
		return Plugin_Handled;
	}
	
	gB_Locked[target] = !gB_Locked[target];
	ReplyToCommand(client, "Player has been %s.", (gB_Locked[target])? "locked":"unlocked");
	PrintToChat(target, "An admin has %s your ability to move!", (gB_Locked[target])? "locked":"unlocked");

	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3])
{
	// Movement is locked, don't allow anything.
	if(gB_Locked[client])
	{
		buttons = 0;
		vel[0] = 0.0;
		vel[1] = 0.0;
		impulse = 0;

		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public int Native_CanBypass(Handle plugin, int numParams)
{
	if(!gCV_AllowBypass.BoolValue)
	{
		return false;
	}

	int client = GetNativeCell(1);

	switch(gI_Timer)
	{
		case Timer_Shavit:
		{
			Shavit_GetStyleStrings(Shavit_GetBhopStyle(client), sSpecialString, gS_SpecialString, 128);

			if(StrContains(gS_SpecialString, "oryx_bypass", false) != -1)
			{
				return true;
			}
		}

		case Timer_Blacky2:
		{
			return TAS_InEditMode(client);
		}

		case Timer_Blacky183:
		{
			any styleconfig[StyleConfig];
			Style_GetConfig(GetClientStyle(client), styleconfig);

			if(StrContains(styleconfig[Special_Key], "oryx_bypass", false) != -1)
			{
				return true;
			}
		}
	}

	return false;
}

public int Native_OryxTrigger(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int level = GetNativeCell(2);
	
	char[] sLevel = new char[16];
	char[] sCheatDescription = new char[32];

	GetNativeString(3, sCheatDescription, 32);

	Action result = Plugin_Continue;
	Call_StartForward(gH_Forwards_OnTrigger);
	Call_PushCell(client);
	Call_PushCellRef(level);
	Call_PushStringEx(sCheatDescription, 32, SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_Finish(result);

	if(result == Plugin_Stop)
	{
		return view_as<int>(Plugin_Stop);
	}

	if(level == TRIGGER_LOW)
	{
		strcopy(sLevel, 16, "LOW");
		gB_NoSound = true; // Don't play the annoying beep sound for LOW detections.
	}

	else if(level == TRIGGER_MEDIUM)
	{
		strcopy(sLevel, 16, "MEDIUM");
	}

	else if(level == TRIGGER_HIGH)
	{
		strcopy(sLevel, 16, "HIGH");

		if(result != Plugin_Handled)
		{
			KickClient(client, "[ORYX] %s", sCheatDescription);
		}
	}

	else if(level == TRIGGER_HIGH_NOKICK)
	{
		strcopy(sLevel, 16, "HIGH-NOKICK");
	}

	else if(level == TRIGGER_DEFINITIVE)
	{
		strcopy(sLevel, 16, "DEFINITIVE");

		if(result != Plugin_Handled)
		{
			KickClient(client, "[ORYX] %s", sCheatDescription);
		}
	}

	else if(level == TRIGGER_TEST)
	{
		char[] sBuffer = new char[128];
		Format(sBuffer, 128, "(\x03%N\x01) - %s | Level: \x04TESTING", client, sCheatDescription);

		for(int i = 1; i <= MaxClients; i++)
		{
			if(gB_Testing[i] && IsClientInGame(i))
			{
				PrintToChat(i, "%s", sBuffer);
			}
		}

		return view_as<int>(result);
	}

	char[] sAuth = new char[32];
	GetClientAuthId(client, AuthId_Steam3, sAuth, 32);

	char[] sBuffer = new char[128];
	Format(sBuffer, 128, "\x03%N\x01 - \x05%s\x01 Cheat: %s | Level: %s", client, sAuth, sCheatDescription, sLevel);
	Oryx_PrintToAdmins("%s", sBuffer);
	
	LogToFileEx(gS_LogPath, "%L - Cheat: %s | Level: %s", client, sCheatDescription, sLevel);

	return view_as<int>(result);
}

public int Native_WithinThreshold(Handle plugin, int numParams)
{
	float f1 = GetNativeCell(1);
	float f2 = GetNativeCell(2);
	float threshold = GetNativeCell(3);

	return view_as<int>(FloatAbs(f1 - f2) <= threshold);
}

public int Native_PrintToAdmins(Handle plugin, int numParams)
{
	static int iWritten = 0; // Useless?

	char[] sBuffer = new char[300];
	FormatNativeString(0, 1, 2, 300, iWritten, sBuffer);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(CheckCommandAccess(i, "oryx_admin", ADMFLAG_GENERIC))
		{
			PrintToChat(i, "%s\x04[ORYX]\x01 %s", (gEV_Type == Engine_CSGO)? " ":"", sBuffer);

			if(!gB_NoSound)
			{
				if(gEV_Type == Engine_CSS || gEV_Type == Engine_TF2)
				{
					EmitSoundToClient(i, gS_BeepSound);
				}

				else
				{
					ClientCommand(i, "play */%s", gS_BeepSound);
				}
			}
		}
	}

	gB_NoSound = false;
}

public int Native_PrintToAdminsConsole(Handle plugin, int numParams)
{
	static int iWritten = 0; // Useless?

	char[] sBuffer = new char[300];
	FormatNativeString(0, 1, 2, 300, iWritten, sBuffer);

	for(int i = 1; i <= MaxClients; i++)
	{
		if(CheckCommandAccess(i, "oryx_admin", ADMFLAG_GENERIC))
		{
			PrintToConsole(i, "[ORYX] %s", sBuffer);
		}
	}
}

public int Native_LogMessage(Handle plugin, int numParams)
{
	char[] sPlugin = new char[32];

	if(!GetPluginInfo(plugin, PlInfo_Name, sPlugin, 32))
	{
		GetPluginFilename(plugin, sPlugin, 32);
	}

	static int iWritten = 0; // Useless?

	char[] sBuffer = new char[300];
	FormatNativeString(0, 1, 2, 300, iWritten, sBuffer);
	
	LogToFileEx(gS_LogPath, "[%s] %s", sPlugin, sBuffer);
}
