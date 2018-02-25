#include <sourcemod>
#include <socket>

#define MAX_AUTHID_LENGTH 20 // TODO: RE-CHECK!
#define PREFIX "BANCHECKER" // TODO: Better Name

#define ESEA_HOSTNAME	"play.esea.net"
#define ESEA_QUERY		"index.php?s=support&d=ban_list&type=1&format=csv"

Handle g_hBanlist = INVALID_HANDLE;

/* Plugin Functions */
public OnPluginStart()
{
	// Initialize.
	g_hBanlist = CreateTrie();
	
	ESEA_DownloadBanlist();
}

public OnClientAuthorized(client, const char[] auth)
{
	if (IsFakeClient(client))
		return;
	
	// Workaround for universe digit change on L4D+ engines. // TODO: No Longer Needed?
	char sAuthID[MAX_AUTHID_LENGTH];
	FormatEx(sAuthID, sizeof(sAuthID), "STEAM_0:%s", auth[8]);
	
	bool bShouldLog;
	
	if(GetTrieValue(g_hBanlist, sAuthID, bShouldLog))
	{
		if(bShouldLog)
		{
			SetTrieValue(g_hBanlist, sAuthID, 0);
		}
		
		
		KickClient(client, "%t", "BANNED", "ESEA", "www.ESEA.net"); // TODO:better messages
		
		LogAction(client, -1, "[Warning][%s] Client is on the banlist", PREFIX);
		PrintToServer("[Warning][%s] %s is on the banlist", PREFIX, client)
	}
}

ESEA_DownloadBanlist()
{
	// Begin downloading the banlist in memory.
	Handle socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketSetOption(socket, ConcatenateCallbacks, 8192);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, ESEA_HOSTNAME, 80);
}

ESEA_ParseBan(char[] baninfo)
{
	if (baninfo[0] != '"')
		return;
		
	// Parse one line of the CSV banlist.
	char sAuthID[MAX_AUTHID_LENGTH];
	
	int length = FindCharInString(baninfo[3], '"') + 9;
	FormatEx(sAuthID, length, "STEAM_0:%s", baninfo[3]);
	
	SetTrieValue(g_hBanlist, sAuthID, 1);
}

public OnSocketConnected(Handle socket, any arg)
{
	char sRequest[256];
	
	FormatEx(sRequest,
		sizeof(sRequest),
		"GET /%s HTTP/1.0\r\nHost: %s\r\nCookie: viewed_welcome_page=1\r\nConnection: close\r\n\r\n",
		ESEA_QUERY,
		ESEA_HOSTNAME);
	
	SocketSend(socket, sRequest);
}

public OnSocketReceive(Handle socket, char[] data, const size, any arg)
{
	// Parse raw data as it's received.
	static bool bParsedHeader, bSplitData;
	static char sBuffer[256];
	int idx, length;
	
	if (!bParsedHeader)
	{
		// Parse and skip header data.
		if ((idx = StrContains(data, "\r\n\r\n")) == -1)
			return;
		
		idx += 4;
		
		// Skip the first line as well (column names).
		int offset = FindCharInString(data[idx], '\n');
		
		if (offset == -1)
			return;
		
		idx += offset + 1;
		bParsedHeader = true;
	}
	
	// Check if we had split data from the previous callback.
	if (bSplitData)
	{
		length = FindCharInString(data[idx], '\n');
		
		if (length == -1)
			return;
		
		length += 1;
		int maxsize = strlen(sBuffer) + length;
		
		if (maxsize <= sizeof(sBuffer))
		{
			Format(sBuffer, maxsize, "%s%s", sBuffer, data[idx]);
			ESEA_ParseBan(sBuffer);
		}
		
		idx += length;
		bSplitData = false;
	}
	
	// Parse incoming data.
	while (idx < size)
	{
		length = FindCharInString(data[idx], '\n');
		
		if (length == -1)
		{
			FormatEx(sBuffer, sizeof(sBuffer), "%s", data[idx]);
			
			bSplitData = true;
			return;
		}
		else if (length < sizeof(sBuffer))
		{
			length += 1;
			
			FormatEx(sBuffer, length, "%s", data[idx]);
			ESEA_ParseBan(sBuffer);
			
			idx += length;
		}
	}
}

public OnSocketDisconnected(Handle socket, any arg)
{
	CloseHandle(socket);
	
	// Check all players against the new list.
	char sAuthID[MAX_AUTHID_LENGTH];
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientAuthorized(i) && GetClientAuthId(i, AuthId_Steam2, sAuthID, sizeof(sAuthID), false))
		{
			OnClientAuthorized(i, sAuthID);
		}
	}
}

public OnSocketError(Handle socket, const errorType, const errorNum, any arg)
{
	CloseHandle(socket);
}
