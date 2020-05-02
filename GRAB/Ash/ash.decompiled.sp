/*
** ATTENTION
** THE PRODUCED CODE, IS NOT ABLE TO COMPILE!
** THE DECOMPILER JUST TRIES TO GIVE YOU A POSSIBILITY
** TO LOOK HOW A PLUGIN DOES IT'S JOB AND LOOK FOR
** POSSIBLE MALICIOUS CODE.
**
** ALL CONVERSIONS ARE WRONG! AT EXAMPLE:
** SetEntityRenderFx(client, RenderFx 0);  →  SetEntityRenderFx(client, view_as<RenderFx>0);  →  SetEntityRenderFx(client, RENDERFX_NONE);
*/

 PlVers __version = 5;
 float NULL_VECTOR[3];
 char NULL_STRING[1];
 Extension __ext_core = 72;
 int MaxClients;
 Extension __ext_sdktools = 2488;
public Plugin myinfo =
{
	name = "Anti-StrafeHack",
	description = "Based on BASH. Not BASH.",
	author = "ici (Thanks to blacky)",
	version = "1.65",
	url = "http://steamcommunity.com/id/1ci"
};
 int g_Tick[66];
 int g_LastTurnDir[66];
 int g_LastTurnTime[66];
 bool g_bTurned[66][2];
 bool g_bOnGround[66];
 bool g_bOldOnGround[66];
 bool g_bWalking[66] =
{
	1, ...
}
 bool g_bOldWalking[66];
 bool g_bPreventInvalidMovSpam[66];
 int g_TotalStrafes[66];
 int g_GoodStrafes[66];
 int g_PerfectStrafes[66];
 char g_sMapName[16];
 char g_sLogFile[64];
 Handle gH_Logger;
 char g_sAPIKey[16];
 Handle gH_Cvar_APIKey;
 Handle gH_Database;
 Handle gH_Cvar_Database_Driver;
 int g_Frames[66][40][2];
 int g_CurrentFrame[66];
 int g_LastMoveDir[66];
 int g_LastMoveTime[66];
 int g_TotalSync[66];
 int g_GoodSync[66][3];
 int g_TimerTotalSync[66];
 int g_TimerGoodSync[66];
 int g_FramesSW[66][40][2];
 int g_CurrentFrameSW[66];
 int g_LastMoveDirSW[66];
 int g_LastMoveTimeSW[66];
 int g_TotalSyncSW[66];
 int g_GoodSyncSW[66][3];
 int g_TimerTotalSyncSW[66];
 int g_TimerGoodSyncSW[66];
 int g_TimerTotalSyncHSW[66];
 int g_TimerGoodSyncHSW[66];
 int g_CurrentFrameKeysAD[66];
 int g_CurrentFrameKeysWS[66];
 int g_AdminMenuPage[66] =
{
	1, ...
}
 int g_AdminSelectedUserID[66];
 bool g_bPrintAnalysis[66];
 bool g_bDebugStrafes[66];
 bool g_bCheckSync[66];
 bool g_bPrintAnalysisSW[66];
 bool g_bDebugStrafesSW[66];
 bool g_bCheckSyncSW[66];
 bool g_bDebugKeysHoldtimeAD[66];
 bool g_bDebugKeysHoldtimeWS[66];
 bool g_bConsoleOutput[66];
 bool g_bPrintAngleDiff[66];
 bool g_bCheckAngleDiff[66];
 bool g_bIsDebugOnAnalysis;
 bool g_bIsDebugOnStrafes;
 bool g_bIsDebugOnAnalysisSW;
 bool g_bIsDebugOnStrafesSW;
 bool g_bIsDebugOnSync;
 bool g_bIsDebugOnKeysAD;
 bool g_bIsDebugOnKeysWS;
 bool g_bIsDebugOnAdv;
 Handle gH_TimerTopMsg[66];
 bool g_bBlockAngleCheck[66];
public int __ext_core_SetNTVOptional()
{
	MarkNativeAsOptional("GetFeatureStatus");
	MarkNativeAsOptional("RequireFeature");
	MarkNativeAsOptional("AddCommandListener");
	MarkNativeAsOptional("RemoveCommandListener");
	MarkNativeAsOptional("BfWriteBool");
	MarkNativeAsOptional("BfWriteByte");
	MarkNativeAsOptional("BfWriteChar");
	MarkNativeAsOptional("BfWriteShort");
	MarkNativeAsOptional("BfWriteWord");
	MarkNativeAsOptional("BfWriteNum");
	MarkNativeAsOptional("BfWriteFloat");
	MarkNativeAsOptional("BfWriteString");
	MarkNativeAsOptional("BfWriteEnt");
	MarkNativeAsOptional("BfWriteAngle");
	MarkNativeAsOptional("BfWriteCoord");
	MarkNativeAsOptional("BfWriteVecCoord");
	MarkNativeAsOptional("BfWriteVecNormal");
	MarkNativeAsOptional("BfWriteAngles");
	MarkNativeAsOptional("BfReadBool");
	MarkNativeAsOptional("BfReadByte");
	MarkNativeAsOptional("BfReadChar");
	MarkNativeAsOptional("BfReadShort");
	MarkNativeAsOptional("BfReadWord");
	MarkNativeAsOptional("BfReadNum");
	MarkNativeAsOptional("BfReadFloat");
	MarkNativeAsOptional("BfReadString");
	MarkNativeAsOptional("BfReadEntity");
	MarkNativeAsOptional("BfReadAngle");
	MarkNativeAsOptional("BfReadCoord");
	MarkNativeAsOptional("BfReadVecCoord");
	MarkNativeAsOptional("BfReadVecNormal");
	MarkNativeAsOptional("BfReadAngles");
	MarkNativeAsOptional("BfGetNumBytesLeft");
	MarkNativeAsOptional("BfWrite.WriteBool");
	MarkNativeAsOptional("BfWrite.WriteByte");
	MarkNativeAsOptional("BfWrite.WriteChar");
	MarkNativeAsOptional("BfWrite.WriteShort");
	MarkNativeAsOptional("BfWrite.WriteWord");
	MarkNativeAsOptional("BfWrite.WriteNum");
	MarkNativeAsOptional("BfWrite.WriteFloat");
	MarkNativeAsOptional("BfWrite.WriteString");
	MarkNativeAsOptional("BfWrite.WriteEntity");
	MarkNativeAsOptional("BfWrite.WriteAngle");
	MarkNativeAsOptional("BfWrite.WriteCoord");
	MarkNativeAsOptional("BfWrite.WriteVecCoord");
	MarkNativeAsOptional("BfWrite.WriteVecNormal");
	MarkNativeAsOptional("BfWrite.WriteAngles");
	MarkNativeAsOptional("BfRead.ReadBool");
	MarkNativeAsOptional("BfRead.ReadByte");
	MarkNativeAsOptional("BfRead.ReadChar");
	MarkNativeAsOptional("BfRead.ReadShort");
	MarkNativeAsOptional("BfRead.ReadWord");
	MarkNativeAsOptional("BfRead.ReadNum");
	MarkNativeAsOptional("BfRead.ReadFloat");
	MarkNativeAsOptional("BfRead.ReadString");
	MarkNativeAsOptional("BfRead.ReadEntity");
	MarkNativeAsOptional("BfRead.ReadAngle");
	MarkNativeAsOptional("BfRead.ReadCoord");
	MarkNativeAsOptional("BfRead.ReadVecCoord");
	MarkNativeAsOptional("BfRead.ReadVecNormal");
	MarkNativeAsOptional("BfRead.ReadAngles");
	MarkNativeAsOptional("BfRead.GetNumBytesLeft");
	MarkNativeAsOptional("PbReadInt");
	MarkNativeAsOptional("PbReadFloat");
	MarkNativeAsOptional("PbReadBool");
	MarkNativeAsOptional("PbReadString");
	MarkNativeAsOptional("PbReadColor");
	MarkNativeAsOptional("PbReadAngle");
	MarkNativeAsOptional("PbReadVector");
	MarkNativeAsOptional("PbReadVector2D");
	MarkNativeAsOptional("PbGetRepeatedFieldCount");
	MarkNativeAsOptional("PbSetInt");
	MarkNativeAsOptional("PbSetFloat");
	MarkNativeAsOptional("PbSetBool");
	MarkNativeAsOptional("PbSetString");
	MarkNativeAsOptional("PbSetColor");
	MarkNativeAsOptional("PbSetAngle");
	MarkNativeAsOptional("PbSetVector");
	MarkNativeAsOptional("PbSetVector2D");
	MarkNativeAsOptional("PbAddInt");
	MarkNativeAsOptional("PbAddFloat");
	MarkNativeAsOptional("PbAddBool");
	MarkNativeAsOptional("PbAddString");
	MarkNativeAsOptional("PbAddColor");
	MarkNativeAsOptional("PbAddAngle");
	MarkNativeAsOptional("PbAddVector");
	MarkNativeAsOptional("PbAddVector2D");
	MarkNativeAsOptional("PbRemoveRepeatedFieldValue");
	MarkNativeAsOptional("PbReadMessage");
	MarkNativeAsOptional("PbReadRepeatedMessage");
	MarkNativeAsOptional("PbAddMessage");
	MarkNativeAsOptional("Protobuf.ReadInt");
	MarkNativeAsOptional("Protobuf.ReadFloat");
	MarkNativeAsOptional("Protobuf.ReadBool");
	MarkNativeAsOptional("Protobuf.ReadString");
	MarkNativeAsOptional("Protobuf.ReadColor");
	MarkNativeAsOptional("Protobuf.ReadAngle");
	MarkNativeAsOptional("Protobuf.ReadVector");
	MarkNativeAsOptional("Protobuf.ReadVector2D");
	MarkNativeAsOptional("Protobuf.GetRepeatedFieldCount");
	MarkNativeAsOptional("Protobuf.SetInt");
	MarkNativeAsOptional("Protobuf.SetFloat");
	MarkNativeAsOptional("Protobuf.SetBool");
	MarkNativeAsOptional("Protobuf.SetString");
	MarkNativeAsOptional("Protobuf.SetColor");
	MarkNativeAsOptional("Protobuf.SetAngle");
	MarkNativeAsOptional("Protobuf.SetVector");
	MarkNativeAsOptional("Protobuf.SetVector2D");
	MarkNativeAsOptional("Protobuf.AddInt");
	MarkNativeAsOptional("Protobuf.AddFloat");
	MarkNativeAsOptional("Protobuf.AddBool");
	MarkNativeAsOptional("Protobuf.AddString");
	MarkNativeAsOptional("Protobuf.AddColor");
	MarkNativeAsOptional("Protobuf.AddAngle");
	MarkNativeAsOptional("Protobuf.AddVector");
	MarkNativeAsOptional("Protobuf.AddVector2D");
	MarkNativeAsOptional("Protobuf.RemoveRepeatedFieldValue");
	MarkNativeAsOptional("Protobuf.ReadMessage");
	MarkNativeAsOptional("Protobuf.ReadRepeatedMessage");
	MarkNativeAsOptional("Protobuf.AddMessage");
	VerifyCoreVersion();
	return 0;
}

float operator-(Float:)(float oper)
{
	return oper ^ -2147483648;
}

