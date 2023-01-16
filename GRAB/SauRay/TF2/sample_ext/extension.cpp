/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Sample Extension
 * Copyright (C) 2004-2008 AlliedModders LLC.  All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

#define no_init_all

#include "extension.h"
#include <iostream>
#include <stdio.h>
#include <windows.h>
#include "detours.h"
#include "psapi.h"
#include <vector>
#include <string>
#include <unordered_map>
#include "usercmd.h"
#include "iplayerinfo.h"
#include "utlvector.h"

/**
 * @file extension.cpp
 * @brief Implement extension code here.
 */

SauRayExtension saurayExtensionInstance;		/**< Global singleton for extension's main interface */
HWND SaurayWindow = NULL;
WPARAM DispatchWindow = NULL;
IServerGameEnts *g_pGameEnts = NULL;
DWORD serverBase;
DWORD serverSize;
typedef float(__thiscall* tProcessUsercmds)(void*, CUserCmd *, int, int, int, bool);
tProcessUsercmds pProcessUsercmds;
CGlobalVars *g_pGlobals = NULL;
IPlayerInfoManager *g_pPlayerInfoManager = NULL;

namespace SAURAY_CALLS
{
	enum CALL_NAME
	{
		SET_DEBUG = 0,
		START,
		FEED_MAP,
		REMOVE_PLAYER,
		CAN_SEE,
		THREAD_START,
		THREAD_JOIN,
		LOOP,
		RESET_ROUND,
		CREATE_SMOKE
	};

	struct SetDebugParams
	{
		unsigned int width;
		unsigned int height;
	};

	struct StartParams
	{
		unsigned int maxPlayers;
		unsigned int playerTraceRes;
		unsigned int saurayTemporalHistoryAmount;
	};

	struct FeedMapParams
	{
		char mapName[256];
	};

	struct RemovePlayerParams
	{
		unsigned int playerId;
	};

	struct SetPlayerParams
	{
		unsigned int playerId;
		unsigned int teamId;
		float weaponLen;
		float absMin[3];
		float absMax[3];
		float e1[3];
		float e2[3];
		float look1[3];
		float up1[3];
		float look2[3];
		float up2[3];
		float yfov;
		float whr;
	};

	struct CanSeeParams
	{
		unsigned int viewerId;
		unsigned int subjectId;
	};

	struct SmokeParams
	{
		float ox, oy, oz;
	};

	std::vector<SetPlayerParams> paramsToTransmit;

	std::string className = std::string("SauRay_IPCHost");
	std::string windowName = std::string("SauRay_IPCHostWindow");
	int windowNumber;

	/*
	
	The following are un-used for now...
	We might need to do work with intermediate angles later...

	struct qAngles
	{
		float pitch, yaw, roll;
	};

	struct vec3
	{
		float x, y, z;
	};

	std::unordered_map<unsigned int, qAngles> intermediateLookDir;

	float QuakeDegToRad(int deg)
	{
		return deg * (3.1415926535f / 180.0f);
	}

	vec3 QuakeAngleVectors(qAngles & qa)
	{
		float sp, sy, cp, cy;

		sy = sinf(QuakeDegToRad(qa.yaw));
		cy = cosf(QuakeDegToRad(qa.yaw));
		sp = sinf(QuakeDegToRad(qa.pitch));
		cp = cosf(QuakeDegToRad(qa.pitch));

		vec3 retVal;
		retVal.x = cp * cy;
		retVal.y = cp * sy;
		retVal.z = -sp;

		return retVal;
	}
	*/
}

using namespace SAURAY_CALLS;

void GetWindowOnce(unsigned int windowNumber)
{
	if (!SaurayWindow)
	{
		className += std::to_string(windowNumber);
		windowName += std::to_string(windowNumber);
		SaurayWindow = FindWindow(className.c_str(), windowName.c_str());
	}
	if (!DispatchWindow) DispatchWindow = (WPARAM)((HWND)GetCurrentProcess());
}

