#pragma tabsize 0

#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <csgo_colors>

#define REQUIRE_EXTENSIONS
#include <dhooks>
#include <steamworks>

#pragma newdecls required

#define PLUGIN_VERSION "3.2.1"

#undef REQUIRE_PLUGIN
#include <materialadmin>
#include <sourcebanspp>

#define MS MAXPLAYERS + 1
#define MAX_EDICTS 2048
#define LC(%0) for(int %0 = MaxClients + 1; --%0;)
#define SZF(%0) %0, sizeof(%0)
#define IS_CLIENT(%1)  (1 <= %1 <= MaxClients)
#define MAX_IP_LENGTH 16
#define MAX_LOG_LENGTH 1024
#define MAX_TIME_LENGTH 12
#define SAMPLE 64
#define MAX_AUTHID_LENGTH 32

#define Size 0 // Intrusion prevention, must match the smx Size // .ref 295628
#define key "0" // 64 Digit Key made of all Letters and Numbers
#define time 0 // Unix Time since when the Plugin can be activated // .ref 927583
#define DEBUG 0
#define CHECK_LISENCE 0 // Activate License Check
#define URL "http://license.hotstar-project.net/hotguard/32_01031235346312"
#define ZAPROS "key=%s&ip=%s&port=%i&version=%s&sm=%s"

ArrayList g_hSmokeEnt;

Handle g_hTeleport = null;
int g_iCvar[64];
char g_sCvarChatLog[12], g_sCvarChatSound[20];
bool g_bNiceCheck = false, g_bJoyStick[MS], g_bLateLoad, g_bBan[MS], g_bIsVisible[MS][MS], g_bCacheAlive[MS], g_bCacheFake[MS], g_bSmokeHooked[MS], g_bFlashHooked[MS], g_bAWHooked[MS];
int g_iLerpTime = -1, g_iTickCount, g_iTickCountCMD[MS], g_iWeaponOwner[MAX_EDICTS], iEntPlayerResource = -1, iOffset[8], g_iPVSCache[MS][MS], g_iCacheTicks, g_iCacheTeam[MS], g_iBanType, g_iMinSmokes, m_vecOrigin, m_flFlashDuration, m_flFlashMaxAlpha, g_iInvalidMoveCount[MS], g_iButtonPressedTick[MS][2], /* g_iAutoShootTemp[MS], g_iAutoShoot[MS], g_iAutoShootCount[MS], */g_iDeltaChanged[MS];
float g_vMins[MS][3], g_vMaxs[MS][3], g_vAbsOrigin[MS][3], g_vEyePos[MS][3], g_vEyeAngles[MS][3], g_fSmokeTimeTick, g_fFlashBangTime[MS], g_fMaxMove;
ConVar hConvarBhop = null, hSvCheats = null;

float g_iCmdGameTime[MS];
int g_iAimBlockEntity[MS], g_iAimBlockActive[MS];
int g_iGameTick[MS], g_ilGameTick[MS];
int g_iDetectDesyncAngles[MS];
//int g_iBeamSprite;
#include "hotguard/timers.sp"
#include "hotguard/cmd.sp"
#include "hotguard/stock.sp"
#include "hotguard/antiwh.sp"
#include "hotguard/fixsmoke.sp"
#include "hotguard/fixflash.sp"
#include "hotguard/blockaim.sp"

