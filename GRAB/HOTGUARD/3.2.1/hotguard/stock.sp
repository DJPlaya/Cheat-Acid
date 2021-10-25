stock bool HG_LOG(int iClient, char[] sLog, any...)
{
	#if (DEBUG != 1)
	if (g_bBan[iClient])return;
	#endif
	if (!g_iCvar[0])return;
	
	if (HG_IsValidClient(iClient))
	{
		char sMap[MAX_NAME_LENGTH + 2], sIP[MAX_IP_LENGTH], sBuffer[MAX_LOG_LENGTH], sBufferStats[MAX_LOG_LENGTH], sBufferLog[MAX_LOG_LENGTH], sTime[MAX_TIME_LENGTH], sDate[MAX_TIME_LENGTH], sPath[PLATFORM_MAX_PATH], sAuth[MAX_AUTHID_LENGTH];
		
		if (!GetClientIP(iClient, SZF(sIP)))
		{
			strcopy(SZF(sIP), "Failed to get IP %s");
		}
		
		int iGetTime = GetTime();
		FormatTime(SZF(sTime), "%X", iGetTime)
		FormatTime(SZF(sDate), "%d_%m_%y", iGetTime);
		
		GetCurrentMap(SZF(sMap));
		VFormat(SZF(sBufferLog), sLog, 3);
		GetClientAuthId(iClient, AuthId_Steam2, SZF(sAuth));
		
		FormatEx(SZF(sBuffer), "%s %s | %N<%s> [%s] %ims - %s", sTime, sMap, iClient, sAuth, sIP, Client_GetFakePing(iClient), sBufferLog);
		
		
		BuildPath(Path_SM, SZF(sPath), "logs/hotguard/hotguard_%s.txt", sDate);
		File hFile = OpenFile(sPath, "a");
		
		if (hFile != null)
		{
			WriteFileLine(hFile, sBuffer);
			if (g_iCvar[3])
			{
				if (iEntPlayerResource != -1)
				{
					int iLevel = GetClientStats(iClient, iEntPlayerResource, iOffset[0]);
					FormatEx(SZF(sBufferStats), "Player: %N - [CSGO RANK] %i | [LIKES] Leader: %i Teacher: %i Friendly: %i | [OTHER] AbuseMute: %i", iClient, iLevel, GetClientStats(iClient, iEntPlayerResource, iOffset[1]), GetClientStats(iClient, iEntPlayerResource, iOffset[2]), GetClientStats(iClient, iEntPlayerResource, iOffset[3]), GetClientStats(iClient, iEntPlayerResource, iOffset[4]));
					WriteFileLine(hFile, sBufferStats);
				}
			}
		}
		
		delete hFile;
	}
	
}

stock void HG_CHATLOG(int iClient, const char[] sLog)
{
	if (!g_sCvarChatLog)return;
	
	LC(i)
	{
		#if (DEBUG != 1)
		if (g_bBan[i])return;
		#endif
		if (HG_IsValidClient(i) && HG_CheckAdminImmunity(i))
		{
			if (g_sCvarChatSound[0])ClientCommand(i, "playgamesound %s", g_sCvarChatSound);
			CGOPrintToChat(i, "%t %t %t %t", "HOTGUARD_TAGCHAT", "HOTGUARD_Analyz", "HOTGUARD_CHATPLAYERCOLOR", iClient, "HOTGUARD_DETECTED", sLog);
		}
	}
}

stock bool HG_CheckAdminImmunity(int iClient)
{
	int iUserFlagBits = GetUserFlagBits(iClient);
	
	if (iUserFlagBits > 0)
	{
		if (strcmp(g_sCvarChatLog, ""))
			return true;
		else if (iUserFlagBits & (ReadFlagString(g_sCvarChatLog) | ADMFLAG_ROOT) > 0)
			return true;
	}
	return false;
}