float operator+(Float:,_:)(float oper1, int oper2)
{
	return FloatAdd(oper1, float(oper2));
}

bool operator==(Float:,_:)(float oper1, int oper2)
{
	return __FLOAT_EQ__(oper1, float(oper2));
}

Handle StartMessageOne(char msgname[], int client, int flags)
{
	int players[1];
	players[0] = client;
	return StartMessage(msgname, players, 1, flags);
}

int GetEntSendPropOffs(int ent, char prop[], bool actual)
{
	char cls[64];
	if (!GetEntityNetClass(ent, cls, 64))
	{
		return -1;
	}
	if (actual)
	{
		return FindSendPropInfo(cls, prop, 0, 0, 0);
	}
	return FindSendPropOffs(cls, prop);
}

MoveType GetEntityMoveType(int entity)
{
	static bool gotconfig;
	static char datamap[8];
	if (!gotconfig)
	{
		Handle gc = LoadGameConfigFile("core.games");
		bool exists = GameConfGetKeyValue(gc, "m_MoveType", "", 32);
		CloseHandle(gc);
		if (!exists)
		{
			strcopy("", 32, "m_MoveType");
		}
		__unk = 1;
	}
	return GetEntProp(entity, PropType 1, "", 4, 0);
}

int SetEntityMoveType(int entity, MoveType mt)
{
	static bool gotconfig;
	static char datamap[8];
	if (!gotconfig)
	{
		Handle gc = LoadGameConfigFile("core.games");
		bool exists = GameConfGetKeyValue(gc, "m_MoveType", "", 32);
		CloseHandle(gc);
		if (!exists)
		{
			strcopy("", 32, "m_MoveType");
		}
		__unk = 1;
	}
	SetEntProp(entity, PropType 1, "", mt, 4, 0);
	return 0;
}

int SetEntityRenderColor(int entity, int r, int g, int b, int a)
{
	static bool gotconfig;
	static char prop[8];
	if (!gotconfig)
	{
		Handle gc = LoadGameConfigFile("core.games");
		bool exists = GameConfGetKeyValue(gc, "m_clrRender", "", 32);
		CloseHandle(gc);
		if (!exists)
		{
			strcopy("", 32, "m_clrRender");
		}
		__unk = 1;
	}
	int offset = GetEntSendPropOffs(entity, "", false);
	if (0 >= offset)
	{
		ThrowError("SetEntityRenderColor not supported by this mod");
	}
	SetEntData(entity, offset, r, 1, true);
	SetEntData(entity, offset + 1, g, 1, true);
	SetEntData(entity, offset + 2, b, 1, true);
	SetEntData(entity, offset + 3, a, 1, true);
	return 0;
}

public void OnPluginStart()
{
	CreateConVar("sm_ash_version", "1.65", "Anti-StrafeHack Version", 401728, false, 0, false, 0);
	gH_Cvar_Database_Driver = CreateConVar("sm_ash_database_driver", "anticheat", "Specifies the configuration driver to use from SourceMod's database.cfg", 262144, false, 0, false, 0);
	gH_Cvar_APIKey = CreateConVar("sm_ash_api_key", "", "API Key", 0, false, 0, false, 0);
	HookConVarChange(gH_Cvar_APIKey, ConVarChanged 9);
	AutoExecConfig(true, "anticheat", "sourcemod");
	RegConsoleCmd("sm_ashdebug", SM_AshDebug, "Debugging menu", 0);
	RegServerCmd("sm_startrecord", SrvCmd 37, "", 0);
	RegServerCmd("sm_getsync", SrvCmd 35, "", 0);
	RegServerCmd("sm_ashdb", SrvCmd 31, "", 0);
	HookEvent("round_start", EventHook 17, EventHookMode 2);
	HookEvent("player_spawn", EventHook 15, EventHookMode 1);
	BuildPath(PathType 0, g_sLogFile, 256, "logs/Anti-StrafeHack");
	if (!DirExists(g_sLogFile, false, "GAME"))
	{
		CreateDirectory(g_sLogFile, 511, false, "DEFAULT_WRITE_PATH");
	}
	BuildPath(PathType 0, g_sLogFile, 256, "logs/Anti-StrafeHack/log.txt");
	return void 0;
}

public void OnMapStart()
{
	PrecacheSound("physics/glass/glass_impact_bullet4.wav", true);
	GetCurrentMap(g_sMapName, 64);
	return void 0;
}

public int Event_RoundStart(Handle event, char name[], bool dontBroadcast)
{
	HookTeleports();
	return 0;
}

public void OnConfigsExecuted()
{
	GetConVarString(gH_Cvar_APIKey, g_sAPIKey, 64);
	SQL_DBConnect();
	return void 0;
}

public int CvarChange(Handle convar, char oldValue[], char newValue[])
{
	GetConVarString(gH_Cvar_APIKey, g_sAPIKey, 64);
	return 0;
}

public void OnClientPutInServer(int client)
{
	g_Tick[client] = 0;
	g_CurrentFrame[client] = 0;
	g_bWalking[client] = 1;
	g_bPreventInvalidMovSpam[client] = 0;
	g_TotalSync[client] = 0;
	g_GoodSync[client][0][0][0] = 0;
	g_GoodSync[client][0][0][4] = 0;
	g_GoodSync[client][0][0][8] = 0;
	g_TimerTotalSync[client] = 0;
	g_TimerGoodSync[client] = 0;
	g_CurrentFrameSW[client] = 0;
	g_TotalSyncSW[client] = 0;
	g_GoodSyncSW[client][0][0][0] = 0;
	g_GoodSyncSW[client][0][0][4] = 0;
	g_GoodSyncSW[client][0][0][8] = 0;
	g_TimerTotalSyncSW[client] = 0;
	g_TimerGoodSyncSW[client] = 0;
	g_TimerTotalSyncHSW[client] = 0;
	g_TimerGoodSyncHSW[client] = 0;
	g_CurrentFrameKeysAD[client] = 0;
	g_CurrentFrameKeysWS[client] = 0;
	g_AdminMenuPage[client] = 1;
	g_AdminSelectedUserID[client] = 0;
	g_bPrintAnalysis[client] = 0;
	g_bDebugStrafes[client] = 0;
	g_bCheckSync[client] = 0;
	g_bPrintAnalysisSW[client] = 0;
	g_bDebugStrafesSW[client] = 0;
	g_bCheckSyncSW[client] = 0;
	g_bDebugKeysHoldtimeAD[client] = 0;
	g_bDebugKeysHoldtimeWS[client] = 0;
	g_bConsoleOutput[client] = 0;
	g_bPrintAngleDiff[client] = 0;
	g_bCheckAngleDiff[client] = 0;
	g_bBlockAngleCheck[client] = 0;
	return void 0;
}

public void OnClientDisconnect_Post(int client)
{
	if (gH_TimerTopMsg[client][0][0])
	{
		KillTimer(gH_TimerTopMsg[client][0][0], false);
		gH_TimerTopMsg[client] = 0;
	}
	g_bPrintAnalysis[client] = 0;
	g_bIsDebugOnAnalysis = IsDebugOnAnalysis();
	g_bDebugStrafes[client] = 0;
	g_bIsDebugOnStrafes = IsDebugOnStrafes();
	g_bCheckSync[client] = 0;
	g_bCheckSyncSW[client] = 0;
	g_bIsDebugOnSync = IsDebugOnSync();
	g_bPrintAnalysisSW[client] = 0;
	g_bIsDebugOnAnalysisSW = IsDebugOnAnalysisSW();
	g_bDebugStrafesSW[client] = 0;
	g_bIsDebugOnStrafesSW = IsDebugOnStrafesSW();
	g_bDebugKeysHoldtimeAD[client] = 0;
	g_bIsDebugOnKeysAD = IsDebugOnKeysAD();
	g_bDebugKeysHoldtimeWS[client] = 0;
	g_bIsDebugOnKeysWS = IsDebugOnKeysWS();
	g_bConsoleOutput[client] = 0;
	g_bPrintAngleDiff[client] = 0;
	g_bCheckAngleDiff[client] = 0;
	g_bIsDebugOnAdv = IsDebugOnAdv();
	return void 0;
}


/* ERROR! Das Objekt des Typs "Lysis.DJumpCondition" kann nicht in Typ "Lysis.DJump" umgewandelt werden. */
 function "OnPlayerRunCmd" (number 16)

/* ERROR! Das Objekt des Typs "Lysis.DReturn" kann nicht in Typ "Lysis.DJumpCondition" umgewandelt werden. */
 function "InvalidMovement" (number 17)
void CheckIfTurned(int client, float fAngleDiff)
{
	int var1;
	if (__FLOAT_GT__(fAngleDiff, 0))
	{
		ClientTurned(client, 0);
		return void 0;
	}
	int var2;
	if (__FLOAT_LT__(fAngleDiff, 0))
	{
		ClientTurned(client, 1);
	}
	return void 0;
}

void ClientTurned(int client, int turnDirection)
{
	g_LastTurnDir[client] = turnDirection;
	g_LastTurnTime[client] = g_Tick[client][0][0];
	g_bTurned[client][0][0][turnDirection] = 1;
	g_bTurned[client][0][0][turnDirection + 1] = 0;
	int var2;
	if (g_bOnGround[client][0][0])
	{
		return void 0;
	}
	HandleFrameIfMovedFirst(client, turnDirection);
	HandleFrameIfMovedFirst_SW(client, turnDirection);
	return void 0;
}

void HandleFrameIfMovedFirst(int client, int turnDirection)
{
	if (g_LastMoveDir[client][0][0] == turnDirection)
	{
		int difference = g_LastMoveTime[client][0][0] - g_LastTurnTime[client][0][0] + 1;
		int var2 = difference;
		if (20 >= var2 & -20 <= var2)
		{
			g_Frames[client][0][0][g_CurrentFrame[client][0][0]][0] = difference;
			g_Frames[client][0][0][g_CurrentFrame[client][0][0]][4] = 0;
			g_CurrentFrame[client]++;
			g_TotalStrafes[client]++;
			int var3 = difference;
			if (1 >= var3 & -1 <= var3)
			{
				g_PerfectStrafes[client]++;
			}
			int var4 = difference;
			if (5 >= var4 & -5 <= var4)
			{
				g_GoodStrafes[client]++;
			}
			if (g_bIsDebugOnStrafes)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var1;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFFFF[ASH] \x0700FF08%N \x07FF69B4moved first \x07FFFFFF| F | TD: \x07FFFF00%d", client, difference);
						}
					}
					i++;
				}
			}
			AntiCheatCheck1(client, g_CurrentFrame[client][0][0]);
			AntiCheatCheck2(client, g_CurrentFrame[client][0][0]);
		}
	}
	return void 0;
}

