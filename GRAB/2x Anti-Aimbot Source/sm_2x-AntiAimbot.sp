//CHANGELOG
//
//v1.01 
//	* Changed certain variables to apply to server-side
//
//v1.02
//	* Fixed timeInterval variable to timeInterval[client]
//  * Changed hit detection to compare first impact as opposed to previouis impact
//  * Reset violation values on client disconnect and banned/kicked
//
//v1.03
//  * Fixed GetClientAuthString error
//
//v1.04
//  * Modified plugin to exclude thompson & mp40 in aimbot detection
//  * Decreased default value for Cvar_2XAA_ORIGIN_T
//

#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION "1.04"

new Handle:Cvar_2XAA_ENABLED
new Handle:Cvar_2XAA_ORIGIN_ENABLED
new Handle:Cvar_2XAA_HITGROUP_ENABLED
new Handle:Cvar_2XAA_ORIGIN_C
new Handle:Cvar_2XAA_ORIGIN_T
new Handle:Cvar_2XAA_PUNISHMENT
new Handle:Cvar_2XAA_CONNECT_MESSAGE
new Handle:Cvar_2XAA_TIME_ENABLED
new Handle:Cvar_2XAA_TIME_CONSISTENCY
new Handle:Cvar_2XAA_TIME_THRESHOLD
new Handle:MySQL_Bans
new Handle:SB_Bans
new String:client_name[33]
new Float:ImpactOrigin[3], Float:victimOrigin[3], Float:vAngles[3], Float:vOrigin[3], Float:distance, Float:distanceFirst[MAXPLAYERS+1] = {0.0, ...}, Float:timeInterval[MAXPLAYERS+1] = {15.0, ...}
new impactPass[MAXPLAYERS+1] = {0, ...}, announce[MAXPLAYERS+1] = {1, ...}, timeViolations[MAXPLAYERS+1] = {0, ...}, victim, pVictim[MAXPLAYERS+1]

public Plugin:myinfo = 
{
	name = "2x Anti-Aimbot Source (For CS:S, DoD:S, TF2, L4D)",
	author = "simoneaolson",
	description = "Detects and flags clients who are aimbotting",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
}

public OnPluginStart()
{
	AutoExecConfig(true, "sm_2x_Anti-Aimbot", "sm_2x_Anti-Aimbot")
	CreateConVar("sm_2xaa_version", PLUGIN_VERSION, "Current plugin version number", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY)
	Cvar_2XAA_ENABLED = CreateConVar("sm_2xaa_enabled", "1", "Enable anti-aimbot detection 0/1", FCVAR_PLUGIN)
	Cvar_2XAA_ORIGIN_ENABLED = CreateConVar("sm_2xaa_origin_enabled", "1", "Enable consistent origin anti-aimbot detection 0/1", FCVAR_PLUGIN)
	Cvar_2XAA_HITGROUP_ENABLED = CreateConVar("sm_2xaa_hitgroup_enabled", "1", "Enable consistent hitgroup anti-aimbot detection 0/1", FCVAR_PLUGIN)
	Cvar_2XAA_ORIGIN_C = CreateConVar("sm_2xaa_origin_consistency", "4", "Number of consistent hits in victim absolute origin to flag client as cheater (MAX=10) (MIN=3)", FCVAR_PLUGIN)
	Cvar_2XAA_ORIGIN_T = CreateConVar("sm_2xaa_origin_threshsold", "1.98", "Distance between x number of hits to consider aimbotting (inches)", FCVAR_PLUGIN)
	Cvar_2XAA_TIME_CONSISTENCY = CreateConVar("sm_2xaa_time_consistency", "4", "Number of time violations to consider client aimbotting", FCVAR_PLUGIN)
	Cvar_2XAA_TIME_THRESHOLD = CreateConVar("sm_2xaa_time_threshold", "0.50", "Time between hits to consider client aimbotting", FCVAR_PLUGIN)
	Cvar_2XAA_TIME_ENABLED = CreateConVar("sm_2xaa_time_enabled", "1", "Enable/Disable time violations 0/1", FCVAR_PLUGIN)
	Cvar_2XAA_PUNISHMENT = CreateConVar("sm_2xaa_punishment", "1", "Default punishment when detecting an aimbotting client. 0-Do nothing 1-Ban client 2-Kick client", FCVAR_PLUGIN)
	Cvar_2XAA_CONNECT_MESSAGE = CreateConVar("sm_2xaa_connect_message", "\x01[\x042xAA\x01] \x04Anti-Aimbot \x01detection is \x04ENABLED. \x01If you are \x04Aimbotting \x01you \x04WILL INEVITABLY \x01be caught!!", "Default plugin announce message to display on client connect", FCVAR_PLUGIN)
	MySQL_Bans = CreateConVar("sm_2xaa_mysql","0","Use only in conjunction with MySQL Bans Plugin", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY)
	SB_Bans = CreateConVar("sm_2xaa_sb","0","Use only in conjunction with source bans plugin", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY)

	if (GetConVarBool(Cvar_2XAA_ENABLED)==false) return
	if (GetConVarBool(Cvar_2XAA_ENABLED)==true && GetConVarBool(Cvar_2XAA_ORIGIN_ENABLED)==false && GetConVarBool(Cvar_2XAA_HITGROUP_ENABLED)==false) return
	HookEventEx("player_spawn", PlayerSpawn)
	HookEventEx("player_hurt", PlayerDamage)
}