cell_t SauraySetDebug(IPluginContext *pContext, const cell_t *params)
{
	GetWindowOnce(params[1]);

	SetDebugParams setDebugParams;
	setDebugParams.width = params[2];
	setDebugParams.height = params[3];

	COPYDATASTRUCT CDSEnvelope;
	CDSEnvelope.dwData = CALL_NAME::SET_DEBUG;
	CDSEnvelope.cbData = sizeof(setDebugParams);
	CDSEnvelope.lpData = &setDebugParams;

	return (cell_t)SendMessage(SaurayWindow, WM_COPYDATA, DispatchWindow, (LPARAM)((LPVOID)&CDSEnvelope));
}

cell_t SaurayStart(IPluginContext *pContext, const cell_t *params)
{
	GetWindowOnce(params[1]);

	StartParams startParams;
	startParams.maxPlayers = params[2];
	startParams.playerTraceRes = params[3];
	startParams.saurayTemporalHistoryAmount = params[4];

	COPYDATASTRUCT CDSEnvelope;
	CDSEnvelope.dwData = CALL_NAME::START;
	CDSEnvelope.cbData = sizeof(startParams);
	CDSEnvelope.lpData = &startParams;

	return (cell_t)SendMessage(SaurayWindow, WM_COPYDATA, DispatchWindow, (LPARAM)((LPVOID)&CDSEnvelope));
}

cell_t SaurayFeedMap(IPluginContext *pContext, const cell_t *params)
{
	GetWindowOnce(params[1]);

	FeedMapParams feedMapParams;
	char *mapNameTmp;
	pContext->LocalToString(params[2], &mapNameTmp);

	mapNameTmp[strcspn(mapNameTmp, "\n")] = 0;
	mapNameTmp[strcspn(mapNameTmp, "\r")] = 0;

	memset(feedMapParams.mapName, 0, sizeof(feedMapParams.mapName));
	memcpy(feedMapParams.mapName, mapNameTmp, strlen(mapNameTmp) + 1);

	COPYDATASTRUCT CDSEnvelope;
	CDSEnvelope.dwData = CALL_NAME::FEED_MAP;
	CDSEnvelope.cbData = sizeof(feedMapParams);
	CDSEnvelope.lpData = &feedMapParams;

	return (cell_t)SendMessage(SaurayWindow, WM_COPYDATA, DispatchWindow, (LPARAM)((LPVOID)&CDSEnvelope));
}

cell_t SaurayRemovePlayer(IPluginContext *pContext, const cell_t *params)
{
	GetWindowOnce(params[1]);

	RemovePlayerParams removePlayerParams;
	removePlayerParams.playerId = params[2];

	COPYDATASTRUCT CDSEnvelope;
	CDSEnvelope.dwData = CALL_NAME::REMOVE_PLAYER;
	CDSEnvelope.cbData = sizeof(removePlayerParams);
	CDSEnvelope.lpData = &removePlayerParams;

	return (cell_t)SendMessage(SaurayWindow, WM_COPYDATA, DispatchWindow, (LPARAM)((LPVOID)&CDSEnvelope));
}

