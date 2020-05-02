new MaxClients;
new NULL_STRING;
new NULL_VECTOR;
public Extension:__ext_SteamWorks =
{
	name = "SteamWorks",
	file = "SteamWorks.ext",
	autoload = 1,
	required = 1,
};
public Extension:__ext_core =
{
	name = "Core",
	file = "core",
	autoload = 0,
	required = 0,
};
public Extension:__ext_cstrike =
{
	name = "cstrike",
	file = "games/game.cstrike.ext",
	autoload = 0,
	required = 1,
};
public Extension:__ext_sdkhooks =
{
	name = "SDKHooks",
	file = "sdkhooks.ext",
	autoload = 1,
	required = 1,
};
public Extension:__ext_sdktools =
{
	name = "SDKTools",
	file = "sdktools.ext",
	autoload = 1,
	required = 1,
};
public SharedPlugin:__pl_materialadmin =
{
	name = "materialadmin",
	file = "materialadmin.smx",
	required = 0,
};
public SharedPlugin:__pl_sourcebanspp =
{
	name = "sourcebans++",
	file = "sbpp_main.smx",
	required = 0,
};
public PlVers:__version =
{
	version = 5,
	filevers = "1.10.0.6462",
	date = "02/19/2020",
	time = "17:31:23"
};
public Plugin:myinfo =
{
	name = "HotGuard Server-side Anti-Cheat",
	description = "Kill Cheat",
	author = "MaZa",
	version = "3.1",
	url = "https://vk.com/xMaZax & hotstar-project.net"
};
new g_vard4ac;
new g_var24d0;
new g_var24c8;
new g_var24d8;
new g_vard388 = -1;
new g_var24cc;
new g_vard6d0;
new g_vard6d8;
new g_vardc08;
new g_var24e8;
new g_vard6cc;
new g_vard4a4;
new g_vard4a0;
new g_var2110;
new g_vard498;
new g_var24d4;
new g_vard5b8;
new g_vard5c0;
new g_var14fe0 = 1138819072;
new g_vard244;
new g_vard358;
new g_var8fc;
new g_var944;
new g_var15350 = -1;
new g_var15368 = -1;
new g_var15388 = -1;
new g_var2004;
new g_var98c;
new g_var9dc;
new g_vard6d4;
new g_vard5bc;
new g_vard6dc;
new g_vard360;
new g_var24dc;
new g_var24e0;
new g_vardc0c;
new g_var24e4;
new g_var24f8;
new g_var24f4;
new g_var24f0;
new g_var24ec;
new g_vard364;
new g_varf5d8;
new g_vard350;
new g_vard35c;
new g_vard354;
new g_var14fe4;
new g_vard494;
new g_vard49c;
new g_vard4a8 = -1;
.10484.HG_SetPluginDetection(_arg0)
{
	if (.4276.StrEqual(_arg0, 65292, 1))
	{
		g_vard4ac = 1;
	}
	else
	{
		if (.4276.StrEqual(_arg0, 65304, 1))
		{
			g_vard4ac = 2;
		}
		if (.4276.StrEqual(_arg0, 65320, 1))
		{
			g_vard4ac = 3;
		}
	}
	return 0;
}

.10708.HG_IsValidClient(_arg0, _arg1, _arg2)
{
	new var3;
	if (1 <= _arg0 <= MaxClients && IsClientInGame(_arg0) && (IsFakeClient(_arg0) && _arg1) && IsClientSourceTV(_arg0) && IsClientReplay(_arg0) && (_arg2 && IsPlayerAlive(_arg0)))
	{
		return 0;
	}
	return 1;
}

.11056.HG_AimBlockCreateObject(_arg0)
{
	if (9468[_arg0])
	{
		return 0;
	}
	9732[_arg0] = CreateEntityByName(65336, -1);
	if (9732[_arg0] != -1)
	{
		DispatchKeyValue(9732[_arg0], 65360, 8648);
		if (DispatchSpawn(9732[_arg0]))
		{
			SetVariantString(65368);
			AcceptEntityInput(9732[_arg0], 65380, _arg0, 9732[_arg0], 0);
			SetEntPropEnt(9732[_arg0], 0, 65392, _arg0, 0);
			SetEntPropFloat(9732[_arg0], 0, 65408, 1072483533, 0);
			.5660.SetEntityRenderMode(9732[_arg0], 10);
			.5060.SetEntityMoveType(9732[_arg0], 0);
			SetEntProp(9732[_arg0], 0, 65424, 217, 4, 0);
			SetEntProp(9732[_arg0], 0, 65436, 1, 1, 0);
			SetEntProp(9732[_arg0], 1, 65452, 0, 2, 0);
			SetEntProp(9732[_arg0], 1, 65468, 10, 4, 0);
			9468[_arg0] = 9732[_arg0];
		}
	}
	return 0;
}

.12108.HG_AimBlockDeleteObject(_arg0)
{
	if (9468[_arg0])
	{
		new var1;
		if (9732[_arg0] != -1 && IsValidEntity(9732[_arg0]) && 9468[_arg0] == 9732[_arg0])
		{
			AcceptEntityInput(9732[_arg0], 65488, -1, -1, 0);
			AcceptEntityInput(9732[_arg0], 65496, -1, -1, 0);
		}
		9468[_arg0] = 0;
		return 0;
	}
	return 0;
}

.12556.IsLineBlockedBySmoke(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	new var2 = 0;
	.3772.SubtractVectors(_arg2, _arg1, var2);
	new var3;
	var3 = NormalizeVector(var2, var2);
	new var4 = 1174267904;
	new var5 = 0;
	new var6 = 0;
	.3772.SubtractVectors(_arg0, _arg1, var6);
	new var7;
	var7 = GetVectorDotProduct(var6, var2);
	new var8 = 0;
	if (!(var7 < 0.0))
	{
		if (!(var7 >= var3))
		{
			.4064.ScaleVector(var8, var7);
			.3480.AddVectors(_arg1, var8, var8);
		}
	}
	new var9 = 0;
	.3772.SubtractVectors(var8, _arg0, var9);
	new var10;
	var10 = GetVectorLength(var9, 1);
	if (var10 < var4)
	{
		new var11;
		var11 = GetVectorLength(var6, 1);
		.3772.SubtractVectors(_arg0, _arg2, var5);
		new var12;
		var12 = GetVectorLength(var5, 1);
		if (var11 < var4)
		{
			if (var12 < var4)
			{
				.3772.SubtractVectors(_arg2, _arg1, var5);
				var1 += GetVectorLength(var5, 0);
			}
			else
			{
				new var13;
				var13 = SquareRoot(var4 - var10);
				.3772.SubtractVectors(var8, _arg1, var5);
				if (var7 > 0.0)
				{
					var1 += var13 + GetVectorLength(var5, 0);
				}
				else
				{
					var1 += var13 - GetVectorLength(var5, 0);
				}
			}
		}
		else
		{
			if (var12 < var4)
			{
				new var14;
				var14 = SquareRoot(var4 - var10);
				new var15 = 0;
				.3772.SubtractVectors(_arg2, _arg0, var15);
				.3772.SubtractVectors(var8, _arg2, var5);
				if (GetVectorDotProduct(var15, var2) > 0.0)
				{
					var1 += var14 + GetVectorLength(var5, 0);
				}
				else
				{
					var1 += var14 - GetVectorLength(var5, 0);
				}
			}
			new var16;
			var16 = SquareRoot(var4 - var10) * 2.0;
			var1 += var16;
		}
	}
	return var1 > 0.0;
}

.14880.HG_GetPlayerSpeed(_arg0)
{
	new var1 = 0;
	GetEntPropVector(_arg0, 1, 65504, var1, 0);
	return GetVectorLength(var1, 0);
}

.15016.UTIL_BanClient(_arg0, _arg1)
{
	if (56064[_arg0])
	{
		return 0;
	}
	new var1;
	if (g_var24d0 == 3 || IsClientInKickQueue(_arg0))
	{
		return 0;
	}
	new var2 = 0;
	FormatEx(var2, 129, 65524, 65532, 65548);
	switch (g_vard4ac)
	{
		case 1:
		{
			SBBanPlayer(0, _arg0, _arg1, var2);
		}
		case 2:
		{
			SBPP_BanPlayer(0, _arg0, _arg1, var2);
		}
		case 3:
		{
			MABanPlayer(0, _arg0, 1, _arg1, var2);
		}
		default:
		{
			BanClient(_arg0, _arg1, 1, var2, 65564, 65568, 0);
		}
	}
	return 0;
}

.15556.UTIL_LOG(_arg0, _arg1, _arg2)
{
	if (56064[_arg0])
	{
		return 0;
	}
	new var1;
	if (g_var24c8 == 1 && IsClientInKickQueue(_arg0))
	{
		return 0;
	}
	new var2 = 0;
	new var3 = 0;
	new var4 = 0;
	new var5 = 0;
	new var6 = 0;
	new var7 = 0;
	new var8 = 0;
	new var9 = 0;
	new var10 = 0;
	if (.10708.HG_IsValidClient(_arg0, 0, 1))
	{
		if (!(GetClientIP(_arg0, var4, 17, 1)))
		{
			strcopy(var4, 17, 65572);
		}
		GetCurrentMap(var2, 32);
		var10 = .8096.Client_GetFakePing(_arg0, 1);
		GetClientWeapon(_arg0, var3, 32);
	}
	VFormat(var5, 1024, _arg2, 4);
	FormatTime(var6, NULL_STRING, 65588, GetTime({0,0}));
	new var11;
	var11 = GetMyHandle();
	GetPluginFilename(var11, var8, 256);
	switch (_arg1)
	{
		case 0:
		{
			Format(var5, 1024, 65600, var8, var6, var5, var4, var10, var2, var3);
		}
		case 1:
		{
			Format(var5, 1024, 65664, var8, var6, var5, var4, var10, var2, var3);
		}
		case 2:
		{
			Format(var5, 1024, 65736, var8, var6, var5, var4, var10, var2, var3);
		}
		case 3:
		{
			Format(var5, 1024, 65804, var8, var6, var5, var4, var10, var2, var3);
		}
		default:
		{
		}
	}
	new var12 = 0;
	if (0 < g_var24d8)
	{
		if (g_vard388 != -1)
		{
			new var13;
			var13 = .18536.GetClientStats(_arg0, g_vard388, 54120/* ERROR unknown load Constant */);
			new var14;
			var14 = .18536.GetClientStats(_arg0, g_vard388, 54120 + 4/* ERROR unknown load Binary */);
			new var15;
			var15 = .18536.GetClientStats(_arg0, g_vard388, 54120 + 8/* ERROR unknown load Binary */);
			new var16;
			var16 = .18536.GetClientStats(_arg0, g_vard388, 54120 + 12/* ERROR unknown load Binary */);
			new var17;
			var17 = .18536.GetClientStats(_arg0, g_vard388, 54120 + 16/* ERROR unknown load Binary */);
			Format(var12, 1024, 65872, _arg0, var13, var14, var15, var16, var17);
		}
	}
	FormatTime(var7, NULL_STRING, 65972, GetTime({0,0}));
	BuildPath(0, var9, 256, 65984, var7);
	new var18;
	var18 = OpenFile(var9, 66016, 0, 66020);
	if (var18)
	{
		WriteFileLine(var18, var5);
		if (0 < g_var24d8)
		{
			WriteFileLine(var18, var12);
		}
		CloseHandle(var18);
		var18 = 0;
	}
	else
	{
		LogError(66028);
	}
	CloseHandle(var11);
	var11 = 0;
	return 0;
}

