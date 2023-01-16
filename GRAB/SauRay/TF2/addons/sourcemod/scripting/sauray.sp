#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required

public Plugin myinfo =
{
	name =			"sauray",
	author =		"Baktash Abdollah-shamshir-saz",
	description =	"SauRay(TM) Anti-wallhack",
	version =		"1.0.0.0",
	url =			"http://www.sauray.tech"
};

native void SauraySetDebug(int windowNumber, int width, int height);
native void SaurayStart(int windowNumber, int maxPlayers, int playerTraceRes, int temporalHistoryAmount);
native void SaurayFeedMap(int windowNumber, const char[] mapName);
native int SaurayRemovePlayer(int windowNumber, int player_id);
native int SauraySetPlayer(int player_id, int team_id, float weaponLen,
						   float absmin_x, float absmin_y, float absmin_z,
						   float absmax_x, float absmax_y, float absmax_z, 
						   float e1x, float e1y, float e1z, 
						   float e2x, float e2y, float e2z, 
						   float look1x, float look1y, float look1z, 
						   float up1x, float up1y, float up1z, 
						   float look2x, float look2y, float look2z, 
						   float up2x, float up2y, float up2z, 
						   float yfov, float whr);
native int SaurayCanSee(int windowNumber, int viewer, int subject);
native int SaurayThreadStart(int windowNumber);
native int SaurayThreadJoin(int windowNumber);
native void SaurayResetRound(int windowNumber);

bool visibilityMatrix[(MAXPLAYERS + 1) * (MAXPLAYERS + 1)] = {true, ...};
int rttMissCount[MAXPLAYERS + 1] = {0, ...};
bool playerActive[MAXPLAYERS + 1] = {false, ...};
bool launchedOnce = false;
float serverFrameTime;
char mapName[256];

ConVar cvar_window_num = null;
ConVar cvar_is_debug = null;
ConVar cvar_debug_w = null;
ConVar cvar_debug_h = null;
ConVar cvar_trace_res = null;
ConVar cvar_temporal_history = null;
ConVar cvar_highping_allowed;
bool highPingAllowed = false;
int windowNum = 1;
bool isDebug = true;
int debugWidth = 1280;
int debugHeight = 1280;
int traceRes = 640;
int temporalHistory = 2;
StringMap gunLengths = null;

bool configsLoaded = false;
bool mapStarted = false;
bool resetRound = false;

// Performance logging
int transmitSent = 0;
int transmitTotalDecisions = 0;
Handle minuteLoggerHandle = null;

enum struct lastSnapshot
{
	float lastOrigX;
	float lastOrigY;
	float lastOrigZ;
	float lastLookX;
	float lastLookY;
	float lastLookZ;
	float lastUpX;
	float lastUpY;
	float lastUpZ;
}

lastSnapshot playerSnapshots[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	return APLRes_Success;
}

public void highPingPermChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	highPingAllowed = StrEqual(newValue, "1");
}

public void OnPluginStart()
{
	cvar_highping_allowed = CreateConVar("cvar_highping_allowed", "0");
	cvar_highping_allowed.AddChangeHook(highPingPermChanged);
	HookEvent("teamplay_round_start", RoundStartEvent);
	AddNormalSoundHook (SoundHook);
}

public void OnPluginEnd()
{
	UnhookEvent ("teamplay_round_start", RoundStartEvent);
	RemoveNormalSoundHook(SoundHook);
}

public Action RoundStartEvent(Event event, const char[] name, bool dontBroadcast)
{
	resetRound = true;
}

stock float fmax(float a, float b)
{
	return a > b ? a : b;
} 

stock float fmin(float a, float b)
{
	return a < b ? a : b;
}

