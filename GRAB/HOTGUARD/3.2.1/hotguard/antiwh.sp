
public void OnGameFrame()
{
	g_iTickCount = GetGameTickCount();
}

bool DisableModuleAntiWallhack()
{
	
	g_iCacheTicks = 0;
	
	UnhookEvent("player_spawn", eAWPlayerEvent, EventHookMode_Pre);
	UnhookEvent("player_death", eAWPlayerEvent, EventHookMode_Pre);
	UnhookEvent("player_team", eAWPlayerEvent, EventHookMode_Pre);
	
	LC(iClient)
	{
		if (HG_IsValidClient(iClient, true, true))
		{
			g_bCacheAlive[iClient] = false;
			g_bCacheFake[iClient] = false;
			
			for (int i = 0; i < sizeof(g_iPVSCache); i++)
			{
				g_iPVSCache[i][iClient] = 0;
				g_bIsVisible[i][iClient] = true;
			}
			
			
			g_bAWHooked[iClient] = false;
			SDKUnhook(iClient, SDKHook_SetTransmit, Hook_SetTransmit);
			SDKUnhook(iClient, SDKHook_WeaponEquipPost, Hook_WeaponEquipPost);
			SDKUnhook(iClient, SDKHook_WeaponDropPost, Hook_WeaponDropPost);
		}
	}
	
	int maxEdicts = GetEntityCount();
	for (int i = MaxClients + 1; i < maxEdicts; i++)
	{
		if (g_iWeaponOwner[i])
		{
			g_iWeaponOwner[i] = 0;
			SDKUnhook(i, SDKHook_SetTransmit, Hook_SetTransmitWeapon);
		}
	}
	
	return false;
}

bool EnableModuleAntiWallhack()
{
	
	g_iCacheTicks = RoundToNearest(0.2 / GetTickInterval());
	
	for (int i = 0; i < sizeof(g_bIsVisible); i++)
	{
		for (int j = 0; j < sizeof(g_bIsVisible[]); j++)
		{
			g_bIsVisible[i][j] = true;
		}
	}
	
	HookEvent("player_spawn", eAWPlayerEvent, EventHookMode_Pre);
	HookEvent("player_death", eAWPlayerEvent, EventHookMode_Pre);
	HookEvent("player_team", eAWPlayerEvent, EventHookMode_Pre);
	
	
	return false;
}

bool Hook_ModuleAntiWallhack(int iClient)
{
	if (!g_bAWHooked[iClient])
	{
		if (HG_IsValidClient(iClient, true, true))
		{
			g_bAWHooked[iClient] = true;
			
			AW_UpdateClientCache(iClient);
			SDKHook(iClient, SDKHook_SetTransmit, Hook_SetTransmit);
			SDKHook(iClient, SDKHook_WeaponEquipPost, Hook_WeaponEquipPost);
			SDKHook(iClient, SDKHook_WeaponDropPost, Hook_WeaponDropPost);
			
			
			int maxEdicts = GetEntityCount();
			for (int i = MaxClients + 1; i < maxEdicts; i++)
			{
				if (IsValidEdict(i))
				{
					int owner = GetEntPropEnt(i, Prop_Data, "m_hOwnerEntity");
					
					if (IS_CLIENT(owner))
					{
						g_iWeaponOwner[i] = owner;
						if (owner == iClient)
						{
							SDKHook(i, SDKHook_SetTransmit, Hook_SetTransmitWeapon);
						}
					}
				}
			}
		}
	}
	
}

public Action eAWPlayerEvent(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	
	AW_UpdateClientCache(iClient);
	
	return Plugin_Continue;
}

