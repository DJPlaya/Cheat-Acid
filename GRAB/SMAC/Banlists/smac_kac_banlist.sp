#pragma semicolon 1

/* SM Includes */
#include <sourcemod>
#include <socket>
#include <smac>
#undef REQUIRE_PLUGIN
#include <updater>

/* Plugin Info */
public Plugin:myinfo =
{
	name = "SMAC KAC Global Banlist",
	author = "Kigen",
	description = "Kicks players on the KAC global banlist",
	version = SMAC_VERSION,
	url = "www.kigenac.com"
};

/* Globals */
#define UPDATE_URL	"http://godtony.mooo.com/smac/smac_kac_banlist.txt"

new Handle:g_hCvarKick = INVALID_HANDLE;
new Handle:g_hSocket = INVALID_HANDLE;
new bool:g_bChecked[MAXPLAYERS+1] = {false, ...};
new g_iInError = 0;

new Handle:g_hDenyArray = INVALID_HANDLE;
new Handle:g_hValidateTimer[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
new bool:g_bLateLoad = false;

/* Plugin Functions */
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	g_bLateLoad = late;
	return APLRes_Success;
}

public OnPluginStart()
{
	LoadTranslations("smac.phrases");
	
	// Convars.
	g_hCvarKick = SMAC_CreateConVar("smac_kac_kick", "1", "Automatically kick players on the KAC banlist.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	g_hDenyArray = CreateTrie();
	
	CreateTimer(14400.0, Timer_ClearAll, _, TIMER_REPEAT); // Clear the Deny Array every 4 hours.
	CreateTimer(5.0, Timer_CheckAll, _, TIMER_REPEAT);
	
	if (g_bLateLoad)
	{
		decl String:sAuth[MAX_AUTHID_LENGTH];
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientAuthorized(i) && GetClientAuthString(i, sAuth, sizeof(sAuth)))
			{
				OnClientAuthorized(i, sAuth);
			}
			
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}

	// Updater.
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public OnClientAuthorized(client, const String:auth[])
{
	if ( IsFakeClient(client) )
		return;
	
	// Workaround for universe digit change on L4D+ engines.
	decl String:sAuthID[MAX_AUTHID_LENGTH];
	FormatEx(sAuthID, sizeof(sAuthID), "STEAM_0:%s", auth[8]);

	decl Handle:f_hTemp, String:f_sReason[256];

	if ( GetTrieString(g_hDenyArray, sAuthID, f_sReason, sizeof(f_sReason)) && GetConVarBool(g_hCvarKick) )
	{
		KickClient(client, "%s", f_sReason);
		OnClientDisconnect(client);
		return;
	}

	f_hTemp = g_hValidateTimer[client];
	g_hValidateTimer[client] = INVALID_HANDLE;
	if ( f_hTemp != INVALID_HANDLE )
		CloseHandle(f_hTemp);
}

public OnClientPutInServer(client)
{
	if ( !IsFakeClient(client) && !IsClientAuthorized(client) ) // Not authorized yet?!?
		g_hValidateTimer[client] = CreateTimer(10.0, Timer_Validate, client);
}

public OnClientDisconnect(client)
{
	new Handle:f_hTemp = g_hValidateTimer[client];
	
	g_hValidateTimer[client] = INVALID_HANDLE;
	if ( f_hTemp != INVALID_HANDLE )
		CloseHandle(f_hTemp);
	
	g_bChecked[client] = false;
}

public Action:Timer_CheckAll(Handle:timer, any:we)
{
	if ( g_iInError > 0 )
	{
		g_iInError--;
		return Plugin_Continue;
	}

	decl Handle:f_hTemp;
	f_hTemp = g_hSocket;
	if ( f_hTemp != INVALID_HANDLE )
	{
		g_hSocket = INVALID_HANDLE;
		CloseHandle(f_hTemp);
	}

	for(new i=1;i<=MaxClients;i++)
	{
		if ( IsClientAuthorized(i) && !g_bChecked[i] )
		{
			g_iInError = 1;
			g_hSocket = SocketCreate(SOCKET_TCP, Network_OnSocketError);
			SocketSetArg(g_hSocket, i);
			SocketConnect(g_hSocket, Network_OnSocketConnect, Network_OnSocketReceive, Network_OnSocketDisconnect, "master.kigenac.com", 9652);
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}

public Action:Timer_Validate(Handle:timer, any:client)
{
	g_hValidateTimer[client] = INVALID_HANDLE;

	if ( !IsClientInGame(client) || IsClientAuthorized(client) )
		return Plugin_Stop;

	KickClient(client, "%t", "SMAC_FailedAuth");
	
	return Plugin_Stop;
}

public Action:Timer_ClearAll(Handle:timer, any:nothing)
{
	ClearTrie(g_hDenyArray);
}

//- Socket Functions -//

public Network_OnSocketConnect(Handle:socket, any:client)
{
	if ( !SocketIsConnected(socket) )
		return;

	decl String:f_sAuthID[MAX_AUTHID_LENGTH];
	
	if ( !IsClientAuthorized(client) || !GetClientAuthString(client, f_sAuthID, sizeof(f_sAuthID)) )
	{
		SocketDisconnect(socket);
	}
	else
	{
		f_sAuthID[6] = '0';
		SocketSend(socket, f_sAuthID, strlen(f_sAuthID)+1); // Send that \0! - Kigen
	}
	
	return;
}

public Network_OnSocketDisconnect(Handle:socket, any:client)
{
	if ( socket == g_hSocket )
		g_hSocket = INVALID_HANDLE;
	CloseHandle(socket);
	return;
}

public Network_OnSocketReceive(Handle:socket, String:data[], const size, any:client) 
{
	if ( socket == INVALID_HANDLE || !IsClientAuthorized(client) )
		return;

	g_bChecked[client] = true;
	if ( StrEqual(data, "_BAN") )
	{
		if ( SMAC_CheatDetected(client) == Plugin_Continue )
		{
			decl String:f_sAuthID[MAX_AUTHID_LENGTH], String:f_sBuffer[256];
			GetClientAuthString(client, f_sAuthID, sizeof(f_sAuthID));
			f_sAuthID[6] = '0';
			
			FormatEx(f_sBuffer, sizeof(f_sBuffer), "%T", "SMAC_GlobalBanned", client, "KAC", "www.kigenac.com");
			SetTrieString(g_hDenyArray, f_sAuthID, f_sBuffer);
			
			SMAC_PrintAdminNotice("%N | %s | KAC Ban", client, f_sAuthID);
			
			if (GetConVarBool(g_hCvarKick))
			{
				SMAC_LogAction(client, "was kicked.");
				KickClient(client, "%t", "SMAC_GlobalBanned", "KAC", "www.kigenac.com");
			}
			else
			{
				SMAC_LogAction(client, "is on the banlist.");
			}
		}
	}
	else if ( StrEqual(data, "_OK") )
	{
		// sigh here.
	}
	else
	{
		g_bChecked[client] = false;
		SMAC_LogAction(client, "got unknown reply from KAC master server. Data: %s", data);
	}
	if ( SocketIsConnected(socket) )
		SocketDisconnect(socket);
}

public Network_OnSocketError(Handle:socket, const errorType, const errorNum, any:client)
{
	if ( socket == INVALID_HANDLE )
		return;
	
	if ( g_hSocket == socket )
		g_hSocket = INVALID_HANDLE;
	
	CloseHandle(socket);
}
