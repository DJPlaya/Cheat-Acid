#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma newdecls required
#define M_PI 3.1415926535

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
native void SaurayCreateSmoke(int windowNumber, float ox, float oy, float oz);

bool visibilityMatrix[(MAXPLAYERS + 1) * (MAXPLAYERS + 1)] = {true, ...};
int rttMissCount[MAXPLAYERS + 1] = {0, ...};
bool playerBlind[MAXPLAYERS + 1] = {false, ...};
bool playerActive[MAXPLAYERS + 1] = {false, ...};
bool launchedOnce = false;
float serverFrameTime;
char mapName[256];

bool TDM = false;
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
	HookUserMessage(GetUserMessageId("ProcessSpottedEntityUpdate"), ObfuscateRadar, true); 
	HookEvent("round_start", RoundStartEvent);
	HookEvent("player_blind", PlayerFlashBanged, EventHookMode_Pre);
	HookEvent("smokegrenade_detonate", SmokeDetonate, EventHookMode_Pre);
	AddNormalSoundHook (SoundHook);
	AddTempEntHook("Shotgun Shot", TE_OnShotgunShot);
}

public void OnPluginEnd()
{
	UnhookUserMessage(GetUserMessageId("ProcessSpottedEntityUpdate"), ObfuscateRadar, true); 
	UnhookEvent ("round_start", RoundStartEvent);
	UnhookEvent ("player_blind", PlayerFlashBanged);
	UnhookEvent ("smokegrenade_detonate", SmokeDetonate);
	RemoveNormalSoundHook(SoundHook);
	RemoveTempEntHook("Shotgun Shot", TE_OnShotgunShot);
}

public Action ObfuscateRadar(UserMsg msg_id, Handle pb, const int[] players, int playersNum, bool reliable, bool init)
{
	int rpbCount = PbGetRepeatedFieldCount(pb, "entity_updates");
	for (int i = 0; i != rpbCount; i++)
	{
		Handle rpbAtI = PbReadRepeatedMessage(pb, "entity_updates", i);
		int oX = PbReadInt (rpbAtI, "origin_x") + (GetURandomInt() % 50 - 25); // Only fidget with lateral values... the vertical one is needed to display above/below hints in radar...
		int oY = PbReadInt (rpbAtI, "origin_y") + (GetURandomInt() % 50 - 25);
		PbSetInt (rpbAtI, "origin_x", oX);
		PbSetInt (rpbAtI, "origin_y", oY);
	}
	return Plugin_Continue;
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

public void PlayerFlashBanged(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	float blindDuration = GetEventFloat(event, "blind_duration");

	float tmpAngles[3], curEye[3], curLook[3], curRight[3], curUp[3], flashPosition[3], flashDir[3];
	GetClientEyePosition(client, curEye);
	GetClientEyeAngles(client, tmpAngles);
	GetAngleVectors (tmpAngles, curLook, curRight, curUp);
	GetEntPropVector(GetEventInt(event, "entityid"), Prop_Send, "m_vecOrigin", flashPosition);
	SubtractVectors (flashPosition, curEye, flashDir);
	NormalizeVector (flashDir, flashDir);
	float flashAngle = ArcCosine (GetVectorDotProduct (flashDir, curLook));
	
	// using https://counterstrike.fandom.com/wiki/Flashbang as a guide
	float totallyBlindDuration;
	if ( flashAngle < (53.0/180.0) * M_PI )
	{
		totallyBlindDuration = (1.88/4.87) * blindDuration;
	}
	else if ( flashAngle < (72.0/180.0) * M_PI )
	{
		totallyBlindDuration = (0.45/3.4) * blindDuration;
	}
	else if ( flashAngle < (101.0/180.0) * M_PI )
	{
		totallyBlindDuration = (0.08/1.95) * blindDuration;
	}
	else
	{
		totallyBlindDuration = (0.08/0.95) * blindDuration;
	}
	totallyBlindDuration -= 0.3;
	if ( totallyBlindDuration > 0.0 )
	{
		playerBlind[client] = true;
		CreateTimer(totallyBlindDuration, UnFlashPlayer, client, 0);
	}
}

public void SmokeDetonate(Event event, const char[] name, bool dontBroadcast)
{
	SaurayCreateSmoke(windowNum, GetEventFloat(event, "x"), GetEventFloat(event, "y"), GetEventFloat(event, "z"));
}

public Action UnFlashPlayer(Handle timer, int client)
{
	if (IsClientConnected(client) && IsClientInGame(client)) playerBlind[client] = false;
}

public Action MinuteLogger(Handle timer, int client)
{
	int playerCount = 0;
	for (int i = 1; i < MAXPLAYERS; i++)
		if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
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
		gunLengths.SetValue ("weapon_awp", 64.0);
		gunLengths.SetValue ("weapon_ssg08", 64.0);
		gunLengths.SetValue ("weapon_m4a1_silencer", 51.2);
		gunLengths.SetValue ("weapon_negev", 49.6);
		gunLengths.SetValue ("weapon_scar20", 49.6);
		gunLengths.SetValue ("weapon_g3sg1", 48.0);
		gunLengths.SetValue ("weapon_ak47", 41.6);
		gunLengths.SetValue ("weapon_sg556", 40.0);
		gunLengths.SetValue ("weapon_usp_silencer", 40.0);
		gunLengths.SetValue ("weapon_nova", 39.0);
		gunLengths.SetValue ("weapon_m249", 39.0);
		gunLengths.SetValue ("weapon_galilar", 38.0);
		gunLengths.SetValue ("weapon_xm1014", 38.0);
		gunLengths.SetValue ("weapon_m4a1", 37.0);
		gunLengths.SetValue ("weapon_elite", 37.0);
		gunLengths.SetValue ("weapon_mag7", 36.0);
		gunLengths.SetValue ("weapon_bizon", 36.0);
		gunLengths.SetValue ("weapon_sawedoff", 35.0);
		gunLengths.SetValue ("weapon_deagle", 35.0);
		gunLengths.SetValue ("weapon_ump45", 34.0);
		gunLengths.SetValue ("weapon_hkp2000", 33.0);
		gunLengths.SetValue ("weapon_zeus", 33.0);
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
	
	TDM = GetConVarInt(FindConVar("mp_teammates_are_enemies")) == 1;
	
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
			bool curViewerActive = IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i);
			bool canSeeEveryone = !curViewerActive || IsClientSourceTV(i) || GetClientTeam(i) == 1;
			if (canSeeEveryone || playerBlind[i])
			{
				for (int j = 1; j < MAXPLAYERS; j++)
					visibilityMatrix[j * (MAXPLAYERS + 1) + i] = canSeeEveryone ? true : false;
				visibilityMatrix[i * (MAXPLAYERS + 1) + i] = true;
			}
			else
			{
				for (int j = 1; j < MAXPLAYERS; j++)
				{
					bool curSubjectActive = IsClientConnected(j) && IsClientInGame(j) && IsPlayerAlive(j);
					if (i == j || !curSubjectActive || IsClientSourceTV(j) || GetClientTeam(j) == 1 || (!TDM && GetClientTeam(i) == GetClientTeam(j)))
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
		bool curPlayerActive = IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i);
		
		if (curPlayerActive)
		{
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
			
			int teamId = 0;
			if (!TDM)
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

	// Fix CSGO bad flag
	int fixedFlags = flags & ~(1 << 10);

	// Fake precaching
	char fixedSampleName[PLATFORM_MAX_PATH] = "*";
	StrCat(fixedSampleName, PLATFORM_MAX_PATH - 2, sample);
	AddToStringTable(FindStringTable("soundprecache"), fixedSampleName);

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
			EmitSoundToClient(clients[i], fixedSampleName, SOUND_FROM_WORLD, channel, level, fixedFlags, volume, pitch, _, newOrigin);
		}
		else
		{
			// Fixes "self footsteps too loud" bug
			float fixedVolume = volume;
			if (clients[i] == entity)
				fixedVolume = volume * 0.45;

			EmitSoundToClient(clients[i], fixedSampleName, entity, channel, level, fixedFlags, fixedVolume, pitch);
		}
	}
	return Plugin_Stop;
}