public Plugin myinfo =  {
	description = "Server anti-cheat system", 
	version = PLUGIN_VERSION, 
	author = "MaZa", 
	name = "HotGuard AntiCheat", 
	url = "vk.com/xMaZax"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	
	if (GetEngineVersion() != Engine_CSGO) {
		strcopy(error, err_max, "This plugin works only on CS:GO!");
		return APLRes_Failure;
	}

	g_bLateLoad = late;
	
	#if (CHECK_LISENCE != 0)		
	int iUnix = GetTime();
	bool bBad;
	
	CreateTimer(120.0, Timer_CheckBuy, _, TIMER_FLAG_NO_MAPCHANGE);
	
	if (iUnix >= time || iUnix < 100000) // .ref 927583
	{
		bBad = true;
	}
	
	char szPluginsDir[PLATFORM_MAX_PATH], sPlugin[PLATFORM_MAX_PATH];
	
	Handle myHandle = GetMyHandle();
	GetPluginFilename(myHandle, sPlugin, PLATFORM_MAX_PATH);
	
	BuildPath(Path_SM, szPluginsDir, sizeof(szPluginsDir), "plugins/%s", sPlugin);
	
	int iFileSize = FileSize(szPluginsDir); // .ref 295628
	
	if (myHandle == INVALID_HANDLE)
	{
		bBad = true;
	}
	
	if (iFileSize != Size || iFileSize < 33000)
	{
		bBad = true;
	}
	
	if (bBad)
	{
		strcopy(error, err_max, "[HOTGUARD] - Could not find the license");
		return APLRes_Failure;
	}
	
	#endif
	
	LoadTranslations("hotguard.phrases");
	
	return APLRes_Success;
}

public void OnLibraryAdded(const char[] sName) { HG_SetPluginDetection(sName); }


public void OnLibraryRemoved(const char[] sName) { HG_SetPluginDetection(sName); }