public Action Hook_SetTransmit(int iEntity, int iClient)
{
	
	static int iLastChecked[MS][MS];
	
	if (iLastChecked[iEntity][iClient] == g_iTickCount)
	{
		return g_bIsVisible[iEntity][iClient] ? Plugin_Continue : Plugin_Handled;
	}
	
	iLastChecked[iEntity][iClient] = g_iTickCount;
	
	switch (g_iCvar[2])
	{
		case 0:
		{
			if (g_bCacheAlive[iClient] && g_bCacheAlive[iEntity] && g_iCacheTeam[iClient] != g_iCacheTeam[iEntity]) // && 
			{
				AW_UpdateClientCachePos(iEntity);
				AW_UpdateClientCachePos(iClient);
				
				if (AW_IsAbleToSee(iEntity, iClient))
				{
					g_iPVSCache[iEntity][iClient] = g_iTickCount + g_iCacheTicks;
					g_bIsVisible[iEntity][iClient] = true;
				}
				else if (g_iTickCount > g_iPVSCache[iEntity][iClient])
				{
					g_bIsVisible[iEntity][iClient] = false;
				}
				
			} else {
				g_bIsVisible[iEntity][iClient] = true;
			}
		}
		case 1: //Проверим своих тимейтов
		{
			if (g_bCacheAlive[iClient] && g_bCacheAlive[iEntity])
			{
				AW_UpdateClientCachePos(iEntity);
				AW_UpdateClientCachePos(iClient);
				
				if (AW_IsAbleToSee(iEntity, iClient))
				{
					g_iPVSCache[iEntity][iClient] = g_iTickCount + g_iCacheTicks;
					g_bIsVisible[iEntity][iClient] = true;
				}
				else if (g_iTickCount > g_iPVSCache[iEntity][iClient])
				{
					g_bIsVisible[iEntity][iClient] = false;
				}
				
			} else {
				g_bIsVisible[iEntity][iClient] = true;
			}
		}
		case 2: //Проверка если игрок мертв и наблюдает от лица другого игрока
		{
			if (g_bCacheAlive[iClient])
			{
				if (g_bCacheAlive[iEntity] && g_iCacheTeam[iClient] != g_iCacheTeam[iEntity])
				{
					AW_UpdateClientCachePos(iEntity);
					AW_UpdateClientCachePos(iClient);
					
					if (AW_IsAbleToSee(iEntity, iClient))
					{
						g_iPVSCache[iEntity][iClient] = g_iTickCount + g_iCacheTicks;
						g_bIsVisible[iEntity][iClient] = true;
					}
					else if (g_iTickCount > g_iPVSCache[iEntity][iClient])
					{
						g_bIsVisible[iEntity][iClient] = false;
					}
				} else {
					g_bIsVisible[iEntity][iClient] = true;
				}
				
			} else if (!g_bCacheFake[iClient] && Client_GetObserverMode(iClient) == OBS_MODE_IN_EYE)
			{
				int iTarget = Client_GetObserverTarget(iClient);
				
				if (IS_CLIENT(iTarget))
				{
					g_bIsVisible[iEntity][iClient] = g_bIsVisible[iEntity][iTarget];
				}
				else
				{
					g_bIsVisible[iEntity][iClient] = true;
				}
			} else {
				g_bIsVisible[iEntity][iClient] = true;
			}
		}
		case 3: //Проверка если игрок мертв и наблюдает от лица другого игрока && Проверим своих тимейтов
		{
			if (g_bCacheAlive[iClient])
			{
				if (g_bCacheAlive[iEntity])
				{
					AW_UpdateClientCachePos(iEntity);
					AW_UpdateClientCachePos(iClient);
					
					if (AW_IsAbleToSee(iEntity, iClient))
					{
						g_iPVSCache[iEntity][iClient] = g_iTickCount + g_iCacheTicks;
						g_bIsVisible[iEntity][iClient] = true;
					}
					else if (g_iTickCount > g_iPVSCache[iEntity][iClient])
					{
						g_bIsVisible[iEntity][iClient] = false;
					}
				} else {
					g_bIsVisible[iEntity][iClient] = true;
				}
				
			} else if (!g_bCacheFake[iClient] && Client_GetObserverMode(iClient) == OBS_MODE_IN_EYE)
			{
				int iTarget = Client_GetObserverTarget(iClient);
				
				if (IS_CLIENT(iTarget))
				{
					g_bIsVisible[iEntity][iClient] = g_bIsVisible[iEntity][iTarget];
				}
				else
				{
					g_bIsVisible[iEntity][iClient] = true;
				}
			} else {
				g_bIsVisible[iEntity][iClient] = true;
			}
			
		}
	}
	
	return g_bIsVisible[iEntity][iClient] ? Plugin_Continue : Plugin_Handled;
}

public Action Hook_SetTransmitWeapon(int iEntity, int iClient)
{
	return g_bIsVisible[g_iWeaponOwner[iEntity]][iClient] ? Plugin_Continue : Plugin_Handled;
}

void AW_UpdateClientCache(int i)
{
	
	g_iCacheTeam[i] = GetClientTeam(i);
	g_bCacheAlive[i] = IsPlayerAlive(i);
	g_bCacheFake[i] = IsFakeClient(i);
}