cell_t SauraySetPlayer(IPluginContext *pContext, const cell_t *params)
{
	SetPlayerParams setPlayerParams;
	setPlayerParams.playerId = params[1];
	setPlayerParams.teamId = params[2];
	setPlayerParams.weaponLen = sp_ctof(params[3]);
	setPlayerParams.absMin[0] = sp_ctof(params[4]);
	setPlayerParams.absMin[1] = sp_ctof(params[5]);
	setPlayerParams.absMin[2] = sp_ctof(params[6]);
	setPlayerParams.absMax[0] = sp_ctof(params[7]);
	setPlayerParams.absMax[1] = sp_ctof(params[8]);
	setPlayerParams.absMax[2] = sp_ctof(params[9]);
	setPlayerParams.e1[0] = sp_ctof(params[10]);
	setPlayerParams.e1[1] = sp_ctof(params[11]);
	setPlayerParams.e1[2] = sp_ctof(params[12]);
	setPlayerParams.e2[0] = sp_ctof(params[13]);
	setPlayerParams.e2[1] = sp_ctof(params[14]);
	setPlayerParams.e2[2] = sp_ctof(params[15]);
	setPlayerParams.look1[0] = sp_ctof(params[16]);
	setPlayerParams.look1[1] = sp_ctof(params[17]);
	setPlayerParams.look1[2] = sp_ctof(params[18]);
	setPlayerParams.up1[0] = sp_ctof(params[19]);
	setPlayerParams.up1[1] = sp_ctof(params[20]);
	setPlayerParams.up1[2] = sp_ctof(params[21]);
	setPlayerParams.look2[0] = sp_ctof(params[22]);
	setPlayerParams.look2[1] = sp_ctof(params[23]);
	setPlayerParams.look2[2] = sp_ctof(params[24]);
	setPlayerParams.up2[0] = sp_ctof(params[25]);
	setPlayerParams.up2[1] = sp_ctof(params[26]);
	setPlayerParams.up2[2] = sp_ctof(params[27]);
	setPlayerParams.yfov = sp_ctof(params[28]);
	setPlayerParams.whr = sp_ctof(params[29]);

	paramsToTransmit.push_back(setPlayerParams);
	return 0;
}

cell_t SaurayCanSee(IPluginContext *pContext, const cell_t *params)
{
	GetWindowOnce(params[1]);

	CanSeeParams canSeeParams;
	canSeeParams.viewerId = params[2];
	canSeeParams.subjectId = params[3];

	COPYDATASTRUCT CDSEnvelope;
	CDSEnvelope.dwData = CALL_NAME::CAN_SEE;
	CDSEnvelope.cbData = sizeof(canSeeParams);
	CDSEnvelope.lpData = &canSeeParams;

	return (cell_t)SendMessage(SaurayWindow, WM_COPYDATA, DispatchWindow, (LPARAM)((LPVOID)&CDSEnvelope));
}

cell_t SaurayThreadStart(IPluginContext *pContext, const cell_t *params)
{
	GetWindowOnce(params[1]);

	COPYDATASTRUCT CDSEnvelope;
	CDSEnvelope.dwData = CALL_NAME::THREAD_START;
	CDSEnvelope.cbData = (unsigned int)(paramsToTransmit.size() * sizeof(SetPlayerParams));
	CDSEnvelope.lpData = (LPVOID)paramsToTransmit.data();

	cell_t retVal = (cell_t)SendMessage(SaurayWindow, WM_COPYDATA, DispatchWindow, (LPARAM)((LPVOID)&CDSEnvelope));

	paramsToTransmit.clear();

	return retVal;
}

cell_t SaurayThreadJoin(IPluginContext *pContext, const cell_t *params)
{
	GetWindowOnce(params[1]);

	unsigned int tmp;

	COPYDATASTRUCT CDSEnvelope;
	CDSEnvelope.dwData = CALL_NAME::THREAD_JOIN;
	CDSEnvelope.cbData = sizeof(tmp);
	CDSEnvelope.lpData = &tmp;

	return (cell_t)SendMessage(SaurayWindow, WM_COPYDATA, DispatchWindow, (LPARAM)((LPVOID)&CDSEnvelope));
}

cell_t SaurayLoop(IPluginContext *pContext, const cell_t *params)
{
	GetWindowOnce(params[1]);

	COPYDATASTRUCT CDSEnvelope;
	CDSEnvelope.dwData = CALL_NAME::LOOP;
	CDSEnvelope.cbData = (unsigned int)(paramsToTransmit.size() * sizeof(SetPlayerParams));
	CDSEnvelope.lpData = (LPVOID)paramsToTransmit.data();

	cell_t retVal = (cell_t)SendMessage(SaurayWindow, WM_COPYDATA, DispatchWindow, (LPARAM)((LPVOID)&CDSEnvelope));

	paramsToTransmit.clear();

	return retVal;
}