.17744.HG_CheckAdminImmunity(_arg0)
{
	new var1;
	var1 = GetUserFlagBits(_arg0);
	if (0 < var1)
	{
		if (.4276.StrEqual(9160, 66060, 1))
		{
			return 1;
		}
		if (0 < ReadFlagString(9160, 0) | 16384 & var1)
		{
			return 1;
		}
	}
	return 0;
}

.18028.HG_PrintToAdmins(_arg0)
{
	if (g_var24cc != 1)
	{
		return 0;
	}

/* ERROR! null */
 function ".18028.HG_PrintToAdmins" (number 9)
.18536.GetClientStats(_arg0, _arg1, _arg2)
{
	return GetEntData(_arg1, _arg0 * 4 + _arg2, 4);
}

.18620.HG_SetDefaults(_arg0)
{
	56064[_arg0] = 0;
	56336[_arg0] = 0;
	9468[_arg0] = 0;
	return 0;
}

.18768.HookEvents()
{
	HookEvent(66084, 27, 0);
	HookEvent(66096, 29, 0);
	HookEvent(66112, 31, 0);
	HookEvent(66128, 33, 1);
	HookEvent(66144, 35, 2);
	HookEvent(66156, 37, 1);
	HookEventEx(66180, 37, 1);
	return 0;
}

.19092.Event_PlayerTeam(_arg0)
{
	if (g_vard6d0)
	{
		new var1;
		var1 = GetClientOfUserId(Event.GetInt(_arg0, 66204, 0));
		if (.10708.HG_IsValidClient(var1, 1, 1))
		{
			.38972.AntiWallhack_UpdateClientCache(var1);
		}
		return 0;
	}
	return 0;
}

.19292.Event_PlayerDeath(_arg0)
{
	new var1;
	if (g_vard6d8 && g_vard6d0)
	{
		return 0;
	}
	new var2;
	var2 = GetClientOfUserId(Event.GetInt(_arg0, 66212, 0));
	if (g_vard6d8)
	{
		if (.10708.HG_IsValidClient(var2, 0, 1))
		{
			.12108.HG_AimBlockDeleteObject(var2);
		}
	}
	if (g_vard6d0)
	{
		if (.10708.HG_IsValidClient(var2, 1, 1))
		{
			.38972.AntiWallhack_UpdateClientCache(var2);
		}
	}
	return 0;
}

.19652.Event_PlayerSpawn(_arg0)
{
	new var1;
	var1 = GetClientOfUserId(Event.GetInt(_arg0, 66220, 0));
	g_vardc08 = 0;
	if (g_vard6d8)
	{
		if (.10708.HG_IsValidClient(var1, 0, 1))
		{
			.11056.HG_AimBlockCreateObject(var1);
		}
	}
	if (g_vard6d0)
	{
		if (.10708.HG_IsValidClient(var1, 1, 1))
		{
			.38972.AntiWallhack_UpdateClientCache(var1);
		}
	}
	if (g_var24e8)
	{
		if (8200[var1])
		{
			ArrayList.Clear(8200[var1]);
		}
	}
	return 0;
}

.20056.Event_PlayerBlind(_arg0)
{
	if (g_vard6cc)
	{
		new var1;
		var1 = GetClientOfUserId(Event.GetInt(_arg0, 66228, 0));
		.32304.HookSetTransmitPlayerBlind();
		if (GetEntDataFloat(var1, g_vard4a4) < 255.0)
		{
			56336[var1] = 0;
			return 0;
		}
		new var2;
		var2 = GetEntDataFloat(var1, g_vard4a0);
		new var3;
		var3 = GetGameTime();
		if (var2 > 2.9)
		{
			56336[var1] = var3 + var2 - 2.9;
		}
		else
		{
			56336[var1] = var3 + var2 / 10.0;
		}
		CreateTimer(var2, 261, 0, 0);
		return 0;
	}
	return 0;
}

.20732.Event_RoundStart()
{
	ArrayList.Clear(g_var2110);
	g_vard498 = 0;
	if (g_vard6d8)
	{
		new var1;
		var1 = MaxClients + 1;
		var1--;
		while (var1)
		{
			if (.10708.HG_IsValidClient(var1, 0, 1))
			{
				.11056.HG_AimBlockCreateObject(var1);
			}
		}
		return 0;
	}
	return 0;
}

.20980.OnSmokeEvent(_arg0, _arg1)
{
	if (_arg1 + 13/* ERROR unknown load Binary */ == 100)
	{
		CreateTimer(1096810496, 263, 0, 0);
		.31396.HookSetTransmitSmokeDetonate();
		ArrayList.Push(g_var2110, Event.GetInt(_arg0, 66236, 0));
	}
	else
	{
		g_vard498 += 1;
		if (ArrayList.Length.get(g_var2110) == g_vard498)
		{
			ArrayList.Clear(g_var2110);
			g_vard498 = 0;
		}
	}
	return 0;
}

.22112.OnCvarRetrieved(_arg0, _arg1, _arg2, _arg3, _arg4)
{
	if (.4276.StrEqual(_arg3, 66372, 1))
	{
		if (StringToInt(_arg4, 10) != 89)
		{
			.18028.HG_PrintToAdmins(66384, 66448, 66468, _arg1, 66484);
			.15556.UTIL_LOG(_arg1, 2, 66500, _arg1, 66524);
			.15016.UTIL_BanClient(_arg1, g_var24d4);
			56064[_arg1] = 1;
		}
	}
	if (.4276.StrEqual(_arg3, 66540, 1))
	{
		if (StringToInt(_arg4, 10) != 89)
		{
			.18028.HG_PrintToAdmins(66556, 66620, 66640, _arg1, 66656);
			.15556.UTIL_LOG(_arg1, 2, 66672, _arg1, 66696);
			.15016.UTIL_BanClient(_arg1, g_var24d4);
			56064[_arg1] = 1;
		}
	}
	if (.4276.StrEqual(_arg3, 66712, 1))
	{
		if (StringToInt(_arg4, 10) > 1)
		{
			.18028.HG_PrintToAdmins(66724, 66788, 66808, _arg1, 66824);
			.15556.UTIL_LOG(_arg1, 2, 66840, _arg1, 66864);
			.15016.UTIL_BanClient(_arg1, g_var24d4);
			56064[_arg1] = 1;
		}
	}
	if (.4276.StrEqual(_arg3, 66880, 1))
	{
		if (0 < StringToInt(_arg4, 10))
		{
			.18028.HG_PrintToAdmins(66896, 66960, 66980, _arg1, 66996);
			.15556.UTIL_LOG(_arg1, 2, 67012, _arg1, 67036);
			.15016.UTIL_BanClient(_arg1, g_var24d4);
			56064[_arg1] = 1;
		}
	}
	if (.4276.StrEqual(_arg3, 67052, 1))
	{
		if (0 < StringToInt(_arg4, 10))
		{
			.18028.HG_PrintToAdmins(67064, 67128, 67148, _arg1, 67164);
			.15556.UTIL_LOG(_arg1, 2, 67180, _arg1, 67204);
			.15016.UTIL_BanClient(_arg1, g_var24d4);
			56064[_arg1] = 1;
		}
	}
	if (.4276.StrEqual(_arg3, 67220, 1))
	{
		if (0.98 != StringToFloat(_arg4))
		{
			.18028.HG_PrintToAdmins(67232, 67296, 67316, _arg1, 67332);
			.15556.UTIL_LOG(_arg1, 2, 67348, _arg1, 67372);
			.15016.UTIL_BanClient(_arg1, g_var24d4);
			56064[_arg1] = 1;
		}
	}
	new var1 = 0;
	while (var1 < 8)
	{
		if (.4276.StrEqual(_arg3, 8468[var1], 1))
		{
			if (.3360.5>0(StringToFloat(_arg4), 0))
			{
				.18028.HG_PrintToAdmins(67388, 67452, 67472, _arg1, 67488);
				.15556.UTIL_LOG(_arg1, 2, 67504, _arg1, 67528);
				.15016.UTIL_BanClient(_arg1, g_var24d4);
				56064[_arg1] = 1;
			}
		}
		var1++;
	}
	return 0;
}

.26516.TraceAimBlockEnable()
{
	g_vard6d8 = 1;
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.10708.HG_IsValidClient(var1, 0, 1))
		{
			.11056.HG_AimBlockCreateObject(var1);
		}
	}
	return 0;
}

.26712.TraceAimBlockDisable()
{
	g_vard6d8 = 0;
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.10708.HG_IsValidClient(var1, 0, 1))
		{
			.12108.HG_AimBlockDeleteObject(var1);
		}
	}
	return 0;
}

.26904.TraceSmokeEnable()
{
	g_vard5b8 = 1;
	return 0;
}

.26936.TraceSmokeDisable()
{
	g_vard5b8 = 0;
	return 0;
}

.26964.TraceFlashEnable()
{
	g_vard5c0 = 1;
	return 0;
}

.26996.TraceFlashDisable()
{
	g_vard5c0 = 0;
	return 0;
}

.27024.TraceAntiWallhackEnable()
{
	g_vard6d0 = 1;
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.10708.HG_IsValidClient(var1, 1, 1))
		{
			.28076.AntiWallhackHook(var1);
			.38972.AntiWallhack_UpdateClientCache(var1);
		}
	}
	new var2;
	var2 = GetEntityCount();
	new var3;
	var3 = MaxClients + 1;
	while (var3 < var2)
	{
		if (IsValidEdict(var3))
		{
			new var4;
			var4 = GetEntPropEnt(var3, 1, 68148, 0);
			if (1 <= var4 <= MaxClients)
			{
				9996[var3] = var4;
				SDKHook(var3, 6, 221);
			}
		}
		var3++;
	}
	return 0;
}