void AntiCheatCheck1(int client, int numFrames)
{
	if (numFrames == 20)
	{
		int movedFirstCount = 0;
		int turnedFirstCount = 0;
		int movedFirstPerfect = 0;
		int turnedFirstPerfect = 0;
		int movedFirst1 = 0;
		int turnedFirst1 = 0;
		int movedFirst2 = 0;
		int turnedFirst2 = 0;
		CountFrames(client, g_Frames, 20, movedFirstCount, turnedFirstCount, movedFirstPerfect, turnedFirstPerfect, movedFirst1, turnedFirst1, movedFirst2, turnedFirst2);
		float fSync1 = GetClientSync(client, 0);
		float fSync2 = GetClientSync(client, 1);
		float fSync3 = GetClientSync(client, 2);
		int var2;
		if (__FLOAT_LT__(fSync1, fSync2))
		{
			SayText2Admins("\x01\x07FFFF0020\x07FFFFFF Strafes Tick Difference Analysis");
			SayText2Admins("\x01\x07FFFFFFMF:  \x0700FF08%d  \x07FFFFFFMF2:  \x0700FF08%d  \x07FFFFFFMF1:  \x0700FF08%d  \x07FFFFFFMFP:  \x0700FF08%d", movedFirstCount, movedFirst2, movedFirst1, movedFirstPerfect);
			SayText2Admins("\x01\x07FFFFFFTF:  \x0700FF08%d  \x07FFFFFFTF2:  \x0700FF08%d  \x07FFFFFFTF1:  \x0700FF08%d  \x07FFFFFFTFP:  \x0700FF08%d", turnedFirstCount, turnedFirst2, turnedFirst1, turnedFirstPerfect);
			SayText2Admins("\x01\x07FFFFFFSync:  \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f", fSync1, fSync2, fSync3);
			SayText2Admins("\x01\x07FFFFFFPlayer: \x0700FF08%N", client);
			SayText2All("\x01\x07FF6200%N is suspected of using a strafehack!", client);
			FreezeClient(client, 5);
			LogCheater(client, CheatDetection 4, "Suspected of using a strafehack.\nDetection: 20 Strafes Tick Difference", fSync1, fSync2, fSync3, movedFirstCount, movedFirstPerfect, turnedFirstCount, turnedFirstPerfect, movedFirst1, movedFirst2, turnedFirst1, turnedFirst2);
		}
		else
		{
			if (g_bIsDebugOnAnalysis)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var3;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFF0020\x07FFFFFF Strafes Tick Difference Analysis");
							SayText2(i, "\x01\x07FFFFFFMF:  \x0700FF08%d  \x07FFFFFFMF2:  \x0700FF08%d  \x07FFFFFFMF1:  \x0700FF08%d  \x07FFFFFFMFP:  \x0700FF08%d", movedFirstCount, movedFirst2, movedFirst1, movedFirstPerfect);
							SayText2(i, "\x01\x07FFFFFFTF:  \x0700FF08%d  \x07FFFFFFTF2:  \x0700FF08%d  \x07FFFFFFTF1:  \x0700FF08%d  \x07FFFFFFTFP:  \x0700FF08%d", turnedFirstCount, turnedFirst2, turnedFirst1, turnedFirstPerfect);
							SayText2(i, "\x01\x07FFFFFFSync:  \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f", fSync1, fSync2, fSync3);
							SayText2(i, "\x01\x07FFFFFFPlayer: \x0700FF08%N", client);
						}
					}
					i++;
				}
			}
		}
	}
	return void 0;
}

void AntiCheatCheck2(int client, int numFrames)
{
	if (numFrames == 40)
	{
		int movedFirstCount = 0;
		int turnedFirstCount = 0;
		int movedFirstPerfect = 0;
		int turnedFirstPerfect = 0;
		int movedFirst1 = 0;
		int turnedFirst1 = 0;
		int movedFirst2 = 0;
		int turnedFirst2 = 0;
		CountFrames(client, g_Frames, 40, movedFirstCount, turnedFirstCount, movedFirstPerfect, turnedFirstPerfect, movedFirst1, turnedFirst1, movedFirst2, turnedFirst2);
		float fSync1 = GetClientSync(client, 0);
		float fSync2 = GetClientSync(client, 1);
		float fSync3 = GetClientSync(client, 2);
		int var2;
		if (turnedFirstPerfect >= 30)
		{
			SayText2Admins("\x01\x07FFFF0040\x07FFFFFF Strafes Tick Difference Analysis");
			SayText2Admins("\x01\x07FFFFFFMF:  \x0700FF08%d  \x07FFFFFFMF2:  \x0700FF08%d  \x07FFFFFFMF1:  \x0700FF08%d  \x07FFFFFFMFP:  \x0700FF08%d", movedFirstCount, movedFirst2, movedFirst1, movedFirstPerfect);
			SayText2Admins("\x01\x07FFFFFFTF:  \x0700FF08%d  \x07FFFFFFTF2:  \x0700FF08%d  \x07FFFFFFTF1:  \x0700FF08%d  \x07FFFFFFTFP:  \x0700FF08%d", turnedFirstCount, turnedFirst2, turnedFirst1, turnedFirstPerfect);
			SayText2Admins("\x01\x07FFFFFFSync:  \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f", fSync1, fSync2, fSync3);
			SayText2Admins("\x01\x07FFFFFFPlayer: \x0700FF08%N", client);
			SayText2All("\x01\x07FF6200%N is suspected of using a strafehack!", client);
			FreezeClient(client, 5);
			LogCheater(client, CheatDetection 5, "Suspected of using a strafehack.\nDetection: 40 Strafes Tick Difference", fSync1, fSync2, fSync3, movedFirstCount, movedFirstPerfect, turnedFirstCount, turnedFirstPerfect, movedFirst1, movedFirst2, turnedFirst1, turnedFirst2);
		}
		else
		{
			if (g_bIsDebugOnAnalysis)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var3;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFF0040\x07FFFFFF Strafes Tick Difference Analysis");
							SayText2(i, "\x01\x07FFFFFFMF:  \x0700FF08%d  \x07FFFFFFMF2:  \x0700FF08%d  \x07FFFFFFMF1:  \x0700FF08%d  \x07FFFFFFMFP:  \x0700FF08%d", movedFirstCount, movedFirst2, movedFirst1, movedFirstPerfect);
							SayText2(i, "\x01\x07FFFFFFTF:  \x0700FF08%d  \x07FFFFFFTF2:  \x0700FF08%d  \x07FFFFFFTF1:  \x0700FF08%d  \x07FFFFFFTFP:  \x0700FF08%d", turnedFirstCount, turnedFirst2, turnedFirst1, turnedFirstPerfect);
							SayText2(i, "\x01\x07FFFFFFSync:  \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f", fSync1, fSync2, fSync3);
							SayText2(i, "\x01\x07FFFFFFPlayer: \x0700FF08%N", client);
						}
					}
					i++;
				}
			}
		}
		g_TotalSync[client] = 0;
		g_GoodSync[client][0][0][0] = 0;
		g_GoodSync[client][0][0][4] = 0;
		g_GoodSync[client][0][0][8] = 0;
		g_CurrentFrame[client] = 0;
	}
	return void 0;
}

void HandleFrameIfMovedFirst_SW(int client, int turnDirection)
{
	if (g_LastMoveDirSW[client][0][0] == turnDirection)
	{
		int differenceSW = g_LastMoveTimeSW[client][0][0] - g_LastTurnTime[client][0][0] + 1;
		int var2 = differenceSW;
		if (20 >= var2 & -20 <= var2)
		{
			g_FramesSW[client][0][0][g_CurrentFrameSW[client][0][0]][0] = differenceSW;
			g_FramesSW[client][0][0][g_CurrentFrameSW[client][0][0]][4] = 0;
			g_CurrentFrameSW[client]++;
			if (g_bIsDebugOnStrafesSW)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var1;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFFFF[ASH] \x0700FF08%N \x07FF69B4moved first \x07FFFFFF| S | TD: \x07FFFF00%d", client, differenceSW);
						}
					}
					i++;
				}
			}
			AntiCheatCheck1_SW(client, g_CurrentFrameSW[client][0][0]);
			AntiCheatCheck2_SW(client, g_CurrentFrameSW[client][0][0]);
		}
	}
	return void 0;
}

void AntiCheatCheck1_SW(int client, int numFrames)
{
	if (numFrames == 20)
	{
		int movedFirstCount = 0;
		int turnedFirstCount = 0;
		int movedFirstPerfect = 0;
		int turnedFirstPerfect = 0;
		int movedFirst1 = 0;
		int turnedFirst1 = 0;
		int movedFirst2 = 0;
		int turnedFirst2 = 0;
		CountFrames(client, g_FramesSW, 20, movedFirstCount, turnedFirstCount, movedFirstPerfect, turnedFirstPerfect, movedFirst1, turnedFirst1, movedFirst2, turnedFirst2);
		float fSync1 = GetClientSyncSW(client, 0);
		float fSync2 = GetClientSyncSW(client, 1);
		float fSync3 = GetClientSyncSW(client, 2);
		int var2;
		if (__FLOAT_LT__(fSync1, fSync2))
		{
			SayText2Admins("\x01\x07FFFF0020\x07FFFFFF Strafes Tick Difference Analysis [Sideways]");
			SayText2Admins("\x01\x07FFFFFFMF:  \x0700FF08%d  \x07FFFFFFMF2:  \x0700FF08%d  \x07FFFFFFMF1:  \x0700FF08%d  \x07FFFFFFMFP:  \x0700FF08%d", movedFirstCount, movedFirst2, movedFirst1, movedFirstPerfect);
			SayText2Admins("\x01\x07FFFFFFTF:  \x0700FF08%d  \x07FFFFFFTF2:  \x0700FF08%d  \x07FFFFFFTF1:  \x0700FF08%d  \x07FFFFFFTFP:  \x0700FF08%d", turnedFirstCount, turnedFirst2, turnedFirst1, turnedFirstPerfect);
			SayText2Admins("\x01\x07FFFFFFSync:  \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f", fSync1, fSync2, fSync3);
			SayText2Admins("\x01\x07FFFFFFPlayer: \x0700FF08%N", client);
			SayText2All("\x01\x07FF6200%N is suspected of using a strafehack! [Sideways]", client);
			FreezeClient(client, 5);
			LogCheater(client, CheatDetection 6, "Suspected of using a strafehack [Sideways].\nDetection: 20 Strafes Tick Difference [Sideways]", fSync1, fSync2, fSync3, movedFirstCount, movedFirstPerfect, turnedFirstCount, turnedFirstPerfect, movedFirst1, movedFirst2, turnedFirst1, turnedFirst2);
		}
		else
		{
			if (g_bIsDebugOnAnalysisSW)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var3;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFF0020\x07FFFFFF Strafes Tick Difference Analysis [Sideways]");
							SayText2(i, "\x01\x07FFFFFFMF:  \x0700FF08%d  \x07FFFFFFMF2:  \x0700FF08%d  \x07FFFFFFMF1:  \x0700FF08%d  \x07FFFFFFMFP:  \x0700FF08%d", movedFirstCount, movedFirst2, movedFirst1, movedFirstPerfect);
							SayText2(i, "\x01\x07FFFFFFTF:  \x0700FF08%d  \x07FFFFFFTF2:  \x0700FF08%d  \x07FFFFFFTF1:  \x0700FF08%d  \x07FFFFFFTFP:  \x0700FF08%d", turnedFirstCount, turnedFirst2, turnedFirst1, turnedFirstPerfect);
							SayText2(i, "\x01\x07FFFFFFSync:  \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f", fSync1, fSync2, fSync3);
							SayText2(i, "\x01\x07FFFFFFPlayer: \x0700FF08%N", client);
						}
					}
					i++;
				}
			}
		}
	}
	return void 0;
}