cell_t SaurayResetRound(IPluginContext *pContext, const cell_t *params)
{
	GetWindowOnce(params[1]);

	unsigned int tmp;

	COPYDATASTRUCT CDSEnvelope;
	CDSEnvelope.dwData = CALL_NAME::RESET_ROUND;
	CDSEnvelope.cbData = sizeof(tmp);
	CDSEnvelope.lpData = &tmp;

	return (cell_t)SendMessage(SaurayWindow, WM_COPYDATA, DispatchWindow, (LPARAM)((LPVOID)&CDSEnvelope));
}

cell_t SaurayCreateSmoke(IPluginContext *pContext, const cell_t *params)
{
	GetWindowOnce(params[1]);

	SmokeParams smokeParams;
	smokeParams.ox = sp_ctof(params[2]);
	smokeParams.oy = sp_ctof(params[3]);
	smokeParams.oz = sp_ctof(params[4]);

	COPYDATASTRUCT CDSEnvelope;
	CDSEnvelope.dwData = CALL_NAME::CREATE_SMOKE;
	CDSEnvelope.cbData = sizeof(smokeParams);
	CDSEnvelope.lpData = &smokeParams;

	return (cell_t)SendMessage(SaurayWindow, WM_COPYDATA, DispatchWindow, (LPARAM)((LPVOID)&CDSEnvelope));
}

const sp_nativeinfo_t SaurayNatives[] =
{
	{"SauraySetDebug",		SauraySetDebug},
	{"SaurayStart",			SaurayStart},
	{"SaurayFeedMap",		SaurayFeedMap},
	{"SaurayRemovePlayer",	SaurayRemovePlayer},
	{"SauraySetPlayer",		SauraySetPlayer},
	{"SaurayCanSee",		SaurayCanSee},
	{"SaurayThreadStart",	SaurayThreadStart},
	{"SaurayThreadJoin",	SaurayThreadJoin},
	{"SaurayLoop",			SaurayLoop},
	{"SaurayResetRound",	SaurayResetRound},
	{"SaurayCreateSmoke",	SaurayCreateSmoke},
	{NULL, NULL}
};

void SauRayExtension::SDK_OnAllLoaded()
{
	sharesys->AddNatives(myself, SaurayNatives);
}

