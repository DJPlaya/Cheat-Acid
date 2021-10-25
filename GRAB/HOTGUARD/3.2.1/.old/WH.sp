stock bool IsConVarDefault(Handle convar)
{
	char sDefaultVal[16], sCurrentVal[16];
	GetConVarDefault(convar, SZF(sDefaultVal));
	GetConVarString(convar, SZF(sCurrentVal));
	
	return StrEqual(sDefaultVal, sCurrentVal);
}

public Action Event_PlayerStateChanged(Event hEvent, const char[] sEvName, bool bDontBroadcas)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	
	if (iClient)
	{
		Wallhack_UpdateClientCache(iClient);
	}

}

void Wallhack_UpdateClientCache(int iClient)
{
	
	g_iTeam[iClient] = GetClientTeam(iClient);
	g_bIsObserver[iClient] = IsClientObserver(iClient);
	g_bIsFake[iClient] = IsFakeClient(iClient);
	g_bNoDead[iClient] = IsPlayerAlive(iClient);
	
	// Clients that should not be tested for visibility.
	g_bIgnore[iClient] = g_bIsFake[iClient];
}

void Wallhack_Enable()
{
	
	g_bEnabled = true;
	
	HookEvent("player_spawn", Event_PlayerStateChanged, EventHookMode_Post);
	HookEvent("player_death", Event_PlayerStateChanged, EventHookMode_Post);
	HookEvent("player_team", Event_PlayerStateChanged, EventHookMode_Post);
	
	
	LC(i)
	{
		
		if (UTIL_IsValidClient(i, true))
		{
			Wallhack_Hook(i);
			Wallhack_UpdateClientCache(i);
		}
	}
	
	int maxEdicts = GetEntityCount();
	for (int i = MaxClients + 1; i < maxEdicts; i++)
	{
		if (IsValidEdict(i))
		{
			int owner = GetEntPropEnt(i, Prop_Data, "m_hOwnerEntity");
			
			if (IS_CLIENT(owner))
			{
				g_iWeaponOwner[i] = owner;
				if (UTIL_IsValidClient(i, true))
					SDKHook(i, SDKHook_SetTransmit, Hook_SetTransmitWeapon);
			}
		}
	}
	
	
}

void Wallhack_Disable()
{
	g_bEnabled = false;
	
	UnhookEvent("player_spawn", Event_PlayerStateChanged, EventHookMode_Post);
	UnhookEvent("player_death", Event_PlayerStateChanged, EventHookMode_Post);
	UnhookEvent("player_team", Event_PlayerStateChanged, EventHookMode_Post);
	
	
	LC(i)
	{
		if (UTIL_IsValidClient(i, true))
		{
			Wallhack_Unhook(i);
		}
	}
	
	
	int maxEdicts = GetEntityCount();
	for (int i = MaxClients + 1; i < maxEdicts; i++)
	{
		if (g_iWeaponOwner[i])
		{
			g_iWeaponOwner[i] = 0;
			if (UTIL_IsValidClient(i, true))
				SDKUnhook(i, SDKHook_SetTransmit, Hook_SetTransmitWeapon);
		}
	}
}

/**
 * Hooks
 */