void AntiCheatCheck2_SW(int client, int numFrames)
{
	if (numFrames == 40)
	{
		int movedFirstCount = 0;
		int turnedFirstCount = 0;
		int movedFirstPerfect = 0;
		int turnedFirstPerfect = 0;
		int movedFirst1 = 0;
		int turnedFirst1 = 0;
		int movedFirst2 = 0;
		int turnedFirst2 = 0;
		CountFrames(client, g_FramesSW, 40, movedFirstCount, turnedFirstCount, movedFirstPerfect, turnedFirstPerfect, movedFirst1, turnedFirst1, movedFirst2, turnedFirst2);
		float fSync1 = GetClientSyncSW(client, 0);
		float fSync2 = GetClientSyncSW(client, 1);
		float fSync3 = GetClientSyncSW(client, 2);
		int var2;
		if (__FLOAT_LT__(fSync1, fSync2))
		{
			SayText2Admins("\x01\x07FFFF0040\x07FFFFFF Strafes Tick Difference Analysis [Sideways]");
			SayText2Admins("\x01\x07FFFFFFMF:  \x0700FF08%d  \x07FFFFFFMF2:  \x0700FF08%d  \x07FFFFFFMF1:  \x0700FF08%d  \x07FFFFFFMFP:  \x0700FF08%d", movedFirstCount, movedFirst2, movedFirst1, movedFirstPerfect);
			SayText2Admins("\x01\x07FFFFFFTF:  \x0700FF08%d  \x07FFFFFFTF2:  \x0700FF08%d  \x07FFFFFFTF1:  \x0700FF08%d  \x07FFFFFFTFP:  \x0700FF08%d", turnedFirstCount, turnedFirst2, turnedFirst1, turnedFirstPerfect);
			SayText2Admins("\x01\x07FFFFFFSync:  \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f", fSync1, fSync2, fSync3);
			SayText2Admins("\x01\x07FFFFFFPlayer: \x0700FF08%N", client);
			SayText2All("\x01\x07FF6200%N is suspected of using a strafehack! [Sideways]", client);
			FreezeClient(client, 5);
			LogCheater(client, CheatDetection 7, "Suspected of using a strafehack [Sideways].\nDetection: 40 Strafes Tick Difference [Sideways]", fSync1, fSync2, fSync3, movedFirstCount, movedFirstPerfect, turnedFirstCount, turnedFirstPerfect, movedFirst1, movedFirst2, turnedFirst1, turnedFirst2);
		}
		else
		{
			if (g_bIsDebugOnAnalysisSW)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var3;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFF0040\x07FFFFFF Strafes Tick Difference Analysis [Sideways]");
							SayText2(i, "\x01\x07FFFFFFMF:  \x0700FF08%d  \x07FFFFFFMF2:  \x0700FF08%d  \x07FFFFFFMF1:  \x0700FF08%d  \x07FFFFFFMFP:  \x0700FF08%d", movedFirstCount, movedFirst2, movedFirst1, movedFirstPerfect);
							SayText2(i, "\x01\x07FFFFFFTF:  \x0700FF08%d  \x07FFFFFFTF2:  \x0700FF08%d  \x07FFFFFFTF1:  \x0700FF08%d  \x07FFFFFFTFP:  \x0700FF08%d", turnedFirstCount, turnedFirst2, turnedFirst1, turnedFirstPerfect);
							SayText2(i, "\x01\x07FFFFFFSync:  \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f", fSync1, fSync2, fSync3);
							SayText2(i, "\x01\x07FFFFFFPlayer: \x0700FF08%N", client);
						}
					}
					i++;
				}
			}
		}
		g_TotalSyncSW[client] = 0;
		g_GoodSyncSW[client][0][0][0] = 0;
		g_GoodSyncSW[client][0][0][4] = 0;
		g_GoodSyncSW[client][0][0][8] = 0;
		g_CurrentFrameSW[client] = 0;
	}
	return void 0;
}

void CheckIfSwitchedMov(int client, float fSideMove, float fForwardMove, float fAngleY)
{
	static float fLastSideMove[66];
	static float fLastForwardMove[66];
	static int moveTicks[66][20][2];
	static int currentMoveTick[66];
	if (__FLOAT_LT__(fSideMove, 0))
	{
		if (__FLOAT_GE__(88164[client], 0))
		{
			if (g_Tick[client][0][0] - g_LastMoveTime[client][0][0] <= 5)
			{
				88692[client][104796[client]] = 0;

/* ERROR! unknown load */
 function "CheckIfSwitchedMov" (number 26)
void ClientSwitchedMov(int client)
{
	if (g_bTurned[client][0][0][g_LastMoveDir[client][0][0]] == true)
	{
		int difference = g_LastMoveTime[client][0][0] - g_LastTurnTime[client][0][0];
		int var2 = difference;
		if (20 >= var2 & -20 <= var2)
		{
			g_Frames[client][0][0][g_CurrentFrame[client][0][0]][0] = difference;
			g_Frames[client][0][0][g_CurrentFrame[client][0][0]][4] = 1;
			g_CurrentFrame[client]++;
			g_TotalStrafes[client]++;
			int var3 = difference;
			if (1 >= var3 & -1 <= var3)
			{
				g_PerfectStrafes[client]++;
			}
			int var4 = difference;
			if (5 >= var4 & -5 <= var4)
			{
				g_GoodStrafes[client]++;
			}
			if (g_bIsDebugOnStrafes)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var1;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFFFF[ASH] \x0700FF08%N \x0700FFFFturned first \x07FFFFFF| F | TD: \x07FFFF00%d", client, difference);
						}
					}
					i++;
				}
			}
			AntiCheatCheck1(client, g_CurrentFrame[client][0][0]);
			AntiCheatCheck2(client, g_CurrentFrame[client][0][0]);
		}
	}
	return void 0;
}

void ClientSwitchedMovSW(int client)
{
	if (g_bTurned[client][0][0][g_LastMoveDirSW[client][0][0]] == true)
	{
		int differenceSW = g_LastMoveTimeSW[client][0][0] - g_LastTurnTime[client][0][0];
		int var2 = differenceSW;
		if (20 >= var2 & -20 <= var2)
		{
			g_FramesSW[client][0][0][g_CurrentFrameSW[client][0][0]][0] = differenceSW;
			g_FramesSW[client][0][0][g_CurrentFrameSW[client][0][0]][4] = 1;
			g_CurrentFrameSW[client]++;
			if (g_bIsDebugOnStrafesSW)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var1;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFFFF[ASH] \x0700FF08%N \x0700FFFFturned first \x07FFFFFF| S | TD: \x07FFFF00%d", client, differenceSW);
						}
					}
					i++;
				}
			}
			AntiCheatCheck1_SW(client, g_CurrentFrameSW[client][0][0]);
			AntiCheatCheck2_SW(client, g_CurrentFrameSW[client][0][0]);
		}
	}
	return void 0;
}

void CountFrames(int client, int array[][][], int amount, &int movedFirstCount, &int turnedFirstCount, &int movedFirstPerfect, &int turnedFirstPerfect, &int movedFirst1, &int turnedFirst1, &int movedFirst2, &int turnedFirst2)
{
	int f = 0;
	while (f < amount)
	{
		if (array[client][f][4])
		{
			int var5 = turnedFirstCount;
			var5++;
			turnedFirstCount = var5;
			switch (array[client][f][0])
			{
				case 0: {
					int var8 = turnedFirstPerfect;
					var8++;
					turnedFirstPerfect = var8;
					f++;
				}
				case 1: {
					int var7 = turnedFirst1;
					var7++;
					turnedFirst1 = var7;
					f++;
				}
				case 2: {
					int var6 = turnedFirst2;
					var6++;
					turnedFirst2 = var6;
					f++;
				}
				default: {
					f++;
				}
			}
		}
		else
		{
			int var1 = movedFirstCount;
			var1++;
			movedFirstCount = var1;
			switch (array[client][f][0])
			{
				case -2: {
					int var4 = movedFirst2;
					var4++;
					movedFirst2 = var4;
					f++;
				}
				case -1: {
					int var3 = movedFirst1;
					var3++;
					movedFirst1 = var3;
					f++;
				}
				case 0: {
					int var2 = movedFirstPerfect;
					var2++;
					movedFirstPerfect = var2;
					f++;
				}
				default: {
					f++;
				}
			}
			f++;
		}
		f++;
	}
	return void 0;
}

void CheckIfSwitchedKeys(int client, int buttons)
{
	static int oldButtons[66];
	static int holdAD[66];
	static int holdWS[66];
	if (buttons & 512)
	{
		if (buttons & 1024)
		{
			105756[client]++;
		}
		int var1;
		if (!buttons & 1024)
		{
			if (105756[client])
			{
				g_CurrentFrameKeysAD[client] = 0;
			}
			else
			{
				g_CurrentFrameKeysAD[client]++;
				AntiCheatCheck_KeysAD(client, g_CurrentFrameKeysAD[client][0][0]);
			}
			if (g_bIsDebugOnKeysAD)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var2;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFFFF[ASH] \x0700FF08%N \x07FFFFFFD\x07FFFF00->\x07FFFFFFA | Hold: \x07FFFF00%d \x07FFFFFFStreak: \x07FFFF00%d", client, 105756[client], g_CurrentFrameKeysAD[client]);
						}
					}
					i++;
				}
			}
			105756[client] = 0;
		}
	}
	if (buttons & 1024)
	{
		int var3;
		if (!buttons & 512)
		{
			if (105756[client])
			{
				g_CurrentFrameKeysAD[client] = 0;
			}
			else
			{
				g_CurrentFrameKeysAD[client]++;
				AntiCheatCheck_KeysAD(client, g_CurrentFrameKeysAD[client][0][0]);
			}
			if (g_bIsDebugOnKeysAD)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var4;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFFFF[ASH] \x0700FF08%N \x07FFFFFFA\x07FFFF00->\x07FFFFFFD | Hold: \x07FFFF00%d \x07FFFFFFStreak: \x07FFFF00%d", client, 105756[client], g_CurrentFrameKeysAD[client]);
						}
					}
					i++;
				}
			}
			105756[client] = 0;
		}
	}
	if (buttons & 8)
	{
		if (buttons & 16)
		{
			106020[client]++;
		}
		int var5;
		if (!buttons & 16)
		{
			if (106020[client])
			{
				g_CurrentFrameKeysWS[client] = 0;
			}
			else
			{
				g_CurrentFrameKeysWS[client]++;
				AntiCheatCheck_KeysWS(client, g_CurrentFrameKeysWS[client][0][0]);
			}
			if (g_bIsDebugOnKeysWS)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var6;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFFFF[ASH] \x0700FF08%N \x07FFFFFFS\x07FFFF00->\x07FFFFFFW | Hold: \x07FFFF00%d \x07FFFFFFStreak: \x07FFFF00%d", client, 106020[client], g_CurrentFrameKeysWS[client]);
						}
					}
					i++;
				}
			}
			106020[client] = 0;
		}
	}
	if (buttons & 16)
	{
		int var7;
		if (!buttons & 8)
		{
			if (106020[client])
			{
				g_CurrentFrameKeysWS[client] = 0;
			}
			else
			{
				g_CurrentFrameKeysWS[client]++;
				AntiCheatCheck_KeysWS(client, g_CurrentFrameKeysWS[client][0][0]);
			}
			if (g_bIsDebugOnKeysWS)
			{
				int i = 1;
				while (i <= MaxClients)
				{
					int var8;
					if (!IsClientInGame(i))
					{
					}
					else
					{
						int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
						if (client == target)
						{
							SayText2(i, "\x01\x07FFFFFF[ASH] \x0700FF08%N \x07FFFFFFW\x07FFFF00->\x07FFFFFFS | Hold: \x07FFFF00%d \x07FFFFFFStreak: \x07FFFF00%d", client, 106020[client], g_CurrentFrameKeysWS[client]);
						}
					}
					i++;
				}
			}
			106020[client] = 0;
		}
	}
	105492[client] = buttons;
	return void 0;
}

