/*
TODO:
-OnCheatsEnabled2 is called every Mapchange and checks all players, how to check if the map is fully started?
-Add an Cvar for the sv_cheats check
-Remove Breakpoints? (Since the Plugin is important to run)
-Remove sv_cheats check but fix all security Issues and exploitable Commands
*/

#pragma newdecls required

//#include <smlib/clients>
#undef REQUIRE_EXTENSIONS
#tryinclude <smrcon>
#define REQUIRE_EXTENSIONS

#define PLUGIN_VERSION "1.0"

Handle hVersion = INVALID_HANDLE, hCvarRconPass = INVALID_HANDLE, hCvarCheats = INVALID_HANDLE;
char sRconRealPass[128];
bool bRconLocked = false, bSMRconLoaded = false;

public Plugin myinfo =
{
	name = "Cheat-Acid: Server Protect",
	author = "Playa",
	description = "Anti Cheat System. This Module protects the Server from Attacks, Data Leaks and Hijack Attempts",
	version = PLUGIN_VERSION,
	url = "FunForBattle"
}

public void OnPluginStart()
{
	hVersion = CreateConVar("ca_serverprotect_version", PLUGIN_VERSION, "Plugin Version", FCVAR_UNLOGGED|FCVAR_DONTRECORD);
	SetConVarString(hVersion, PLUGIN_VERSION);
	
	bSMRconLoaded = LibraryExists("smrcon");
	
	hCvarRconPass = FindConVar("rcon_password");
	if(!hCvarRconPass)
	{
		PrintToServer("[Error][Cheat-Acid: Server Protect] ConVar 'rcon_password' dosent exist!");
		LogError("[Error][Cheat-Acid: Server Protect] ConVar 'rcon_password' dosent exist!");
		SetFailState("ConVar 'rcon_password' dosent exist!");
	}
	
	hCvarCheats = FindConVar("sv_cheats");
	if(!hCvarCheats)
	{
		PrintToServer("[Error][Cheat-Acid: Server Protect] ConVar 'sv_cheats' dosent exist!");
		LogError("[Error][Cheat-Acid: Server Protect] ConVar 'sv_cheats' dosent exist!");
		SetFailState("ConVar 'sv_cheats' dosent exist!");
	}
	
	HookConVarChange(hCvarRconPass, OnRconPassChanged);
	HookConVarChange(hCvarCheats, OnCheatsEnabled);
}

public void OnConfigsExecuted()
{
	if(!bRconLocked)
	{
		GetConVarString(hCvarRconPass, sRconRealPass, sizeof(sRconRealPass));
		bRconLocked = true;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "smrcon"))
		bSMRconLoaded = true;
}

public void OnLibraryRemoved(const char[] name)
{
	if(StrEqual(name, "smrcon"))
		bSMRconLoaded = false;
}

public void OnRconPassChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(bRconLocked && !StrEqual(newValue, sRconRealPass))
	{
		LogMessage("[Warning][Cheat-Acid: Server Protect] Rcon Password changed to %s. Reverting back to Original");
		SetConVarString(hCvarRconPass, sRconRealPass);
	}
}

public void OnCheatsEnabled(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(GetConVarBool(hCvarCheats))
		RequestFrame(OnCheatsEnabled2); // Delay the Cheats disable, so the Server can set ConVars that require Cheats on Map start
}

public void OnCheatsEnabled2()
{
	LogMessage("[Warning][Cheat-Acid: Server Protect] sv_cheats got enabled. Disabling it to prevent Exploits...");
	for(int iClient = 1; iClient <= MaxClients; iClient++)
		if(Client_IsIngameAuthorized(iClient, true))
			if(GetUserAdmin(iClient) != INVALID_ADMIN_ID)
				PrintToChat(iClient, "[Warning][Cheat-Acid: Server Protect] sv_cheats got enabled. Disabling it to prevent Exploits...");
				
	SetConVarBool(hCvarCheats, false);
}

public Action SMRCon_OnAuth(rconId, const char[] address, const char[] password, &bool allow)
{
	allow = false; // Rework a checking Mechanism, SM Admins maybe
	return Plugin_Changed;
}

public Action SMRCon_OnCommand(rconId, const char[] address, const char[] command, &bool allow)
{
	allow = false; // Rework a checking Mechanism, SM Admins maybe
	return Plugin_Changed;
}