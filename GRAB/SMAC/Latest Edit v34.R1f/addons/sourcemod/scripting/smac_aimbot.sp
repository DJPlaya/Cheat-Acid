#include <sourcemod>
#include <sdktools>
#include <smac>

public Plugin:myinfo =
{
	name = "SMAC: Aimbot Detector",
	author = SMAC_AUTHOR,
	description = "Analyzes clients to detect aimbots",
	version = SMAC_VERSION,
	url = SMAC_URL
};


#define AIM_ANGLE_CHANGE	45.0	// Max angle change that a player should snap
#define AIM_BAN_MIN			3		// Minimum number of detections before an auto-ban is allowed
#define AIM_MIN_DISTANCE	200.0	// Minimum distance acceptable for a detection.

new Handle:g_hCvarAimbotBan = INVALID_HANDLE;
new Handle:g_IgnoreWeapons = INVALID_HANDLE;

new Float:g_fEyeAngles[MAXPLAYERS+1][64][3];
new g_iEyeIndex[MAXPLAYERS+1];

new g_iAimDetections[MAXPLAYERS+1];
new g_iAimbotBan = 0;
new g_iMaxAngleHistory;

/* Plugin Functions */
public OnPluginStart()
{
	LoadTranslations("smac.phrases");
	g_hCvarAimbotBan = SMAC_CreateConVar("smac_aimbot_ban", "3", "Number of aimbot detections before a player is banned. Minimum allowed is 3. (0 = Never ban)", _, true, 0.0);
	OnSettingsChanged(g_hCvarAimbotBan, "", "");
	HookConVarChange(g_hCvarAimbotBan, OnSettingsChanged);
	if ((g_iMaxAngleHistory = TIME_TO_TICK(0.5)) > sizeof(g_fEyeAngles[]))
	{
		g_iMaxAngleHistory = sizeof(g_fEyeAngles[]);
	}
	g_IgnoreWeapons = CreateTrie();
	SetTrieValue(g_IgnoreWeapons, "weapon_knife", 1);
	HookEntityOutput("trigger_teleport", "OnEndTouch", Teleport_OnEndTouch);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
}

public OnClientPutInServer(client)
{
	if (IsClientNew(client))
	{
		g_iAimDetections[client] = 0;
		Aimbot_ClearAngles(client);
	}
}

public OnSettingsChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	new iNewValue = GetConVarInt(convar);
	
	if (iNewValue > 0 && iNewValue < AIM_BAN_MIN)
	{
		SetConVarInt(convar, AIM_BAN_MIN);
		return;
	}

	g_iAimbotBan = iNewValue;
}