void AW_UpdateClientCachePos(int iClient)
{
	static int iLastChecked[MS];
	
	if (iLastChecked[iClient] == g_iTickCount)
	{
		return;
	}
	
	iLastChecked[iClient] = g_iTickCount;
	
	GetClientMins(iClient, g_vMins[iClient]);
	GetClientMaxs(iClient, g_vMaxs[iClient]);
	GetClientAbsOrigin(iClient, g_vAbsOrigin[iClient]);
	GetClientEyePosition(iClient, g_vEyePos[iClient]);
	
	g_vMaxs[iClient][2] *= 1.0;
	g_vMins[iClient][2] -= g_vMaxs[iClient][2];
	g_vAbsOrigin[iClient][2] += g_vMaxs[iClient][2];
	
	
	if (IsFakeClient(iClient))return;
	
	float vVelocity[MS][3];
	GetClientAbsVelocity(iClient, vVelocity[iClient]);
	
	if (g_iLerpTime == -1)
	{
		g_iLerpTime = FindDataMapInfo(iClient, "m_fLerpTime");
	}
	
	float fTickInterval = GetTickInterval();
	
	float fLerpTime = GetEntDataFloat(iClient, g_iLerpTime);
	int iLerpTicks = RoundToNearest(fLerpTime / fTickInterval) - 1;
	
	int iGameTick = GetGameTickCount() - 1;
	int iDelta = iGameTick - g_iTickCountCMD[iClient];
	
	float fCorrect = 0.0;
	
	fCorrect += GetClientLatency(iClient, NetFlow_Outgoing);
	fCorrect += iLerpTicks * fTickInterval;
	
	float vTemp[3];
	vTemp[0] = FloatAbs(vVelocity[iClient][0]) * 0.01;
	vTemp[1] = FloatAbs(vVelocity[iClient][1]) * 0.01;
	vTemp[2] = FloatAbs(vVelocity[iClient][2]) * 0.01;
	
	float vPredicted[3];
	//PrintToChat(iClient, "%f | %f | %i | %i", (fCorrect - iDelta * fTickInterval) + 0.3, iDelta, iTargetTick, g_iTickCountt);
	ScaleVector(vVelocity[iClient], (fCorrect - iDelta * fTickInterval)); //iDelta + 0.2 //  + 0.3
	AddVectors(g_vAbsOrigin[iClient], vVelocity[iClient], vPredicted);
	
	TR_TraceHullFilter(vPredicted, vPredicted, view_as<float>( { -5.0, -5.0, -5.0 } ), view_as<float>( { 5.0, 5.0, 5.0 } ), MASK_VISIBLE, Filter_WorldOnly)
	
	if (!TR_DidHit())
	{
		g_vAbsOrigin[iClient] = vPredicted;
		AddVectors(g_vEyePos[iClient], vVelocity[iClient], g_vEyePos[iClient]);
	}
	
	if (vTemp[0] > 1.0)
	{
		g_vMins[iClient][0] *= vTemp[0];
		g_vMaxs[iClient][0] *= vTemp[0];
	}
	if (vTemp[1] > 1.0)
	{
		g_vMins[iClient][1] *= vTemp[1];
		g_vMaxs[iClient][1] *= vTemp[1];
	}
	if (vTemp[2] > 1.0)
	{
		g_vMins[iClient][2] *= vTemp[2];
		g_vMaxs[iClient][2] *= vTemp[2];
	}
}

public void OnEntityCreated(int iEntity, const char[] classname)
{
	if (iEntity > MaxClients && iEntity < MAX_EDICTS)
	{
		g_iWeaponOwner[iEntity] = 0;
	}
}

public void OnEntityDestroyed(int iEntity)
{
	if (iEntity > MaxClients && iEntity < MAX_EDICTS)
	{
		g_iWeaponOwner[iEntity] = 0;
	}
	
	if (g_iCvar[11])
	{
		for (int iClient = 1; iClient <= MaxClients; iClient++)
		{
			if (iEntity == g_iAimBlockEntity[iClient])
				g_iAimBlockActive[iClient] = 0;
		}
	}
}

public void Hook_WeaponEquipPost(int client, int weapon)
{
	if (weapon > MaxClients && weapon < MAX_EDICTS)
	{
		g_iWeaponOwner[weapon] = client;
		SDKHook(weapon, SDKHook_SetTransmit, Hook_SetTransmitWeapon);
	}
}

public void Hook_WeaponDropPost(int client, int weapon)
{
	if (weapon > MaxClients && weapon < MAX_EDICTS)
	{
		g_iWeaponOwner[weapon] = 0;
		SDKUnhook(weapon, SDKHook_SetTransmit, Hook_SetTransmitWeapon);
	}
}

