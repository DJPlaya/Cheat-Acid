
#include <sourcemod>
#include <sdkhooks>
#include <smac>
/* Plugin Info */
public Plugin:myinfo =
{
	name = "SMAC: Anti-Flash",
	author = SMAC_AUTHOR,
	description = "Prevents anti-flashbang cheats from working",
	version = SMAC_VERSION,
	url = SMAC_URL
};


new Float:g_fFlashedUntil[MAXPLAYERS+1];
new bool:g_bFlashHooked = false;

public OnPluginStart()
{
	// Hooks.
	HookEvent("player_blind", Event_PlayerBlind, EventHookMode_Post);
}


public OnClientPutInServer(client)
{
	if (g_bFlashHooked)
	{
		SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	}
}

public OnClientDisconnect(client)
{
	g_fFlashedUntil[client] = 0.0;
}

public Event_PlayerBlind(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IS_CLIENT(client) && !IsFakeClient(client))
	{
		new Float:alpha = GetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha");
		
		if (alpha < 255.0)
		{
			// New flashes override previous ones.
			g_fFlashedUntil[client] = 0.0;
			return;
		}
		
		new Float:duration = GetEntPropFloat(client, Prop_Send, "m_flFlashDuration");
		
		if (duration > 2.9)
		{
			g_fFlashedUntil[client] = GetGameTime() + duration - 2.9;
		}
		else
		{
			g_fFlashedUntil[client] = GetGameTime() + duration * 0.1;
		}
		
		// Fade in the flash.
		SendMsgFadeUser(client, RoundToNearest(duration * 1000.0));
		
		if (!g_bFlashHooked)
		{
			AntiFlash_HookAll();
		}
			
		CreateTimer(duration, Timer_FlashEnded);
	}
}

public Action:Timer_FlashEnded(Handle:timer)
{
	/* Check if there are any other flashes being processed. Otherwise, we can unhook. */
	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_fFlashedUntil[i])
		{
			return Plugin_Stop;
		}
	}
	
	if (g_bFlashHooked)
	{
		AntiFlash_UnhookAll();
	}
	
	return Plugin_Stop;
}

public Action:Hook_SetTransmit(entity, client)
{
	/* Don't send client data to players that are fully blind. */
	if (g_fFlashedUntil[client])
	{
		if (g_fFlashedUntil[client] > GetGameTime())
			return (entity == client) ? Plugin_Continue : Plugin_Handled;
		
		// Fade out the flash.
		SendMsgFadeUser(client, 0);
		g_fFlashedUntil[client] = 0.0;
	}
	
	return Plugin_Continue;
}

AntiFlash_HookAll()
{
	g_bFlashHooked = true;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			SDKHook(i, SDKHook_SetTransmit, Hook_SetTransmit);
		}
	}
}

AntiFlash_UnhookAll()
{
	g_bFlashHooked = false;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			SDKUnhook(i, SDKHook_SetTransmit, Hook_SetTransmit);
		}
	}
}

SendMsgFadeUser(client, duration)
{
	static UserMsg:msgFadeUser = INVALID_MESSAGE_ID;
	
	if (msgFadeUser == INVALID_MESSAGE_ID)
		msgFadeUser = GetUserMessageId("Fade");
	
	decl players[1];
	players[0] = client;
	
	new Handle:bf = StartMessageEx(msgFadeUser, players, 1);
	BfWriteShort(bf, (duration > 0) ? duration : 50); // duration
	BfWriteShort(bf, (duration > 0) ? 1000 : 0); // hold time
	BfWriteShort(bf, FFADE_IN|FFADE_PURGE);
	BfWriteByte(bf, 255); // r
	BfWriteByte(bf, 255); // g
	BfWriteByte(bf, 255); // b
	BfWriteByte(bf, 255); // a
	
	EndMessage();
}
