#include <sdktools>
#include <smac>

public Plugin:myinfo =
{
	name = "SMAC: Client Protection",
	author = SMAC_AUTHOR,
	description = "Blocks general client exploits",
	version = SMAC_VERSION,
	url = SMAC_URL
};

new Float:g_fTeamJoinTime[MAXPLAYERS+1][6];
new g_iNameChanges[MAXPLAYERS+1];
new g_iAchievements[MAXPLAYERS+1];
new bool:g_bMapStarted = false;

/* Plugin Functions */
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	g_bMapStarted = late;
	return APLRes_Success;
}

public OnPluginStart()
{
	LoadTranslations("smac.phrases");
	
	// Convars.
	HookUserMessage(GetUserMessageId("TextMsg"), Hook_TextMsg, true);
	
	HookEventEx("player_team", Event_PlayerTeam, EventHookMode_Pre);
	HookEvent("player_changename", Event_PlayerChangeName, EventHookMode_Post);
	CreateTimer(10.0, Timer_DecreaseCount, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	AddCommandListener(Command_Autobuy, "autobuy");

	// Check all clients.
	if (g_bMapStarted)
	{
		decl String:sReason[256];

		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsClientConnected(i) && !OnClientConnect(i, sReason, sizeof(sReason)))
			{
				KickClient(i, "%s", sReason);
			}
		}
	}
}

public OnMapStart()
{
	// Give time for players to connect before we start checking for spam.
	CreateTimer(20.0, Timer_MapStarted, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_MapStarted(Handle:timer)
{
	g_bMapStarted = true;
	return Plugin_Stop;
}

public OnMapEnd()
{
	g_bMapStarted = false;
}

public bool:OnClientConnect(client, String:rejectmsg[], size)
{
	if (IsFakeClient(client))
	{
		return true;
	}
	if (!IsClientNameValid(client))
	{
		FormatEx(rejectmsg, size, "%T", "SMAC_ChangeName", client);
		return false;
	}

	return true;
}

public OnClientPutInServer(client)
{
	if (IsClientNew(client))
	{
		g_iNameChanges[client] = 0;
		g_iAchievements[client] = 0;
	}
}

public OnClientSettingsChanged(client)
{
	if (!IsFakeClient(client) && !IsClientNameValid(client))
	{
		KickClient(client, "%t", "SMAC_ChangeName");
	}
}

public OnClientDisconnect_Post(client)
{
	for (new i = 0; i < sizeof(g_fTeamJoinTime[]); i++)
	{
		g_fTeamJoinTime[client][i] = 0.0;
	}
}

public Action:Hook_TextMsg(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	// Name spam notices will only be sent to the offending client.
	if (!reliable || playersNum != 1)
		return Plugin_Continue;
	
	// The message we are looking for is sent to chat.
	new destination = BfReadByte(bf);
	
	if (destination != 3)
		return Plugin_Continue;
	
	decl String:sBuffer[64];
	BfReadString(bf, sBuffer, sizeof(sBuffer));
	
	if (StrEqual(sBuffer, "#Name_change_limit_exceeded"))
	{
		new client = players[0];
		
		if (!IsFakeClient(client) && SMAC_CheatDetected(client, Detection_NameChangeSpam, INVALID_HANDLE) == Plugin_Continue)
		{
			SMAC_LogAction(client, "was kicked for name change spam.");
			KickClient(client, "%t", "SMAC_CommandSpamKick");
		}
	}
	
	return Plugin_Continue;
}

public Action:Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (dontBroadcast)
		return Plugin_Continue;
	
	// Don't broadcast team changes if they're being spammed.
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IS_CLIENT(client))
	{
		new Float:fGameTime = GetGameTime();
		new team = GetEventInt(event, "team");
		
		if (team < 0 || team >= sizeof(g_fTeamJoinTime[]))
			team = 0;
		
		if (g_fTeamJoinTime[client][team] > fGameTime)
		{
			SetEventBroadcast(event, true);
		}
		
		g_fTeamJoinTime[client][team] = fGameTime + 30.0;
	}
	
	return Plugin_Continue;
}

public Event_PlayerChangeName(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IS_CLIENT(client) && IsClientInGame(client) && !IsFakeClient(client) && ++g_iNameChanges[client] >= 5)
	{
		if (SMAC_CheatDetected(client, Detection_NameChangeSpam, INVALID_HANDLE) == Plugin_Continue)
		{
			SMAC_LogAction(client, "was kicked for name change spam.");
			KickClient(client, "%t", "SMAC_CommandSpamKick");
		}
		
		g_iNameChanges[client] = 0;
	}
}

