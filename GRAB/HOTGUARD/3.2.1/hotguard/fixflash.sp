
bool DisableModuleFixFlash()
{
	UnhookModuleFixFlash()
	
	UnhookEvent("player_blind", Event_PlayerBlind, EventHookMode_Post);
	
	return false;
}

void UnhookModuleFixFlash()
{
	
	LC(iClient)
	{
		if (HG_IsValidClient(iClient, true, false))
		{
			if (g_bFlashHooked[iClient])
			{
				g_bFlashHooked[iClient] = false;
				SDKUnhook(iClient, SDKHook_SetTransmit, SetTransmitPlayerBlind);
			}
		}
	}
}


bool EnableModuleFixFlash()
{
	HookEvent("player_blind", Event_PlayerBlind, EventHookMode_Post);
	
	return false;
}

void HookModuleFixFlash()
{
	LC(iClient)
	{
		if (HG_IsValidClient(iClient, true, true))
		{
			if (!g_bFlashHooked[iClient])
			{
				g_bFlashHooked[iClient] = true;
				SDKHook(iClient, SDKHook_SetTransmit, SetTransmitPlayerBlind);
			}
		}
	}
}


void Event_PlayerBlind(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	
	if (!IsPlayerAlive(iClient))return;
	
	HookModuleFixFlash();
	
	if (GetEntDataFloat(iClient, m_flFlashMaxAlpha) < 255.0)
	{
		g_fFlashBangTime[iClient] = 0.0;
		return;
	}
	
	float fFlashDuration = GetEntDataFloat(iClient, m_flFlashDuration), fGameTime = GetGameTime();
	
	if (fFlashDuration > 2.9)
	{
		g_fFlashBangTime[iClient] = fGameTime + fFlashDuration - 2.9;
	}
	else
	{
		g_fFlashBangTime[iClient] = (fGameTime + fFlashDuration) / 10.0;
	}
	
	CreateTimer(fFlashDuration, Timer_FlashEnded);
}

public Action Timer_FlashEnded(Handle timer)
{
	UnhookModuleFixFlash();
	
	LC(i)
	{
		if (g_fFlashBangTime[i])
		{
			return Plugin_Stop;
		}
	}
	
	return Plugin_Stop;
}


public Action SetTransmitPlayerBlind(int iEntity, int iClient)
{
	if (GetClientTeam(iClient) == GetClientTeam(iEntity) || !IsPlayerAlive(iClient))return Plugin_Continue; //Добавить квар на проверку тиммейта
	
	if (g_fFlashBangTime[iClient])
	{
		if (g_fFlashBangTime[iClient] >= GetGameTime())
		{
			return (iEntity == iClient) ? Plugin_Continue : Plugin_Handled;
		}
		
		g_fFlashBangTime[iClient] = 0.0;
	}
	
	return Plugin_Continue;
}