/*

Following are un-used for now...

MODULEINFO GetModuleInfo(char *szModule)
{
	MODULEINFO modinfo = { 0 };
	HMODULE hModule = GetModuleHandle(szModule);
	if (hModule == 0)
		return modinfo;

	GetModuleInformation(GetCurrentProcess(), hModule, &modinfo, sizeof(MODULEINFO));
	return modinfo;
}

bool bDataCompare(const BYTE* pData, const BYTE* bMask, const char* szMask)
{
	for (; *szMask; ++szMask, ++pData, ++bMask)
		if (*szMask == 'x' && *pData != *bMask)
			return false;

	return (*szMask) == NULL;
}

DWORD dwFindPattern(DWORD dwAddress, DWORD dwSize, BYTE* pbMask, char* szMask)
{
	for (DWORD i = NULL; i < dwSize; i++)
		if (bDataCompare((BYTE*)(dwAddress + i), pbMask, szMask))
			return (DWORD)(dwAddress + i);

	return 0;
}

class CCommandContext
{
public:
	CUtlVector< CUserCmd > cmds;

	int				numcmds;
	int				totalcmds;
	int				dropped_packets;
	bool			paused;
};

CUtlVector< CCommandContext > m_CommandContext;

CCommandContext *AllocCommandContext(void)
{
	int idx = m_CommandContext.AddToTail();
	if (m_CommandContext.Count() > 1000)
	{
		Assert(0);
	}
	return &m_CommandContext[idx];
}

bool ValidateEdict(edict_t *pEntity)
{
	if (pEntity && !pEntity->IsFree() && pEntity->GetUnknown() != NULL && pEntity->GetUnknown()->GetBaseEntity() != NULL)
		return true;

	return false;
}

int pEntToIndex(edict_t *pEdict)
{
	if (pEdict < g_pGlobals->pEdicts || pEdict >= g_pGlobals->pEdicts + MAX_EDICTS)
		return 0;

	return pEdict - g_pGlobals->pEdicts;
}

int GetPlayerIndexByEdict(edict_t* ent)
{
	if (ValidateEdict(ent))
		return pEntToIndex(ent);
	else
		return 0;
}

float __fastcall new_ProcessUsercmds(void *thisptr, void *edx, CUserCmd *cmds, int numcmds, int totalcmds, int dropped_packets, bool paused)
{
	try
	{
		_asm pushfd
		_asm pushad

		edict_t *ent = g_pGameEnts->BaseEntityToEdict((CBaseEntity*)thisptr);
		if (ValidateEdict(ent))
		{
			int client = GetPlayerIndexByEdict(ent);
			if (g_pPlayerInfoManager->GetPlayerInfo(ent) && g_pPlayerInfoManager->GetPlayerInfo(ent)->IsConnected() && !g_pPlayerInfoManager->GetPlayerInfo(ent)->IsFakeClient())
			{
				CCommandContext *ctx = AllocCommandContext();

				for (int i = totalcmds - 1; i >= 0; i--)
				{
					int iCmdAdded = ctx->cmds.AddToTail(cmds[totalcmds - 1 - i]);

					CUserCmd &cmdFixup = ctx->cmds[iCmdAdded];
					// cmdFixup.viewangles.x, cmdFixup.viewangles.y, cmdFixup.viewangles.z are the intermediate view angles for client at `int client`
				}
				m_CommandContext.RemoveAll();
			}
		}

		_asm popad
		_asm popfd

		return pProcessUsercmds(thisptr, cmds, numcmds, totalcmds, dropped_packets, paused);
	}
	catch (...)
	{
		_asm { popad }
		_asm { popfd }

		return pProcessUsercmds(thisptr, cmds, numcmds, totalcmds, dropped_packets, paused);
	}
}

*/

bool SauRayExtension::SDK_OnMetamodLoad(ISmmAPI * ismm, char * error, size_t maxlen, bool late)
{
	/* Will revisit this section later
	
	GET_V_IFACE_CURRENT(GetServerFactory, g_pGameEnts, IServerGameEnts, INTERFACEVERSION_SERVERGAMEENTS); // INTERFACEVERSION_SERVERGAMEENTS might end up going to 001, 002 and so on... same as above. Make sure you don't get nullptr.
	GET_V_IFACE_CURRENT(GetServerFactory, g_pPlayerInfoManager, IPlayerInfoManager, INTERFACEVERSION_PLAYERINFOMANAGER); // INTERFACEVERSION_PLAYERINFOMANAGER might end up going to 003, 004 and so on... same as above. Make sure you don't get nullptr.
	MODULEINFO infos = GetModuleInfo("server.dll");
	serverBase = (DWORD)infos.lpBaseOfDll;
	serverSize = infos.SizeOfImage;

	DWORD ProcessUsercmds = dwFindPattern(serverBase, serverSize, (PBYTE)"\x55\x8B\xEC\x83\xE4\xF8\x81\xEC\x00\x00\x00\x00\x53\x8B\xD9\x56\x57\x89\x5C\x24\x14\xFF\xB3", "xxxxxxxx????xxxxxxxxxxx");
	if (ProcessUsercmds != NULL)
	{
		g_pGlobals = g_pPlayerInfoManager->GetGlobalVars();

		pProcessUsercmds = (tProcessUsercmds)DetourFunction((PBYTE)ProcessUsercmds, (PBYTE)new_ProcessUsercmds);
	}
	else
	{
		return false;
	}*/

	return true;
}

SMEXT_LINK(&saurayExtensionInstance);
