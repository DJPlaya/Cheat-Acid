#include <sourcemod>
#include <sdktools>
#include <smac>
#include <colors>
#include <geoip>

public Plugin:myinfo =
{
	name = "SMAC: Core",
	author = SMAC_AUTHOR,
	description = "Open source anti-cheat plugin for SourceMod",
	version = SMAC_VERSION,
	url = SMAC_URL
};

new Handle:g_OnCheatDetected = INVALID_HANDLE;
new Handle:g_hCvarBanConsoleMsg = INVALID_HANDLE;
new Handle:g_hCvarBanDuration = INVALID_HANDLE;
new Handle:g_hCvarLogVerbose = INVALID_HANDLE;
new String:g_sLogPath[PLATFORM_MAX_PATH];

/* Plugin Functions */
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	BuildPath(Path_SM, g_sLogPath, sizeof(g_sLogPath), "logs/SMAC.log");
	API_Init();
	RegPluginLibrary("smac");
	return APLRes_Success;
}

public OnPluginStart()
{
	LoadTranslations("smac.phrases");
	g_hCvarBanConsoleMsg = CreateConVar("smac_ban_console_msg", "1", "Display client info in client console.", _, true, 0.0, true, 1.0);
	g_hCvarBanDuration = CreateConVar("smac_ban_duration", "60", "The duration in minutes used for automatic bans. (0 = Permanent)", _, true, 0.0);
	g_hCvarLogVerbose = CreateConVar("smac_log_verbose", "1", "Include extra information about a client being logged.", _, true, 0.0, true, 1.0);
	RegAdminCmd("smac_status", Command_Status, ADMFLAG_GENERIC, "View the server's player status.");	
}

public OnAllPluginsLoaded(){
	decl String:cfgname[64];	Format(cfgname, sizeof(cfgname), "smac_%s",SMAC_VERSION);
	AutoExecConfig(true, cfgname);
}

public Action:Command_Status(client, args){
	ReplyToCommand(client, "UserID  AuthID                IP             Latency       Name");
	decl String:sAuthID[MAX_AUTHID_LENGTH], String:sIP[17], String:sCountry[3];
	for (new i = 1; i <= MaxClients; i++){
		if (IsClientInGame(i) && !IsFakeClient(i)){
		if (!GetClientAuthId(i, AuthId_Engine, sAuthID, sizeof(sAuthID), true)){
		if (GetClientAuthId(i, AuthId_Engine, sAuthID, sizeof(sAuthID), false)){Format(sAuthID, sizeof(sAuthID), "%s (Not Validated)", sAuthID);}
		else	strcopy(sAuthID, sizeof(sAuthID), "Unknown");		}
		if(!GetClientIP(i, sIP, sizeof(sIP))){strcopy(sIP, sizeof(sIP), "Unknown");}
		GeoipCode3(sIP,sCountry);
		ReplyToCommand(client, "#%5d  %-21s %-14s %4i ms    %-s|%N", GetClientUserId(i), sAuthID, sIP, RoundToZero(GetClientLatency(i, NetFlow_Outgoing) * 1024),sCountry, i);
		}
	}
	return Plugin_Handled;
}


API_Init()
{
	CreateNative("SMAC_Log", Native_Log);
	CreateNative("SMAC_LogAction", Native_LogAction);
	CreateNative("SMAC_Ban", Native_Ban);
	CreateNative("SMAC_PrintAdminNotice", Native_PrintAdminNotice);
	CreateNative("SMAC_CreateConVar", Native_CreateConVar);
	CreateNative("SMAC_CheatDetected", Native_CheatDetected);
	g_OnCheatDetected = CreateGlobalForward("SMAC_OnCheatDetected", ET_Event, Param_Cell, Param_String, Param_Cell, Param_Cell);
}


public Native_Log(Handle:plugin, numParams){
	decl String:sFilename[64], String:sBuffer[256];
	GetPluginBasename(plugin, sFilename, sizeof(sFilename));
	FormatNativeString(0, 1, 2, sizeof(sBuffer), _, sBuffer);
	LogToFileEx(g_sLogPath, "[%s] %s", sFilename, sBuffer);	
}