public Action:Command_Autobuy(client, const String:command[], args)
{
	if (!IS_CLIENT(client))
		return Plugin_Continue;
	
	if (!IsClientInGame(client))
		return Plugin_Handled;

	decl String:sAutobuy[256], String:sArg[64];
	new i, t;
	
	GetClientInfo(client, "cl_autobuy", sAutobuy, sizeof(sAutobuy));
	
	if (strlen(sAutobuy) > 255)
	{
		return Plugin_Handled;
	}

	i = 0;
	t = BreakString(sAutobuy, sArg, sizeof(sArg));
	
	while (t != -1)
	{
		if (strlen(sArg) > 30)
		{
			return Plugin_Handled;
		}

		i += t;
		t = BreakString(sAutobuy[i], sArg, sizeof(sArg));
	}

	if (strlen(sArg) > 30)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action:Timer_DecreaseCount(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{if (g_iNameChanges[i])g_iNameChanges[i]--;}
	return Plugin_Continue;
}

bool:IsClientNameValid(client)
{
	decl String:sName[MAX_NAME_LENGTH], String:sChar;

	GetClientName(client, sName, sizeof(sName));
	new iSize = strlen(sName);

	if (iSize < 2 || sName[0] == '&' || IsCharSpace(sName[0]) || IsCharSpace(sName[iSize-1]))
	{
		return false;
	}

	for (new i = 0; i < iSize; i++)
	{
		sChar = sName[i];
		
		// Check unicode characters.
		new bytes = IsCharMB(sChar);
		
		if (bytes > 1)
		{
			if (!IsMBCharValid(sName[i], bytes))
			{
				return false;
			}
			
			i += bytes - 1;
		}
		else if (sChar < 32 || sChar == '%' || sChar == 0x7F)
		{
			return false;
		}
	}
	
	return true;
}

bool:IsMBCharValid(const String:mbchar[], numbytes)
{
	/*
	* A blacklist of unicode characters.
	* Mostly a variation of zero-width and spaces.
	*/
	new wchar = UTF8ToWChar(mbchar, numbytes);
	
	if (wchar == -1)
		return false;
	
	switch (wchar)
	{
		case
			0x00AD,
			0x05BF,
			0x0670,
			0x06E7,
			0x06E8,
			0x0711,
			0x0A51,
			0x0E31,
			0x0EB1,
			0x0EBB,
			0x0EBC,
			0x0F18,
			0x0F19,
			0x0F35,
			0x0F37,
			0x0F39,
			0x135F,
			0x18A9,
			0x20F0,
			0x2800,
			0x3000,
			0x3164,
			0xFB1E,
			0xFEFF,
			0xFFA0:
				return false;
	}
	
	if ((0x0080 <= wchar <= 0x00A0) ||
		(0x0300 <= wchar <= 0x036F) ||
		(0x0483 <= wchar <= 0x0487) ||
		(0x0591 <= wchar <= 0x05BD) ||
		(0x05C1 <= wchar <= 0x05C5) ||
		(0x0610 <= wchar <= 0x061A) ||
		(0x064B <= wchar <= 0x065F) ||
		(0x06D6 <= wchar <= 0x06DC) ||
		(0x06DF <= wchar <= 0x06E4) ||
		(0x06EA <= wchar <= 0x06ED) ||
		(0x0730 <= wchar <= 0x074A) ||
		(0x07A6 <= wchar <= 0x07B0) ||
		(0x07EB <= wchar <= 0x07F3) ||
		(0x0E34 <= wchar <= 0x0E3A) ||
		(0x0E47 <= wchar <= 0x0E4E) ||
		(0x0EB4 <= wchar <= 0x0EB9) ||
		(0x0EC8 <= wchar <= 0x0ECD) ||
		(0x0F71 <= wchar <= 0x0F7E) ||
		(0x0F80 <= wchar <= 0x0F87) ||
		(0x0F8D <= wchar <= 0x0F97) ||
		(0x115A <= wchar <= 0x1160) ||
		(0x11A3 <= wchar <= 0x11A7) ||
		(0x180B <= wchar <= 0x180F) ||
		(0x1DC0 <= wchar <= 0x1DCA) ||
		(0x1DFC <= wchar <= 0x1DFF) ||
		(0x2000 <= wchar <= 0x200F) ||
		(0x2028 <= wchar <= 0x202F) ||
		(0x205F <= wchar <= 0x206F) ||
		(0x302A <= wchar <= 0x302D) ||
		(0x3099 <= wchar <= 0x309A) ||
		(0xFE20 <= wchar <= 0xFE26) ||
		(0xFFF9 <= wchar <= 0xFFFF))
		return false;
	
	return true;
}

UTF8ToWChar(const String:mbchar[], numbytes)
{
	static const mask[] = { 0, 0x7F, 0x1F, 0x0F, 0x07, 0x03, 0x01 };
	
	if (numbytes > 6)
		return -1;
	
	// First byte minus length tag
	new wchar = (mbchar[0] & mask[numbytes]);
	
	for (new i = 1; i < numbytes; i++)
	{
		// Subsequent bytes must start with 10
		if ((mbchar[i] & 0xC0) != 0x80)
			return -1;
		
		wchar <<= 6; // 6 bits of data in each subsequent byte
		wchar |= (mbchar[i] & 0x3F);
	}
	
	return wchar;
}