.27624.TraceAntiWallhackDisable()
{
	g_vard6d0 = 0;
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.10708.HG_IsValidClient(var1, 1, 1))
		{
			.28224.AntiWallhackUnhook(var1);
		}
	}
	new var2;
	var2 = GetEntityCount();
	new var3;
	var3 = MaxClients + 1;
	while (var3 < var2)
	{
		if (9996[var3])
		{
			9996[var3] = 0;
			SDKUnhook(var3, 6, 221);
		}
		var3++;
	}
	return 0;
}

.28076.AntiWallhackHook(_arg0)
{
	SDKHook(_arg0, 6, 219);
	SDKHook(_arg0, 32, 225);
	SDKHook(_arg0, 31, 223);
	return 0;
}

.28224.AntiWallhackUnhook(_arg0)
{
	SDKUnhook(_arg0, 6, 219);
	SDKUnhook(_arg0, 32, 225);
	SDKUnhook(_arg0, 31, 223);
	return 0;
}

.2992.RoundFloat(_arg0)
{
	return RoundToNearest(_arg0);
}

.3028.-5(_arg0)
{
	return _arg0 ^ -2147483648;
}

.3064.5/0(_arg0, _arg1)
{
	return _arg0 / float(_arg1);
}

.3124.0/5(_arg0, _arg1)
{
	return float(_arg0) / _arg1;
}

.31396.HookSetTransmitSmokeDetonate()
{
	new var2;
	var2 = MaxClients + 1;
	var2--;
	while (var2)
	{
		new var1;
		if (IsClientInGame(var2) && 54448[var2])
		{
			54448[var2] = 1;
			SDKHook(var2, 6, 255);
		}
	}
	return 0;
}

.31688.UnhookSetTransmitSmokeDetonate()
{
	new var2;
	var2 = MaxClients + 1;
	var2--;
	while (var2)
	{
		new var1;
		if (IsClientInGame(var2) && 54448[var2])
		{
			54448[var2] = 0;
			SDKUnhook(var2, 6, 255);
		}
	}
	return 0;
}

.3180.5+0(_arg0, _arg1)
{
	return _arg0 + float(_arg1);
}

.32304.HookSetTransmitPlayerBlind()
{
	new var2;
	var2 = MaxClients + 1;
	var2--;
	while (var2)
	{
		new var1;
		if (IsClientInGame(var2) && 54724[var2])
		{
			54724[var2] = 1;
			SDKHook(var2, 6, 253);
		}
	}
	return 0;
}

.3240.5-0(_arg0, _arg1)
{
	return _arg0 - float(_arg1);
}

.32596.UnhookSetTransmitPlayerBlind()
{
	new var2;
	var2 = MaxClients + 1;
	var2--;
	while (var2)
	{
		new var1;
		if (IsClientInGame(var2) && 54724[var2])
		{
			54724[var2] = 0;
			SDKUnhook(var2, 6, 253);
			56336[var2] = 0;
		}
	}
	return 0;
}

.3300.5==0(_arg0, _arg1)
{
	return _arg0 == float(_arg1);
}

.3360.5>0(_arg0, _arg1)
{
	return _arg0 > float(_arg1);
}

.3420.5<0(_arg0, _arg1)
{
	return _arg0 < float(_arg1);
}

.3480.AddVectors(_arg0, _arg1, _arg2)
{
	_arg2 = _arg0 + _arg1;
	_arg2 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */ + _arg1 + 4/* ERROR unknown load Binary */;
	_arg2 + 8/* ERROR unknown load Binary */ = _arg0 + 8/* ERROR unknown load Binary */ + _arg1 + 8/* ERROR unknown load Binary */;
	return 0;
}

.3772.SubtractVectors(_arg0, _arg1, _arg2)
{
	_arg2 = _arg0 - _arg1;
	_arg2 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */ - _arg1 + 4/* ERROR unknown load Binary */;
	_arg2 + 8/* ERROR unknown load Binary */ = _arg0 + 8/* ERROR unknown load Binary */ - _arg1 + 8/* ERROR unknown load Binary */;
	return 0;
}

.38604.IsValidMove(_arg0)
{
	new var1;
	return 0 == _arg0 || _arg0 == g_var14fe0 || _arg0 == g_var14fe0 * 0.75 || _arg0 == g_var14fe0 * 0.5 || _arg0 == g_var14fe0 * 0.25;
}

.38972.AntiWallhack_UpdateClientCache(_arg0)
{
	53564[_arg0] = GetClientTeam(_arg0);
	55008[_arg0] = IsClientObserver(_arg0);
	55800[_arg0] = IsFakeClient(_arg0);
	55272[_arg0] = IsPlayerAlive(_arg0);
	55536[_arg0] = 55800[_arg0];
	return 0;
}

.39316.UpdateClientData(_arg0)
{
	if (g_vard244 == 86504[_arg0])
	{
		return 0;
	}
	86504[_arg0] = g_vard244;
	GetClientMins(_arg0, 56600[_arg0]);
	GetClientMaxs(_arg0, 57656[_arg0]);
	GetClientAbsOrigin(_arg0, 58712[_arg0]);
	GetClientEyePosition(_arg0, 59768[_arg0]);
	57656[_arg0][2] *= 0.5;
	56600[_arg0][2] -= 57656[_arg0][2];
	new var1 = 58712[_arg0][2];
	var1 = var1[57656[_arg0][2]];
	new var2 = 0;
	.51104.GetClientAbsVelocity(_arg0, var2);
	if (!(.51484.IsVectorZero(var2)))
	{
		new var3 = 0;
		var3 = FloatAbs(var2) * 0.01;
		var3 + 4/* ERROR unknown load Binary */ = FloatAbs(var2 + 4/* ERROR unknown load Binary */) * 0.01;
		var3 + 8/* ERROR unknown load Binary */ = FloatAbs(var2 + 8/* ERROR unknown load Binary */) * 0.01;
		new var4 = 0;
		.4064.ScaleVector(var2, .3124.0/5(.8096.Client_GetFakePing(_arg0, 1), 1148846080));
		.3480.AddVectors(58712[_arg0], var2, var4);
		TR_TraceHullFilter(var4, var4, 86768, 86780, 81931, 217, 0);
		g_vard358 += 1;
		if (!(TR_DidHit(0)))
		{
			.3480.AddVectors(59768[_arg0], var2, 59768[_arg0]);
		}
		if (var3 > 1.0)
		{
			56600[_arg0] *= var3;
			57656[_arg0] *= var3;
			62940[_arg0] *= var3;
			63996[_arg0] *= var3;
		}
		if (var3 + 4/* ERROR unknown load Binary */ > 1.0)
		{
			56600[_arg0][1] *= var3 + 4/* ERROR unknown load Binary */;
			57656[_arg0][1] *= var3 + 4/* ERROR unknown load Binary */;
			62940[_arg0][1] *= var3 + 4/* ERROR unknown load Binary */;
			63996[_arg0][1] *= var3 + 4/* ERROR unknown load Binary */;
		}
		if (var3 + 8/* ERROR unknown load Binary */ > 1.0)
		{
			56600[_arg0][2] *= var3 + 8/* ERROR unknown load Binary */;
			57656[_arg0][2] *= var3 + 8/* ERROR unknown load Binary */;
			62940[_arg0][2] *= var3 + 8/* ERROR unknown load Binary */;
			63996[_arg0][2] *= var3 + 8/* ERROR unknown load Binary */;
		}
	}
	return 0;
}

.4064.ScaleVector(_arg0, _arg1)
{
	_arg0 *= _arg1;
	_arg0 + 4/* ERROR unknown load Binary */ *= _arg1;
	_arg0 + 8/* ERROR unknown load Binary */ *= _arg1;
	return 0;
}

.42572.IsAbleToSee(_arg0, _arg1)
{
	if (.46204.IsInFOV(59768[_arg1], 60824[_arg1], 58712[_arg0]))
	{
		new var1 = 0;
		GetEntPropVector(_arg0, 1, 86792, var1, 0);
		GetClientMins(_arg0, 62940[_arg0]);
		GetClientMaxs(_arg0, 63996[_arg0]);
		new var2 = 62940[_arg0];
		var2 = .3240.5-0(var2, 10);
		new var3 = 62940[_arg0][1];
		var3 = .3240.5-0(var3, 10);
		new var4 = 63996[_arg0];
		var4 = .3180.5+0(var4, 10);
		new var5 = 63996[_arg0][1];
		var5 = .3180.5+0(var5, 10);
		new var6 = 0;
		new var7 = 0;
		.3480.AddVectors(var1, 62940[_arg0], var6);
		.3480.AddVectors(var1, 63996[_arg0], var7);
		if (.46460.IsPointVisible(59768[_arg1], 58712[_arg0]))
		{
			return 1;
		}
		if (.44260.IsBoxVisible(var6, var7, 59768[_arg1]))
		{
			return 1;
		}
		if (.46804.IsRectangleVisible(59768[_arg1], 58712[_arg0], 56600[_arg0], 57656[_arg0], 1067869798))
		{
			return 1;
		}
		if (.46596.IsFwdVecVisible(59768[_arg1], 60824[_arg0], 59768[_arg0]))
		{
			return 1;
		}
	}
	return 0;
}

.4276.StrEqual(_arg0, _arg1, _arg2)
{
	return strcmp(_arg0, _arg1, _arg2) == 0;
}

.4328.CanTestFeatures()
{
	return LibraryExists(2280);
}

.4364.HasEntProp(_arg0, _arg1, _arg2)
{
	if (_arg1 == 1)
	{
		return FindDataMapInfo(_arg0, _arg2, 0, 0, 0) != -1;
	}
	if (_arg1)
	{
		return 0;
	}
	new var1 = 0;
	if (GetEntityNetClass(_arg0, var1, NULL_STRING))
	{
		return FindSendPropInfo(var1, _arg2, 0, 0, 0) != -1;
	}
	return 0;
}

