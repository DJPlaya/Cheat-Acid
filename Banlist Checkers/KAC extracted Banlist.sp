/*
INFO:
- The Socket automaticly checks if the player is banned or not
- g_hDenyArray still includes all Bans
*/
#include <sourcemod>
#include <socket>

#define MAX_AUTHID_LENGTH 20 // TODO: RE-CHECK!
#define PREFIX "BANCHECKER" // TODO: Better Name

Handle g_hDenyArray, g_hSocket;

OnPluginStart()
{
	CreateTimer(14400.0, Timer_Refresh, _, TIMER_REPEAT); // Clear the Ban Array every 4 hours
}

public OnClientAuthorized(iClient, const char[] auth)
{
	if(IsFakeClient(iClient))
		return;
		
	// Workaround for universe digit change on L4D+ engines. // TODO: No Longer Needed?
	char sAuthID[MAX_AUTHID_LENGTH];
	FormatEx(sAuthID, sizeof(sAuthID), "STEAM_0:%s", auth[8]);
	
	char f_sReason[256];
	
	if(GetTrieString(g_hDenyArray, sAuthID, f_sReason, sizeof(f_sReason)))
	{
		KickClient(iClient, "%s", f_sReason);
		return;
	}
	
	else
	{
		g_hSocket = SocketCreate(SOCKET_TCP, Network_OnSocketError);
		SocketSetArg(g_hSocket, iClient);
		SocketConnect(g_hSocket, Network_OnSocketConnect, Network_OnSocketReceive, Network_OnSocketDisconnect, "master.kigenac.com", 9652);
	}
}

public Action Timer_Refresh(Handle timer, any nothing)
{
	ClearTrie(g_hDenyArray);
}

//- Socket Functions -//

public Network_OnSocketConnect(Handle socket, any client)
{
	if(!SocketIsConnected(socket))
		return;
		
	char f_sAuthID[MAX_AUTHID_LENGTH];
	
	if(!IsClientAuthorized(client) || !GetClientAuthId(client, AuthId_Steam2, f_sAuthID, sizeof(f_sAuthID)))
		SocketDisconnect(socket);
		
	else
	{
		f_sAuthID[6] = '0';
		SocketSend(socket, f_sAuthID, strlen(f_sAuthID)+1); // Send that \0! - Kigen
	}
	
	return;
}

public Network_OnSocketDisconnect(Handle socket, any client)
{
	if(socket == g_hSocket)
		g_hSocket = INVALID_HANDLE;
		
	CloseHandle(socket);
	return;
}

public Network_OnSocketReceive(Handle socket, char[] data, const size, any client) 
{
	if(socket == INVALID_HANDLE || !IsClientAuthorized(client))
		return;
		
	if(StrEqual(data, "_BAN")) // Is On The Banlist
	{
		char f_sAuthID[MAX_AUTHID_LENGTH], f_sBuffer[256];
		
		GetClientAuthId(client, AuthId_Steam2, f_sAuthID, sizeof(f_sAuthID));
		f_sAuthID[6] = '0';
		
		FormatEx(f_sBuffer, sizeof(f_sBuffer), "%T", "Banned", client, "KAC", "www.kigenac.com"); // TODO:better messages
		SetTrieString(g_hDenyArray, f_sAuthID, f_sBuffer);
	}
	
	else if(StrEqual(data, "_OK")) // Is OK
	{
		// sigh here
	}
	
	else
	{
		LogAction(client, -1, "[Error][%s] Got unknown Reply from KAC Master Server. Data: %s", PREFIX, data);
		PrintToServer("[Error][%s] Got unknown Reply from KAC Master Server. Data: %s", PREFIX, data);
	}
	
	if(SocketIsConnected(socket))
		SocketDisconnect(socket);
}

public Network_OnSocketError(Handle socket, const errorType, const errorNum, any client)
{
	if(socket == INVALID_HANDLE)
		return;
		
	if(g_hSocket == socket)
		g_hSocket = INVALID_HANDLE;
		
	CloseHandle(socket);
}