public Action TE_OnShotgunShot(const char[] te_name, const int[] clients, int numClients, float delay)
{
	float soundOrigin[3], newOrigin[3];
	TE_ReadVector("m_vecOrigin", soundOrigin);
	newOrigin[0] = soundOrigin[0] + float(GetURandomInt() % 200 - 100);
	newOrigin[1] = soundOrigin[1] + float(GetURandomInt() % 200 - 100);
	newOrigin[2] = soundOrigin[2] + float(GetURandomInt() % 200 - 100);
	TE_WriteVector("m_vecOrigin", newOrigin);
	return Plugin_Continue;
}

public void OnClientPutInServer(int i)
{
	SDKHook(i, SDKHook_SetTransmit, VisCheckAction);
}

public void OnClientDisconnect(int i)
{
	SDKUnhook(i, SDKHook_SetTransmit, VisCheckAction);
	playerBlind[i] = false;
	rttMissCount[i] = 0;
}

public bool IsVisible(int viewer, int subject)
{
	return visibilityMatrix[subject * (MAXPLAYERS + 1) + viewer];
}

public Action VisCheckAction(int subject, int viewer)
{
	bool visDecision = IsVisible(viewer, subject);

	bool viewerGood = IsClientConnected(viewer) && IsClientInGame(viewer) && IsPlayerAlive(viewer) && (!IsClientSourceTV(viewer)) && (GetClientTeam(viewer) != 1);
	bool subjectGood = IsClientConnected(subject) && IsClientInGame(subject) && IsPlayerAlive(subject) && (!IsClientSourceTV(subject)) && (GetClientTeam(subject) != 1);
	if (viewerGood && subjectGood && viewer != subject && GetClientTeam(viewer) != GetClientTeam(subject))
	{
		if (visDecision) transmitSent++;
		transmitTotalDecisions++;
	}

	return visDecision ? Plugin_Continue : Plugin_Handled;
}