void AntiCheatCheck_KeysAD(int client, int numFrames)
{
	int var1;
	if (numFrames)
	{
		SayText2Admins("\x01\x07FFD700%N is suspected of having too many perfect key changes! |A/D| (%d)", client, numFrames);
		SayText2Admins("\x01\x07FFFFFFF Sync at frame \x07FFFF00%d\x07FFFFFF:  \x0700FF08%f \x07FFFFFF| \x0700FF08%f \x07FFFFFF| \x0700FF08%f", g_CurrentFrame[client], GetClientSync(client, 0), GetClientSync(client, 1), GetClientSync(client, 2));
		SayText2Admins("\x01\x07FFFFFFS Sync at frame \x07FFFF00%d\x07FFFFFF:  \x0700FF08%f \x07FFFFFF| \x0700FF08%f \x07FFFFFF| \x0700FF08%f", g_CurrentFrameSW[client], GetClientSyncSW(client, 0), GetClientSyncSW(client, 1), GetClientSyncSW(client, 2));
		if (numFrames >= 300)
		{
			LogSuspect(client, SuspectDetection 1, "Suspected of having too many perfect keychanges.\nDetection: Key Holdtime |A/D|", numFrames, 0);
			switch (numFrames)
			{
				case 300: {
				}
				case 400: {
				}
				case 500: {
					KickClient(client, "Strafe configs are not allowed on this server!");
				}
				default: {
				}
			}
			Handle sync = CreateHudSynchronizer();
			if (sync)
			{
				SetHudTextParams(-1, -0,8, 5, 255, 255, 255, 255, 0, 5, 0,1, 0,2);
				ShowSyncHudText(client, sync, "Strafe configs are not allowed on this server!");
				CloseHandle(sync);
			}
		}
	}
	return void 0;
}

void AntiCheatCheck_KeysWS(int client, int numFrames)
{
	int var1;
	if (numFrames)
	{
		SayText2Admins("\x01\x07FFD700%N is suspected of having too many perfect key changes! |W/S| (%d)", client, numFrames);
		SayText2Admins("\x01\x07FFFFFFF Sync at frame \x07FFFF00%d\x07FFFFFF:  \x0700FF08%f \x07FFFFFF| \x0700FF08%f \x07FFFFFF| \x0700FF08%f", g_CurrentFrame[client], GetClientSync(client, 0), GetClientSync(client, 1), GetClientSync(client, 2));
		SayText2Admins("\x01\x07FFFFFFS Sync at frame \x07FFFF00%d\x07FFFFFF:  \x0700FF08%f \x07FFFFFF| \x0700FF08%f \x07FFFFFF| \x0700FF08%f", g_CurrentFrameSW[client], GetClientSyncSW(client, 0), GetClientSyncSW(client, 1), GetClientSyncSW(client, 2));
		if (numFrames >= 300)
		{
			LogSuspect(client, SuspectDetection 2, "Suspected of having too many perfect keychanges.\nDetection: Key Holdtime |W/S|", numFrames, 0);
			switch (numFrames)
			{
				case 300: {
				}
				case 400: {
				}
				case 500: {
					KickClient(client, "Strafe configs are not allowed on this server!");
				}
				default: {
				}
			}
			Handle sync = CreateHudSynchronizer();
			if (sync)
			{
				SetHudTextParams(-1, -0,8, 5, 255, 255, 255, 255, 0, 5, 0,1, 0,2);
				ShowSyncHudText(client, sync, "Strafe configs are not allowed on this server!");
				CloseHandle(sync);
			}
		}
	}
	return void 0;
}

void CheckSync(int client, int buttons, float fSideMove, float fAngleDiff)
{
	if (__FLOAT_EQ__(0, VelocityLength2D(client)))
	{
		return void 0;
	}
	if (__FLOAT_GT__(fAngleDiff, 0))
	{
		g_TotalSync[client]++;
		g_TimerTotalSync[client]++;
		if (buttons & 512)
		{
			g_GoodSync[client][0][0]++;
			if (!buttons & 1024)
			{
				g_GoodSync[client][0][0][4]++;
				g_TimerGoodSync[client]++;
			}
		}
		if (__FLOAT_LT__(fSideMove, 0))
		{
			g_GoodSync[client][0][0][8]++;
		}
		return void 0;
	}
	if (__FLOAT_LT__(fAngleDiff, 0))
	{
		g_TotalSync[client]++;
		g_TimerTotalSync[client]++;
		if (buttons & 1024)
		{
			g_GoodSync[client][0][0]++;
			if (!buttons & 512)
			{
				g_GoodSync[client][0][0][4]++;
				g_TimerGoodSync[client]++;
			}
		}
		if (__FLOAT_GT__(fSideMove, 0))
		{
			g_GoodSync[client][0][0][8]++;
		}
	}
	return void 0;
}

void CheckSyncSW(int client, int buttons, float fForwardMove, float fAngleDiff, float fAngleY)
{
	if (__FLOAT_EQ__(0, VelocityLength2D(client)))
	{
		return void 0;
	}
	switch (GetDirection(client, fAngleY, 1))
	{
		case 1: {
			if (__FLOAT_GT__(fAngleDiff, 0))
			{
				g_TotalSyncSW[client]++;
				g_TimerTotalSyncSW[client]++;
				if (buttons & 16)
				{
					g_GoodSyncSW[client][0][0]++;
					if (!buttons & 8)
					{
						g_GoodSyncSW[client][0][0][4]++;
						g_TimerGoodSyncSW[client]++;
					}
				}
				if (__FLOAT_LT__(fForwardMove, 0))
				{
					g_GoodSyncSW[client][0][0][8]++;
				}
				return void 0;
			}
			if (__FLOAT_LT__(fAngleDiff, 0))
			{
				g_TotalSyncSW[client]++;
				g_TimerTotalSyncSW[client]++;
				if (buttons & 8)
				{
					g_GoodSyncSW[client][0][0]++;
					if (!buttons & 16)
					{
						g_GoodSyncSW[client][0][0][4]++;
						g_TimerGoodSyncSW[client]++;
					}
				}
				if (__FLOAT_GT__(fForwardMove, 0))
				{
					g_GoodSyncSW[client][0][0][8]++;
				}
			}
		}
		case 2: {
			if (__FLOAT_GT__(fAngleDiff, 0))
			{
				g_TotalSyncSW[client]++;
				g_TimerTotalSyncSW[client]++;
				if (buttons & 8)
				{
					g_GoodSyncSW[client][0][0]++;
					if (!buttons & 16)
					{
						g_GoodSyncSW[client][0][0][4]++;
						g_TimerGoodSyncSW[client]++;
					}
				}
				if (__FLOAT_GT__(fForwardMove, 0))
				{
					g_GoodSyncSW[client][0][0][8]++;
				}
				return void 0;
			}
			if (__FLOAT_LT__(fAngleDiff, 0))
			{
				g_TotalSyncSW[client]++;
				g_TimerTotalSyncSW[client]++;
				if (buttons & 16)
				{
					g_GoodSyncSW[client][0][0]++;
					if (!buttons & 8)
					{
						g_GoodSyncSW[client][0][0][4]++;
						g_TimerGoodSyncSW[client]++;
					}
				}
				if (__FLOAT_LT__(fForwardMove, 0))
				{
					g_GoodSyncSW[client][0][0][8]++;
				}
			}
		}
		default: {
		}
	}
	return void 0;
}

void CheckSyncHSW(int client, int buttons, float fAngleDiff)
{
	if (__FLOAT_EQ__(0, VelocityLength2D(client)))
	{
		return void 0;
	}
	if (__FLOAT_GT__(fAngleDiff, 0))
	{
		g_TimerTotalSyncHSW[client]++;
		if (buttons & 8)
		{
			if (buttons & 512)
			{
				if (!buttons & 1024)
				{
					g_TimerGoodSyncHSW[client]++;
				}
			}
		}
		return void 0;
	}
	if (__FLOAT_LT__(fAngleDiff, 0))
	{
		g_TimerTotalSyncHSW[client]++;
		if (buttons & 8)
		{
			if (buttons & 1024)
			{
				if (!buttons & 512)
				{
					g_TimerGoodSyncHSW[client]++;
				}
			}
		}
	}
	return void 0;
}

int GetDirection(int client, float fAngleY, int type)
{
	float vVel[3];
	GetEntPropVector(client, PropType 1, "m_vecAbsVelocity", vVel, 0);
	float fTempAngle = 0;
	switch (type)
	{
		case 0: {
			fTempAngle = fAngleY;
		}
		case 1: {
			fTempAngle = FloatAdd(90, fAngleY);
		}
		default: {
		}
	}
	VectorAngles(vVel, fAngleY);
	if (__FLOAT_LT__(fTempAngle, 0))
	{
		fTempAngle = FloatAdd(360, fTempAngle);
	}
	float fTempAngle2 = FloatSub(fTempAngle, fAngleY);
	if (__FLOAT_LT__(fTempAngle2, 0))
	{
		fTempAngle2 = operator-(Float:)(fTempAngle2);
	}
	switch (type)
	{
		case 0: {
			int var3;
			if (__FLOAT_LT__(fTempAngle2, 22,5))
			{
				return 1;
			}
			int var4;
			if (__FLOAT_GT__(fTempAngle2, 67,5))
			{
				return 2;
			}
			int var7;
			if (__FLOAT_GT__(fTempAngle2, 22,5))
			{
				return 3;
			}
		}
		case 1: {
			int var1;
			if (__FLOAT_LT__(fTempAngle2, 22,5))
			{
				return 1;
			}
			int var2;
			if (__FLOAT_GT__(fTempAngle2, 157,5))
			{
				return 2;
			}
		}
		default: {
		}
	}
	return 0;
}


/* ERROR! Unrecognized opcode sysreq_c */
 function "VectorAngles" (number 37)
float VelocityLength2D(int client)
{
	float vVel[3];
	GetEntPropVector(client, PropType 1, "m_vecAbsVelocity", vVel, 0);
	vVel[8] = 0;
	return GetVectorLength(vVel, false);
}


/* ERROR! Das Objekt des Typs "Lysis.DReturn" kann nicht in Typ "Lysis.DJumpCondition" umgewandelt werden. */
 function "IsSyncEqual" (number 39)
