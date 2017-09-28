/*
    SourceMod Anti-Cheat
    Copyright (C) 2011-2016 SMAC Development Team
    Copyright (C) 2007-2011 CodingDirect LLC
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#pragma semicolon 1

/* SM Includes */
#include <sourcemod>
#include <socket>
#include <smac>
#undef REQUIRE_PLUGIN
#tryinclude <updater>

/* Plugin Info */
public Plugin:myinfo =
{
	name = "SMAC EAC Global Banlist",
	author = SMAC_AUTHOR,
	description = "Kicks players on the EasyAntiCheat banlist",
	version = SMAC_VERSION,
	url = "www.EasyAntiCheat.net"
};

/* Globals */
#define UPDATE_URL	"http://smac.sx/updater/smac_eac_banlist.txt"

#define EAC_HOSTNAME	"easyanticheat.net"
#define EAC_QUERY		"check_guid.php?id="

enum BanType {
	Ban_None = 0,
	Ban_EAC,
	Ban_VAC
};

new Handle:g_hCvarKick = INVALID_HANDLE;
new Handle:g_hCvarVAC = INVALID_HANDLE;
new Handle:g_hBanlist = INVALID_HANDLE;
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
	g_hCvarKick = SMAC_CreateConVar("smac_eac_kick", "1", "Automatically kick players on the EAC banlist.", 0, true, 0.0, true, 1.0);
	g_hCvarVAC = SMAC_CreateConVar("smac_eac_vac", "0", "Check players for previous VAC bans.", 0, true, 0.0, true, 1.0);
	
	// Initialize.
	g_hBanlist = CreateTrie();
	
	if (g_bLateLoad)
	{
		decl String:sAuthID[MAX_AUTHID_LENGTH];
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientAuthorized(i) && GetClientAuthId(i, AuthId_Steam2, sAuthID, sizeof(sAuthID), false))
			{
				OnClientAuthorized(i, sAuthID);
			}
		}
	}

#if defined _updater_included
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
#endif
}

public OnLibraryAdded(const String:name[])
{
#if defined _updater_included
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
#endif
}

public OnClientAuthorized(client, const String:auth[])
{
	if (IsFakeClient(client))
		return;
	
	// Workaround for universe digit change on L4D+ engines.
	decl String:sAuthID[MAX_AUTHID_LENGTH];
	FormatEx(sAuthID, sizeof(sAuthID), "STEAM_0:%s", auth[8]);
	
	// Check the cache first.
	new BanType:banValue = Ban_None;

	if (GetTrieValue(g_hBanlist, sAuthID, banValue))
	{
		if (banValue == Ban_EAC || (banValue == Ban_VAC && GetConVarBool(g_hCvarVAC)))
		{
			if (GetConVarBool(g_hCvarKick) && SMAC_CheatDetected(client, Detection_GlobalBanned_EAC, INVALID_HANDLE) == Plugin_Continue)
			{
				KickClient(client, "%t", "SMAC_GlobalBanned", "EAC", "www.EasyAntiCheat.net");
			}
		}
		
		return;
	}
	
	// Clear a large cache to prevent slowdowns. Shouldn't reach this size anyway.
	if (GetTrieSize(g_hBanlist) > 50000)
		ClearTrie(g_hBanlist);
	
	// Check the banlist.
	new Handle:hPack = CreateDataPack();
	WritePackCell(hPack, GetClientUserId(client));
	WritePackString(hPack, sAuthID);
	
	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
	SocketSetArg(socket, hPack);
	SocketSetOption(socket, ConcatenateCallbacks, 4096);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, EAC_HOSTNAME, 80);
}

public OnSocketConnected(Handle:socket, any:hPack)
{
	decl String:sAuthID[MAX_AUTHID_LENGTH], String:sRequest[256];
	ResetPack(hPack);
	ReadPackCell(hPack);
	ReadPackString(hPack, sAuthID, sizeof(sAuthID));
	FormatEx(sRequest, sizeof(sRequest), "GET /%s%s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n", EAC_QUERY, sAuthID, EAC_HOSTNAME);
	SocketSend(socket, sRequest);
}

public OnSocketReceive(Handle:socket, String:data[], const size, any:hPack)
{
	decl String:sAuthID[MAX_AUTHID_LENGTH], idx;
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
	decl String:sBanChunks[4][64];
	if (ExplodeString(sBanInfo, "|", sBanChunks, sizeof(sBanChunks), sizeof(sBanChunks[])) != 4)
		return;
	
	// Check if it's a VAC ban.
	if (StrEqual(sBanChunks[1], "VAC Banned"))
	{
		SetTrieValue(g_hBanlist, sAuthID, Ban_VAC);
		
		if (!GetConVarBool(g_hCvarVAC))
			return;
	}
	else
	{
		SetTrieValue(g_hBanlist, sAuthID, Ban_EAC);
	}
	
	// Notify and log.
	ResetPack(hPack);
	
	new client = GetClientOfUserId(ReadPackCell(hPack));
	
	if (!IS_CLIENT(client) || SMAC_CheatDetected(client, Detection_GlobalBanned_EAC, INVALID_HANDLE) != Plugin_Continue)
		return;
	
	SMAC_PrintAdminNotice("%N | %s | EAC: %s", client, sBanChunks[0], sBanChunks[1]);
	
	if (GetConVarBool(g_hCvarKick))
	{
		SMAC_LogAction(client, "was kicked. (Reason: %s | Expires: %s)", sBanChunks[1], sBanChunks[3]);
		KickClient(client, "%t", "SMAC_GlobalBanned", "EAC", "www.EasyAntiCheat.net");
	}
	else
	{
		SMAC_LogAction(client, "is on the banlist. (Reason: %s | Expires: %s)", sBanChunks[1], sBanChunks[3]);
	}
}

public OnSocketDisconnected(Handle:socket, any:hPack)
{
	CloseHandle(hPack);
	CloseHandle(socket);
}

public OnSocketError(Handle:socket, const errorType, const errorNum, any:hPack)
{
	CloseHandle(hPack);
	CloseHandle(socket);
}