.44260.IsBoxVisible(_arg0, _arg1, _arg2)
{
	new var3 = 0;
	new var4 = 0;
	while (var4 < 4)
	{
		.6844.Array_Copy(_arg0, var3[var4], 3);
		.6844.Array_Copy(_arg1, var3[var4 + 4], 3);
		var4++;
	}
	new var5 = var3 + 4;
	var5 + var5/* ERROR unknown load Binary */ = _arg1;
	new var6 = var3 + 8;
	var6 + var6/* ERROR unknown load Binary */ = _arg1;
	new var7 = var3 + 8;
	var7 + var7 + 4/* ERROR unknown load Binary */ = _arg1 + 4/* ERROR unknown load Binary */;
	new var8 = var3 + 12;
	var8 + var8 + 4/* ERROR unknown load Binary */ = _arg1 + 4/* ERROR unknown load Binary */;
	new var9 = var3 + 16;
	var9 + var9/* ERROR unknown load Binary */ = _arg0;
	new var10 = var3 + 16;
	var10 + var10 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */;
	new var11 = var3 + 20;
	var11 + var11 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */;
	new var12 = var3 + 28;
	var12 + var12/* ERROR unknown load Binary */ = _arg0;
	new var13 = 0;
	while (var13 < 4)
	{
		new var14;
		new var1;
		if (var13 == 3)
		{
			var1 = 0;
		}
		else
		{
			var1 = var13 + 1;
		}
		var14 = var1;
		if (.46460.IsPointVisible(var3[var13], _arg2))
		{
			return 1;
		}
		if (.46460.IsPointVisible(var3[var14], _arg2))
		{
			return 1;
		}
		var13++;
	}
	new var15 = 4;
	while (var15 < 8)
	{
		new var16;
		new var2;
		if (var15 == 7)
		{
			var2 = 4;
		}
		else
		{
			var2 = var15 + 1;
		}
		var16 = var2;
		if (.46460.IsPointVisible(var3[var15], _arg2))
		{
			return 1;
		}
		if (.46460.IsPointVisible(var3[var16], _arg2))
		{
			return 1;
		}
		var15++;
	}
	new var17 = 0;
	while (var17 < 4)
	{
		if (.46460.IsPointVisible(var3[var17], _arg2))
		{
			return 1;
		}
		if (.46460.IsPointVisible(var3[var17 + 4], _arg2))
		{
			return 1;
		}
		var17++;
	}
	return 0;
}

.46204.IsInFOV(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	new var2 = 0;
	GetAngleVectors(_arg1, var1, NULL_VECTOR, NULL_VECTOR);
	.3772.SubtractVectors(_arg2, _arg0, var2);
	NormalizeVector(var2, var2);
	return GetVectorDotProduct(var2, var1) > 0.0;
}

.46460.IsPointVisible(_arg0, _arg1)
{
	TR_TraceRayFilter(_arg0, _arg1, 24705, 0, 267, 0);
	g_vard358 += 1;
	return 1.0 == TR_GetFraction(0);
}

.46596.IsFwdVecVisible(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	GetAngleVectors(_arg1, var1, NULL_VECTOR, NULL_VECTOR);
	.4064.ScaleVector(var1, 1114636288);
	.3480.AddVectors(_arg2, var1, var1);
	return .46460.IsPointVisible(_arg0, var1);
}

.46804.IsRectangleVisible(_arg0, _arg1, _arg2, _arg3, _arg4)
{
	new var2;
	var2 = _arg3 + 8/* ERROR unknown load Binary */;
	new var3;
	var3 = _arg2 + 8/* ERROR unknown load Binary */;
	new var4;
	var4 = _arg3 - _arg2 + _arg3 + 4/* ERROR unknown load Binary */ - _arg2 + 4/* ERROR unknown load Binary */ / 4.0;
	new var1;
	if (0.0 == var2 && 0.0 == var3 && 0.0 == var4)
	{
		return .46460.IsPointVisible(_arg0, _arg1);
	}
	var2 *= _arg4;
	var3 *= _arg4;
	var4 *= _arg4;
	new var5 = 0;
	new var6 = 0;
	new var7 = 0;
	.3772.SubtractVectors(_arg0, _arg1, var6);
	NormalizeVector(var6, var6);
	GetVectorAngles(var6, var5);
	GetAngleVectors(var5, var6, var7, NULL_VECTOR);
	new var8 = 0;
	new var9 = 0;
	if (FloatAbs(var6 + 8/* ERROR unknown load Binary */) <= 0.7071)
	{
		.4064.ScaleVector(var7, var4);
		var9 + 8/* ERROR unknown load Binary */ += var2;
		.3480.AddVectors(var9, var7, var8 + var8);
		new var10 = var8 + 4;
		.3772.SubtractVectors(var9, var7, var10 + var10);
		var9 + 8/* ERROR unknown load Binary */ += var3;
		new var11;
		var11 = SquareRoot(GetVectorDistance(var9, var7, 0));
		if (.3420.5<0(var11, 40))
		{
			86856/* ERROR unknown load Constant */ = 75;
			86856 + 4/* ERROR unknown load Binary */ = 25;
			var9 = .3180.5+0(var9, 86856/* ERROR unknown load Constant */);
			new var12 = var9 + 4;
			var12 = .3180.5+0(var12, 86856 + 4/* ERROR unknown load Binary */);
			new var13 = var8 + 8;
			.3480.AddVectors(var9, var7, var13 + var13);
			var9 = .3240.5-0(var9, 86856/* ERROR unknown load Constant */);
			new var14 = var9 + 4;
			var14 = .3240.5-0(var14, 86856 + 4/* ERROR unknown load Binary */);
			new var15 = var8 + 12;
			.3772.SubtractVectors(var9, var7, var15 + var15);
		}
		else
		{
			new var16 = var8 + 8;
			.3480.AddVectors(var9, var7, var16 + var16);
			new var17 = var8 + 12;
			.3772.SubtractVectors(var9, var7, var17 + var17);
		}
	}
	else
	{
		if (var6 + 8/* ERROR unknown load Binary */ > 0.0)
		{
			var6 + 8/* ERROR unknown load Binary */ = 0;
			NormalizeVector(var6, var6);
			.4064.ScaleVector(var6, _arg4);
			.4064.ScaleVector(var6, var4);
			.4064.ScaleVector(var7, var4);
			var9 + 8/* ERROR unknown load Binary */ += var2;
			.3480.AddVectors(var9, var7, var9);
			.3772.SubtractVectors(var9, var6, var8 + var8);
			var9 + 8/* ERROR unknown load Binary */ += var2;
			.3772.SubtractVectors(var9, var7, var9);
			new var18 = var8 + 4;
			.3772.SubtractVectors(var9, var6, var18 + var18);
			var9 + 8/* ERROR unknown load Binary */ += var3;
			.3480.AddVectors(var9, var7, var9);
			new var19 = var8 + 8;
			.3480.AddVectors(var9, var6, var19 + var19);
			var9 + 8/* ERROR unknown load Binary */ += var3;
			.3772.SubtractVectors(var9, var7, var9);
			new var20 = var8 + 12;
			.3480.AddVectors(var9, var6, var20 + var20);
		}
		var6 + 8/* ERROR unknown load Binary */ = 0;
		NormalizeVector(var6, var6);
		.4064.ScaleVector(var6, _arg4);
		.4064.ScaleVector(var6, var4);
		.4064.ScaleVector(var7, var4);
		var9 + 8/* ERROR unknown load Binary */ += var2;
		.3480.AddVectors(var9, var7, var9);
		.3480.AddVectors(var9, var6, var8 + var8);
		var9 + 8/* ERROR unknown load Binary */ += var2;
		.3772.SubtractVectors(var9, var7, var9);
		new var21 = var8 + 4;
		.3480.AddVectors(var9, var6, var21 + var21);
		var9 + 8/* ERROR unknown load Binary */ += var3;
		.3480.AddVectors(var9, var7, var9);
		new var22 = var8 + 8;
		.3772.SubtractVectors(var9, var6, var22 + var22);
		var9 + 8/* ERROR unknown load Binary */ += var3;
		.3772.SubtractVectors(var9, var7, var9);
		new var23 = var8 + 12;
		.3772.SubtractVectors(var9, var6, var23 + var23);
	}
	new var24 = 0;
	while (var24 < 4)
	{
		if (.46460.IsPointVisible(_arg0, var8[var24]))
		{
			return 1;
		}
		var24++;
	}
	return 0;
}

.4768.GetEntityMoveType(_arg0)
{
	if (!g_var8fc)
	{
		new var1;
		var1 = GameData.GameData(2336);
		new var2;
		var2 = GameData.GetKeyValue(var1, 2348, 2304, 32);
		CloseHandle(var1);
		var1 = 0;
		if (!var2)
		{
			strcopy(2304, 32, 2360);
		}
		g_var8fc = 1;
	}
	return GetEntProp(_arg0, 1, 2304, 4, 0);
}

.5060.SetEntityMoveType(_arg0, _arg1)
{
	if (!g_var944)
	{
		new var1;
		var1 = GameData.GameData(2408);
		new var2;
		var2 = GameData.GetKeyValue(var1, 2420, 2376, 32);
		CloseHandle(var1);
		var1 = 0;
		if (!var2)
		{
			strcopy(2376, 32, 2432);
		}
		g_var944 = 1;
	}
	SetEntProp(_arg0, 1, 2376, _arg1, 4, 0);
	return 0;
}

.51104.GetClientAbsVelocity(_arg0, _arg1)
{
	new var1;
	if (g_var15350 == -1 && (g_var15350 = FindDataMapInfo(_arg0, 86868, 0, 0, 0)) == -1)
	{
		.51388.ZeroVector(_arg1);
		return 0;
	}
	GetEntDataVector(_arg0, g_var15350, _arg1);
	return 1;
}

.51388.ZeroVector(_arg0)
{
	_arg0 + 8/* ERROR unknown load Binary */ = 0;
	_arg0 + 4/* ERROR unknown load Binary */ = 0;
	_arg0 = 0;
	return 0;
}

.51484.IsVectorZero(_arg0)
{
	new var1;
	return 0 == _arg0 && 0.0 == _arg0 + 4/* ERROR unknown load Binary */ && 0.0 == _arg0 + 8/* ERROR unknown load Binary */;
}

.51668.GetClientObserverMode(_arg0)
{
	new var1;
	if (g_var15368 == -1 && (g_var15368 = FindSendPropInfo(86892, 86904, 0, 0, 0)) == -1)
	{
		return 0;
	}
	return GetEntData(_arg0, g_var15368, 4);
}

.51908.GetClientObserverTarget(_arg0)
{
	new var1;
	if (g_var15388 == -1 && (g_var15388 = FindSendPropInfo(86924, 86936, 0, 0, 0)) == -1)
	{
		return -1;
	}
	return GetEntDataEnt2(_arg0, g_var15388);
}

.53272.Native_IsCoreLoaded()
{
	return !g_var2004;
}

.53300.Native_IfPlayerReadyToBan()
{
	new var1;
	var1 = GetNativeCell(1);
	return 56064[var1];
}

.5368.GetEntityRenderMode(_arg0)
{
	if (!g_var98c)
	{
		new var1;
		var1 = GameData.GameData(2480);
		new var2;
		var2 = GameData.GetKeyValue(var1, 2492, 2448, 32);
		CloseHandle(var1);
		var1 = 0;
		if (!var2)
		{
			strcopy(2448, 32, 2508);
		}
		g_var98c = 1;
	}
	return GetEntProp(_arg0, 0, 2448, 1, 0);
}

