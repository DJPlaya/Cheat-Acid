#pragma newdecls required

#define PLUGIN_VERSION "1.0"

Handle hVersion = INVALID_HANDLE;

public Plugin myinfo =
{
	name = "Cheat-Acid: PART PLUGIN",
	author = "Playa",
	description = "DESCRYPTION",
	version = PLUGIN_VERSION,
	url = "FunForBattle"
}

public void OnPluginStart()
{
	hVersion = CreateConVar("ca_PARTPLUGIN_version", PLUGIN_VERSION, "Plugin Version", FCVAR_UNLOGGED|FCVAR_DONTRECORD);
	SetConVarString(hVersion, PLUGIN_VERSION);
}