public void OnPluginStart()
{
	
	Handle hGameData = LoadGameConfigFile("sdktools.games");
	
	if (hGameData != null)
	{
		int iOffsets = GameConfGetOffset(hGameData, "Teleport");
		
		if (iOffsets != -1)
		{
			g_hTeleport = DHookCreate(iOffsets, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHook_Teleport);
			
			DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
			DHookAddParam(g_hTeleport, HookParamType_ObjectPtr);
			DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
			DHookAddParam(g_hTeleport, HookParamType_Bool);
		}
		
		else
		{
			SetFailState("Couldn't get the offset for \"Teleport\"");
		}
	} else {
		SetFailState("Couldn't find gamedata file sdktools.games");
	}
	
	delete hGameData;
	
	ConVar hCvar;
	hCvar = CreateConVar("hg_log", "1", "Сохраняет некоторые данные от анти-чита (логи)");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookLog)); g_iCvar[0] = hCvar.IntValue;
	hCvar = CreateConVar("hg_log_stats", "1", "Добавлять к логам статистику профиля игрока");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookLogStats)); g_iCvar[3] = hCvar.IntValue;
	hCvar = CreateConVar("hg_chatlog", "z", "Оповещения в чат админам с флагом ?? в чат (0 = ВЫКЛ)");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookChatLog)); hCvar.GetString(SZF(g_sCvarChatLog));
	hCvar = CreateConVar("hg_chatsound", "Buttons.snd15", "Звук оповещения в чат (0 = ВЫКЛ)");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookChatSound)); hCvar.GetString(SZF(g_sCvarChatSound));
	hCvar = CreateConVar("hg_antiwh", "1", "Модуль анти-вх");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookAntiWH)); g_iCvar[1] = hCvar.IntValue;
	hCvar = CreateConVar("hg_antiwh_mode", "0", "0 - Не добавлять проверки, 1 - Проверка своих тимейтов, 2 - Проверка будучи мертвым, 3 - Обе проверки");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookAntiWHMode)); g_iCvar[2] = hCvar.IntValue;
	hCvar = CreateConVar("hg_punishmode", "60", "На какой срок банить игрока? В минутах (-1 = ВЫКЛ | -2 = КИК | -3 = ТОЛЬКО ЛОГИ)");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookPunishMode)); g_iCvar[4] = hCvar.IntValue;
	hCvar = CreateConVar("hg_fixsmoke", "1", "Не передавать данные игрока который за смоком");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookFixSmoke)); g_iCvar[5] = hCvar.IntValue;
	hCvar = CreateConVar("hg_fixflash", "1", "Не передавать данные игроку который ослеплен");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookFixFlash)); g_iCvar[6] = hCvar.IntValue;
	hCvar = CreateConVar("hg_checkdoubleip", "0", "Запрещать входить на сервер двум игрокам с одного IP (sandbox)");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookCheckDoubleIP)); g_iCvar[7] = hCvar.IntValue;
	hCvar = CreateConVar("hg_badmove", "1", "Проверять корректность движения игрока");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookCheckBadMove)); g_iCvar[8] = hCvar.IntValue;
	hCvar = CreateConVar("hg_fixdesync", "1", "Исправить рассинхронизацию угла у игрока");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookCheckDesync)); g_iCvar[9] = hCvar.IntValue;
	hCvar = CreateConVar("hg_bhop", "1", "Детект автобхопа");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookCheckBhop)); g_iCvar[10] = hCvar.IntValue;
	hCvar = CreateConVar("hg_blockaim", "1", "Пытаться блокировать аим");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookBlockAim)); g_iCvar[11] = hCvar.IntValue;
	hCvar = CreateConVar("hg_fixangles", "1", "Исправить некорректные углы");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookFixAngles)); g_iCvar[12] = hCvar.IntValue;
	hCvar = CreateConVar("hg_diffang", "1", "Проверка на синхронизацию углов");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookDiffAng)); g_iCvar[13] = hCvar.IntValue;
	//hCvar = CreateConVar("hg_autoshoot", "0", "Детект авто стрельбы (может детектить макросы)");
	//hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookAutoShoot)); g_iCvar[14] = hCvar.IntValue;
	hCvar = CreateConVar("hg_mouse", "1", "Проверять синхронизацию мыши игрока");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookMouse)); g_iCvar[15] = hCvar.IntValue;
	hCvar = CreateConVar("hg_fakecvar", "1", "Проверять фейковые квары");
	hCvar.AddChangeHook(view_as<ConVarChanged>(ChangeHookFakeCvar)); g_iCvar[16] = hCvar.IntValue;
	
	AutoExecConfig(true, "hotguard");
	
	if (g_iCvar[1])
	{
		EnableModuleAntiWallhack();
	}
	
	if (g_iCvar[5])
		EnableModuleFixSmoke();
	
	if (g_iCvar[6])
		EnableModuleFixFlash();
	
	
	if (g_iCvar[11])
	{
		EnableModuleBlockAim();
	}
	
	if (g_bLateLoad)
	{
		#if (CHECK_LISENCE != 0)	
		LogMessage("The anti-cheat was rebooted during operation, and it may not work correctly in the future.");
		x0404x001();
		#endif
		LC(i)
		{
			if (HG_IsValidClient(i, true, true))
			{
				OnClientPostAdminCheck(i);
			}
		}
	}
	
	iEntPlayerResource = GetPlayerResourceEntity();
	iOffset[0] = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel");
	iOffset[1] = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsLeader");
	iOffset[2] = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsTeacher");
	iOffset[3] = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsFriendly");
	iOffset[4] = FindSendPropInfo("CCSPlayerResource", "m_bHasCommunicationAbuseMute");
	
	m_vecOrigin = FindSendPropInfo("CBaseEntity", "m_vecOrigin");
	m_flFlashDuration = FindSendPropInfo("CCSPlayer", "m_flFlashDuration");
	m_flFlashMaxAlpha = FindSendPropInfo("CCSPlayer", "m_flFlashMaxAlpha");
	hConvarBhop = FindConVar("sv_autobunnyhopping");
	hSvCheats = FindConVar("sv_cheats");
	
	g_fMaxMove = 450.0;
	
	if (!DirExists("/addons/sourcemod/logs/hotguard")) {
		CreateDirectory("/addons/sourcemod/logs/hotguard", 511);
	}
	
	PrecacheModel("models/props_vehicles/cara_69sedan.mdl", true);
	
	SetConVarInt(FindConVar("sv_occlude_players"), 0);
	SetConVarInt(FindConVar("sv_hibernate_when_empty"), 0);
}

