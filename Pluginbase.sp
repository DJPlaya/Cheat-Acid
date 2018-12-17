#pragma newdecls required

#define PLUGIN_VERSION "1.0"

ConVar hVersion;

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
	hVersion = CreateConVar("ca_PARTPLUGIN_version", PLUGIN_VERSION, "Plugin Version", FCVAR_NOTIFY|FCVAR_UNLOGGED|FCVAR_DONTRECORD);
}