stock void SetDefaultsSettings(int iClient)
{
	//INT
	for (int i = 0; i < sizeof(g_iPVSCache); i++)
	{
		g_iPVSCache[i][iClient] = 0;
		g_bIsVisible[i][iClient] = true;
	}
	
	int maxEdicts = GetEntityCount();
	for (int i = MaxClients + 1; i < maxEdicts; i++)
	{
		if (g_iWeaponOwner[i] == iClient)
		{
			g_iWeaponOwner[i] = 0;
		}
	}
	
	g_iAimBlockActive[iClient] = 0;
	g_iAimBlockEntity[iClient] = 0;
	g_iButtonPressedTick[iClient][0] = 0; g_iButtonPressedTick[iClient][1] = 0;
	g_iInvalidMoveCount[iClient] = 0;
	g_iCacheTeam[iClient] = 0;
	g_iTickCountCMD[iClient] = 0;
	g_iAimBlockActive[iClient] = 0;
	g_ilGameTick[iClient] = 0;
	g_iGameTick[iClient] = 0;
	g_iDetectDesyncAngles[iClient] = 0;
	
	//FLOAT
	g_fFlashBangTime[iClient] = 0.0;
	for (int i = 0; i < 3; i++)
	{
		g_vEyeAngles[iClient][i] = 0.0;
		g_vEyePos[iClient][i] = 0.0;
		g_vAbsOrigin[iClient][i] = 0.0;
		g_vMaxs[iClient][i] = 0.0;
		g_vMins[iClient][i] = 0.0;
	}
	g_iCmdGameTime[iClient] = 0.0;
	g_fFlashBangTime[iClient] = 0.0;
	
	//BOOL
	g_bCacheFake[iClient] = false;
	g_bCacheAlive[iClient] = false;
	g_bJoyStick[iClient] = false;
	g_bSmokeHooked[iClient] = false;
	g_bFlashHooked[iClient] = false;
	g_bAWHooked[iClient] = false;
	g_bBan[iClient] = false;
}

void HG_SetPluginDetection(const char[] sName) {
	if (StrEqual(sName, "sourcebans++"))
		g_iBanType = 1;
	else if (StrEqual(sName, "materialadmin"))
		g_iBanType = 2;
}

stock bool HG_Ban(int iClient)
{
	if (g_iCvar[4] == -1 || g_iCvar[4] == -3)return;
	#if (DEBUG != 1)
	if (g_bBan[iClient])return;
	#endif
	char sBuffer[129];
	FormatEx(SZF(sBuffer), "[HOTGUARD 3.2] %t", "HOTGUARD_BAN");
	
	if (g_iCvar[4] == -2)
	{
		KickClient(iClient, sBuffer);
		return;
	}
	
	switch (g_iBanType)
	{
		case 1:
		{
			#if (DEBUG != 1)
			SBPP_BanPlayer(0, iClient, g_iCvar[4], sBuffer);
			#endif
			#if (DEBUG == 1)
			PrintToChatAll(sBuffer, iClient);
			#endif
		}
		case 2:
		{
			#if (DEBUG != 1)
			MABanPlayer(0, iClient, MA_BAN_STEAM, g_iCvar[4], sBuffer);
			#endif
			#if (DEBUG == 1)
			PrintToChatAll(sBuffer, iClient);
			#endif
		}
		default:
		{
			#if (DEBUG != 1)
			BanClient(iClient, g_iCvar[4], BANFLAG_AUTO, sBuffer);
			#endif
			#if (DEBUG == 1)
			PrintToChatAll(sBuffer, iClient);
			#endif
		}
	}
}

stock bool HG_IsValidClient(int iClient, bool bAllowBots = false, bool bAllowDead = true)
{
	if (!(1 <= iClient <= MaxClients) || !IsClientInGame(iClient) || (IsFakeClient(iClient) && !bAllowBots) || (!bAllowDead && !IsPlayerAlive(iClient)))
	{
		return false;
	}
	return true;
}

stock int GetClientStats(int iClient, int iEnt, int iOffsets)
{
	return GetEntData(iEnt, iOffsets + iClient * 4);
}

stock float HG_GetPlayerSpeed(int iClient)
{
	float speed[3];
	GetEntPropVector(iClient, Prop_Data, "m_vecAbsVelocity", speed);
	return GetVectorLength(speed);
} 