char g_sConVarList[][] =  { "cl_grenadepreview", "cl_crosshair_recoil", "weapon_debug_spread_show", "sv_cheats", "net_fakeloss", "net_fakelag", "sv_showlagcompensation", "net_fakejitter", "snd_visualize", "snd_show" }; // cl_ragdoll_gravity 600, sv_pure

public Action Timer_UpdateSettings(Handle timer, any data)
{
	for (int iClient = 1; iClient <= MaxClients; iClient++)
	{
		if (HG_IsValidClient(iClient, false, false))
		{
			QueryClientConVar(iClient, "joystick", OnCvarRetrieved);
			
			if (g_iCvar[16] && hSvCheats.IntValue == 0)
			{
				QueryClientConVar(iClient, "cl_pitchup", OnCvarRetrieved);
				QueryClientConVar(iClient, "cl_pitchdown", OnCvarRetrieved);
				QueryClientConVar(iClient, "cl_bobcycle", OnCvarRetrieved);
				
				for (int i = 0; i < 10; i++)
				{
					QueryClientConVar(iClient, g_sConVarList[i], OnCvarRetrieved);
				}
			}
		}
		
	}
}

void OnCvarRetrieved(QueryCookie cookie, int iClient, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	
	if (StrEqual(cvarName, "joystick"))
	{
		g_bJoyStick[iClient] = (0.0 <= StringToFloat(cvarValue) < 1.0) ? false:true;
	}
	
	if (StrEqual(cvarName, "cl_pitchup"))
	{
		if (StringToInt(cvarValue) != 89)
		{
			HG_CHATLOG(iClient, "FakeCvar");
			HG_LOG(iClient, "FakeCvar #1");
			HG_Ban(iClient);
			g_bBan[iClient] = true;
		}
	}
	
	if (StrEqual(cvarName, "cl_pitchdown"))
	{
		if (StringToInt(cvarValue) != 89)
		{
			HG_CHATLOG(iClient, "FakeCvar");
			HG_LOG(iClient, "FakeCvar #2");
			HG_Ban(iClient);
			g_bBan[iClient] = true;
		}
	}
	
	if (StrEqual(cvarName, "cl_bobcycle"))
	{
		if (StringToFloat(cvarValue) != 0.98)
		{
			HG_CHATLOG(iClient, "FakeCvar");
			HG_LOG(iClient, "FakeCvar #3");
			HG_Ban(iClient);
			g_bBan[iClient] = true;
		}
	}
	
	for (int i = 0; i < 10; i++)
	{
		if (StrEqual(cvarName, g_sConVarList[i]))
		{
			if (StringToInt(cvarValue) > 0)
			{
				HG_CHATLOG(iClient, "FakeCvar");
				HG_LOG(iClient, "FakeCvar #4");
				HG_Ban(iClient);
				g_bBan[iClient] = true;
				break;
			}
		}
	}
	
}

public Action Timer_CheckBuy(Handle hTimer)
{

	if (hTimer == INVALID_HANDLE)
	{
		x0404x001();
	}
	

	if (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "SteamWorks_CreateHTTPRequest") == FeatureStatus_Available)
	{
		SteamWorks_SteamServersConnected();
	} else {
		x0404x001();
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
} 