.5660.SetEntityRenderMode(_arg0, _arg1)
{
	if (!g_var9dc)
	{
		new var1;
		var1 = GameData.GameData(2560);
		new var2;
		var2 = GameData.GetKeyValue(var1, 2572, 2528, 32);
		CloseHandle(var1);
		var1 = 0;
		if (!var2)
		{
			strcopy(2528, 32, 2588);
		}
		g_var9dc = 1;
	}
	SetEntProp(_arg0, 0, 2528, _arg1, 1, 0);
	return 0;
}

.58272.GetSvPureValue()
{
	new var1 = 0;
	ServerCommandEx(var1, 128, "sv_pure");
	new var2 = 0;
	var2 = StrContains(var1, "Current sv_pure value is", 1);
	new var3;
	var3 = var1[var2 + 25];
	return var3;
}

.58756.CvarHookServerLog(_arg0)
{
	g_var24c8 = ConVar.IntValue.get(_arg0);
	return 0;
}

.58808.CvarHookChatLog(_arg0)
{
	g_var24cc = ConVar.IntValue.get(_arg0);
	return 0;
}

.58860.CvarHookChatLogSound(_arg0)
{
	ConVar.GetString(_arg0, 8904, 256);
	return 0;
}

.58912.CvarHookChatLogFlag(_arg0)
{
	ConVar.GetString(_arg0, 9160, 256);
	return 0;
}

.58964.CvarHookBanMode(_arg0)
{
	g_var24d0 = ConVar.IntValue.get(_arg0);
	return 0;
}

.59016.CvarHookBanTime(_arg0)
{
	g_var24d4 = ConVar.IntValue.get(_arg0);
	return 0;
}

.59068.CvarHookTraceAntiWallhack(_arg0)
{
	g_vard6d4 = ConVar.BoolValue.get(_arg0);
	new var1;
	if (g_vard6d4 && g_vard6d0)
	{
		.27024.TraceAntiWallhackEnable();
	}
	else
	{
		new var2;
		if (g_vard6d0 && g_vard6d4)
		{
			.27624.TraceAntiWallhackDisable();
		}
	}
	return 0;
}

.59296.CvarHookTraceFlash(_arg0)
{
	g_vard6cc = ConVar.BoolValue.get(_arg0);
	new var1;
	if (g_vard6cc && g_vard5c0)
	{
		.26964.TraceFlashEnable();
	}
	else
	{
		new var2;
		if (g_vard5c0 && g_vard6cc)
		{
			.26996.TraceFlashDisable();
		}
	}
	return 0;
}

.59524.CvarHookTraceSmoke(_arg0)
{
	g_vard5bc = ConVar.BoolValue.get(_arg0);
	new var1;
	if (g_vard5bc && g_vard5b8)
	{
		.26904.TraceSmokeEnable();
	}
	else
	{
		new var2;
		if (g_vard5b8 && g_vard5bc)
		{
			.26936.TraceSmokeDisable();
		}
	}
	return 0;
}

.5968.CGOPrintToChat(_arg0, _arg1)
{
	SetGlobalTransTarget(_arg0);
	VFormat(3576, 2048, _arg1, 3);
	new var1 = 0;
	new var2 = 0;
	while (var2 < 14)
	{
		ReplaceString(3576, 2048, 5624[var2], 5836[var2], 0);
		var2++;
	}
	var2 = 0;
	while (3576[var2])
	{
		if (3576[var2] == 10)
		{
			3576[var2] = 0;
			PrintToChat(_arg0, 5948, var1 + 3576);
			var1 = var2 + 1;
		}
		var2++;
	}
	PrintToChat(_arg0, 5952, var1 + 3576);
	return 0;
}

.59752.CvarHookTraceAimBlock(_arg0)
{
	g_vard6dc = ConVar.BoolValue.get(_arg0);
	new var1;
	if (g_vard6dc && g_vard6d8)
	{
		.26516.TraceAimBlockEnable();
	}
	else
	{
		new var2;
		if (g_vard6d8 && g_vard6dc)
		{
			.26712.TraceAimBlockDisable();
		}
	}
	return 0;
}

.59980.CvarHookTraceAimBlockBeta(_arg0)
{
	g_vard360 = ConVar.IntValue.get(_arg0);
	return 0;
}

.60032.CvarHookAntiDoubleIP(_arg0)
{
	g_var24dc = ConVar.IntValue.get(_arg0);
	return 0;
}

.60084.CvarHookAntiFakeCvar(_arg0)
{
	g_var24e0 = ConVar.IntValue.get(_arg0);
	return 0;
}

.60136.CvarHookDelayCvarCheck(_arg0)
{
	g_vardc0c = ConVar.FloatValue.get(_arg0);
	return 0;
}

.60188.CvarHookBlockSides(_arg0)
{
	g_var24e4 = ConVar.IntValue.get(_arg0);
	return 0;
}

.60240.CvarHookBackTrack(_arg0)
{
	g_var24e8 = ConVar.IntValue.get(_arg0);
	return 0;
}

.60292.CvarHookUntrustedAngles(_arg0)
{
	g_var24f8 = ConVar.IntValue.get(_arg0);
	return 0;
}

.60344.CvarHookBadMove(_arg0)
{
	g_var24f4 = ConVar.IntValue.get(_arg0);
	return 0;
}

.60396.CvarHookBhop(_arg0)
{
	g_var24f0 = ConVar.IntValue.get(_arg0);
	return 0;
}

.60448.CvarHookFixDesync(_arg0)
{
	g_var24ec = ConVar.IntValue.get(_arg0);
	return 0;
}

.60500.CvarHookStats(_arg0)
{
	g_var24d8 = ConVar.IntValue.get(_arg0);
	return 0;
}

.63376.SteamWorks_SteamServersConnected()
{
	new var1 = 0;
	new var2;
	var2 = ConVar.IntValue.get(FindConVar("hostport"));
	if (SteamWorks_GetPublicIP(var1))
	{
		new var3 = 0;
		new var4 = 0;
		FormatEx(var4, 24, "%i.%i.%i.%i", var1, var1 + 4, var1 + 8, var1 + 12);
		new var5;
		var5 = SteamWorks_CreateHTTPRequest(3, "http://license.hotstar-project.net/hotguard/1010110100101");
		FormatEx(var3, 256, "key=%s&ip=%s&port=%i&version=%s&sm=%s", "a2eR386lXu1ptNBb7GKSvDOwwrGVBLxwcm4yrYqM0OYyZBwYMzzLIatPNaF3Arl3", var4, var2, "3.1", "1.10.0.6462");
		SteamWorks_SetHTTPRequestRawPostBody(var5, "application/x-www-form-urlencoded", var3, 256);
		SteamWorks_SetHTTPCallbacks(var5, 283, -1, -1, 0);
		SteamWorks_SendHTTPRequest(var5);
	}
	else
	{
		.64328.x0404x001();
	}
	return 0;
}

.64328.x0404x001()
{
	SetFailState("[%s]", "https://vk.com/xMaZax & hotstar-project.net", 18);
	return 0;
}

.6604.Math_Min(_arg0, _arg1)
{
	if (_arg0 < _arg1)
	{
		_arg0 = _arg1;
	}
	return _arg0;
}

.6672.Math_Max(_arg0, _arg1)
{
	if (_arg0 > _arg1)
	{
		_arg0 = _arg1;
	}
	return _arg0;
}

.6740.Math_Clamp(_arg0, _arg1, _arg2)
{
	_arg0 = .6604.Math_Min(_arg0, _arg1);
	_arg0 = .6672.Math_Max(_arg0, _arg2);
	return _arg0;
}

.6844.Array_Copy(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	while (var1 < _arg2)
	{
		_arg1[var1] = _arg0[var1];
		var1++;
	}
	return 0;
}

.7020.Entity_IsValid(_arg0)
{
	return IsValidEntity(_arg0);
}

.7056.Entity_IsPlayer(_arg0)
{
	new var1;
	if (_arg0 < 1 || _arg0 > MaxClients)
	{
		return 0;
	}
	return 1;
}

.7180.Entity_Kill(_arg0, _arg1)
{
	if (.7056.Entity_IsPlayer(_arg0))
	{
		ForcePlayerSuicide(_arg0);
		return 1;
	}
	if (_arg1)
	{
		return AcceptEntityInput(_arg0, 5972, -1, -1, 0);
	}
	return AcceptEntityInput(_arg0, 5988, -1, -1, 0);
}

.8096.Client_GetFakePing(_arg0, _arg1)
{
	if (IsFakeClient(_arg0))
	{
		return 0;
	}
	new var1 = 0;
	new var2;
	var2 = GetClientLatency(_arg0, 0);
	new var3 = 0;
	GetClientInfo(_arg0, 6496, var3, 4);
	new var4;
	var4 = GetTickInterval();
	var2 -= .3064.5/0(1056964608, StringToInt(var3, 10)) + GetTickInterval() * 1.0;
	if (_arg1)
	{
		var2 -= var4 * 0.5;
	}
	var1 = .2992.RoundFloat(var2 * 1000.0);
	var1 = .6740.Math_Clamp(var1, 5, 1000);
	return var1;
}

.9880.HG_SetServerSettings()
{
	SetConVarInt(FindConVar(65052), 0, 0, 0);
	SetConVarInt(FindConVar(65076), 2, 0, 0);
	SetConVarInt(FindConVar(65104), 2, 0, 0);
	SetConVarInt(FindConVar(65132), 1, 0, 0);
	SetConVarInt(FindConVar(65152), 1, 0, 0);
	SetConVarInt(FindConVar(65164), 1, 0, 0);
	SetConVarInt(FindConVar(65188), 1, 0, 0);
	SetConVarInt(FindConVar(65212), 1, 0, 0);
	SetConVarInt(FindConVar(65240), 1, 0, 0);
	SetConVarInt(FindConVar(65252), g_vard364, 0, 0);
	SetConVarInt(FindConVar(65272), g_vard364, 0, 0);
	return 0;
}

