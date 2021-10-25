public void OnSmokeSpawn(int entity)
{
	SDKUnhook(entity, SDKHook_SpawnPost, OnSmokeSpawn);
	g_vSmokeList.Push(entity);
}


bool IsLineBlockedBySmoke(const float smokeOrigin[3], const float from[3], const float to[3])
{
	
	float totalSmokedLength = 0.5;
	float sightDir[3]; SubtractVectors(to, from, sightDir);
	float sightLength = NormalizeVector(sightDir, sightDir);
	float grenadeBloat = 1.0;
	float smokeRadiusSq = (SmokeGrenadeRadius * SmokeGrenadeRadius * grenadeBloat * grenadeBloat) / 1.6;
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
				float smokedLength = 1.0 * SquareRoot(smokeRadiusSq - lengthSq);
				totalSmokedLength += smokedLength;
			}
		}
	}
	float maxSmokedLength = 0.7 * SmokeGrenadeRadius;
	
	return (totalSmokedLength > maxSmokedLength);
}

bool IsSmokeAlive(int entity)
{

	
	int m_iSpawnTime = GetEntProp(entity, Prop_Send, "m_nSmokeEffectTickBegin");
	int ilLifetime = (GetGameTickCount() - m_iSpawnTime) / 100;
	int EndSmokeTime = 18; //DEFAULT 19
	
	if (ilLifetime > 0 && ilLifetime <= EndSmokeTime)
	{
		return true;
	}
	
	
	return false;
} 