public Native_LogAction(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (!IS_CLIENT(client) || !IsClientConnected(client)){ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);}
	
	decl String:sAuthID[MAX_AUTHID_LENGTH];
	if (!GetClientAuthId(client, AuthId_Engine, sAuthID, sizeof(sAuthID), true))	{
	if (GetClientAuthId(client, AuthId_Engine, sAuthID, sizeof(sAuthID), false)){Format(sAuthID, sizeof(sAuthID), "%s (Not Validated)", sAuthID);}
	else	{strcopy(sAuthID, sizeof(sAuthID), "Unknown");}}
	
	decl String:sIP[17];
	if (!GetClientIP(client, sIP, sizeof(sIP)))	{strcopy(sIP, sizeof(sIP), "Unknown");}
	
	decl String:sVersion[16], String:sFilename[64], String:sBuffer[512];
	GetPluginInfo(plugin, PlInfo_Version, sVersion, sizeof(sVersion));
	GetPluginBasename(plugin, sFilename, sizeof(sFilename));
	FormatNativeString(0, 2, 3, sizeof(sBuffer), _, sBuffer);
	
	// Verbose client logging.
	if (GetConVarBool(g_hCvarLogVerbose) && IsClientInGame(client))
	{
		decl String:sMap[MAX_MAPNAME_LENGTH], Float:vOrigin[3], Float:vAngles[3], String:sWeapon[32], iTeam, iLatency;
		GetCurrentMap(sMap, sizeof(sMap));
		GetClientAbsOrigin(client, vOrigin);
		GetClientEyeAngles(client, vAngles);
		GetClientWeapon(client, sWeapon, sizeof(sWeapon));
		iTeam = GetClientTeam(client);
		iLatency = RoundToNearest(GetClientAvgLatency(client, NetFlow_Outgoing) * 1000.0);
		
		LogToFileEx(g_sLogPath,
			"[%s | %s] %N (ID: %s | IP: %s) %s\n\tMap: %s | Origin: %.0f %.0f %.0f | Angles: %.0f %.0f %.0f | Weapon: %s | Team: %i | Latency: %ims",
			sFilename,
			sVersion,
			client,
			sAuthID,
			sIP,
			sBuffer,
			sMap,
			vOrigin[0], vOrigin[1], vOrigin[2],
			vAngles[0], vAngles[1], vAngles[2],
			sWeapon,
			iTeam,
			iLatency);
	}
	else
	{
		LogToFileEx(g_sLogPath, "[%s | %s] %N (ID: %s | IP: %s) %s", sFilename, sVersion, client, sAuthID, sIP, sBuffer);
	}
	
}

// native SMAC_Ban(client, const String:reason[], any:...);
public Native_Ban(Handle:plugin, numParams)
{
	decl String:sVersion[16], String:sReason[256];
	new client = GetNativeCell(1);
	new duration = GetConVarInt(g_hCvarBanDuration);
	
	GetPluginInfo(plugin, PlInfo_Version, sVersion, sizeof(sVersion));
	FormatNativeString(0, 2, 3, sizeof(sReason), _, sReason);
	Format(sReason, sizeof(sReason), "SMAC: %s", sReason);
	decl String:sAuth[21],String:sIP[17], String:sContact[32];
	GetClientAuthId(client, AuthId_Engine, sAuth, 21); GetClientIP(client,sIP,17); GetConVarString(FindConVar("sv_contact"),sContact, sizeof(sContact));
	if (GetConVarBool(g_hCvarBanConsoleMsg))	PrintToConsole(client, "%t", "SMAC_BannedClientCon", client, sAuth, sIP, sReason, duration, sContact);
	ServerCommand("sm_ban #%d %i \"%s\"", GetClientUserId(client), duration, sReason);
}

public Native_PrintAdminNotice(Handle:plugin, numParams)
{
	decl String:sBuffer[192];

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && CheckCommandAccess(i, "smac_admin_notices", ADMFLAG_GENERIC, true))
		{
			SetGlobalTransTarget(i);
			FormatNativeString(0, 1, 2, sizeof(sBuffer), _, sBuffer);
			CPrintToChat(i, "{green}%t{red}%s", "SMAC_Tag", sBuffer);
		}
	}
}

// native Handle:SMAC_CreateConVar(const String:name[], const String:defaultValue[], const String:description[]="", flags=0, bool:hasMin=false, Float:min=0.0, bool:hasMax=false, Float:max=0.0);
public Native_CreateConVar(Handle:plugin, numParams)
{
	decl String:name[64], String:defaultValue[16], String:description[192];
	GetNativeString(1, name, sizeof(name));
	GetNativeString(2, defaultValue, sizeof(defaultValue));
	GetNativeString(3, description, sizeof(description));
	
	new flags = GetNativeCell(4);
	new bool:hasMin = bool:GetNativeCell(5);
	new Float:min = Float:GetNativeCell(6);
	new bool:hasMax = bool:GetNativeCell(7);
	new Float:max = Float:GetNativeCell(8);
	
	decl String:sFilename[64];
	GetPluginBasename(plugin, sFilename, sizeof(sFilename));
	Format(description, sizeof(description), "[%s] %s", sFilename, description);
	
	return _:CreateConVar(name, defaultValue, description, flags, hasMin, min, hasMax, max);
}

// native Action:SMAC_CheatDetected(client, DetectionType:type = Detection_Unknown, Handle:info = INVALID_HANDLE);
public Native_CheatDetected(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	
	if (!IS_CLIENT(client) || !IsClientConnected(client)){ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);}
	if (IsClientInKickQueue(client)){return _:Plugin_Handled;}
	decl String:sFilename[64];
	GetPluginBasename(plugin, sFilename, sizeof(sFilename));
	new DetectionType:type = Detection_Unknown;
	new Handle:info = INVALID_HANDLE;
	if (numParams == 3)
	{
		type = DetectionType:GetNativeCell(2);
		info = Handle:GetNativeCell(3);
	}
	
	new Action:result = Plugin_Continue;
	Call_StartForward(g_OnCheatDetected);
	Call_PushCell(client);
	Call_PushString(sFilename);
	Call_PushCell(type);
	Call_PushCell(info);
	Call_Finish(result);
	
	return _:result;
}