public AskPluginLoad2(_arg0, _arg1, _arg2, _arg3)
{
	new var2;
	var2 = GetTime({0,0});
	new var3 = 0;
	CreateTimer(1123024896, 257, 0, 3);
	new var1;
	if (var2 >= 1588291200 || var2 < 100000)
	{
		var3 = 1;
	}
	new var4 = 0;
	new var5 = 0;
	new var6;
	var6 = GetMyHandle();
	GetPluginFilename(var6, var5, 256);
	BuildPath(0, var4, 256, "plugins/%s", var5);
	new var7;
	var7 = FileSize(var4, 0, "GAME");
	if (!var6)
	{
		var3 = 1;
	}
	if (var7 != 37122)
	{
		var3 = 1;
	}
	if (var3)
	{
		strcopy(_arg2, _arg3, "[HOTGUARD] - Could not find the license");
		return 1;
	}
	if (GetEngineVersion() != 12)
	{
		strcopy(_arg2, _arg3, "This plugin works only on CS:GO!");
		return 1;
	}
	g_vard364 = RoundToZero(1.0 / GetTickInterval());
	if (!(DirExists("/addons/sourcemod/logs/hotguard", 0, "GAME")))
	{
		CreateDirectory("/addons/sourcemod/logs/hotguard", 511, 0, "DEFAULT_WRITE_PATH");
		LogError("We didn't find the folder so we created it for you.");
	}
	strcopy(8648, 256, "models/props_vehicles/cara_69sedan.mdl");
	.9880.HG_SetServerSettings();
	g_varf5d8 = 1.0 / GetTickInterval();
	CreateNative("HG_IsCoreLoaded", 131);
	CreateNative("HG_IfPlayerReadyToBan", 133);
	g_var2004 = GlobalForward.GlobalForward("HG_OnCoreIsReady", 0);
	return 0;
}

