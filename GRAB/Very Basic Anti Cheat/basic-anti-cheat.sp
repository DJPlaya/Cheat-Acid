/**
* VBAC - Very Basic Anti Cheat
*
* Description:
*	This plugin bans cheaters and players with the name of "unconnected"
*
* Usage:
*	 Install and go!
*	
* Thanks to:
* 	Everyone in http://forums.alliedmods.net/showthread.php?t=72097
*	and in http://forums.alliedmods.net/showthread.php?t=72170
*	  
* To-do:	
*	Move MySQL banning into its own function
*
* Version 1.0
* 	- After a few attempts :-P
*
* Version 2.0
*	- Added wireframe check, added bot check, altered  version var & tidied code
*
* Version 3.0
*	- Added consistancy check, added MySQL Bans support, moved name check to when the client connects and made functions more effcient by putting get details inside so are only used if needed
*
* Version 3.1
*	- Added sourcebans compatibilty
*
* Version 3.2
*	- Resolved fakeclient issues
*
* Version 3.3
*	- Resolved 'Client N is not connected' issues
*/
//////////////////////////////////////////////////////////////////
// Defines
//////////////////////////////////////////////////////////////////
#pragma semicolon 1
#include <sourcemod>
#define PLUGIN_VERSION "3.3"

//////////////////////////////////////////////////////////////////
// Delcare Handles
//////////////////////////////////////////////////////////////////
new Handle:g_CheckCvar;
new Handle:g_cvarToCheck;
new Handle:MySQL_Bans;
new Handle:SB_Bans;

//////////////////////////////////////////////////////////////////
// Plugin Info
//////////////////////////////////////////////////////////////////
public Plugin:myinfo = 
{
	name = "VBAC",
	author = "MoggieX",
	description = "Very Basic Anti Cheat",
	version = PLUGIN_VERSION,
	url = "http://www.UKManDown.co.uk"
};