void Wallhack_Hook(int iClient)
{
	SDKHook(iClient, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKHook(iClient, SDKHook_WeaponEquipPost, Hook_WeaponEquipPost);
	SDKHook(iClient, SDKHook_WeaponDropPost, Hook_WeaponDropPost);
}

void Wallhack_Unhook(int iClient)
{
	SDKUnhook(iClient, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKUnhook(iClient, SDKHook_WeaponEquipPost, Hook_WeaponEquipPost);
	SDKUnhook(iClient, SDKHook_WeaponDropPost, Hook_WeaponDropPost);
}


public void OnEntityCreated(int iEntity, const char[] classname)
{
	
	if (iEntity > MaxClients && iEntity < MAX_EDICTS)
	{
		g_iWeaponOwner[iEntity] = 0;
	}
	
	
	if (g_bSmokeEnabled)
	{
		if (strcmp(classname, "smokegrenade_projectile") == 0)
		{
			SDKHook(iEntity, SDKHook_SpawnPost, OnSmokeSpawn);
		}
	}
	
	if (g_bFlashEnabled)
	{
		if (strcmp(classname, "flashbang_projectile") == 0)
		{
			SDKHook(iEntity, SDKHook_SpawnPost, OnFlashSpawn);
		}
	}
}

public void OnEntityDestroyed(int iEntity)
{
	if (iEntity == 0)return;
	
	//WH
	if (iEntity > MaxClients && iEntity < MAX_EDICTS)
	{
		g_iWeaponOwner[iEntity] = 0;
	}
	
	//AIMBLOCK
	
	
	
	
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (iEntity == iClientBlock[iClient])
			iClientBlock[iClient] = 0;
	}
	
	
	//ANTISMOKE
	
	if (g_bSmokeEnabled)
	{
		if (g_vSmokeList.Length > 0)
		{
			int index = g_vSmokeList.FindValue(iEntity);
			if (index > -1)
			{
				g_vSmokeList.Erase(index);
			}
		}
	}
	
	
	//ANTIFLASH
	
	if (g_bFlashEnabled)
	{
		if (g_vFlashList.Length > 0)
		{
			int index = g_vFlashList.FindValue(iEntity);
			if (index > -1)
			{
				g_vFlashList.Erase(index);
			}
		}
	}
}

public void Hook_WeaponEquipPost(int iClient, int weapon)
{
	if (weapon > MaxClients && weapon < MAX_EDICTS)
	{
		
		g_iWeaponOwner[weapon] = iClient;
		SDKHook(weapon, SDKHook_SetTransmit, Hook_SetTransmitWeapon);
	}
}

public void Hook_WeaponDropPost(int iClient, int weapon)
{
	
	if (weapon > MaxClients && weapon < MAX_EDICTS)
	{
		
		g_iWeaponOwner[weapon] = 0;
		SDKUnhook(weapon, SDKHook_SetTransmit, Hook_SetTransmitWeapon);
	}
	
	
}



public void OnGameFrame()
{
	
	
	if (!g_bEnabled)
		return;
	
	
	
	g_iTickCount = GetGameTickCount();
	
	// Increment to next thread.
	if (++g_iCurrentThread > g_iTotalThreads)
	{
		g_iCurrentThread = 1;
		
		// Reassign threads
		if (g_iTraceCount)
		{
			// Calculate total needed threads for the next pass.
			g_iTotalThreads = g_iTraceCount / 1280 + 1;
			
			// Assign each client to a thread.
			any iThreadAssign = 1;
			
			for (int i = 1; i <= MaxClients; i++)
			{
				
				if (g_bNoDead[i] && IsClientInGame(i))
				{
					
					g_iThread[i] = iThreadAssign;
					
					if (++iThreadAssign > g_iTotalThreads)
					{
						iThreadAssign = 1;
					}
				}
			}
			
			g_iTraceCount = 0;
		}
	}
}





/*
public Action OnBombDisplay(int iEntity, int iClient)
{
	GetClientEyePosition(iClient, g_vEyePos[iClient]);

	return (IsEntityVisible(g_vEyePos[iClient], BombVec)) ? Plugin_Continue : Plugin_Handled;
} */

/*

float GetLerpTime() {
	static ConVar* cl_interp = g_csgo.m_cvar()->FindVar("cl_interp");
	static ConVar* cl_updaterate = g_csgo.m_cvar()->FindVar("cl_updaterate");
	static ConVar* cl_interp_ratio = g_csgo.m_cvar()->FindVar("cl_interp_ratio");
	static ConVar* sv_maxupdaterate = g_csgo.m_cvar()->FindVar("sv_maxupdaterate");
	static ConVar* sv_minupdaterate = g_csgo.m_cvar()->FindVar("sv_minupdaterate");
	static ConVar* sv_client_min_interp_ratio = g_csgo.m_cvar()->FindVar("sv_client_min_interp_ratio");
	static ConVar* sv_client_max_interp_ratio = g_csgo.m_cvar()->FindVar("sv_client_max_interp_ratio");
	auto Interp = cl_interp->GetFloat();
	auto UpdateRate = cl_updaterate->GetFloat();
	auto InterpRatio = static_cast<float>(cl_interp_ratio->GetInt());
	auto MaxUpdateRate = static_cast<float>(sv_maxupdaterate->GetInt());
	auto MinUpdateRate = static_cast<float>(sv_minupdaterate->GetInt());
	auto ClientMinInterpRatio = sv_client_min_interp_ratio->GetFloat();
	auto ClientMaxInterpRatio = sv_client_max_interp_ratio->GetFloat();
	if (ClientMinInterpRatio > InterpRatio)
		InterpRatio = ClientMinInterpRatio;
	if (InterpRatio > ClientMaxInterpRatio)
		InterpRatio = ClientMaxInterpRatio;
	if (MaxUpdateRate <= UpdateRate)
		UpdateRate = MaxUpdateRate;
	if (MinUpdateRate > UpdateRate)
		UpdateRate = MinUpdateRate;
	auto v20 = InterpRatio / UpdateRate;
	if (v20 <= Interp)
		return Interp;
	else
		return v20;
} */



void UpdateClientData(int iClient)
{
	
	
	/* Only update iClient data once per tick. */
	static iLastCached[MPS];
	
	if (iLastCached[iClient] == g_iTickCount)
		return;
	
	iLastCached[iClient] = g_iTickCount;
	
	GetClientMins(iClient, g_vMins[iClient]);
	GetClientMaxs(iClient, g_vMaxs[iClient]);
	GetClientAbsOrigin(iClient, g_vAbsCentre[iClient]);
	GetClientEyePosition(iClient, g_vEyePos[iClient]);
	
	
	
	// Adjust vectors relative to the model's absolute centre.
	g_vMaxs[iClient][2] *= 0.5;
	g_vMins[iClient][2] -= g_vMaxs[iClient][2];
	g_vAbsCentre[iClient][2] += g_vMaxs[iClient][2];
	
	// Adjust vectors based on the iClients velocity.
	float vVelocity[3];
	GetClientAbsVelocity(iClient, vVelocity);
	
	
	if (!IsVectorZero(vVelocity))
	{
		// Lag compensation.
		int iTargetTick;
		
		if (g_bIsFake[iClient])
		{
			iTargetTick = g_iTickCount - 1;
		}
		else
		{
			// Based on CLagCompensationManager::StartLagCompensation.
			float fCorrect = 0.0;
			fCorrect += GetClientLatency(iClient, NetFlow_Outgoing);
			fCorrect += GetClientLatency(iClient, NetFlow_Incoming);
			
			// calc number of view interpolation ticks - 1
			int iLerpTicks = TIME_TO_TICKS(GetEntPropFloat(iClient, Prop_Data, "m_fLerpTime"));
			
			// add view interpolation latency see C_BaseEntity::GetInterpolationAmount()
			fCorrect += TICKS_TO_TIME(iLerpTicks);
			
			// check bouns [0,sv_maxunlag]
			fCorrect = ClampValue(fCorrect, 0.0, GetConVarFloat(FindConVar("sv_maxunlag")));
			
			// correct tick send by player 
			iTargetTick = g_iCmdTickCount[iClient] - iLerpTicks;
			
			// calc difference between tick send by player and our latency based tick
			if (FloatAbs(fCorrect - TICKS_TO_TIME(g_iTickCount - iTargetTick)) > 0.2)
			{
				
				// Difference between cmd time and latency is too big > 200ms.
				// Use time correction based on latency.
				iTargetTick = g_iTickCount - TIME_TO_TICKS(fCorrect);
			}
		}
		
		// Use velocity before it's modified.
		float vTemp[3];
		vTemp[0] = FloatAbs(vVelocity[0]) * 0.01;
		vTemp[1] = FloatAbs(vVelocity[1]) * 0.01;
		vTemp[2] = FloatAbs(vVelocity[2]) * 0.01;
		
		// Calculate predicted positions for the next frame.
		float vPredicted[3];
		ScaleVector(vVelocity, TICKS_TO_TIME(g_iTotalThreads * (g_iTickCount - iTargetTick)));
		AddVectors(g_vAbsCentre[iClient], vVelocity, vPredicted);
		
		// Make sure the predicted position is still inside the world.
		TR_TraceHullFilter(vPredicted, vPredicted, view_as<float>( { -5.0, -5.0, -5.0 } ), view_as<float>( { 5.0, 5.0, 5.0 } ), MASK_PLAYERSOLID_BRUSHONLY, Filter_WorldOnly);
		
		g_iTraceCount++;
		
		
		if (!TR_DidHit())
		{
			g_vAbsCentre[iClient] = vPredicted;
			AddVectors(g_vEyePos[iClient], vVelocity, g_vEyePos[iClient]);
		}
		
		// Expand the mins/maxs to help smooth during fast movement.
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
}


/**
 * Calculations
 */
bool IsAbleToSee(int iEntity, int iClient)
{
	
	g_vEyePos[iClient][2] -= 1;
	
	
	
	
	
	
	
	if (IsInFOV(g_vEyePos[iClient], g_vEyeAngles[iClient], g_vAbsCentre[iEntity]))
	{
		/*
		PrintToChat(iClient, "%f %f %f", ShadowDirection[0], ShadowDirection[1], ShadowDirection[2]);
		
		
		static float shadow_trace_end[3];
		shadow_trace_end = ShadowDirection;
		
		ScaleVector(shadow_trace_end, ShadowMaxDist);
		
		AddVectors(g_vEyePos[iEntity], NULL_VECTOR, shadow_trace_end);
		
		Handle Trace = TR_ClipRayToEntityEx(g_vEyePos[iEntity], shadow_trace_end, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, 0);
		float EndTrace[3];
		TR_GetEndPosition(EndTrace, Trace);
		NormalizeVector(EndTrace, EndTrace);
		
		AddVectors(g_vEyePos[iEntity], EndTrace, shadow_trace_end);
		delete Trace;
		
		SetupPoints(g_vEyePos[iClient], shadow_trace_end);
		
		
		if (IsPointVisible(g_vEyePos[iClient], shadow_trace_end))
			return true; */
		/*
		int iLight = -1;
		while ((iLight = FindEntityByClassname(iLight, "env_cascade_light")) != -1)
		{
			int owner = GetEntPropEnt(iLight, Prop_Data, "m_hOwnerEntity");
			if (IS_CLIENT(owner))
			{
				PrintCenterText(iClient, "%f %f %f", Direction[0], Direction[1], Direction[2]);
				//GetEntPropVector(i, Prop_Data, "m_vecOrigin", Direction);
				//GetEntPropVector(i, Prop_Data, "origin", Direction);
			}
			
			Handle Trace = TR_ClipRayToEntityEx(g_vEyePos[iEntity], g_vEyePos[iClient], MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, iLight);
			float EndTrace[3];
			TR_GetEndPosition(EndTrace, Trace);
			SetupPoints(g_vEyePos[iClient], EndTrace);
			delete Trace;
			//AcceptEntityInput(iLight, "Kill");
		} */
		
		
		
		
		
		// Check if centre is visible.
		
		//if (ClientViews(iClient, iEntity, 0.0, 0.73))
		//return true;
		
		if (IsPointVisible(g_vEyePos[iClient], g_vAbsCentre[iEntity]))
			return true;
		
		// Check if weapon tip is visible.
		if (IsFwdVecVisible(g_vEyePos[iClient], g_vEyeAngles[iEntity], g_vEyePos[iEntity]))
			return true;
		
		// Check outer 4 corners of player.
		if (IsRectangleVisible(g_vEyePos[iClient], g_vAbsCentre[iEntity], g_vMins[iEntity], g_vMaxs[iEntity], 1.30)) //1.90
			return true;
		
		// Check inner 4 corners of player.
		if (IsRectangleVisible(g_vEyePos[iClient], g_vAbsCentre[iEntity], g_vMins[iEntity], g_vMaxs[iEntity], 0.65)) //0.26
			return true;
		
		
	}
	
	return false;
}


public bool AddTrigger(int iEntity, ArrayList triggers)
{
	TR_ClipCurrentRayToEntity(MASK_PLAYERSOLID_BRUSHONLY, iEntity);
	if (TR_DidHit())triggers.Push(iEntity);
	
	return true;
}

bool IsInFOV(const float start[3], const float angles[3], const float end[3])
{
	
	float normal[3], plane[3];
	
	GetAngleVectors(angles, normal, NULL_VECTOR, NULL_VECTOR);
	SubtractVectors(end, start, plane);
	NormalizeVector(plane, plane);
	
	return GetVectorDotProduct(plane, normal) > 0.0; // Cosine(Deg2Rad(179.9 / 2.0))
	
}


bool IsPointVisible(const float start[3], const float end[3])
{
	TR_TraceRayFilter(start, end, MASK_VISIBLE, RayType_EndPoint, TraceEntityFilterPlayer);
	//SetupPoints(start, end);
	g_iTraceCount++;
	return TR_GetFraction() == 1.0;
}

/*
bool IsEntityVisible(const float start[3], const float end[3])
{
	TR_TraceRayFilter(start, end, MASK_VISIBLE, RayType_EndPoint, Filter_NoPlayers);
	//SetupPoints(start, end);
	return TR_GetFraction() == 1.0;
} */

bool IsFwdVecVisible(const float start[3], const float angles[3], const float end[3])
{
	float fwd[3];
	
	GetAngleVectors(angles, fwd, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(fwd, 55.0);
	AddVectors(end, fwd, fwd);
	
	return IsPointVisible(start, fwd);
}

bool IsRectangleVisible(const float start[3], const float end[3], const float mins[3], const float maxs[3], float scale = 1.0)
{
	float ZpozOffset = maxs[2];
	float ZnegOffset = mins[2];
	float WideOffset = ((maxs[0] - mins[0]) + (maxs[1] - mins[1])) / 4.0; //1.9
	
	//PrintToChatAll("WideOffset: %f", WideOffset);
	
	// This rectangle is just a point!
	if (ZpozOffset == 0.0 && ZnegOffset == 0.0 && WideOffset == 0.0)
	{
		return IsPointVisible(start, end);
	}
	
	// Adjust to scale.
	ZpozOffset *= scale;
	ZnegOffset *= scale;
	WideOffset *= scale;
	
	// Prepare rotation matrix.
	float angles[3], fwd[3], right[3];
	
	SubtractVectors(start, end, fwd);
	NormalizeVector(fwd, fwd);
	
	GetVectorAngles(fwd, angles);
	GetAngleVectors(angles, fwd, right, NULL_VECTOR);
	
	float vRectangle[4][3], vTemp[3];
	
	// If the player is on the same level as us, we can optimize by only rotating on the z-axis.
	
	
	if (FloatAbs(fwd[2]) <= 0.7071)
	{
		ScaleVector(right, WideOffset);
		
		// Corner 1, 2
		vTemp = end;
		vTemp[2] += ZpozOffset;
		//vTemp[1] -= 20; //STABILIZATION
		AddVectors(vTemp, right, vRectangle[0]);
		SubtractVectors(vTemp, right, vRectangle[1]);
		
		// Corner 3, 4
		vTemp = end;
		
		vTemp[2] += ZnegOffset;
		
		
		
		//GO TO SUPPORT SHADOW
		float Distance = SquareRoot(GetVectorDistance(vTemp, right));
		if (Distance < 40)
		{
			static int TempShadow[2];
			TempShadow[0] = 75;
			TempShadow[1] = 25;
			
			vTemp[0] += TempShadow[0];
			vTemp[1] += TempShadow[1];
			AddVectors(vTemp, right, vRectangle[2]);
			vTemp[0] -= TempShadow[0];
			vTemp[1] -= TempShadow[1];
			SubtractVectors(vTemp, right, vRectangle[3]);
		} else {
			AddVectors(vTemp, right, vRectangle[2]);
			SubtractVectors(vTemp, right, vRectangle[3]);
		}
		
		
	}
	else if (fwd[2] > 0.0) // Player is below us.
	{
		fwd[2] = 0.0;
		NormalizeVector(fwd, fwd);
		
		ScaleVector(fwd, scale);
		ScaleVector(fwd, WideOffset);
		ScaleVector(right, WideOffset);
		
		// Corner 1
		vTemp = end;
		vTemp[2] += ZpozOffset;
		AddVectors(vTemp, right, vTemp);
		SubtractVectors(vTemp, fwd, vRectangle[0]);
		
		// Corner 2
		vTemp = end;
		vTemp[2] += ZpozOffset;
		SubtractVectors(vTemp, right, vTemp);
		SubtractVectors(vTemp, fwd, vRectangle[1]);
		
		// Corner 3
		vTemp = end;
		vTemp[2] += ZnegOffset;
		AddVectors(vTemp, right, vTemp);
		AddVectors(vTemp, fwd, vRectangle[2]);
		
		// Corner 4
		vTemp = end;
		vTemp[2] += ZnegOffset;
		SubtractVectors(vTemp, right, vTemp);
		AddVectors(vTemp, fwd, vRectangle[3]);
	}
	else // Player is above us.
	{
		fwd[2] = 0.0;
		NormalizeVector(fwd, fwd);
		
		ScaleVector(fwd, scale);
		ScaleVector(fwd, WideOffset);
		ScaleVector(right, WideOffset);
		
		// Corner 1
		vTemp = end;
		vTemp[2] += ZpozOffset;
		AddVectors(vTemp, right, vTemp);
		AddVectors(vTemp, fwd, vRectangle[0]);
		
		// Corner 2
		vTemp = end;
		vTemp[2] += ZpozOffset;
		SubtractVectors(vTemp, right, vTemp);
		AddVectors(vTemp, fwd, vRectangle[1]);
		
		// Corner 3
		vTemp = end;
		vTemp[2] += ZnegOffset;
		AddVectors(vTemp, right, vTemp);
		SubtractVectors(vTemp, fwd, vRectangle[2]);
		
		// Corner 4
		vTemp = end;
		vTemp[2] += ZnegOffset;
		SubtractVectors(vTemp, right, vTemp);
		SubtractVectors(vTemp, fwd, vRectangle[3]);
	}
	
	// Run traces on all corners.
	for (int i = 0; i < 4; i++)
	{
		if (IsPointVisible(start, vRectangle[i]))
		{
			return true;
		}
	}
	
	return false;
}



/**
 * Clients
 */

stock bool GetClientAbsVelocity(int iClient, float velocity[3])
{
	static int offset = -1;
	
	if (offset == -1 && (offset = FindDataMapInfo(iClient, "m_vecAbsVelocity")) == -1) // FindDataMapOffs(iClient, "m_vecAbsVelocity")) == -1)
	{
		ZeroVector(velocity);
		return false;
	}
	
	GetEntDataVector(iClient, offset, velocity);
	return true;
}


public Action SetupPoints(const float start[3], const float end[3])
{
	
	TE_SetupBeamPoints(start, end, g_iBeamSprite, g_iHaloSprite, 0, 15, 0.1, 2.5, 6.0, 5, 6.0, { 50, 0, 88, 75 }, 1);
	
	TE_SendToAll();
	
}

stock void ZeroVector(float vec[3])
{
	vec[0] = vec[1] = vec[2] = 0.0;
}

stock bool IsVectorZero(const float vec[3])
{
	return vec[0] == 0.0 && vec[1] == 0.0 && vec[2] == 0.0;
}



any MinValue(any value, any min)
{
	return (value < min) ? min : value;
}

any MaxValue(any value, any max)
{
	return (value > max) ? max : value;
}

any ClampValue(any value, any min, any max)
{
	value = MinValue(value, min);
	value = MaxValue(value, max);
	
	return value;
}

stock any GetClientObserverMode(int iClient)
{
	static int offset = -1;
	
	if (offset == -1 && (offset = FindSendPropInfo("CBasePlayer", "m_iObserverMode")) == -1) //FindSendPropOffs("CBasePlayer", "m_iObserverMode")) == -1)
	{
		return OBS_MODE_NONE;
	}
	
	return GetEntData(iClient, offset);
}


/*
stock bool ClientViews(int viewer, int target, float fMaxDistance = 0.0, float fThreshold = 0.73)
{
	// Retrieve view and target eyes position
	float fViewPos[3]; GetClientEyePosition(viewer, fViewPos);
	float fViewAng[3]; GetClientEyeAngles(viewer, fViewAng);
	float fViewDir[3];
	float fTargetPos[3]; GetClientEyePosition(target, fTargetPos);
	float fTargetDir[3];
	float fDistance[3];
	
	// Calculate view direction
	fViewAng[0] = fViewAng[2] = 0.0;
	GetAngleVectors(fViewAng, fViewDir, NULL_VECTOR, NULL_VECTOR);
	
	// Calculate distance to viewer to see if it can be seen.
	fDistance[0] = fTargetPos[0] - fViewPos[0];
	fDistance[1] = fTargetPos[1] - fViewPos[1];
	fDistance[2] = 0.0;
	if (fMaxDistance != 0.0)
	{
		if (((fDistance[0] * fDistance[0]) + (fDistance[1] * fDistance[1])) >= (fMaxDistance * fMaxDistance))
			return false;
	}
	
	// Check dot product. If it's negative, that means the viewer is facing
	// backwards to the target.
	NormalizeVector(fDistance, fTargetDir);
	if (GetVectorDotProduct(fViewDir, fTargetDir) < fThreshold)return false;
	
	// Now check if there are no obstacles in between through raycasting
	Handle hTrace = TR_TraceRayFilterEx(fViewPos, fTargetPos, MASK_PLAYERSOLID_BRUSHONLY, RayType_EndPoint, ClientViewsFilter);
	if (TR_DidHit(hTrace)) { delete hTrace; return false; }
	delete hTrace;
	
	// Done, it's visible
	return true;
}

public bool ClientViewsFilter(int Entity, int Mask, any Junk)
{
	if (Entity >= 1 && Entity <= MaxClients)return false;
	return true;
}
*/