public CheckUntrusted()
{
	if (g_var24f8)
	{
		new var6 = 1;
		while (var6 <= MaxClients)
		{
			new var1;
			if (IsValidEntity(var6) && .4364.HasEntProp(var6, 0, 67544) && IsClientConnected(var6) && IsClientInGame(var6) && IsPlayerAlive(var6) && IsFakeClient(var6))
			{
				new var7 = 0;
				new var8 = 0;

/* ERROR! lysis.nodes.types.DConstant cannot be cast to lysis.nodes.types.DDeclareLocal */
 function "CheckUntrusted" (number 104)
public Filter_Entity(_arg0)
{
	return 1 <= GetEntPropEnt(_arg0, 1, 85968, 0) <= MaxClients;
}

public Filter_NoPlayers(_arg0)
{
	new var1;
	return _arg0 > MaxClients && 1 <= GetEntPropEnt(_arg0, 1, 85888, 0) <= MaxClients;
}

public Filter_TraceEntityPlayer(_arg0, _arg1, _arg2)
{
	return _arg0 != _arg2;
}

public Filter_WorldOnly()
{
	return 0;
}

public Hook_SetTransmitTraceAntiWallhack(_arg0, _arg1)
{
	if (g_vard244 == 68164[_arg0][_arg1])
	{
		new var1;
		if (35876[_arg0][_arg1])
		{
			var1 = 0;
		}
		else
		{
			var1 = 3;
		}
		return var1;
	}
	68164[_arg0][_arg1] = g_vard244;
	if (55272[_arg1])
	{
		new var2;
		if (55272[_arg0] && 53564[_arg0] != 53564[_arg1] && 55536[_arg1])
		{
			if (g_vard350 == 53832[_arg1])
			{
				.39316.UpdateClientData(_arg1);
				.39316.UpdateClientData(_arg0);
				if (.42572.IsAbleToSee(_arg0, _arg1))
				{
					35876[_arg0][_arg1] = 1;
					18188[_arg0][_arg1] = g_vard35c + g_vard244;
				}
				if (18188[_arg0][_arg1] < g_vard244)
				{
					35876[_arg0][_arg1] = 0;
				}
			}
		}
		else
		{
			35876[_arg0][_arg1] = 1;
		}
	}
	else
	{
		new var3;
		if (55800[_arg1] && 55272[_arg0] && .51668.GetClientObserverMode(_arg1) == 4 && 53564[_arg1] > 0)
		{
			new var5;
			var5 = .51908.GetClientObserverTarget(_arg1);
			if (1 <= var5 <= MaxClients)
			{
				35876[_arg0][_arg1] = 35876[_arg0][var5];
			}
			else
			{
				35876[_arg0][_arg1] = 1;
			}
		}
		35876[_arg0][_arg1] = 1;
	}
	new var4;
	if (35876[_arg0][_arg1])
	{
		var4 = 0;
	}
	else
	{
		var4 = 3;
	}
	return var4;
}

public Hook_SetTransmitWeapon(_arg0, _arg1)
{
	new var1;
	if (35876[9996[_arg0]][_arg1])
	{
		var1 = 0;
	}
	else
	{
		var1 = 3;
	}
	return var1;
}

public Hook_WeaponDropPost(_arg0, _arg1)
{
	new var1;
	if (_arg1 > MaxClients && _arg1 < 2048)
	{
		9996[_arg1] = 0;
		SDKUnhook(_arg1, 6, 221);
	}
	return 0;
}

public Hook_WeaponEquipPost(_arg0, _arg1)
{
	new var1;
	if (_arg1 > MaxClients && _arg1 < 2048)
	{
		9996[_arg1] = _arg0;
		SDKHook(_arg1, 6, 221);
	}
	return 0;
}

public MaZa_DEC2RGB(_arg0, _arg1, _arg2, _arg3)
{
	_arg1 = _arg0 & 16711680 >>> 16;
	_arg2 = _arg0 & 65280 >>> 8;
	_arg3 = _arg0 & 255;
	return 0;
}

public MaZa_RGB2DEC(_arg0, _arg1, _arg2)
{
	return _arg1 << 8 + _arg0 << 16 + _arg2;
}

public OnClientDisconnect_Post(_arg0)
{
	.18620.HG_SetDefaults(_arg0);
	if (g_vard6d8)
	{
		if (.10708.HG_IsValidClient(_arg0, 0, 1))
		{
			new var1 = 1;
			while (var1 <= MaxClients)
			{
				if (9468[_arg0] == var1)
				{
					9468[_arg0] = 0;
				}
				var1++;
			}
		}
	}
	if (g_vard6d0)
	{
		55008[_arg0] = 0;
		55272[_arg0] = 0;
		55536[_arg0] = 0;
		new var2 = 0;
		while (var2 < 2048)
		{
			if (_arg0 == 9996[var2])
			{
				9996[var2] = 0;
			}
			var2++;
		}
		new var3 = 0;
		while (var3 < 66)
		{
			18188[var3][_arg0] = 0;
			35876[var3][_arg0] = 1;
			var3++;
		}
	}
	.31688.UnhookSetTransmitSmokeDetonate();
	.32596.UnhookSetTransmitPlayerBlind();
	if (g_var24e8)
	{
		new var4 = 8200[_arg0];
		CloseHandle(var4);
		var4 = 0;
	}
	return 0;
}

public OnClientPutInServer(_arg0)
{
	.18620.HG_SetDefaults(_arg0);
	if (g_var24dc == 1)
	{
		new var3 = 0;
		new var4 = 0;
		GetClientIP(_arg0, var3, 32, 1);
		new var5;
		var5 = MaxClients + 1;
		var5--;
		while (var5)
		{
			new var1;
			if (IsClientConnected(var5) && IsFakeClient(_arg0) && IsFakeClient(var5) && _arg0 != var5)
			{
				GetClientIP(var5, var4, 32, 1);
				if (!(strcmp(var3, var4, 1)))
				{
					.15556.UTIL_LOG(_arg0, 2, "%L [DOUBLE IP] - %t", _arg0, "HOTGUARD_BANLOG");
					KickClient(var5, "%t%t", "HOTGUARD_TAGBAN", "HOTGUARD_DOUBLEIP_KICK");
				}
			}
		}
	}
	if (g_vard6d8)
	{
		9468[_arg0] = 0;
	}
	if (g_vard6d0)
	{
		.28076.AntiWallhackHook(_arg0);
		.38972.AntiWallhack_UpdateClientCache(_arg0);
	}
	new var2;
	if (IsFakeClient(_arg0) && 8200[_arg0])
	{
		8200[_arg0] = ArrayList.ArrayList(1, 0);
	}
	return 0;
}

public OnEntityCreated(_arg0)
{
	new var1;
	if (_arg0 > MaxClients && _arg0 < 2048)
	{
		9996[_arg0] = 0;
	}
	return 0;
}

public OnEntityDestroyed(_arg0)
{
	if (_arg0)
	{
		if (g_vard6d8)
		{
			new var2 = 1;
			while (var2 <= MaxClients)
			{
				if (9732[var2] == _arg0)
				{
					9468[var2] = 0;
				}
				var2++;
			}
		}
		if (g_vard6d0)
		{
			new var1;
			if (_arg0 > MaxClients && _arg0 < 2048)
			{
				9996[_arg0] = 0;
			}
		}
		return 0;
	}
	return 0;
}

public OnGameFrame()
{
	if (g_vard6d0)
	{
		g_vard244 = GetGameTickCount();
		g_vard350 += 1;
		if (g_vard350 > g_vard354)
		{
			g_vard350 = 1;
			if (g_vard358)
			{
				g_vard354 = g_vard358 / g_vard364 + 1;
				new var2 = 1;
				new var3;
				var3 = MaxClients + 1;
				var3--;
				while (var3)
				{
					new var1;
					if (IsClientInGame(var3) && 55272[var3])
					{
						53832[var3] = var2;
						var2++;
						if (var2 > g_vard354)
						{
							var2 = 1;
						}
					}
				}
				g_vard358 = 0;
			}
		}
		return 0;
	}
	return 0;
}

public OnLibraryAdded(_arg0)
{
	.10484.HG_SetPluginDetection(_arg0);
	return 0;
}

public OnLibraryRemoved(_arg0)
{
	.10484.HG_SetPluginDetection(_arg0);
	return 0;
}

public OnMapStart()
{
	.9880.HG_SetServerSettings();
	CreateTimer(1097859072, 257, 0, 2);
	CreateTimer(g_vardc0c, 265, 0, 3);
	if (g_var24f8)
	{
		CreateTimer(1077936128, 209, 0, 3);
	}
	PrecacheModel(8648, 1);
	return 0;
}

public OnPlayerRunCmd(_arg0, _arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7, _arg8)
{
	new var1;
	if (IsClientInGame(_arg0) && IsFakeClient(_arg0) && IsClientSourceTV(_arg0) && IsPlayerAlive(_arg0))
	{
		return 0;
	}
	if (0 >= _arg7)
	{
		return 3;
	}
	if (g_var24ec)
	{
		new var2;
		if (GetEntityFlags(_arg0) & 1 && .14880.HG_GetPlayerSpeed(_arg0) < 0.01)
		{
			if (_arg7 % 2 == 1)
			{
				new var15;
				var15 = _arg4 + 4/* ERROR unknown load Binary */ - g_var14fe4;
				new var3;
				if (-90.0 == var15 || 90.0 == var15)
				{
					_arg4 + 4/* ERROR unknown load Binary */ += var15;
				}
			}
			g_var14fe4 = _arg4 + 4/* ERROR unknown load Binary */;
		}
	}
	if (g_var24f0)
	{
		new var4;
		if (.4768.GetEntityMoveType(_arg0) != 9 && ConVar.IntValue.get(FindConVar(85992)))
		{
			new var16;
			var16 = GetEntityFlags(_arg0) & 1;
			new var17;
			var17 = _arg1 & 2;
			new var5;
			if (var17 && var16)
			{
				54156[_arg0]++;
			}
			new var6;
			if (var17 && var16)
			{
				if (54156[_arg0] == 1)
				{
					_arg1 = _arg1 & -3;
					_arg1 = _arg1 & -5;
				}
			}
			new var7;
			if (var17 && var16)
			{
				54156[_arg0] = 0;
			}
		}
	}
	if (g_var24f4)
	{
		new var18;
		var18 = _arg3;
		new var19;
		var19 = _arg3 + 4/* ERROR unknown load Binary */;
		new var8;
		if ((var18 == g_var14fe0 && _arg1 & 8) || (var19 == .3028.-5(g_var14fe0) && _arg1 & 512) || (var18 == .3028.-5(g_var14fe0) && _arg1 & 16) || (var19 == g_var14fe0 && _arg1 & 1024))
		{
			if (g_var24d0 != 1)
			{
				_arg3 = 0;
				_arg3 + 4/* ERROR unknown load Binary */ = 0;
			}
			.18028.HG_PrintToAdmins(86012, 86080, 86100, _arg0, 86116);
			.15556.UTIL_LOG(_arg0, 0, 86132, _arg0, 86160);
			.15016.UTIL_BanClient(_arg0, g_var24d4);
			56064[_arg0] = 1;
		}
		new var13;
		if (.38604.IsValidMove(var18) && .38604.IsValidMove(var19))
		{
			if (g_var24d0 != 1)
			{
				_arg3 = 0;
				_arg3 + 4/* ERROR unknown load Binary */ = 0;
			}
			.18028.HG_PrintToAdmins(86176, 86244, 86264, _arg0, 86280);
			.15556.UTIL_LOG(_arg0, 0, 86296, _arg0, 86324);
			.15016.UTIL_BanClient(_arg0, g_var24d4);
			56064[_arg0] = 1;
		}
		if (_arg1 & 4194304)
		{
			if (g_var24d0 != 1)
			{
				_arg1 = _arg1 & -4194305;
			}
			.18028.HG_PrintToAdmins(86340, 86408, 86428, _arg0, 86444);
			.15556.UTIL_LOG(_arg0, 0, 86460, _arg0, 86488);
			.15016.UTIL_BanClient(_arg0, g_var24d4);
			56064[_arg0] = 1;
		}
	}
	new var14;
	if (g_var24e4 > 0 && _arg1 & 384)
	{
		_arg1 = _arg1 & -129;
		_arg1 = _arg1 & -257;
		_arg3 = 0;
		_arg3 + 4/* ERROR unknown load Binary */ = 0;
		_arg3 + 8/* ERROR unknown load Binary */ = 0;
	}
	if (g_var24e8)
	{
		if (8200[_arg0])
		{
			if (ArrayList.FindValue(8200[_arg0], _arg8, 0) == -1)
			{
				ArrayList.Push(8200[_arg0], _arg8);
				if (ArrayList.Length.get(8200[_arg0]) > g_vard494)
				{
					ArrayList.Erase(8200[_arg0], 0);
				}
			}
			SortADTArray(8200[_arg0], 1, 0);
			_arg8 = ArrayList.Get(8200[_arg0], 0, 0, 0) - GetRandomInt(32, NULL_STRING);
			if (ArrayList.FindValue(8200[_arg0], _arg8, 0) == -1)
			{
				ArrayList.Push(8200[_arg0], _arg8);
			}
			if (ArrayList.Length.get(8200[_arg0]) > g_vard494)
			{
				ArrayList.Erase(8200[_arg0], 0);
			}
			return 1;
		}
	}
	return 0;
}

public OnPluginEnd()
{
	CloseHandle(g_var2110);
	g_var2110 = 0;
	.31688.UnhookSetTransmitSmokeDetonate();
	.32596.UnhookSetTransmitPlayerBlind();
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.10708.HG_IsValidClient(var1, 0, 1))
		{
			.12108.HG_AimBlockDeleteObject(var1);
		}
	}
	return 0;
}

public OnPluginStart()
{
	g_vard388 = GetPlayerResourceEntity();
	54120/* ERROR unknown load Constant */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel", 0, 0, 0);
	54120 + 4/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsLeader", 0, 0, 0);
	54120 + 8/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsTeacher", 0, 0, 0);
	54120 + 12/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsFriendly", 0, 0, 0);
	54120 + 16/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_bHasCommunicationAbuseMute", 0, 0, 0);
	g_vard49c = FindSendPropInfo("CBaseEntity", "m_vecOrigin", 0, 0, 0);
	g_vard4a0 = FindSendPropInfo("CCSPlayer", "m_flFlashDuration", 0, 0, 0);
	g_vard4a4 = FindSendPropInfo("CCSPlayer", "m_flFlashMaxAlpha", 0, 0, 0);
	LoadTranslations("hotguard.phrases");
	g_var2110 = ArrayList.ArrayList(1, 0);
	new var1 = 1;
	while (var1 <= MaxClients)
	{
		if (IsClientInGame(var1))
		{
			OnClientPutInServer(var1);
		}
		var1++;
	}
	new var2 = 0;
	var2 = CreateConVar("hg_serverlog", "1", 87816, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 141);
	g_var24c8 = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_chatlog", "1", 87888, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 143);
	g_var24cc = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_chatlog_sound", "Buttons.snd15", 88020, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 145);
	ConVar.GetString(var2, 8904, 256);
	var2 = CreateConVar("hg_chatlog_flag", "b", 88084, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 147);
	ConVar.GetString(var2, 9160, 256);
	var2 = CreateConVar("hg_banmode", "1", 88240, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 149);
	g_var24d0 = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_bantime", "60", 88364, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 151);
	g_var24d4 = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_tracewh", "1", 88448, 0, 0, 0, 0, 0);
	.59068.CvarHookTraceAntiWallhack(var2, 88576, 88580);
	HookConVarChange(var2, 153);
	var2 = CreateConVar("hg_traceaim", "1", 88600, 0, 0, 0, 0, 0);
	.59752.CvarHookTraceAimBlock(var2, 88716, 88720);
	HookConVarChange(var2, 161);
	ConVar.AddChangeHook(var2, 163);
	g_vard360 = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_traceflash", "1", 88744, 0, 0, 0, 0, 0);
	.59296.CvarHookTraceFlash(var2, 88884, 88888);
	HookConVarChange(var2, 155);
	var2 = CreateConVar("hg_tracesmoke", "1", 88912, 0, 0, 0, 0, 0);
	.59524.CvarHookTraceSmoke(var2, 89036, 89040);
	HookConVarChange(var2, 157);
	var2 = CreateConVar("hg_antidoubleip", "0", 89064, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 165);
	g_var24dc = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_antifakecvar", "1", 89236, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 167);
	g_var24e0 = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_delaycvarcheck", "1.0", 89340, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 169);
	g_vardc0c = ConVar.FloatValue.get(var2);
	var2 = CreateConVar("hg_blocksides", "1", 89560, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 171);
	g_var24e4 = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_backtrack", "1", 89620, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 173);
	g_var24e8 = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_untrustedangles", "1", 89696, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 175);
	g_var24f8 = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_badmove", "1", 89772, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 177);
	g_var24f4 = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_bhopblock", "1", 89848, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 179);
	g_var24f0 = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_fixdesync", "1", 89900, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 181);
	g_var24ec = ConVar.IntValue.get(var2);
	var2 = CreateConVar("hg_stats", "1", 89980, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var2, 183);
	g_var24d8 = ConVar.IntValue.get(var2);
	g_vard35c = RoundToNearest(0.1 / GetTickInterval() + 0.5);
	new var3 = 0;
	while (var3 < 66)
	{
		new var4 = 0;
		while (var4 < 66)
		{
			35876[var3][var4] = 1;
			var4++;
		}
		var3++;
	}
	new var5;
	var5 = MaxClients + 1;
	var5--;
	while (var5)
	{
		if (.10708.HG_IsValidClient(var5, 0, 1))
		{
			.11056.HG_AimBlockCreateObject(var5);
		}
	}
	g_vard494 = RoundToZero(1.0 / GetTickInterval() * ConVar.FloatValue.get(FindConVar("sv_maxunlag")));
	g_vard4a8 = .58272.GetSvPureValue();
	.18768.HookEvents();
	AutoExecConfig(1, "hotguard", "sourcemod");
	Call_StartForward(g_var2004);
	Call_Finish(0);
	CloseHandle(g_var2004);
	g_var2004 = 0;
	return 0;
}

public SetTransmitPlayerBlind(_arg0, _arg1)
{
	if (GetClientTeam(_arg0) == GetClientTeam(_arg1))
	{
		return 0;
	}
	if (56336[_arg1])
	{
		if (56336[_arg1] >= GetGameTime())
		{
			new var1;
			if (_arg1 == _arg0)
			{
				var1 = 0;
			}
			else
			{
				var1 = 3;
			}
			return var1;
		}
		56336[_arg1] = 0;
	}
	return 0;
}

public SetTransmitSmokeDetonate(_arg0, _arg1)
{
	if (GetClientTeam(_arg0) == GetClientTeam(_arg1))
	{
		return 0;
	}
	new var2;
	var2 = g_vard498;
	while (ArrayList.Length.get(g_var2110) > var2)
	{
		new var3;
		var3 = ArrayList.Get(g_var2110, var2, 0, 0);
		if (IsValidEntity(var3))
		{
			GetEntDataVector(_arg1, g_vard49c, 85852);
			GetEntDataVector(_arg0, g_vard49c, 85864);
			GetEntDataVector(var3, g_vard49c, 85876);
			85852 + 8/* ERROR unknown load Binary */ -= 64.0;
			if (.12556.IsLineBlockedBySmoke(85876, 85852, 85864))
			{
				new var1;
				if (_arg1 == _arg0)
				{
					var1 = 0;
				}
				else
				{
					var1 = 3;
				}
				return var1;
			}
		}
		var2++;
	}
	return 0;
}

public Timer_CheckBuy(_arg0)
{
	if (!_arg0)
	{
		.64328.x0404x001();
	}
	new var1;
	if (.4328.CanTestFeatures() && GetFeatureStatus(0, "SteamWorks_CreateHTTPRequest"))
	{
		.63376.SteamWorks_SteamServersConnected();
	}
	else
	{
		.64328.x0404x001();
	}
	return 4;
}

public Timer_CheckIP()
{
	new var1;
	if (.4328.CanTestFeatures() && GetFeatureStatus(0, 66248))
	{
		.63376.SteamWorks_SteamServersConnected();
	}
	return 4;
}

public Timer_FlashEnded()
{
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (56336[var1])
		{
			return 4;
		}
	}
	.32596.UnhookSetTransmitPlayerBlind();
	return 4;
}

public Timer_SmokeEnded()
{
	new var1;
	var1 = MaxClients + 1;
	var1--;
	if (var1)
	{
		return 4;
	}
	.31688.UnhookSetTransmitSmokeDetonate();
	return 4;
}

public Timer_UpdateSettings()
{
	new var2 = 1;
	while (var2 <= MaxClients)
	{
		if (.10708.HG_IsValidClient(var2, 0, 0))
		{
			new var1;
			if (g_var24e0 == 1 && ConVar.IntValue.get(FindConVar(66280)))
			{
				QueryClientConVar(var2, 66292, 39, 0);
				QueryClientConVar(var2, 66304, 39, 0);
				QueryClientConVar(var2, 66320, 39, 0);
				QueryClientConVar(var2, 66332, 39, 0);
				QueryClientConVar(var2, 66348, 39, 0);
				QueryClientConVar(var2, 66360, 39, 0);
				new var3 = 0;
				while (var3 < 8)
				{
					QueryClientConVar(var2, 8468[var3], 39, 0);
					var3++;
				}
			}
		}
		var2++;
	}
	return 0;
}

public TraceEntityFilterPlayer(_arg0, _arg1)
{
	if (_arg0)
	{
		new var7;
		var7 = GetEntProp(_arg0, 0, 85904, 1, 0);
		new var2;
		if (GetEntityFlags(_arg0) & 16777216 && (var7 != 1 && var7 != 6))
		{
			if (!(_arg1 & 33554432))
			{
				return 0;
			}
		}
		new var3;
		if (_arg1 & 2 && .5368.GetEntityRenderMode(_arg0))
		{
			return 0;
		}
		new var4;
		if (_arg1 & 16384 && GetEntProp(_arg0, 1, 85920, 1, 0) == 7)
		{
			return 0;
		}
		new var5;
		if (_arg0 && _arg1 & 67108864 && GetEntProp(_arg0, 0, 85932, 1, 0) == 1)
		{
			return 0;
		}
		new var6;
		return _arg0 > MaxClients && 1 <= GetEntPropEnt(_arg0, 1, 85952, 0) <= MaxClients;
	}
	return 1;
}

public __ext_core_SetNTVOptional()
{
	MarkNativeAsOptional(100);
	MarkNativeAsOptional(120);
	MarkNativeAsOptional(136);
	MarkNativeAsOptional(156);
	MarkNativeAsOptional(180);
	MarkNativeAsOptional(192);
	MarkNativeAsOptional(204);
	MarkNativeAsOptional(216);
	MarkNativeAsOptional(232);
	MarkNativeAsOptional(244);
	MarkNativeAsOptional(256);
	MarkNativeAsOptional(272);
	MarkNativeAsOptional(288);
	MarkNativeAsOptional(304);
	MarkNativeAsOptional(320);
	MarkNativeAsOptional(336);
	MarkNativeAsOptional(352);
	MarkNativeAsOptional(372);
	MarkNativeAsOptional(388);
	MarkNativeAsOptional(400);
	MarkNativeAsOptional(412);
	MarkNativeAsOptional(424);
	MarkNativeAsOptional(436);
	MarkNativeAsOptional(448);
	MarkNativeAsOptional(460);
	MarkNativeAsOptional(472);
	MarkNativeAsOptional(488);
	MarkNativeAsOptional(504);
	MarkNativeAsOptional(516);
	MarkNativeAsOptional(528);
	MarkNativeAsOptional(544);
	MarkNativeAsOptional(560);
	MarkNativeAsOptional(576);
	MarkNativeAsOptional(596);
	MarkNativeAsOptional(616);
	MarkNativeAsOptional(636);
	MarkNativeAsOptional(656);
	MarkNativeAsOptional(676);
	MarkNativeAsOptional(696);
	MarkNativeAsOptional(716);
	MarkNativeAsOptional(736);
	MarkNativeAsOptional(756);
	MarkNativeAsOptional(776);
	MarkNativeAsOptional(796);
	MarkNativeAsOptional(816);
	MarkNativeAsOptional(840);
	MarkNativeAsOptional(864);
	MarkNativeAsOptional(884);
	MarkNativeAsOptional(900);
	MarkNativeAsOptional(916);
	MarkNativeAsOptional(932);
	MarkNativeAsOptional(952);
	MarkNativeAsOptional(968);
	MarkNativeAsOptional(984);
	MarkNativeAsOptional(1004);
	MarkNativeAsOptional(1024);
	MarkNativeAsOptional(1044);
	MarkNativeAsOptional(1064);
	MarkNativeAsOptional(1084);
	MarkNativeAsOptional(1104);
	MarkNativeAsOptional(1128);
	MarkNativeAsOptional(1148);
	MarkNativeAsOptional(1172);
	MarkNativeAsOptional(1184);
	MarkNativeAsOptional(1196);
	MarkNativeAsOptional(1208);
	MarkNativeAsOptional(1224);
	MarkNativeAsOptional(1236);
	MarkNativeAsOptional(1248);
	MarkNativeAsOptional(1264);
	MarkNativeAsOptional(1280);
	MarkNativeAsOptional(1304);
	MarkNativeAsOptional(1316);
	MarkNativeAsOptional(1328);
	MarkNativeAsOptional(1340);
	MarkNativeAsOptional(1352);
	MarkNativeAsOptional(1364);
	MarkNativeAsOptional(1376);
	MarkNativeAsOptional(1388);
	MarkNativeAsOptional(1404);
	MarkNativeAsOptional(1416);
	MarkNativeAsOptional(1428);
	MarkNativeAsOptional(1440);
	MarkNativeAsOptional(1452);
	MarkNativeAsOptional(1464);
	MarkNativeAsOptional(1476);
	MarkNativeAsOptional(1488);
	MarkNativeAsOptional(1504);
	MarkNativeAsOptional(1532);
	MarkNativeAsOptional(1548);
	MarkNativeAsOptional(1572);
	MarkNativeAsOptional(1588);
	MarkNativeAsOptional(1608);
	MarkNativeAsOptional(1628);
	MarkNativeAsOptional(1648);
	MarkNativeAsOptional(1668);
	MarkNativeAsOptional(1688);
	MarkNativeAsOptional(1708);
	MarkNativeAsOptional(1728);
	MarkNativeAsOptional(1748);
	MarkNativeAsOptional(1772);
	MarkNativeAsOptional(1804);
	MarkNativeAsOptional(1820);
	MarkNativeAsOptional(1840);
	MarkNativeAsOptional(1860);
	MarkNativeAsOptional(1880);
	MarkNativeAsOptional(1900);
	MarkNativeAsOptional(1920);
	MarkNativeAsOptional(1940);
	MarkNativeAsOptional(1960);
	MarkNativeAsOptional(1984);
	MarkNativeAsOptional(2000);
	MarkNativeAsOptional(2020);
	MarkNativeAsOptional(2040);
	MarkNativeAsOptional(2060);
	MarkNativeAsOptional(2080);
	MarkNativeAsOptional(2100);
	MarkNativeAsOptional(2120);
	MarkNativeAsOptional(2140);
	MarkNativeAsOptional(2164);
	MarkNativeAsOptional(2200);
	MarkNativeAsOptional(2224);
	MarkNativeAsOptional(2256);
	VerifyCoreVersion();
	return 0;
}

public __pl_materialadmin_SetNTVOptional()
{
	MarkNativeAsOptional(7932);
	MarkNativeAsOptional(7948);
	MarkNativeAsOptional(7960);
	MarkNativeAsOptional(7976);
	MarkNativeAsOptional(7996);
	MarkNativeAsOptional(8016);
	MarkNativeAsOptional(8040);
	MarkNativeAsOptional(8060);
	MarkNativeAsOptional(8080);
	MarkNativeAsOptional(8096);
	return 0;
}

public __pl_sourcebanspp_SetNTVOptional()
{
	MarkNativeAsOptional(8148);
	MarkNativeAsOptional(8160);
	MarkNativeAsOptional(8176);
	return 0;
}

public __smlib_GetPlayersInRadius_Sort(_arg0, _arg1)
{
	return FloatCompare(6512[_arg0], 6512[_arg1]);
}

public __smlib_Timer_ChangeOverTime(_arg0, _arg1)
{
	new var1;
	var1 = EntRefToEntIndex(ReadPackCell(_arg1));
	if (.7020.Entity_IsValid(var1))
	{
		new var2;
		var2 = ReadPackFloat(_arg1);
		new var3;
		var3 = ReadPackCell(_arg1);
		new var4;
		var4 = ReadPackFunction(_arg1);
		new var5 = 0;
		Call_StartFunction(0, var4);
		Call_PushCellRef(var1);
		Call_PushFloatRef(var2);
		Call_PushCellRef(var3);
		Call_Finish(var5);
		if (var5)
		{
			ResetPack(_arg1, 1);
			WritePackCell(_arg1, EntIndexToEntRef(var1));
			WritePackFloat(_arg1, var2);
			WritePackCell(_arg1, var3 + 1);
			WritePackFunction(_arg1, var4);
			ResetPack(_arg1, 0);
			CreateTimer(var2, 277, _arg1, 0);
			return 4;
		}
		return 4;
	}
	return 4;
}

public _smlib_Timer_Effect_Fade(_arg0, _arg1)
{
	new var2;
	var2 = ReadPackCell(_arg1);
	new var3;
	var3 = ReadPackCell(_arg1);
	new var4;
	var4 = ReadPackFunction(_arg1);
	new var5;
	var5 = ReadPackCell(_arg1);
	if (var4 != -1)
	{
		Call_StartFunction(0, var4);
		Call_PushCell(var2);
		Call_PushCell(var5);
		Call_Finish(0);
	}
	new var1;
	if (var3 && IsValidEntity(var2))
	{
		.7180.Entity_Kill(var2, 0);
	}
	return 4;
}

public _smlib_TraceEntityFilter(_arg0)
{
	return _arg0 == 0;
}

public x000001(_arg0, _arg1, _arg2, _arg3)
{
	CloseHandle(_arg0);
	_arg0 = 0;
	new var1;
	var1 = _arg3;
	if (var1 < 500)
	{
		switch (var1)
		{
			case 201:
			{
				LogAction(-1, -1, 90512);
			}
			case 404:
			{
				PrintToServer(90592);
				.64328.x0404x001();
			}
			case 413:
			{
				PrintToServer(90632);
				.64328.x0404x001();
			}
			default:
			{
				PrintToServer(90672, var1);
				.64328.x0404x001();
			}
		}
	}
	return 0;
}

