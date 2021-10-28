#include <smac>
public Plugin:myinfo =
{
	name = "SMAC: Rcon Locker",
	author = "KorDen",
	description = "Protects against rcon crashes and exploits",
	version = SMAC_VERSION,
	url = SMAC_URL
};

new Handle:g_hCvarRconPass = INVALID_HANDLE,
	bool:g_bRconLocked = false,
	String:g_sRconRealPass[128];

public OnPluginStart()
{
	g_hCvarRconPass = FindConVar("rcon_password");
	HookConVarChange(g_hCvarRconPass, OnRconPassChanged);
}

public OnConfigsExecuted()
{
	if (!g_bRconLocked)
	{
		GetConVarString(g_hCvarRconPass, g_sRconRealPass, sizeof(g_sRconRealPass));
		g_bRconLocked = true;
	}
}

public OnRconPassChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (g_bRconLocked && !StrEqual(newValue, g_sRconRealPass))
	{
		SMAC_Log("Rcon password changed to \"%s\". Reverting back to original config value.", newValue);
		SetConVarString(g_hCvarRconPass, g_sRconRealPass);
	}
}