float TruncateFloat(float trunc)
{
	return FloatDiv(float(RoundToNearest(FloatMul(100, trunc))), 100);
}

int SayText2(int to, char message[])
{
	Handle hBf = StartMessageOne("SayText2", to, 0);
	if (!hBf)
	{
		return 0;
	}
	char buffer[1024];
	VFormat(buffer, 1024, message, 3);
	BfWriteByte(hBf, to);
	BfWriteByte(hBf, 1);
	BfWriteString(hBf, buffer);
	EndMessage();
	return 0;
}

int SayText2All(char message[])
{
	int to = 1;
	while (to <= MaxClients)
	{
		int var1;
		if (!IsClientInGame(to))
		{
		}
		else
		{
			Handle hBf = StartMessageOne("SayText2", to, 0);
			if (!hBf)
			{
				return 0;
			}
			char buffer[1024];
			VFormat(buffer, 1024, message, 2);
			BfWriteByte(hBf, to);
			BfWriteByte(hBf, 1);
			BfWriteString(hBf, buffer);
			EndMessage();
		}
		to++;
	}
	return 0;
}

int SayText2Admins(char message[])
{
	int to = 1;
	while (to <= MaxClients)
	{
		int var1;
		if (!IsClientInGame(to))
		{
		}
		else
		{
			Handle hBf = StartMessageOne("SayText2", to, 0);
			if (!hBf)
			{
				return 0;
			}
			char buffer[1024];
			VFormat(buffer, 1024, message, 2);
			BfWriteByte(hBf, to);
			BfWriteByte(hBf, 1);
			BfWriteString(hBf, buffer);
			EndMessage();
		}
		to++;
	}
	return 0;
}

int TopMessage(int client, char text[])
{
	char message[128];
	VFormat(message, 128, text, 3);
	Handle kv = CreateKeyValues("Stuff", "title", message);
	KvSetColor(kv, "color", 0, 255, 50, 255);
	KvSetNum(kv, "level", 1);
	KvSetNum(kv, "time", 10);
	CreateDialog(client, kv, DialogType 0);
	CloseHandle(kv);
	return 0;
}

bool IsAdmin(int client)
{
	AdminId admin = GetUserAdmin(client);
	bool customFlag = GetAdminFlag(admin, AdminFlag 1, AdmAccessMode 1);
	if (customFlag)
	{
		return true;
	}
	return false;
}

int FreezeClient(int client, float time)
{
	SetEntityMoveType(client, MoveType 0);
	SetEntityRenderColor(client, 255, 128, 0, 190);
	float vec[3];
	GetClientEyePosition(client, vec);
	EmitAmbientSound("physics/glass/glass_impact_bullet4.wav", vec, client, 130, 0, 1, 100, 0);
	CreateTimer(time, Timer_FreezeClient, GetClientUserId(client), 0);
	return 0;
}

public Action Timer_FreezeClient(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	int var1;
	if (!client)
	{
		return Action 0;
	}
	float vec[3];
	GetClientAbsOrigin(client, vec);
	vec[8] += 10;
	GetClientEyePosition(client, vec);
	EmitAmbientSound("physics/glass/glass_impact_bullet4.wav", vec, client, 130, 0, 1, 100, 0);
	float vVel[3];
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
	SetEntityMoveType(client, MoveType 2);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	return Action 0;
}

int FreezeSilent(int client, float time)
{
	SetEntityMoveType(client, MoveType 0);
	CreateTimer(time, Timer_FreezeSilent, GetClientUserId(client), 0);
	return 0;
}

public Action Timer_FreezeSilent(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	int var1;
	if (!client)
	{
		return Action 0;
	}
	float vVel[3];
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
	SetEntityMoveType(client, MoveType 2);
	return Action 0;
}

public Action Timer_PreventInvalidMovSpam(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (!client)
	{
		return Action 0;
	}
	g_bPreventInvalidMovSpam[client] = 0;
	return Action 0;
}

public Action SM_StartRecord(int args)
{
	if (args < 1)
	{
		return Action 3;
	}
	char sUserID[16];
	GetCmdArgString(sUserID, 16);
	int client = GetClientOfUserId(StringToInt(sUserID, 10));
	if (!client)
	{
		return Action 3;
	}
	g_TimerTotalSync[client] = 0;
	g_TimerGoodSync[client] = 0;
	g_TimerTotalSyncSW[client] = 0;
	g_TimerGoodSyncSW[client] = 0;
	g_TimerTotalSyncHSW[client] = 0;
	g_TimerGoodSyncHSW[client] = 0;
	g_TotalStrafes[client] = 0;
	g_GoodStrafes[client] = 0;
	g_PerfectStrafes[client] = 0;
	return Action 3;
}

public Action SM_GetSync(int args)
{
	if (args < 1)
	{
		return Action 3;
	}
	char sUserID[16];
	char sStyle[8];
	char sSync[8];
	GetCmdArg(1, sUserID, 16);
	GetCmdArg(2, sStyle, 8);
	int client = GetClientOfUserId(StringToInt(sUserID, 10));
	if (!client)
	{
		return Action 3;
	}
	int style = StringToInt(sStyle, 10);
	switch (style)
	{
		case 1: {
			float fSync = GetClientTimerSync(client);
			FloatToString(fSync, sSync, 8);
			ServerCommand("sm_es_receivesync %s %.5s", sUserID, sSync);
		}
		case 2: {
			float fSync = GetClientTimerSyncSW(client);
			FloatToString(fSync, sSync, 8);
			ServerCommand("sm_es_receivesync %s %.5s", sUserID, sSync);
		}
		case 3: {
			float fSync = GetClientTimerSyncHSW(client);
			FloatToString(fSync, sSync, 8);
			ServerCommand("sm_es_receivesync %s %.5s", sUserID, sSync);
		}
		default: {
		}
	}
	return Action 3;
}

float GetClientSync(int client, int syncNum)
{
	if (0 < g_TotalSync[client][0][0])
	{
		return FloatMul(100, FloatDiv(float(g_GoodSync[client][0][0][syncNum]), float(g_TotalSync[client][0][0])));
	}
	return 0;
}

float GetClientSyncSW(int client, int syncNum)
{
	if (0 < g_TotalSyncSW[client][0][0])
	{
		return FloatMul(100, FloatDiv(float(g_GoodSyncSW[client][0][0][syncNum]), float(g_TotalSyncSW[client][0][0])));
	}
	return 0;
}

float GetClientTimerSync(int client)
{
	if (0 < g_TimerTotalSync[client][0][0])
	{
		return FloatMul(100, FloatDiv(float(g_TimerGoodSync[client][0][0]), float(g_TimerTotalSync[client][0][0])));
	}
	return 0;
}

float GetClientTimerSyncSW(int client)
{
	if (0 < g_TimerTotalSyncSW[client][0][0])
	{
		return FloatMul(100, FloatDiv(float(g_TimerGoodSyncSW[client][0][0]), float(g_TimerTotalSyncSW[client][0][0])));
	}
	return 0;
}

float GetClientTimerSyncHSW(int client)
{
	if (0 < g_TimerTotalSyncHSW[client][0][0])
	{
		return FloatMul(100, FloatDiv(float(g_TimerGoodSyncHSW[client][0][0]), float(g_TimerTotalSyncHSW[client][0][0])));
	}
	return 0;
}

float GetClientStrafePerf(int client)
{
	if (0 < g_TotalStrafes[client][0][0])
	{
		return FloatMul(100, FloatDiv(float(g_PerfectStrafes[client][0][0]), float(g_TotalStrafes[client][0][0])));
	}
	return 0;
}

float GetClientGoodStrafePerf(int client)
{
	if (0 < g_TotalStrafes[client][0][0])
	{
		return FloatMul(100, FloatDiv(float(g_GoodStrafes[client][0][0]), float(g_TotalStrafes[client][0][0])));
	}
	return 0;
}


/* ERROR! Unrecognized opcode stradjust_pri */
 function "LogSuspect" (number 60)

/* ERROR! Unrecognized opcode stradjust_pri */
 function "LogCheater" (number 61)
void SQL_DBConnect()
{
	char sDatabaseDriver[64];
	GetConVarString(gH_Cvar_Database_Driver, sDatabaseDriver, 64);
	if (SQL_CheckConfig(sDatabaseDriver))
	{
		if (gH_Database)
		{
			CloseHandle(gH_Database);
			gH_Database = 0;
		}
		SQL_TConnect(SQLTCallback 11, sDatabaseDriver, any 0);
	}
	else
	{
		PrintToServer("[ASH] Error: could not find database configuration '%s' at databases.cfg", sDatabaseDriver);
		LogError("[ASH] Error: could not find database configuration '%s' at databases.cfg", sDatabaseDriver);
	}
	return void 0;
}

public int DB_Callback_DBConnect(Handle owner, Handle hndl, char error[], any data)
{
	if (hndl)
	{
		gH_Database = hndl;
		PrintToServer("[ASH] Database connection successful.");
		return 0;
	}
	PrintToServer("[ASH] Database connection failure: %s", error);
	LogError("[ASH] Database connection failure: %s", error);
	return 0;
}

public int DB_Callback_Insert(Handle owner, Handle hndl, char error[], any data)
{
	if (hndl)
	{
		return 0;
	}
	LogError("[ASH] Error on DB_Callback_Insert: %s", error);
	return 0;
}

public Action SM_AshDB(int args)
{
	SQL_DBConnect();
	return Action 3;
}

public Action SM_AshDebug(int client, int args)
{
	if (!client)
	{
		ReplyToCommand(client, "You cannot run this command through the server console.");
		return Action 3;
	}
	if (!IsAdmin(client))
	{
		SayText2(client, "\x01\x07FFFFFF[ASH] You are not authorized to run this command.");
		return Action 3;
	}
	AshDebugMenu(client, g_AdminMenuPage[client][0][0]);
	return Action 3;
}