public void OnMapStart()
{
	SetConVarInt(FindConVar("sv_occlude_players"), 0);
	SetConVarInt(FindConVar("sv_hibernate_when_empty"), 0);
	
	CreateTimer(0.2, Timer_UpdateSettings, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	#if (CHECK_LISENCE != 0)
	CreateTimer(20.0, Timer_CheckBuy, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	#endif
}

public void OnMapEnd()
{
	UnhookModuleFixSmoke();
	UnhookModuleFixFlash();
}

public MRESReturn DHook_Teleport(int iClient, Handle hReturn)
{
	if (1 <= iClient <= MaxClients)
	{
		g_iDetectDesyncAngles[iClient] = 0;
		g_iDeltaChanged[iClient] = 0;
	}
	
	return MRES_Ignored;
}

public void OnPluginEnd()
{
	if (g_iCvar[1])
	{
		DisableModuleAntiWallhack();
	}
	
	if (g_iCvar[5])
		DisableModuleFixSmoke();
	
	if (g_iCvar[6])
		DisableModuleFixFlash();
	
	if (g_iCvar[11])
	{
		LC(iClient)
		{
			Unhook_ModuleBlockAim(iClient);
		}
		DisableModuleBlockAim();
	}
}


void ChangeHookLog(ConVar hCvar) { g_iCvar[0] = hCvar.IntValue; }
void ChangeHookLogStats(ConVar hCvar) { g_iCvar[3] = hCvar.IntValue; }
void ChangeHookChatLog(ConVar hCvar) { hCvar.GetString(SZF(g_sCvarChatLog)); }
void ChangeHookChatSound(ConVar hCvar) { hCvar.GetString(SZF(g_sCvarChatSound)); }
void ChangeHookAntiWH(ConVar hCvar)
{
	g_iCvar[1] = hCvar.IntValue;
	if (g_iCvar[1])
	{
		LC(i)
		{
			if (HG_IsValidClient(i, true, true))
			{
				Hook_ModuleAntiWallhack(i);
			}
		}
		EnableModuleAntiWallhack();
	} else if (!g_iCvar[1])
	{
		DisableModuleAntiWallhack(); }
}
void ChangeHookAntiWHMode(ConVar hCvar) { g_iCvar[2] = hCvar.IntValue; }
void ChangeHookPunishMode(ConVar hCvar) { g_iCvar[4] = hCvar.IntValue; }
void ChangeHookFixSmoke(ConVar hCvar) { g_iCvar[5] = hCvar.IntValue; if (g_iCvar[5]) { EnableModuleFixSmoke(); } else if (!g_iCvar[5])DisableModuleFixSmoke(); }
void ChangeHookFixFlash(ConVar hCvar) { g_iCvar[6] = hCvar.IntValue; if (g_iCvar[6]) { EnableModuleFixFlash(); } else if (!g_iCvar[6])DisableModuleFixFlash(); }
void ChangeHookCheckDoubleIP(ConVar hCvar) { g_iCvar[7] = hCvar.IntValue; }
void ChangeHookCheckBadMove(ConVar hCvar) { g_iCvar[8] = hCvar.IntValue; }
void ChangeHookCheckDesync(ConVar hCvar) { g_iCvar[9] = hCvar.IntValue; }
void ChangeHookCheckBhop(ConVar hCvar) { g_iCvar[10] = hCvar.IntValue; }
void ChangeHookBlockAim(ConVar hCvar) { g_iCvar[11] = hCvar.IntValue;
	if (g_iCvar[11])
	{
		LC(iClient)
		{
			Hook_ModuleBlockAim(iClient);
		}
		EnableModuleBlockAim();
	} else if (!g_iCvar[11])
	{
		LC(iClient)
		{
			Unhook_ModuleBlockAim(iClient);
		}
		DisableModuleBlockAim();
	}
}
void ChangeHookFixAngles(ConVar hCvar) { g_iCvar[12] = hCvar.IntValue; }
void ChangeHookDiffAng(ConVar hCvar) { g_iCvar[13] = hCvar.IntValue; }
//void ChangeHookAutoShoot(ConVar hCvar) { g_iCvar[14] = hCvar.IntValue; }
void ChangeHookMouse(ConVar hCvar) { g_iCvar[15] = hCvar.IntValue; }
void ChangeHookFakeCvar(ConVar hCvar) { g_iCvar[16] = hCvar.IntValue; }

public void OnClientPostAdminCheck(int iClient)
{
	SetDefaultsSettings(iClient);
	
	if (g_hTeleport != null)
	{
		DHookEntity(g_hTeleport, true, iClient);
	}
	
	if (g_iCvar[7])
	{
		char IP1[32], IP2[32];
		GetClientIP(iClient, SZF(IP1));
		LC(i)
		{
			if (IsClientConnected(i) && !IsFakeClient(iClient) && !IsFakeClient(i) && i != iClient)
			{
				GetClientIP(i, SZF(IP2));
				if (!strcmp(IP1, IP2, true))
				{
					HG_LOG(iClient, "[DOUBLE IP]");
					KickClient(i, "%t%t", "HOTGUARD_TAGBAN", "HOTGUARD_DOUBLEIP_KICK");
				}
			}
		}
	}
	
	if (g_iCvar[1])
	{
		EnableModuleAntiWallhack();
		Hook_ModuleAntiWallhack(iClient);
	}
	
	if (g_iCvar[11])
	{
		Hook_ModuleBlockAim(iClient);
	}
}

public void OnClientDisconnect_Post(int iClient)
{
	SetDefaultsSettings(iClient);
	
	if (g_iCvar[11])
	{
		if (HG_IsValidClient(iClient))
		{
			ModuleBlockAimRemoveObject(iClient);
			for (int iEntity = 1; iEntity <= MaxClients; iEntity++)
			{
				if (iEntity == g_iAimBlockActive[iClient])
					g_iAimBlockActive[iClient] = 0;
			}
		}
	}
}



int SteamWorks_SteamServersConnected()
{
	int iIP[4];
	int iPort = FindConVar("hostport").IntValue;
	
	//LICENSE
	if (SteamWorks_GetPublicIP(iIP))
	{
		char szBuffer[256], szIP[24];
		FormatEx(SZF(szIP), "%i.%i.%i.%i", iIP[0], iIP[1], iIP[2], iIP[3]);
		
		Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, URL);
		FormatEx(SZF(szBuffer), ZAPROS, key, szIP, iPort, PLUGIN_VERSION, SOURCEMOD_VERSION);
		SteamWorks_SetHTTPRequestRawPostBody(hRequest, "application/x-www-form-urlencoded", SZF(szBuffer));
		SteamWorks_SetHTTPCallbacks(hRequest, x000001);
		SteamWorks_SendHTTPRequest(hRequest);
	} else {
		x0404x001();
	}
}

public int x000001(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode)
{
	delete hRequest;
	int iStatus = view_as<int>(eStatusCode);
	if (iStatus < 500)
	{
		switch (iStatus)
		{
			case 201:
			{
				if (!g_bNiceCheck)
					LogAction(-1, -1, "[HOTGUARD] >> Проверка лицензии прошла успешна!");
				
				g_bNiceCheck = true;
			}
			case 404:
			{
				PrintToServer("[HOTGUARD] >> Код ошибки: #2");
				x0404x001();
			}
			case 413:
			{
				PrintToServer("[HOTGUARD] >> Код ошибки: #3");
				x0404x001();
			}
			default:
			{
				PrintToServer("[HOTGUARD] >> Код неизвестной ошибки: %i", iStatus);
				x0404x001();
			}
		}
	}
}

void x0404x001()
{
	SetFailState("[%s]", "vk.com/xMaZax", SP_ERROR_HEAPLEAK);
} 