//////////////////////////////////////////////////////////////////
// Normal CVars + Hooking
//////////////////////////////////////////////////////////////////
public OnPluginStart()
{
	CreateConVar("sm_vbac_version", PLUGIN_VERSION, "VBAC Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_cvarToCheck = CreateConVar("sm_vbac_value", "sv_cheats", "sv_cheats to check against",FCVAR_PRINTABLEONLY);	//|FCVAR_REPLICATED|FCVAR_NOTIFY
	MySQL_Bans = CreateConVar("sm_vbac_mysql","0","Use only in conjunction with MySQL Bans Plugin", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	SB_Bans = CreateConVar("sm_vbac_sb","0","Use only in conjunction with source bans plugin", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	HookEvent("player_spawn", Event_player_spawn);
}

//////////////////////////////////////////////////////////////////
// Name Check
//////////////////////////////////////////////////////////////////
public OnClientPostAdminCheck(client)
{

	// Declarations
	decl String:player_name[65];
	decl String:steam_id[32];

	// why is this like this? I have no idea!
	steam_id[0] = '\0';

	// Get Steam ID
	GetClientAuthString(client, steam_id, sizeof(steam_id));

	// Get client Details
	GetClientName(client, player_name, sizeof(player_name));

	//this checks to see if the player is unconneted or not the player is unconnected or not
	if (strcmp(player_name, "\0") == 0) 
	{ 
		// Notify in chatas i'd want to wet my panties when we get one
		PrintToChatAll("\x04======== \x03Unconnected Found! \x04========");
		PrintToChatAll("\x03[VBAC] \x04Name: \x03%s \x04SteamID: \x03%s \x04 was found to have an invalid name", player_name, steam_id);
		PrintToChatAll("\x04======== \x03Unconnected Found! \x04========");

		/* START: Mysql Banning Function */
		if (GetConVarInt(MySQL_Bans) == 1)
 		{
			decl String:error[255];		// Error!
			new Handle:db = SQL_Connect("default", true, error, sizeof(error));

 			if (db == INVALID_HANDLE)
 			{
				LogAction(client, -1, "[VBAC MySQL] Could Not Connect to Database, error: %s", error);
  				CloseHandle(db);
  				return true;
 			}

 			decl String:query[255];

	 		Format(query, sizeof(query), "INSERT INTO mysql_bans (steam_id, player_name, ban_length, ban_reason, banned_by) VALUES ('%s', '%s', '0', 'VBAC NAME BAN ', 'VBAC-MySQL')", steam_id, player_name);
				
 			SQL_Query(db, query);
			LogAction(client, -1, "[VBAC NAME BAN] Name: %s SteamID: %s was BANNED for having a name of unconnected", player_name, steam_id);
  			CloseHandle(db);

		}
		/* END: Mysql Banning Function */

		if (GetConVarInt(SB_Bans) == 1)
		{
			ServerCommand("sm_ban #%d 0 VAC-Ban-Detected-Unconnected-#ATC561413",GetClientUserId(client));
		}
		else
		{
		// Ban the *
		BanClient(client, 
				0, 
				BANFLAG_AUTO, 
				"unconnected_player", 
				"VAC Ban Detected #ATC561412", 
				"VBAC",
				client);
		}

		// Log the event
		LogAction(client, -1, "[VBAC NAME BAN] Name: %s SteamID: %s was BANNED for having a name of unconnected", player_name, steam_id);

	}
	return true;
}

//////////////////////////////////////////////////////////////////
// Player checking on spawn event
//////////////////////////////////////////////////////////////////
public Action:Event_player_spawn(Handle:event, const String:name[], bool:dontBroadcast)
 {

	// Added check to make sure sv_cheats is not enabled and this will save everyone for getting banned if some nubcake enables the checked server var

	// Declarations
	decl String:check[65];

	// Stuff the value in a handle
	GetConVarString(g_cvarToCheck, check, 65);
	g_CheckCvar = FindConVar(check);

	// now check against it and if its OFF do *stuff*
	if (GetConVarInt(g_CheckCvar) == 0)
	{

		// Get Client
		new client = GetClientOfUserId(GetEventInt(event, "userid"));

		// Query the client for sv_cheats - ClientConVar
		QueryClientConVar(client, "sv_cheats", ConVarQueryFinished:ClientConVar1, client);

		// Query the client for sv_consistency - ClientConVar3
		QueryClientConVar(client, "sv_consistency", ConVarQueryFinished:ClientConVar3, client);


	}

	// Close Handles as its polite & saves memory
	CloseHandle(g_CheckCvar);
	CloseHandle(g_cvarToCheck);

	return Plugin_Continue;
}

//////////////////////////////////////////////////////////////////
// sv_cheats
//////////////////////////////////////////////////////////////////
public ClientConVar1(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName1[], const String:cvarValue1[])
 {
	if ( !IsClientConnected(client) )
		return true;

	// Declarations
	decl String:player_name[65];
	decl String:steam_id[32];

	// why is this like this? I have no idea!
	steam_id[0] = '\0';

	// Get Steam ID
	GetClientAuthString(client, steam_id, sizeof(steam_id));

	// Get client Details
	GetClientName(client, player_name, sizeof(player_name));

	// For Interger values
	new cvarValueNew = StringToInt(cvarValue1);

	//if sv_cheats is not equalto 0 then we ban the player
	if (cvarValueNew != 0)
	{
		// Notify in chatas i'd want to wet my panties when we get one
		PrintToChatAll("\x04======== \x03CHEATER FOUND! \x04========");
		PrintToChatAll("\x03[VBAC CHEATER FOUND!] \x04Name: \x03%s \x04SteamID: \x03%s \x04CVar: \x03%s \x04CVar Value: \x03%s", player_name, steam_id, cvarName1, cvarValue1);
		PrintToChatAll("\x04======== \x03CHEATER FOUND! \x04========");


		//new identifier = 1;
		//BanBanBan(player_name, steam_id, cvarName1, cvarValue1, identifier);


		/* START: Mysql Banning Function */
		if (GetConVarInt(MySQL_Bans) == 1)
 		{
			decl String:error[255];		// Error!
			new Handle:db = SQL_Connect("default", true, error, sizeof(error));

 			if (db == INVALID_HANDLE)
 			{
				LogAction(client, -1, "[VBAC MySQL] Could Not Connect to Database, error: %s", error);
  				CloseHandle(db);
  				return true;
 			}

 			decl String:query[255];

	 		Format(query, sizeof(query), "INSERT INTO mysql_bans (steam_id, player_name, ban_length, ban_reason, banned_by) VALUES ('%s', '%s', '0', 'VBAC CVAR %s Value %s ', 'VBAC-MySQL')", steam_id, player_name, cvarName1, cvarValue1);
				
 			SQL_Query(db, query);
			LogAction(client, -1, "[VBAC MySQL] Steam ID: %s, Name: %s, CVar Name: %s, CVar Value: %s", steam_id, player_name, cvarName1, cvarValue1);	
  			CloseHandle(db);

		}
		/* END: Mysql Banning Function */


		if (GetConVarInt(SB_Bans) == 1)
		{
			ServerCommand("sm_ban #%d 0 VAC-Ban-Detected-Cheats-#ATC561413",GetClientUserId(client));
		}
		else
		{
		// Ban the *
		BanClient(client, 
				0, 
				BANFLAG_AUTO, 
				"sv_cheats_bypass", 
				"VAC Ban Detected #ATC561411", 
				"VBAC",
				client);		
		}

		// Log the event
		LogAction(client, -1, "[VBAC SV_CHEATS BAN] Name: %s SteamID: %s was BANNED for CVar: %s CVar Value: %s", player_name, steam_id, cvarName1, cvarValue1);

	}

	return true;
}  

//////////////////////////////////////////////////////////////////
// sv_consistency
//////////////////////////////////////////////////////////////////
public ClientConVar3(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName3[], const String:cvarValue3[])
 {

	if ( !IsClientConnected(client) )
		return true;

	// For Interger values
	new cvarValueNew = StringToInt(cvarValue3);

	//if sv_cheats is not equalto 0 then we ban the player
	if (cvarValueNew != 1)
	{
		// Declarations
		decl String:player_name[65];
		decl String:steam_id[32];

		// Get Steam ID
		GetClientAuthString(client, steam_id, sizeof(steam_id));

		// Get client Details
		GetClientName(client, player_name, sizeof(player_name));

		// Notify in chatas i'd want to wet my panties when we get one
		PrintToChatAll("\x04======== \x03CHEATER FOUND! \x04========");
		PrintToChatAll("\x03[VBAC CHEATER FOUND!] \x04Name: \x03%s \x04SteamID: \x03%s \x04CVar: \x03%s \x04CVar Value: \x03%s", player_name, steam_id, cvarName3, cvarValue3);
		PrintToChatAll("\x04======== \x03CHEATER FOUND! \x04========");

		/* START: Mysql Banning Function */
		if (GetConVarInt(MySQL_Bans) == 1)
 		{
			decl String:error[255];		// Error!
			new Handle:db = SQL_Connect("default", true, error, sizeof(error));

 			if (db == INVALID_HANDLE)
 			{
				LogAction(client, -1, "[VBAC MySQL] Could Not Connect to Database, error: %s", error);
  				CloseHandle(db);
  				return true;
 			}

 			decl String:query[255];

	 		Format(query, sizeof(query), "INSERT INTO mysql_bans (steam_id, player_name, ban_length, ban_reason, banned_by) VALUES ('%s', '%s', '0', 'VBAC CVAR %s Value %s ', 'VBAC-MySQL')", steam_id, player_name, cvarName3, cvarValue3);
				
 			SQL_Query(db, query);
			LogAction(client, -1, "[VBAC MySQL] Steam ID: %s, Name: %s, CVar Name: %s, CVar Value: %s", steam_id, player_name, cvarName3, cvarValue3);	
  			CloseHandle(db);
		}
		/* END: Mysql Banning Function */

		if (GetConVarInt(SB_Bans) == 1)
		{
			ServerCommand("sm_ban #%d 0 VAC-Ban-Detected-consistency-#ATC561409",GetClientUserId(client));
		}
		else
		{
		// Ban the *
		BanClient(client, 
				0, 
				BANFLAG_AUTO, 
				"sv_consistency_bypass", 
				"VAC Ban Detected #ATC561409", 
				"VBAC",
				client);
		}

		// Log the event
		LogAction(client, -1, "[VBAC CONSISTANCY BAN] Name: %s SteamID: %s was BANNED for CVar: %s CVar Value: %s", player_name, steam_id, cvarName3, cvarValue3);
	}

	return true;
}