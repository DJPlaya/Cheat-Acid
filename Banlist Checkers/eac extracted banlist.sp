/*
- TODO: Talk with EAC about the removed bancheck PHP file
*/

#include <sourcemod>
#include <socket>
#include <smlib/clients>

#define MAX_AUTHID_LENGTH 20 // TODO: RE-CHECK!
#define PREFIX "BANCHECKER" // TODO: Better Name

#define EAC_HOSTNAME	"easyanticheat.net"
#define EAC_QUERY		"check_guid.php?id="

enum BanType {
	Ban_None = 0,
	Ban_EAC,
	Ban_VAC
};

Handle g_hCvarVAC = INVALID_HANDLE;
Handle g_hBanlist = INVALID_HANDLE;

/* Plugin Functions */

public OnPluginStart()
{
	g_hCvarVAC = CreateConVar("smac_eac_vac", "0", "Check players for previous VAC bans.", 0, true, 0.0, true, 1.0);
	
	// Initialize.
	g_hBanlist = CreateTrie();
	
	//OnClientAuthorized(i, sAuthID);
}

public OnClientAuthorized(client, const char[] auth)
{
	if (IsFakeClient(client))
		return;
	
	// Workaround for universe digit change on L4D+ engines. // TODO: No Longer Needed?
	char sAuthID[MAX_AUTHID_LENGTH];
	FormatEx(sAuthID, sizeof(sAuthID), "STEAM_0:%s", auth[8]);
	
	// Check the cache first.
	BanType banValue = Ban_None;
	
	if(GetTrieValue(g_hBanlist, sAuthID, banValue))
	{
		if(banValue == Ban_EAC || (banValue == Ban_VAC && GetConVarBool(g_hCvarVAC)))
		{
			KickClient(client, "%t", "SMAC_GlobalBanned", "EAC", "www.EasyAntiCheat.net");
		}
		
		return;
	}
	
	else// Check the banlist // TODO: Check this Datapack stuff
	{
	Handle hPack = CreateDataPack();
	WritePackCell(hPack, GetClientUserId(client));
	WritePackString(hPack, sAuthID);
	
	Handle socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketSetArg(socket, hPack);
	SocketSetOption(socket, ConcatenateCallbacks, 4096);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, EAC_HOSTNAME, 80);
	}
	
	// Clear a large cache to prevent slowdowns. Shouldn't reach this size anyway.
	if(GetTrieSize(g_hBanlist) > 64000)
		ClearTrie(g_hBanlist);
}

public OnSocketConnected(Handle socket, any hPack)
{
	char sAuthID[MAX_AUTHID_LENGTH], sRequest[256];
	ResetPack(hPack);
	ReadPackCell(hPack);
	ReadPackString(hPack, sAuthID, sizeof(sAuthID));
	FormatEx(sRequest, sizeof(sRequest), "GET /%s%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", EAC_QUERY, sAuthID, EAC_HOSTNAME);
	SocketSend(socket, sRequest);
}

public OnSocketReceive(Handle socket, char[] data, const size, any hPack)
{
	char sAuthID[MAX_AUTHID_LENGTH], idx;
	ResetPack(hPack);
	ReadPackCell(hPack);
	ReadPackString(hPack, sAuthID, sizeof(sAuthID));
	
	// Check if we already have the result we needed.
	if (GetTrieValue(g_hBanlist, sAuthID, idx))
		return;
	
	// Make sure we're reading the actual banlist.
	if ((idx = StrContains(data, "[BEGIN LIST]")) == -1)
		return;
	
	// Look for the SteamID.
	new offset = StrContains(data[idx], sAuthID);
	
	if (offset == -1)
	{
		// Not on the banlist.
		SetTrieValue(g_hBanlist, sAuthID, Ban_None);
		return;
	}
	
	idx += offset;
	
	// Get ban info string.
	new length = FindCharInString(data[idx], '\n') + 1;
	
	decl String:sBanInfo[length];
	strcopy(sBanInfo, length, data[idx]);
	
	// 0 - SteamID
	// 1 - Ban reason
	// 2 - Ban date
	// 3 - Expiration date
	char sBanChunks[4][64];
	if (ExplodeString(sBanInfo, "|", sBanChunks, sizeof(sBanChunks), sizeof(sBanChunks[])) != 4)
		return;
	
	// Check if it's a VAC ban.
	if(StrEqual(sBanChunks[1], "VAC Banned"))
	{
		SetTrieValue(g_hBanlist, sAuthID, Ban_VAC);
		
		if (!GetConVarBool(g_hCvarVAC))
			return;
	}
	
	else
		SetTrieValue(g_hBanlist, sAuthID, Ban_EAC);
		
	// Notify and log.
	ResetPack(hPack);
	
	int iClient = GetClientOfUserId(ReadPackCell(hPack));
	
	if(!Client_IsValid(iClient)) //IS_CLIENT(iClient) // TODO:Whats that?
		return;
	
	//Warn about the Ban
	LogAction(iClient, -1, "[Warning][%s]Client is on the banlist. (Reason: %s | Expires: %s)", PREFIX, sBanChunks[1], sBanChunks[3]);
	PrintToServer("[Warning][%s] %s is on the banlist. (Reason: %s | Expires: %s)", PREFIX, iClient, sBanChunks[1], sBanChunks[3]);
	KickClient(iClient, "%t", "BANNED", "EAC", "www.EasyAntiCheat.net"); // TODO: Better Messages
}

public OnSocketDisconnected(Handle socket, any hPack)
{
	CloseHandle(hPack);
	CloseHandle(socket);
}

public OnSocketError(Handle socket, const errorType, const errorNum, any hPack)
{
	CloseHandle(hPack);
	CloseHandle(socket);
}