public PlayerDamage(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "attacker"))
	victim = GetClientOfUserId(GetEventInt(event, "userid"))
	new String:weaponName[32]
	new String:SteamID[32]
	GetClientAuthString(client, SteamID, 32)
	GetEventString(event, "weapon", weaponName, 32)
	GetClientName(client, client_name, 33)
	if (GetConVarInt(Cvar_2XAA_TIME_ENABLED)==1)
	{
		if (victim != pVictim[client]) 
		{
			if (GetEngineTime()-timeInterval[client] < GetConVarInt(Cvar_2XAA_TIME_THRESHOLD))
			{
				timeViolations[client] += 1
				if (timeViolations[client]==GetConVarInt(Cvar_2XAA_TIME_CONSISTENCY))
				{
					timeViolations[client] = 0
					GetClientName(client, client_name, 33)
					PrintToChatAll("\x04========== AIMBOTTING CLIENT DETECTED ==========")
					PrintToChatAll("\x01[\x042xAA\x01] Client: (\x04%s) \x01has been detected Aimbotting!", client_name)
					PrintToChatAll("\x01 --> (\x04%s\x01) has hit %i victims within %.2fs", client_name, GetConVarInt(Cvar_2XAA_TIME_CONSISTENCY), GetConVarFloat(Cvar_2XAA_TIME_THRESHOLD))
					BanKick(client, SteamID)
				}
			} else {
				timeViolations[client] = 1
			}
		}
		pVictim[client] = victim
	}
	GetClientEyePosition(client, vOrigin)
	GetClientEyeAngles(client, vAngles)
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceRayDontHitSelf, client)
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(ImpactOrigin, trace)
	} else {
		return
	}
	GetClientAbsOrigin(victim, victimOrigin)
	distance = GetVectorDistance(ImpactOrigin, victimOrigin, false)
	new Float:distanceAbs = distance-distanceFirst[client]
	if (distanceAbs<0) distanceAbs = distanceAbs-2*distanceAbs

	//Begin detection of consistent origin aimbotting
	if (GetConVarInt(Cvar_2XAA_ORIGIN_ENABLED)==1 && strcmp(SteamID, "BOT")!=0)
	{
		if (distanceAbs<=GetConVarFloat(Cvar_2XAA_ORIGIN_T) && strcmp(weaponName, "spade")!=0 && strcmp(weaponName, "knife")!=0 && strcmp(weaponName, "famas")!=0 && strcmp(weaponName, "thompson")!=0 && strcmp(weaponName, "mp40")!=0)
		{
			impactPass[client] += 1
			if (impactPass[client]==GetConVarInt(Cvar_2XAA_ORIGIN_C) && GetConVarInt(Cvar_2XAA_PUNISHMENT)>0)
			{
				impactPass[client] = 0
				PrintToChatAll("\x04========== AIMBOTTING CLIENT DETECTED ==========")
				PrintToChatAll("\x01[\x042xAA\x01] Client: (\x04%s) \x01has been detected Aimbotting!", client_name)
				PrintToChatAll("\x01 --> (\x04%s\x01) has a 100 percent consistency of \x04Bullet Impact Origin (within \x04%.3fm\x01) in \x04%i \x01hits.", client_name, distanceAbs, GetConVarInt(Cvar_2XAA_ORIGIN_C))
				BanKick(client, SteamID)
			}
		} else {
			impactPass[client] = 1
			distanceFirst[client] = distance
		}
	}
	timeInterval[client] = GetEngineTime()
}