public Action MinuteLogger(Handle timer, int client)
{
	int playerCount = 0;
	for (int i = 1; i < MAXPLAYERS; i++)
		if (i <= MaxClients && IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
			playerCount++;
	
	LogToFile ("playerStats.txt", "player count: %d, transmitSent: %d, transmitTotalDecisions: %d", playerCount, transmitSent, transmitTotalDecisions);
	transmitSent = 0;
	transmitTotalDecisions = 0;
}

public void OnMapStart()
{
	if ( gunLengths == null )
	{
		gunLengths = new StringMap();
		gunLengths.SetValue ("tf_weapon_sniperrifle", 64.0);
		gunLengths.SetValue ("tf_weapon_flamethrower", 45.0);
		gunLengths.SetValue ("tf_weapon_medigun", 45.0);
		gunLengths.SetValue ("tf_weapon_pipebomblauncher", 45.0);
		gunLengths.SetValue ("tf_weapon_grenadelauncher", 45.0);
		gunLengths.SetValue ("tf_weapon_rocketlauncher", 45.0);
		gunLengths.SetValue ("tf_weapon_particle_cannon", 45.0);
		gunLengths.SetValue ("tf_weapon_bat_wood", 40.0);
		gunLengths.SetValue ("tf_weapon_bat_fish", 40.0);
		gunLengths.SetValue ("tf_weapon_bat_giftwrap", 40.0);
		gunLengths.SetValue ("tf_weapon_pep_brawler_blaster", 35.0);
		gunLengths.SetValue ("tf_weapon_handgun_scout_primary", 33.0);
		gunLengths.SetValue ("tf_weapon_scattergun", 33.0);
		gunLengths.SetValue ("tf_weapon_soda_popper", 33.0);
		gunLengths.SetValue ("tf_weapon_shotgun", 33.0);
	}
	GetCurrentMap(mapName, sizeof(mapName));
	serverFrameTime = GetTickInterval();

	cvar_window_num = CreateConVar("sauray_window_num", "1", "SauRay window number");
	cvar_is_debug = CreateConVar("sauray_is_debug", "1", "SauRay debug mode flag");
	cvar_debug_w = CreateConVar("sauray_debug_w", "1280", "SauRay debug width");
	cvar_debug_h = CreateConVar("sauray_debug_h", "1280", "SauRay debug height");
	cvar_trace_res = CreateConVar("sauray_trace_res", "640", "SauRay trace resolution");
	cvar_temporal_history = CreateConVar("sauray_temporal_history", "2", "SauRay temporal history");

	char configName[256];
	GetCommandLineParam("+sauray_config_file", configName, sizeof(configName), "sauray");
	AutoExecConfig(true, configName);

	mapStarted = false;

	if (minuteLoggerHandle)
	{
		CloseHandle(minuteLoggerHandle);
		minuteLoggerHandle = null;
	}
	minuteLoggerHandle = CreateTimer(60.0, MinuteLogger, _, TIMER_REPEAT);
}

public void OnConfigsExecuted()
{
	cvar_window_num = FindConVar("sauray_window_num");
	cvar_is_debug = FindConVar("sauray_is_debug");
	cvar_debug_w = FindConVar("sauray_debug_w");
	cvar_debug_h = FindConVar("sauray_debug_h");
	cvar_trace_res = FindConVar("sauray_trace_res");
	cvar_temporal_history = FindConVar("sauray_temporal_history");
	
	windowNum = GetConVarInt(cvar_window_num);
	isDebug = GetConVarBool(cvar_is_debug);
	debugWidth = GetConVarInt(cvar_debug_w);
	debugHeight = GetConVarInt(cvar_debug_h);
	traceRes = GetConVarInt(cvar_trace_res);
	temporalHistory = GetConVarInt(cvar_temporal_history);
	
	configsLoaded = true;
}

public void OnGameFrame()
{
	if (!configsLoaded) return ;
	
	if (configsLoaded && !mapStarted)
	{
		if (launchedOnce) SaurayThreadJoin(windowNum);
		launchedOnce = false;
		
		if (isDebug) SauraySetDebug(windowNum, debugWidth, debugHeight);
		SaurayStart(windowNum, MAXPLAYERS, traceRes, temporalHistory);
		SaurayFeedMap(windowNum, mapName);

		for (int i = 1; i != MAXPLAYERS + 1; i++)
			playerActive[i] = false;
		for (int i = 1; i != (MAXPLAYERS + 1) * (MAXPLAYERS + 1); i++)
			visibilityMatrix[i] = true;

		mapStarted = true;
	}
	
	if (launchedOnce)
	{
		SaurayThreadJoin(windowNum);
		if (resetRound)
		{
			SaurayResetRound(windowNum);
			resetRound = false;
		}
		for (int i = 1; i < MAXPLAYERS; i++)
		{
			bool curViewerActive = (i <= MaxClients) && IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i);
			bool canSeeEveryone = !curViewerActive || IsClientSourceTV(i) || GetClientTeam(i) == 1;
			if (canSeeEveryone)
			{
				for (int j = 1; j < MAXPLAYERS; j++)
					visibilityMatrix[j * (MAXPLAYERS + 1) + i] = canSeeEveryone ? true : false;
				visibilityMatrix[i * (MAXPLAYERS + 1) + i] = true;
			}
			else
			{
				for (int j = 1; j < MAXPLAYERS; j++)
				{
					bool curSubjectActive = (j <= MaxClients) && IsClientConnected(j) && IsClientInGame(j) && IsPlayerAlive(j);
					if (i == j || !curSubjectActive || IsClientSourceTV(j) || GetClientTeam(j) == 1 || GetClientTeam(i) == GetClientTeam(j))
						visibilityMatrix[j * (MAXPLAYERS + 1) + i] = true;
					else
						visibilityMatrix[j * (MAXPLAYERS + 1) + i] = SaurayCanSee (windowNum, i - 1, j - 1) > 0 ? true : false;
				}
			}
		}
	}
	float absMin[3], absMax[3];
	float aabbMin[3], aabbMax[3];
	float lastEye[3], curEye[3], futEye[3], curFoot[3];
	float lastLook[3], curLook[3], lookDelta[3], futLook[3];
	float lastUp[3], curUp[3], upDelta[3], futUp[3];
	float lastVelocity[3], curVelocity[3];
	
	for (int i = 1; i < MAXPLAYERS; i++)
	{
		bool curPlayerActive = (i <= MaxClients) && IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i);
		
		if (curPlayerActive)
		{
			// Minigun always transmits for some reason.
			// The following couple of code blocks prevent this.
			// Fixes are thanks to Mikusch's deathrun plugin.

			//-------------------------------------
			// Force player's items to not transmit
			for (int slot = 0; slot <= 10; slot++)
			{
				int item =  GetPlayerWeaponSlot(i, slot);
				if (IsValidEntity(item))
					SetEdictFlags(item, (GetEdictFlags(item) & ~FL_EDICT_ALWAYS));
			}
			
			// Force disguise weapon to not transmit
			int disguiseWeapon = GetEntPropEnt(i, Prop_Send, "m_hDisguiseWeapon");
			if (IsValidEntity(disguiseWeapon))
				SetEdictFlags(disguiseWeapon, (GetEdictFlags(disguiseWeapon) & ~FL_EDICT_ALWAYS));
			//-------------------------------------

			bool playerFake = IsFakeClient(i);
			float playerLatency = 0.03;
			if (!playerFake) playerLatency = GetClientLatency(i, NetFlow_Both);

			if ( !highPingAllowed && !playerFake && playerLatency > 0.128 )
			{
				rttMissCount[i]++;
				if ( rttMissCount[i] % 100 == 0 ) PrintCenterText (i, "You need an RTT below 128ms. Warning: %d/5", (rttMissCount[i] / 100) + 1);
				if (rttMissCount[i] == 500)
				{
					KickClient (i, "You need a RTT below 128ms");
					rttMissCount[i] = 0;
				}
			}
			else
				rttMissCount[i] = 0;
			
			char weaponName[50];
			float heldWeaponLen = 32.0;
			GetClientWeapon(i, weaponName, 50);
			if ( gunLengths && !gunLengths.GetValue (weaponName, heldWeaponLen) ) heldWeaponLen = 32.0;

			GetClientEyePosition(i, curEye);
			GetClientAbsOrigin(i, curFoot);
			float tmpAngles[3], curRight[3];
			GetClientEyeAngles(i, tmpAngles);
			GetAngleVectors (tmpAngles, curLook, curRight, curUp);

			if (!playerActive[i])
			{
				playerSnapshots[i].lastOrigX = curEye[0];
				playerSnapshots[i].lastOrigY = curEye[1];
				playerSnapshots[i].lastOrigZ = curEye[2];
				playerSnapshots[i].lastLookX = curLook[0];
				playerSnapshots[i].lastLookY = curLook[1];
				playerSnapshots[i].lastLookZ = curLook[2];
				playerSnapshots[i].lastUpX = curUp[0];
				playerSnapshots[i].lastUpY = curUp[1];
				playerSnapshots[i].lastUpZ = curUp[2];
			}

			lastEye[0] = playerSnapshots[i].lastOrigX;
			lastEye[1] = playerSnapshots[i].lastOrigY;
			lastEye[2] = playerSnapshots[i].lastOrigZ;
			lastLook[0] = playerSnapshots[i].lastLookX;
			lastLook[1] = playerSnapshots[i].lastLookY;
			lastLook[2] = playerSnapshots[i].lastLookZ;
			lastUp[0] = playerSnapshots[i].lastUpX;
			lastUp[1] = playerSnapshots[i].lastUpY;
			lastUp[2] = playerSnapshots[i].lastUpZ;

			GetEntPropVector(i, Prop_Data, "m_vecAbsVelocity", curVelocity);

			SubtractVectors(curEye, lastEye, lastVelocity);

			float curSpeedSq = GetVectorDotProduct(curVelocity,curVelocity);
			float lastSpeedSq = GetVectorDotProduct(lastVelocity,lastVelocity);
			float speedScaler = 1.0;
			
			if ( curSpeedSq > 0.0 && lastSpeedSq > curSpeedSq ) speedScaler = SquareRoot (lastSpeedSq / curSpeedSq);

			ScaleVector (curVelocity, speedScaler * serverFrameTime * 10.0);
			
			AddVectors (curEye, curVelocity, futEye);
			Handle traceHandle = TR_TraceRayEx(curEye, futEye, MASK_SHOT, RayType_EndPoint); // Make sure future position doesn't end up inside the wall
			if ( TR_DidHit(traceHandle) )
			{
				float curVelocitySmall[3];
				TR_GetEndPosition(futEye, traceHandle);
				curVelocitySmall[0] = curVelocity[0];
				curVelocitySmall[1] = curVelocity[1];
				curVelocitySmall[2] = curVelocity[2];
				NormalizeVector (curVelocitySmall, curVelocitySmall);
				SubtractVectors(futEye, curVelocitySmall, futEye);
			}
			CloseHandle(traceHandle);
			
			SubtractVectors(curLook, lastLook, lookDelta);
			AddVectors (curLook, lookDelta, futLook);
			SubtractVectors(curUp, lastUp, upDelta);
			AddVectors (curUp, upDelta, futUp);

			GetClientMins(i, aabbMin);
			GetClientMaxs(i, aabbMax);
			AddVectors (curFoot, aabbMin, absMin);
			AddVectors (curFoot, aabbMax, absMax);
			absMin[0] -= 2.0;
			absMin[1] -= 2.0;
			absMax[0] += 2.0;
			absMax[1] += 2.0;
			
			int teamId;
			if ( GetClientTeam(i) == 2 )
				teamId = 1;
			else
				teamId = 2;

			SauraySetPlayer(i - 1, teamId, heldWeaponLen,
							absMin[0], absMin[1], absMin[2],
							absMax[0], absMax[1], absMax[2],
							curEye[0], curEye[1], curEye[2],
							futEye[0], futEye[1], futEye[2],
							curLook[0], curLook[1], curLook[2],
							curUp[0], curUp[1], curUp[2],
							futLook[0], futLook[1], futLook[2],
							futUp[0], futUp[1], futUp[2],
							106.0, (playerLatency > 0.128 && highPingAllowed) ? 1.8 : 1.7777778); // Signal to do a 360 check in shader

			playerSnapshots[i].lastOrigX = curEye[0];
			playerSnapshots[i].lastOrigY = curEye[1];
			playerSnapshots[i].lastOrigZ = curEye[2];
			playerSnapshots[i].lastLookX = curLook[0];
			playerSnapshots[i].lastLookY = curLook[1];
			playerSnapshots[i].lastLookZ = curLook[2];
			playerSnapshots[i].lastUpX = curUp[0];
			playerSnapshots[i].lastUpY = curUp[1];
			playerSnapshots[i].lastUpZ = curUp[2];
		}
		else
		{
			if (playerActive[i])
			{
				SaurayRemovePlayer(windowNum, i - 1);
			}
			rttMissCount[i] = 0;
		}
		playerActive[i] = curPlayerActive;
	}
	
	SaurayThreadStart(windowNum);
	launchedOnce = true;
}