void AshDebugMenu(int client, int page)
{
	Handle panel = CreatePanel(Handle 0);
	SetPanelTitle(panel, "[ASH] Admin Debug Menu", false);
	DrawPanelItem(panel, "Choose a player to debug", 0);
	char sText[256];
	int target = GetClientOfUserId(g_AdminSelectedUserID[client][0][0]);
	if (target)
	{
		FormatEx(sText, 256, "Current player: %N", target);
		DrawPanelText(panel, sText);
	}
	DrawPanelText(panel, " ");
	switch (page)
	{
		case 1: {
			DrawPanelText(panel, "Switches:");
			int var10;
			if (g_bPrintAnalysis[client][0][0])
			{
				var10 = 109748;
			}
			else
			{
				var10 = 109752;
			}
			FormatEx(sText, 256, "[%s] - Analysis", var10);
			DrawPanelItem(panel, sText, 0);
			int var11;
			if (g_bDebugStrafes[client][0][0])
			{
				var11 = 109772;
			}
			else
			{
				var11 = 109776;
			}
			FormatEx(sText, 256, "[%s] - Strafes", var11);
			DrawPanelItem(panel, sText, 0);
			int var12;
			if (g_bCheckSync[client][0][0])
			{
				var12 = 109792;
			}
			else
			{
				var12 = 109796;
			}
			FormatEx(sText, 256, "[%s] - Sync", var12);
			DrawPanelItem(panel, sText, 0);
			DrawPanelText(panel, " ");
			DrawPanelText(panel, "Executables:");
			DrawPanelItem(panel, "Analyse Current Strafes", 0);
			DrawPanelItem(panel, "Print Sync", 0);
			DrawPanelText(panel, " ");
			DrawPanelText(panel, "Section: Forwards");
			DrawPanelText(panel, "Page: 1/4");
			DrawPanelText(panel, " ");
			DrawPanelText(panel, " ");
			SetPanelCurrentKey(panel, 9);
			DrawPanelItem(panel, "Next", 0);
			SetPanelCurrentKey(panel, 10);
			DrawPanelItem(panel, "Exit", 16);
			SendPanelToClient(panel, client, MenuHandler 1, 0);
		}
		case 2: {
			DrawPanelText(panel, "Switches:");
			int var7;
			if (g_bPrintAnalysisSW[client][0][0])
			{
				var7 = 109944;
			}
			else
			{
				var7 = 109948;
			}
			FormatEx(sText, 256, "[%s] - Analysis", var7);
			DrawPanelItem(panel, sText, 0);
			int var8;
			if (g_bDebugStrafesSW[client][0][0])
			{
				var8 = 109968;
			}
			else
			{
				var8 = 109972;
			}
			FormatEx(sText, 256, "[%s] - Strafes", var8);
			DrawPanelItem(panel, sText, 0);
			int var9;
			if (g_bCheckSyncSW[client][0][0])
			{
				var9 = 109988;
			}
			else
			{
				var9 = 109992;
			}
			FormatEx(sText, 256, "[%s] - Sync", var9);
			DrawPanelItem(panel, sText, 0);
			DrawPanelText(panel, " ");
			DrawPanelText(panel, "Executables:");
			DrawPanelItem(panel, "Analyse Current Strafes", 0);
			DrawPanelItem(panel, "Print Sync", 0);
			DrawPanelText(panel, " ");
			DrawPanelText(panel, "Section: Sideways");
			DrawPanelText(panel, "Page: 2/4");
			DrawPanelText(panel, " ");
			SetPanelCurrentKey(panel, 8);
			DrawPanelItem(panel, "Previous", 0);
			SetPanelCurrentKey(panel, 9);
			DrawPanelItem(panel, "Next", 0);
			SetPanelCurrentKey(panel, 10);
			DrawPanelItem(panel, "Exit", 16);
			SendPanelToClient(panel, client, MenuHandler 3, 0);
		}
		case 3: {
			DrawPanelText(panel, "Switches:");
			int var5;
			if (g_bDebugKeysHoldtimeAD[client][0][0])
			{
				var5 = 110156;
			}
			else
			{
				var5 = 110160;
			}
			FormatEx(sText, 256, "[%s] - Holdtime |A/D|", var5);
			DrawPanelItem(panel, sText, 0);
			int var6;
			if (g_bDebugKeysHoldtimeWS[client][0][0])
			{
				var6 = 110188;
			}
			else
			{
				var6 = 110192;
			}
			FormatEx(sText, 256, "[%s] - Holdtime |W/S|", var6);
			DrawPanelItem(panel, sText, 0);
			DrawPanelText(panel, " ");
			DrawPanelText(panel, "Section: Keys");
			DrawPanelText(panel, "Page: 3/4");
			DrawPanelText(panel, " ");
			SetPanelCurrentKey(panel, 8);
			DrawPanelItem(panel, "Previous", 0);
			SetPanelCurrentKey(panel, 9);
			DrawPanelItem(panel, "Next", 0);
			SetPanelCurrentKey(panel, 10);
			DrawPanelItem(panel, "Exit", 16);
			SendPanelToClient(panel, client, MenuHandler 5, 0);
		}
		case 4: {
			DrawPanelText(panel, "Switches:");
			int var1;
			if (g_bConsoleOutput[client][0][0])
			{
				var1 = 110296;
			}
			else
			{
				var1 = 110300;
			}
			FormatEx(sText, 256, "[%s] - Console Output", var1);
			DrawPanelItem(panel, sText, 0);
			int var2;
			if (g_bPrintAngleDiff[client][0][0])
			{
				var2 = 110336;
			}
			else
			{
				var2 = 110340;
			}
			FormatEx(sText, 256, "[%s] - Print Y AngleDiff >70", var2);
			DrawPanelItem(panel, sText, 0);
			int var3;
			if (g_bCheckAngleDiff[client][0][0])
			{
				var3 = 110372;
			}
			else
			{
				var3 = 110376;
			}
			FormatEx(sText, 256, "[%s] - Check Y AngleDiff", var3);
			DrawPanelItem(panel, sText, 0);
			int var4;
			if (gH_TimerTopMsg[client][0][0])
			{
				var4 = 110416;
			}
			else
			{
				var4 = 110420;
			}
			FormatEx(sText, 256, "[%s] - Strafe Perfection [F Only]", var4);
			DrawPanelItem(panel, sText, 0);
			DrawPanelText(panel, " ");
			DrawPanelText(panel, "Section: Advanced");
			DrawPanelText(panel, "Page: 4/4");
			DrawPanelText(panel, " ");
			SetPanelCurrentKey(panel, 8);
			DrawPanelItem(panel, "Previous", 0);
			DrawPanelText(panel, " ");
			SetPanelCurrentKey(panel, 10);
			DrawPanelItem(panel, "Exit", 16);
			SendPanelToClient(panel, client, MenuHandler 7, 0);
		}
		default: {
		}
	}
	CloseHandle(panel);
	return void 0;
}