stock bool AW_IsAbleToSee(int iEntity, int iClient)
{
	
	if (AW_IsFOV(g_vEyePos[iClient], g_vEyeAngles[iClient], g_vAbsOrigin[iEntity]))
	{
		
		if (AW_IsPointVisible(g_vEyePos[iClient], g_vAbsOrigin[iEntity]))
			return true;
		
		if (IsFwdVecVisible(g_vEyePos[iClient], g_vEyeAngles[iEntity], g_vEyePos[iEntity]))
			return true;
		
		GetClientMins(iEntity, g_vMins[iEntity]);
		GetClientMaxs(iEntity, g_vMaxs[iEntity]);
		
		g_vMins[iEntity][0] -= 5; g_vMins[iEntity][1] -= 30; g_vMaxs[iEntity][0] += 5; g_vMaxs[iEntity][1] += 5;
		
		float vVecAbsOrigin[3];
		GetEntPropVector(iEntity, Prop_Data, "m_vecAbsOrigin", vVecAbsOrigin);
		
		float vBoxPrimeMins[3], vBoxPrimeMaxs[3];
		AddVectors(vVecAbsOrigin, g_vMins[iEntity], vBoxPrimeMins);
		AddVectors(vVecAbsOrigin, g_vMaxs[iEntity], vBoxPrimeMaxs);
		
		if (AW_IsBoxVisible(vBoxPrimeMins, vBoxPrimeMaxs, g_vEyePos[iClient]))
			return true;
	}
	
	
	return false;
}


bool AW_IsFOV(const float start[3], const float angles[3], const float end[3])
{
	float normal[3], plane[3];
	
	GetAngleVectors(angles, normal, NULL_VECTOR, NULL_VECTOR);
	SubtractVectors(end, start, plane);
	NormalizeVector(plane, plane);
	
	if (GetVectorDistance(start, end) < 75.0)
		return true;
	
	return (GetVectorDotProduct(plane, normal) > 0.0);
}

bool IsFwdVecVisible(const float start[3], const float angles[3], const float end[3])
{
	float fwd[3];
	
	GetAngleVectors(angles, fwd, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(fwd, 60.0);
	AddVectors(end, fwd, fwd);
	
	return AW_IsPointVisible(start, fwd);
}


stock bool AW_IsBoxVisible(const float bottomCorner[3], const float upperCorner[3], const float start[3])
{
	float corners[8][3];
	
	for (int i = 0; i < 4; i++) {
		Array_Copy(bottomCorner, corners[i], 3);
		Array_Copy(upperCorner, corners[i + 4], 3);
	}
	
	corners[1][0] = upperCorner[0];
	corners[2][0] = upperCorner[0];
	corners[2][1] = upperCorner[1];
	corners[3][1] = upperCorner[1];
	corners[4][0] = bottomCorner[0];
	corners[4][1] = bottomCorner[1];
	corners[5][1] = bottomCorner[1];
	corners[7][0] = bottomCorner[0];
	
	for (int i = 0; i < 8; i++)
	{
		//TE_SetupBeamPoints(corners[i], start, g_iBeamSprite, 0, 0, 0, 0.2, 2.0, 0.5, 1, 0.0, { 255, 255, 255, 255 }, 0);
		//TE_SendToAll();
		if (AW_IsPointVisible(corners[i], start))return true;
	}
	
	return false;
}

bool AW_IsPointVisible(const float start[3], const float end[3])
{
	TR_TraceRayFilter(start, end, MASK_VISIBLE, RayType_EndPoint, Filter_NoPlayers);
	
	//TE_SetupBeamPoints(start, end, g_iBeamSprite, 0, 0, 0, 0.2, 2.0, 0.2, 1, 0.0, { 255, 255, 255, 255 }, 0);
	//TE_SendToAll();
	
	return TR_GetFraction() > 0.995;
}


public bool Filter_NoPlayers(int iEntity, int iContentsMask)
{
	int iCollisionGroup = GetEntProp(iEntity, Prop_Send, "m_CollisionGroup");
	
	if (iCollisionGroup == CONTENTS_EMPTY)return false;
	if (iContentsMask == (CONTENTS_MONSTER | CONTENTS_WINDOW | CONTENTS_LADDER))return false;
	
	return iEntity > MaxClients && !IS_CLIENT(GetEntPropEnt(iEntity, Prop_Data, "m_hOwnerEntity")); //GetEntDataEnt(iEntity, m_hOwnerEntity)
}


public bool Filter_WorldOnly(int entity, int mask)
{
	return false;
}


stock bool GetClientAbsVelocity(int iClient, float velocity[3])
{
	static int offset = -1;
	if (offset == -1 && (offset = FindDataMapInfo(iClient, "m_vecAbsVelocity")) == -1)
	{
		ZeroVector(velocity);
		return false;
	}
	GetEntDataVector(iClient, offset, velocity);
	return true;
}

stock void ZeroVector(float vec[3])
{
	vec[0] = vec[1] = vec[2] = 0.0;
}

stock bool IsVectorZero(const float vec[3])
{
	return vec[0] == 0.0 && vec[1] == 0.0 && vec[2] == 0.0;
}