public Action:BanKick(client, String:SteamID[32])
{
	if (GetConVarInt(Cvar_2XAA_PUNISHMENT)==1)
	{
		PrintToChatAll("\x01 --> SteamID: \x04(%s\x04) \x01has been \x04banned\x01.", SteamID)
		PrintToChatAll("\x04========== AIMBOTTING CLIENT DETECTED ==========")
		
		/* START: Mysql Banning Function */
		if (GetConVarInt(MySQL_Bans)==1)
 		{
			decl String:error[255]	// Error!
			new Handle:db = SQL_Connect("default", true, error, sizeof(error))
 			if (db==INVALID_HANDLE)
 			{
				LogAction(client, -1, "[2xAA-MySQL] Could Not Connect to Database, error: %s", error)
  				CloseHandle(db)
  				return
 			}
 			decl String:query[255]
	 		Format(query, sizeof(query), "INSERT INTO mysql_bans (steam_id, player_name, ban_length, ban_reason, banned_by) VALUES ('%s', '%s', '0', '2xAA-Aimbotting infraction', '2xAA-MySQL')", SteamID, client_name)
 			SQL_Query(db, query)
			LogAction(client, -1, "[2xAA-MySQL] Steam ID: %s, Name: %s; Aimbotting infraction.", SteamID, client_name)
  			CloseHandle(db)
		}
		/* END: Mysql Banning Function */
		
		if (GetConVarInt(SB_Bans)==1)
		{
			ServerCommand("sm_ban #%d 0 Client Banned [2xAA Aimbotting Infraction]", GetClientUserId(client))
		}
		else
		{
			// Ban the Client
			BanClient(client, 0, BANFLAG_AUTO, "Client Banned [2xAA Aimbotting Infraction]", "Client Banned [2xAA Aimbotting Infraction]", "2xAA", client)		
		}
		BanIdentity(SteamID, 0, BANFLAG_AUTHID, "Client Banned [2xAA Aimbotting Infraction]", "sm_ban", client)
	}

	if (GetConVarInt(Cvar_2XAA_PUNISHMENT)==2)
	{
		PrintToChatAll("\x01 --> SteamID \x04(%s\x04) \x01has been \x04kicked\x01.", SteamID)
		PrintToChatAll("\x04========== AIMBOTTING CLIENT DETECTED ==========")
		KickClient(client, "Client Kicked. [2xAA Aimbotting Infraction]")
	}
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"))
	if (announce[client]==1 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client)>1)
	{
		announce[client] = 0
		new String:message[255]
		GetConVarString(Cvar_2XAA_CONNECT_MESSAGE, message, 255)
		PrintToChat(client, message)
	}
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	if(entity==data) // Check if the TraceRay hit the itself
	{
		return false // Don't let the entity be hit
	}
	return true // It didn't hit itself
}

public OnClientDisconnect(client)
{
	announce[client] = 0
	impactPass[client] = 0
	timeViolations[client] = 0	
}