public int AshDebugMenu_Page1(Handle panel, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case 4: {
			switch (param2)
			{
				case 1: {
					SelectPlayer(param1);
				}
				case 2: {
					g_bPrintAnalysis[param1] = !g_bPrintAnalysis[param1][0][0];
					g_bIsDebugOnAnalysis = IsDebugOnAnalysis();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 3: {
					g_bDebugStrafes[param1] = !g_bDebugStrafes[param1][0][0];
					g_bIsDebugOnStrafes = IsDebugOnStrafes();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 4: {
					g_bCheckSync[param1] = !g_bCheckSync[param1][0][0];
					int var3;
					if (g_bCheckSync[param1][0][0])
					{
						g_bCheckSyncSW[param1] = 0;
					}
					g_bIsDebugOnSync = IsDebugOnSync();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 5: {
					int target = GetClientOfUserId(g_AdminSelectedUserID[param1][0][0]);
					int var2;
					if (!target)
					{
						SayText2(param1, "\x01\x07FFFFFF[ASH] The player you picked is not available.");
					}
					else
					{
						int movedFirstCount = 0;
						int turnedFirstCount = 0;
						int movedFirstPerfect = 0;
						int turnedFirstPerfect = 0;
						int movedFirst1 = 0;
						int turnedFirst1 = 0;
						int movedFirst2 = 0;
						int turnedFirst2 = 0;
						CountFrames(target, g_Frames, g_CurrentFrame[target][0][0], movedFirstCount, turnedFirstCount, movedFirstPerfect, turnedFirstPerfect, movedFirst1, turnedFirst1, movedFirst2, turnedFirst2);
						SayText2(param1, "\x01\x07FFFF00%d\x07FFFFFF Strafes Tick Difference Analysis", g_CurrentFrame[target]);
						SayText2(param1, "\x01\x07FFFFFFMF:  \x0700FF08%d  \x07FFFFFFMF2:  \x0700FF08%d  \x07FFFFFFMF1:  \x0700FF08%d  \x07FFFFFFMFP:  \x0700FF08%d", movedFirstCount, movedFirst2, movedFirst1, movedFirstPerfect);
						SayText2(param1, "\x01\x07FFFFFFTF:  \x0700FF08%d  \x07FFFFFFTF2:  \x0700FF08%d  \x07FFFFFFTF1:  \x0700FF08%d  \x07FFFFFFTFP:  \x0700FF08%d", turnedFirstCount, turnedFirst2, turnedFirst1, turnedFirstPerfect);
						SayText2(param1, "\x01\x07FFFFFFSync:  \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f", GetClientSync(target, 0), GetClientSync(target, 1), GetClientSync(target, 2));
						SayText2(param1, "\x01\x07FFFFFFPlayer: \x0700FF08%N", target);
					}
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 6: {
					int target = GetClientOfUserId(g_AdminSelectedUserID[param1][0][0]);
					int var1;
					if (!target)
					{
						SayText2(param1, "\x01\x07FFFFFF[ASH] The player you picked is not available.");
					}
					else
					{
						SayText2(param1, "\x01\x07FFFFFFF Sync at frame \x07FFFF00%d\x07FFFFFF:", g_CurrentFrame[target]);
						SayText2(param1, "\x01\x07FFFFFF#1: \x0700FF08%f", GetClientSync(target, 0));
						SayText2(param1, "\x01\x07FFFFFF#2: \x0700FF08%f", GetClientSync(target, 1));
						SayText2(param1, "\x01\x07FFFFFF#3: \x0700FF08%f", GetClientSync(target, 2));
						SayText2(param1, "\x01\x07FFFFFFPlayer: \x0700FF08%N", target);
					}
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 9: {
					g_AdminMenuPage[param1]++;
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				default: {
				}
			}
		}
		default: {
		}
	}
	return 0;
}

public int AshDebugMenu_Page2(Handle panel, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case 4: {
			switch (param2)
			{
				case 1: {
					SelectPlayer(param1);
				}
				case 2: {
					g_bPrintAnalysisSW[param1] = !g_bPrintAnalysisSW[param1][0][0];
					g_bIsDebugOnAnalysisSW = IsDebugOnAnalysisSW();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 3: {
					g_bDebugStrafesSW[param1] = !g_bDebugStrafesSW[param1][0][0];
					g_bIsDebugOnStrafesSW = IsDebugOnStrafesSW();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 4: {
					g_bCheckSyncSW[param1] = !g_bCheckSyncSW[param1][0][0];
					int var3;
					if (g_bCheckSyncSW[param1][0][0])
					{
						g_bCheckSync[param1] = 0;
					}
					g_bIsDebugOnSync = IsDebugOnSync();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 5: {
					int target = GetClientOfUserId(g_AdminSelectedUserID[param1][0][0]);
					int var2;
					if (!target)
					{
						SayText2(param1, "\x01\x07FFFFFF[ASH] The player you picked is not available.");
					}
					else
					{
						int movedFirstCount = 0;
						int turnedFirstCount = 0;
						int movedFirstPerfect = 0;
						int turnedFirstPerfect = 0;
						int movedFirst1 = 0;
						int turnedFirst1 = 0;
						int movedFirst2 = 0;
						int turnedFirst2 = 0;
						CountFrames(target, g_FramesSW, g_CurrentFrameSW[target][0][0], movedFirstCount, turnedFirstCount, movedFirstPerfect, turnedFirstPerfect, movedFirst1, turnedFirst1, movedFirst2, turnedFirst2);
						SayText2(param1, "\x01\x07FFFF00%d\x07FFFFFF Strafes Tick Difference Analysis [Sideways]", g_CurrentFrameSW[target]);
						SayText2(param1, "\x01\x07FFFFFFMF:  \x0700FF08%d  \x07FFFFFFMF2:  \x0700FF08%d  \x07FFFFFFMF1:  \x0700FF08%d  \x07FFFFFFMFP:  \x0700FF08%d", movedFirstCount, movedFirst2, movedFirst1, movedFirstPerfect);
						SayText2(param1, "\x01\x07FFFFFFTF:  \x0700FF08%d  \x07FFFFFFTF2:  \x0700FF08%d  \x07FFFFFFTF1:  \x0700FF08%d  \x07FFFFFFTFP:  \x0700FF08%d", turnedFirstCount, turnedFirst2, turnedFirst1, turnedFirstPerfect);
						SayText2(param1, "\x01\x07FFFFFFSync:  \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f \x07FFFFFF| \x0700FF08%.2f", GetClientSyncSW(target, 0), GetClientSyncSW(target, 1), GetClientSyncSW(target, 2));
						SayText2(param1, "\x01\x07FFFFFFPlayer: \x0700FF08%N", target);
					}
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 6: {
					int target = GetClientOfUserId(g_AdminSelectedUserID[param1][0][0]);
					int var1;
					if (!target)
					{
						SayText2(param1, "\x01\x07FFFFFF[ASH] The player you picked is not available.");
					}
					else
					{
						SayText2(param1, "\x01\x07FFFFFFS Sync at frame \x07FFFF00%d\x07FFFFFF:", g_CurrentFrameSW[target]);
						SayText2(param1, "\x01\x07FFFFFF#1: \x0700FF08%f", GetClientSyncSW(target, 0));
						SayText2(param1, "\x01\x07FFFFFF#2: \x0700FF08%f", GetClientSyncSW(target, 1));
						SayText2(param1, "\x01\x07FFFFFF#3: \x0700FF08%f", GetClientSyncSW(target, 2));
						SayText2(param1, "\x01\x07FFFFFFPlayer: \x0700FF08%N", target);
					}
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 8: {
					g_AdminMenuPage[param1]--;
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 9: {
					g_AdminMenuPage[param1]++;
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				default: {
				}
			}
		}
		default: {
		}
	}
	return 0;
}

public int AshDebugMenu_Page3(Handle panel, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case 4: {
			switch (param2)
			{
				case 1: {
					SelectPlayer(param1);
				}
				case 2: {
					g_bDebugKeysHoldtimeAD[param1] = !g_bDebugKeysHoldtimeAD[param1][0][0];
					g_bIsDebugOnKeysAD = IsDebugOnKeysAD();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 3: {
					g_bDebugKeysHoldtimeWS[param1] = !g_bDebugKeysHoldtimeWS[param1][0][0];
					g_bIsDebugOnKeysWS = IsDebugOnKeysWS();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 8: {
					g_AdminMenuPage[param1]--;
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 9: {
					g_AdminMenuPage[param1]++;
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				default: {
				}
			}
		}
		default: {
		}
	}
	return 0;
}

public int AshDebugMenu_Page4(Handle panel, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case 4: {
			switch (param2)
			{
				case 1: {
					SelectPlayer(param1);
				}
				case 2: {
					g_bConsoleOutput[param1] = !g_bConsoleOutput[param1][0][0];
					g_bIsDebugOnAdv = IsDebugOnAdv();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 3: {
					g_bPrintAngleDiff[param1] = !g_bPrintAngleDiff[param1][0][0];
					g_bIsDebugOnAdv = IsDebugOnAdv();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 4: {
					g_bCheckAngleDiff[param1] = !g_bCheckAngleDiff[param1][0][0];
					g_bIsDebugOnAdv = IsDebugOnAdv();
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 5: {
					if (gH_TimerTopMsg[param1][0][0])
					{
						KillTimer(gH_TimerTopMsg[param1][0][0], false);
						gH_TimerTopMsg[param1] = 0;
					}
					else
					{
						gH_TimerTopMsg[param1] = CreateTimer(11,1, Timer_TopMsg, param1, 1);
					}
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				case 8: {
					g_AdminMenuPage[param1]--;
					AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
				}
				default: {
				}
			}
		}
		default: {
		}
	}
	return 0;
}

void SelectPlayer(int client)
{
	Handle menu = CreateMenu(MenuHandler 39, MenuAction 28);
	SetMenuTitle(menu, "[ASH] Admin Debug Menu");
	int userid;
	char sBuffer[32];
	char sName[64];
	int i = 1;
	while (i <= MaxClients)
	{
		int var1;
		if (!IsClientConnected(i))
		{
		}
		else
		{
			userid = GetClientUserId(i);
			IntToString(userid, sBuffer, 32);
			GetClientName(i, sName, 64);
			AddMenuItem(menu, sBuffer, sName, 0);
		}
		i++;
	}
	SetMenuOptionFlags(menu, 7);
	DisplayMenu(menu, client, 0);
	return void 0;
}

public int SelectPlayer_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction 16)
	{
		CloseHandle(menu);
	}
	else
	{
		if (action == MenuAction 8)
		{
			if (param2 == -6)
			{
				AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
			}
		}
		if (action == MenuAction 4)
		{
			char sInfo[32];
			int userid = 0;
			int target = 0;
			GetMenuItem(menu, param2, sInfo, 32, 0, "", 0);
			userid = StringToInt(sInfo, 10);
			target = GetClientOfUserId(userid);
			int var1;
			if (!target)
			{
				SayText2(param1, "\x01\x07FFFFFF[ASH] The player you picked is no longer available.");
			}
			else
			{
				g_AdminSelectedUserID[param1] = userid;
				AshDebugMenu(param1, g_AdminMenuPage[param1][0][0]);
			}
		}
	}
	return 0;
}

bool IsDebugOnAnalysis()
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (g_bPrintAnalysis[i][0][0])
		{
			return true;
		}
		i++;
	}
	return false;
}

bool IsDebugOnStrafes()
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (g_bDebugStrafes[i][0][0])
		{
			return true;
		}
		i++;
	}
	return false;
}

bool IsDebugOnAnalysisSW()
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (g_bPrintAnalysisSW[i][0][0])
		{
			return true;
		}
		i++;
	}
	return false;
}

bool IsDebugOnStrafesSW()
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (g_bDebugStrafesSW[i][0][0])
		{
			return true;
		}
		i++;
	}
	return false;
}

bool IsDebugOnSync()
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (g_bCheckSync[i][0][0])
		{
			return true;
		}
		if (g_bCheckSyncSW[i][0][0])
		{
			return true;
		}
		i++;
	}
	return false;
}

bool IsDebugOnKeysAD()
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (g_bDebugKeysHoldtimeAD[i][0][0])
		{
			return true;
		}
		i++;
	}
	return false;
}

bool IsDebugOnKeysWS()
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (g_bDebugKeysHoldtimeWS[i][0][0])
		{
			return true;
		}
		i++;
	}
	return false;
}

bool IsDebugOnAdv()
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (g_bConsoleOutput[i][0][0])
		{
			return true;
		}
		if (g_bPrintAngleDiff[i][0][0])
		{
			return true;
		}
		if (g_bCheckAngleDiff[i][0][0])
		{
			return true;
		}
		i++;
	}
	return false;
}

void DebugAdvanced(int client, float fForwardMove, float fSideMove, float fAngleX, float fAngleY, float fAngleDiff, int skippedFrames)
{
	int i = 1;
	while (i <= MaxClients)
	{
		int var1;
		if (!IsClientInGame(i))
		{
		}
		else
		{
			if (g_bConsoleOutput[i][0][0])
			{
				int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
				if (client == target)
				{
					PrintToConsole(i, "%N  FM: %.2f  SM: %.2f  AX: %.2f  AY: %.2f  AYDiff: %.2f", client, fForwardMove, fSideMove, fAngleX, fAngleY, fAngleDiff);
				}
			}
			if (g_bPrintAngleDiff[i][0][0])
			{
				int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
				if (client == target)
				{
					int var2;
					if (__FLOAT_GT__(fAngleDiff, 70))
					{
						if (skippedFrames)
						{
							SayText2(i, "\x01\x07FFFFFF[ASH] \x0700FF08%N \x07FFFFFFAngleDiff: \x07FFFF00%.3f \x07FFFFFF(Tele/Spawn | Skipped Frames: \x07FFFF00%d\x07FFFFFF/20)", client, fAngleDiff, 20 - skippedFrames);
						}
						SayText2(i, "\x01\x07FFFFFF[ASH] \x0700FF08%N \x07FFFFFFAngleDiff: \x07FFFF00%.3f", client, fAngleDiff);
					}
				}
			}
			if (g_bCheckAngleDiff[i][0][0])
			{
				int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
				if (client == target)
				{
					if (__FLOAT_GT__(fAngleDiff, 0))
					{
						PrintCenterText(i, "< %f  ", fAngleDiff);
					}
					if (__FLOAT_LT__(fAngleDiff, 0))
					{
						PrintCenterText(i, "  %f >", fAngleDiff);
					}
					PrintCenterText(i, "%f", fAngleDiff);
				}
			}
		}
		i++;
	}
	return void 0;
}

void DebugSync(int client)
{
	int i = 1;
	while (i <= MaxClients)
	{
		int var1;
		if (!IsClientInGame(i))
		{
		}
		else
		{
			if (g_bCheckSync[i][0][0])
			{
				int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
				if (client == target)
				{
					Handle sync = CreateHudSynchronizer();
					if (sync)
					{
						SetHudTextParams(-1, -0,8, 0,1, 0, 127, 255, 255, 0, 0, 0, 0);
						ShowSyncHudText(i, sync, "F O R W A R D S\n%.2f | %.2f | %.2f", GetClientSync(client, 0), GetClientSync(client, 1), GetClientSync(client, 2));
						CloseHandle(sync);
					}
				}
			}
			if (g_bCheckSyncSW[i][0][0])
			{
				int target = GetClientOfUserId(g_AdminSelectedUserID[i][0][0]);
				if (client == target)
				{
					Handle sync = CreateHudSynchronizer();
					if (sync)
					{
						SetHudTextParams(-1, -0,8, 0,1, 0, 127, 255, 255, 0, 0, 0, 0);
						ShowSyncHudText(i, sync, "S I D E W A Y S\n%.2f | %.2f | %.2f", GetClientSyncSW(client, 0), GetClientSyncSW(client, 1), GetClientSyncSW(client, 2));
						CloseHandle(sync);
					}
				}
			}
		}
		i++;
	}
	return void 0;
}

void HookTeleports()
{
	int index = -1;
	int var1 = FindEntityByClassname(index, "trigger_teleport");
	index = var1;
	while (var1 != -1)
	{
		HookSingleEntityOutput(index, "OnStartTouch", EntityOutput 41, false);
	}
	return void 0;
}

public int Teleport_OnStartTouch(char output[], int caller, int activator, float delay)
{
	int var1;
	if (activator < 1)
	{
		return 0;
	}
	g_bBlockAngleCheck[activator] = 1;
	return 0;
}

public int Event_PlayerSpawn(Handle event, char name[], bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid", 0));
	g_bBlockAngleCheck[client] = 1;
	return 0;
}


/* ERROR! Das Objekt des Typs "Lysis.DJump" kann nicht in Typ "Lysis.DJumpCondition" umgewandelt werden. */
 function "Timer_TopMsg" (number 87)
