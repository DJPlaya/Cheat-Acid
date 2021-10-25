
bool DisableModuleFixSmoke()
{
	UnhookModuleFixSmoke()
	
	delete g_hSmokeEnt;
	
	UnhookEvent("smokegrenade_detonate", OnSmokeEvent);
	UnhookEvent("smokegrenade_expired", OnSmokeEvent);
	
	return false;
}

void UnhookModuleFixSmoke()
{
	
	LC(iClient)
	{
		if (HG_IsValidClient(iClient, true, true))
		{
			if (g_bSmokeHooked[iClient])
			{
				g_bSmokeHooked[iClient] = false;
				SDKUnhook(iClient, SDKHook_SetTransmit, SetTransmitSmokeDetonate);
			}
		}
	}
}


bool EnableModuleFixSmoke()
{
	g_hSmokeEnt = new ArrayList();
	
	HookEvent("smokegrenade_detonate", OnSmokeEvent);
	HookEvent("smokegrenade_expired", OnSmokeEvent);
	
	return false;
}

void HookModuleFixSmoke()
{
	LC(iClient)
	{
		
		if (HG_IsValidClient(iClient, true, false))
		{
			if (!g_bSmokeHooked[iClient])
			{
				g_bSmokeHooked[iClient] = true;
				SDKHook(iClient, SDKHook_SetTransmit, SetTransmitSmokeDetonate);
			}
		}
	}
}


Action OnSmokeEvent(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	if (sEvName[13] == 'd')
	{
		g_fSmokeTimeTick = GetGameTime();
		CreateTimer(17.0, Timer_SmokeEnded);
		HookModuleFixSmoke();
		g_hSmokeEnt.Push(hEvent.GetInt("entityid"));
	}
	else if (++g_iMinSmokes == g_hSmokeEnt.Length)
	{
		g_hSmokeEnt.Clear();
		g_iMinSmokes = 0;
	}
}

public Action Timer_SmokeEnded(Handle timer)
{
	UnhookModuleFixSmoke();
	
	return Plugin_Stop;
}


public Action SetTransmitSmokeDetonate(int iEntity, int iClient)
{
	if (GetClientTeam(iClient) == GetClientTeam(iEntity))return Plugin_Continue; //Добавить квар на проверку тиммейта
	
	float iSmokeTime = (g_fSmokeTimeTick + 19.0) - GetGameTime();
	if (iSmokeTime > 18.8)return Plugin_Continue;
	
	for (int i = g_iMinSmokes, iSmokeEntity; i != g_hSmokeEnt.Length; ) //
	{

		if(IsValidEntity((iSmokeEntity = g_hSmokeEnt.Get(i++))))
		{
			static float vecClient[3], vecAttacker[3], vecSmoke[3];
			
			GetEntDataVector(iClient, m_vecOrigin, vecClient);
			GetEntDataVector(iEntity, m_vecOrigin, vecAttacker);
			GetEntDataVector(iSmokeEntity, m_vecOrigin, vecSmoke);
			
			if (IsAbleToSeeSmoke(iEntity, iClient, iSmokeEntity))
				return (iEntity == iClient) ? Plugin_Continue : Plugin_Handled;
			
		}
	}
	
	return Plugin_Continue;
}

bool IsAbleToSeeSmoke(int iEntity, int iClient, int iSmokeEntity)
{
	float vecSmoke[3];
	float fEyeClient[3], fEyeEntity[3];
	GetClientEyePosition(iClient, fEyeClient);
	GetClientEyePosition(iEntity, fEyeEntity);
	GetEntDataVector(iSmokeEntity, m_vecOrigin, vecSmoke);
	
	float UpVecSmoke[3];
	UpVecSmoke[0] = vecSmoke[2];
	
	float UpVecClient[3];
	UpVecClient[0] = fEyeClient[2];
	
	if (IsLineBlockedBySmoke(vecSmoke, fEyeClient, fEyeEntity))
		return true;
	
	return false;
}

bool IsLineBlockedBySmoke(const float smokeOrigin[3], const float from[3], const float to[3])
{
	float totalSmokedLength = 0.0;
	float sightDir[3]; SubtractVectors(to, from, sightDir);
	float sightLength = NormalizeVector(sightDir, sightDir);
	float smokeRadiusSq = 12225.0;
	float trash[3];
	
	{
		float toGrenade[3]; SubtractVectors(smokeOrigin, from, toGrenade);
		float alongDist = GetVectorDotProduct(toGrenade, sightDir);
		float close[3];
		
		if (alongDist < 0.0)
		{
			close = from;
		}
		
		else if (alongDist >= sightLength)
		{
			close = to;
		}
		else
		{
			close = sightDir;
			ScaleVector(close, alongDist);
			AddVectors(from, close, close);
		}
		
		float toClose[3]; SubtractVectors(close, smokeOrigin, toClose);
		float lengthSq = GetVectorLength(toClose, true);
		if (lengthSq < smokeRadiusSq)
		{
			float fromSq = GetVectorLength(toGrenade, true);
			SubtractVectors(smokeOrigin, to, trash);
			float toSq = GetVectorLength(trash, true);
			if (fromSq < smokeRadiusSq)
			{
				if (toSq < smokeRadiusSq)
				{
					SubtractVectors(to, from, trash);
					totalSmokedLength += GetVectorLength(trash);
				}
				else
				{
					float halfSmokedLength = SquareRoot(smokeRadiusSq - lengthSq);
					SubtractVectors(close, from, trash);
					if (alongDist > 0.0)
					{
						totalSmokedLength += halfSmokedLength + GetVectorLength(trash);
					}
					else
					{
						totalSmokedLength += halfSmokedLength - GetVectorLength(trash);
					}
				}
			}
			else if (toSq < smokeRadiusSq)
			{
				float halfSmokedLength = SquareRoot(smokeRadiusSq - lengthSq);
				float v[3];
				SubtractVectors(to, smokeOrigin, v);
				SubtractVectors(close, to, trash);
				if (GetVectorDotProduct(v, sightDir) > 0.0)
				{
					totalSmokedLength += halfSmokedLength + GetVectorLength(trash);
				}
				else
				{
					totalSmokedLength += halfSmokedLength - GetVectorLength(trash);
				}
			}
			else
			{
				float smokedLength = 2.0 * SquareRoot(smokeRadiusSq - lengthSq);
				totalSmokedLength += smokedLength;
			}
		}
	}
	
	if (totalSmokedLength > 0.0)
		return true;
	
	return false;
} 