public Teleport_OnEndTouch(const String:output[], caller, activator, Float:delay)
{
	/* A client is being teleported in the map. */
	if (IS_CLIENT(activator) && IsClientConnected(activator))
	{
		Aimbot_ClearAngles(activator);
		CreateTimer(0.1 + delay, Timer_ClearAngles, GetClientUserId(activator), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	
	if (IS_CLIENT(client))
	{
		Aimbot_ClearAngles(client);
		CreateTimer(0.1, Timer_ClearAngles, userid, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl String:sWeapon[32], dummy;
	GetEventString(event, "weapon", sWeapon, sizeof(sWeapon));
	
	if (GetTrieValue(g_IgnoreWeapons, sWeapon, dummy))
		return;
		
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if (IS_CLIENT(victim) && IS_CLIENT(attacker) && victim != attacker && IsClientInGame(victim) && IsClientInGame(attacker))
	{
		decl Float:vVictim[3], Float:vAttacker[3];
		GetClientAbsOrigin(victim, vVictim);
		GetClientAbsOrigin(attacker, vAttacker);
		
		if (GetVectorDistance(vVictim, vAttacker) >= AIM_MIN_DISTANCE)
		{
			Aimbot_AnalyzeAngles(attacker);
		}
	}
}

public Event_EntityKilled(Handle:event, const String:name[], bool:dontBroadcast)
{
	/* (OB Only) Inflictor support lets us ignore non-bullet weapons. */
	new victim = GetEventInt(event, "entindex_killed");
	new attacker = GetEventInt(event, "entindex_attacker");
	new inflictor = GetEventInt(event, "entindex_inflictor");
	
	if (IS_CLIENT(victim) && IS_CLIENT(attacker) && victim != attacker && attacker == inflictor && IsClientInGame(victim) && IsClientInGame(attacker))
	{
		decl String:sWeapon[32], dummy;
		GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
		
		if (GetTrieValue(g_IgnoreWeapons, sWeapon, dummy))
			return;
		
		decl Float:vVictim[3], Float:vAttacker[3];
		GetClientAbsOrigin(victim, vVictim);
		GetClientAbsOrigin(attacker, vAttacker);
		
		if (GetVectorDistance(vVictim, vAttacker) >= AIM_MIN_DISTANCE)
		{
			Aimbot_AnalyzeAngles(attacker);
		}
	}
}


public Action:Timer_ClearAngles(Handle:timer, any:userid)
{
	/* Delayed because the client's angles can sometimes "spin" after being teleported. */
	new client = GetClientOfUserId(userid);
	
	if (IS_CLIENT(client))
	{
		Aimbot_ClearAngles(client);
	}
	
	return Plugin_Stop;
}

public Action:Timer_DecreaseCount(Handle:timer, any:userid)
{
	/* Decrease the detection count by 1. */
	new client = GetClientOfUserId(userid);
	
	if (IS_CLIENT(client) && g_iAimDetections[client])
	{
		g_iAimDetections[client]--;
	}
	
	return Plugin_Stop;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	g_fEyeAngles[client][g_iEyeIndex[client]] = angles;

	if (++g_iEyeIndex[client] == g_iMaxAngleHistory)
	{
		g_iEyeIndex[client] = 0;
	}
		
	return Plugin_Continue;
}

Aimbot_AnalyzeAngles(client)
{
	/* Analyze the client to see if their angles snapped. */
	decl Float:vLastAngles[3], Float:vAngles[3], Float:fAngleDiff;
	new idx = g_iEyeIndex[client];
	
	for (new i = 0; i < g_iMaxAngleHistory; i++)
	{
		if (idx == g_iMaxAngleHistory)
		{
			idx = 0;
		}
			
		if (IsVectorZero(g_fEyeAngles[client][idx]))
		{
			break;
		}
		
		// Nothing to compare on the first iteration.
		if (i == 0)
		{
			vLastAngles = g_fEyeAngles[client][idx];
			idx++;
			continue;
		}
		
		vAngles = g_fEyeAngles[client][idx];
		fAngleDiff = GetVectorDistance(vLastAngles, vAngles);
		
		// If the difference is being reported higher than 180, get the 'real' value.
		if (fAngleDiff > 180)
		{
			fAngleDiff = FloatAbs(fAngleDiff - 360);
		}

		if (fAngleDiff > AIM_ANGLE_CHANGE)
		{
			Aimbot_Detected(client, fAngleDiff);
			break;
		}
		
		vLastAngles = vAngles;
		idx++;
	}
}

Aimbot_Detected(client, const Float:deviation)
{
	// Extra checks must be done here because of data coming from two events.
	if (IsFakeClient(client) || !IsPlayerAlive(client))
		return;
	decl String:sWeapon[32];
	GetClientWeapon(client, sWeapon, sizeof(sWeapon));
	
	new Handle:info = CreateKeyValues("");
	KvSetNum(info, "detection", g_iAimDetections[client]);
	KvSetFloat(info, "deviation", deviation);
	KvSetString(info, "weapon", sWeapon);
	
	if (SMAC_CheatDetected(client, Detection_Aimbot, info) == Plugin_Continue)
	{
		// Expire this detection after 10 minutes.
		CreateTimer(600.0, Timer_DecreaseCount, GetClientUserId(client));
		
		// Ignore the first detection as it's just as likely to be a false positive.
		if (++g_iAimDetections[client] > 1)
		{
			SMAC_PrintAdminNotice("%t", "SMAC_AimbotDetected", client, g_iAimDetections[client], deviation, sWeapon);
			SMAC_LogAction(client, "is suspected of using an aimbot. (Detection #%i | Deviation: %.0f° | Weapon: %s)", g_iAimDetections[client], deviation, sWeapon);
			
			if (g_iAimbotBan && g_iAimDetections[client] >= g_iAimbotBan)
			{
				SMAC_LogAction(client, "was banned for using an aimbot.");
				SMAC_Ban(client, "Aimbot Detected");
			}
		}
	}
	
	CloseHandle(info);
}

Aimbot_ClearAngles(client)
{
	/* Clear angle history and reset the index. */
	g_iEyeIndex[client] = 0;
	
	for (new i = 0; i < g_iMaxAngleHistory; i++)
	{
		ZeroVector(g_fEyeAngles[client][i]);
	}
}