public Action SoundHook(int clients[MAXPLAYERS], int& numClients, char sample[PLATFORM_MAX_PATH], int& entity, int& channel, float& volume, int& level, int& pitch, int& flags, char soundEntry[PLATFORM_MAX_PATH], int& seed)
{
	if (entity < 1 || entity > MaxClients)
		return Plugin_Continue;

	float soundOrigin[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", soundOrigin);

	for (int i = 0; i < numClients; i++)
	{
		if (!IsVisible(clients[i], entity))
		{
			float listenerFootPos[3], diffVec[3], newOrigin[3];
			float diffLen;
			GetClientAbsOrigin(clients[i], listenerFootPos);
			SubtractVectors (listenerFootPos, soundOrigin, diffVec);
			diffLen = fmax (GetVectorLength(diffVec) * 0.5, 100.0);
			newOrigin[0] = soundOrigin[0] + float(GetURandomInt() % RoundFloat (diffLen) - RoundFloat (diffLen/2.0));
			newOrigin[1] = soundOrigin[1] + float(GetURandomInt() % RoundFloat (diffLen) - RoundFloat (diffLen/2.0));
			newOrigin[2] = soundOrigin[2] + float(GetURandomInt() % RoundFloat (diffLen) - RoundFloat (diffLen/2.0));
			EmitSoundToClient(clients[i], sample, SOUND_FROM_WORLD, channel, level, flags, volume, pitch, _, newOrigin);
		}
		else
		{
			// Fixes "self footsteps too loud" bug
			float fixedVolume = volume;
			if (clients[i] == entity)
				fixedVolume = volume * 0.45;

			EmitSoundToClient(clients[i], sample, entity, channel, level, flags, fixedVolume, pitch);
		}
	}
	return Plugin_Stop;
}

public void OnClientPutInServer(int i)
{
	SDKHook(i, SDKHook_SetTransmit, VisCheckAction);
}

public void OnClientDisconnect(int i)
{
	SDKUnhook(i, SDKHook_SetTransmit, VisCheckAction);
	rttMissCount[i] = 0;
}

public bool IsVisible(int viewer, int subject)
{
	return visibilityMatrix[subject * (MAXPLAYERS + 1) + viewer];
}

public Action VisCheckAction(int subject, int viewer)
{
	bool visDecision = IsVisible(viewer, subject);

	bool viewerGood = (viewer <= MaxClients) && IsClientConnected(viewer) && IsClientInGame(viewer) && IsPlayerAlive(viewer) && (!IsClientSourceTV(viewer)) && (GetClientTeam(viewer) != 1);
	bool subjectGood = (subject <= MaxClients) && IsClientConnected(subject) && IsClientInGame(subject) && IsPlayerAlive(subject) && (!IsClientSourceTV(subject)) && (GetClientTeam(subject) != 1);
	if (viewerGood && subjectGood && viewer != subject && GetClientTeam(viewer) != GetClientTeam(subject))
	{
		if (visDecision) transmitSent++;
		transmitTotalDecisions++;
	}

	return visDecision ? Plugin_Continue : Plugin_Handled;
}