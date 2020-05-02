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
public Extension:__ext_dhooks =
{
	name = "dhooks",
	file = "dhooks.ext",
	autoload = 1,
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
	date = "03/18/2020",
	time = "18:22:05"
};
public Plugin:myinfo =
{
	name = "HotGuard AntiCheat",
	description = "Server anti-cheat system",
	author = "MaZa",
	version = "3.2",
	url = "vk.com/xMaZax"
};
new g_vareeb8;
new g_vareeb0;
new g_var8a68 = -1;
new g_vard0b0;
new g_varcfa4;
new g_var6a64;
new g_var6a60 = -1;
new g_var145e0 = -1;
new g_var1ce4;
new g_vareda4;
new g_vard0b4;
new g_vard0b8;
new g_var8fc;
new g_vard0c0;
new g_vard0bc;
new g_var944;
new g_var98c;
new g_var1f14;
new g_var1ce8;
new g_varf648;
new g_vareeb4;
new g_varf798;
.17976.GetAngleDelta(_arg0, _arg1)
{
	new var2 = 5;
	new var3 = 0;
	new var4 = 0;
	new var5 = 0;
	var3 + 8/* ERROR unknown load Binary */ = 0;
	var4 + 8/* ERROR unknown load Binary */ = 0;
	var5 = GetVectorDistance(var3, var4, 0);
	while (var5 > 180.0 && var2 > 0)
	{
		var2--;
		var5 = FloatAbs(var5 - 360.0);
	}
	return var5;
}

.18452.IfStrafeMove(_arg0, _arg1)
{
	new var7 = 0;
	new var1;
	if ((64508/* ERROR unknown load Constant */ == _arg0 && 64508 + 4/* ERROR unknown load Binary */ == _arg0 + 4/* ERROR unknown load Binary */ && 64508 + 4/* ERROR unknown load Binary */ == _arg0 + 4/* ERROR unknown load Binary */) && (_arg1 > 0 || _arg1 + 4/* ERROR unknown load Binary */ > 0))
	{
		var7 = 1;
	}
	else
	{
		new var4;
		if ((64508/* ERROR unknown load Constant */ != _arg0 || 64508 + 4/* ERROR unknown load Binary */ != _arg0 + 4/* ERROR unknown load Binary */ || 64508 + 4/* ERROR unknown load Binary */ != _arg0 + 4/* ERROR unknown load Binary */) && (_arg1 && _arg1 + 4/* ERROR unknown load Binary */))
		{
			var7 = 0;
		}
	}
	64508/* ERROR unknown load Constant */ = _arg0;
	64508 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */;
	64508 + 8/* ERROR unknown load Binary */ = _arg0 + 8/* ERROR unknown load Binary */;
	return var7;
}

.19404.IsValidMove(_arg0)
{
	if (ConVar.IntValue.get(g_vareeb8))
	{
		return 1;
	}
	_arg0 = FloatAbs(_arg0);
	new var1;
	return 0 == _arg0 || _arg0 == g_vareeb0 || _arg0 == g_vareeb0 * 0.75 || _arg0 == g_vareeb0 * 0.5 || _arg0 == g_vareeb0 * 0.25;
}

.19824.IsLegalMoveType(_arg0, _arg1)
{
	new var4;
	var4 = .4188.GetEntityMoveType(_arg0);
	new var5;
	var5 = GetEntityFlags(_arg0);
	new var1;
	return (_arg1 && GetEntProp(_arg0, 1, 64520, 4, 0) < 2) && (var5 & 64 && var5 & 32 && (var4 == 2 || var4 == 1 || var4 == 9));
}

.20212.HG_LOG(_arg0, _arg1)
{
	if (7960[_arg0])
	{
		return 0;
	}
	if (7404/* ERROR unknown load Constant */)
	{
		if (.23556.HG_IsValidClient(_arg0, 0, 1))
		{
			new var1 = 0;
			new var2 = 0;
			new var3 = 0;
			new var4 = 0;
			new var5 = 0;
			new var6 = 0;
			new var7 = 0;
			new var8 = 0;
			new var9 = 0;
			if (!(GetClientIP(_arg0, var2, 16, 1)))
			{
				strcopy(var2, 16, 64536);
			}
			new var10;
			var10 = GetTime({0,0});
			FormatTime(var6, 12, 64564, var10);
			FormatTime(var7, 12, 64568, var10);
			GetCurrentMap(var1, 130);
			VFormat(var5, 1024, _arg1, 3);
			GetClientAuthId(_arg0, 1, var9, 32, 1);
			FormatEx(var3, 1024, 64580, var6, var1, _arg0, var9, var2, .6696.Client_GetFakePing(_arg0, 1), var5);
			BuildPath(0, var8, 256, 64612, var7);
			new var11;
			var11 = OpenFile(var8, 64644, 0, 64648);
			if (var11)
			{
				WriteFileLine(var11, var3);
				if (7404 + 12/* ERROR unknown load Binary */)
				{
					if (g_var8a68 != -1)
					{
						new var12;
						var12 = .23848.GetClientStats(_arg0, g_var8a68, 35436/* ERROR unknown load Constant */);
						FormatEx(var4, 1024, 64656, _arg0, var12, .23848.GetClientStats(_arg0, g_var8a68, 35436 + 4/* ERROR unknown load Binary */), .23848.GetClientStats(_arg0, g_var8a68, 35436 + 8/* ERROR unknown load Binary */), .23848.GetClientStats(_arg0, g_var8a68, 35436 + 12/* ERROR unknown load Binary */), .23848.GetClientStats(_arg0, g_var8a68, 35436 + 16/* ERROR unknown load Binary */));
						WriteFileLine(var11, var4);
					}
				}
			}
			CloseHandle(var11);
			var11 = 0;
		}
		return 0;
	}
	return 0;
}

.21836.HG_CHATLOG(_arg0, _arg1)
{
	if (7660)
	{
		new var2;
		var2 = MaxClients + 1;
		var2--;
		while (var2)
		{
			if (7960[var2])
			{
				return 0;
			}
			new var1;
			if (.23556.HG_IsValidClient(var2, 0, 1) && .22280.HG_CheckAdminImmunity(var2))
			{
				if (7672/* ERROR unknown load Constant */)
				{
					ClientCommand(var2, 64756, 7672);
				}
				.7920.CGOPrintToChat(var2, 64776, 64788, 64808, 64824, _arg0, 64852, _arg1);
			}
		}
		return 0;
	}
	return 0;
}

.22280.HG_CheckAdminImmunity(_arg0)
{
	new var1;
	var1 = GetUserFlagBits(_arg0);
	if (0 < var1)
	{
		if (strcmp(7660, 64872, 1))
		{
			return 1;
		}
		if (0 < ReadFlagString(7660, 0) | 16384 & var1)
		{
			return 1;
		}
	}
	return 0;
}

.22564.SetDefaultsSettings(_arg0)
{
	26968[_arg0] = 0;
	61380[_arg0] = 0;
	60840[_arg0] = 0;
	7960[_arg0] = 0;
	return 0;
}

.22756.HG_SetPluginDetection(_arg0)
{
	if (.4100.StrEqual(_arg0, 64876, 1))
	{
		g_vard0b0 = 1;
	}
	else
	{
		if (.4100.StrEqual(_arg0, 64892, 1))
		{
			g_vard0b0 = 2;
		}
	}
	return 0;
}

.22908.HG_Ban(_arg0)
{
	new var1;
	if (7404 + 16/* ERROR unknown load Binary */ == -1 || 7404 + 16/* ERROR unknown load Binary */ == -3)
	{
		return 0;
	}
	if (7960[_arg0])
	{
		return 0;
	}
	new var2 = 0;
	FormatEx(var2, 129, 64908, 64916, 64932);
	if (7404 + 16/* ERROR unknown load Binary */ == -2)
	{
		KickClient(_arg0, var2);
		return 0;
	}
	switch (g_vard0b0)
	{
		case 1:
		{
			SBPP_BanPlayer(0, _arg0, 7404 + 16/* ERROR unknown load Binary */, var2);
		}
		case 2:
		{
			MABanPlayer(0, _arg0, 1, 7404 + 16/* ERROR unknown load Binary */, var2);
		}
		default:
		{
			BanClient(_arg0, 7404 + 16/* ERROR unknown load Binary */, 1, var2, 64948, 64952, 0);
		}
	}
	return 0;
}

.23556.HG_IsValidClient(_arg0, _arg1, _arg2)
{
	new var3;
	if (1 <= _arg0 <= MaxClients && IsClientInGame(_arg0) && (IsFakeClient(_arg0) && _arg1) && (_arg2 && IsPlayerAlive(_arg0)))
	{
		return 0;
	}
	return 1;
}

.23848.GetClientStats(_arg0, _arg1, _arg2)
{
	return GetEntData(_arg1, _arg0 * 4 + _arg2, 4);
}

.23932.HG_GetPlayerSpeed(_arg0)
{
	new var1 = 0;
	GetEntPropVector(_arg0, 1, 64956, var1, 0);
	return GetVectorLength(var1, 0);
}

.24108.DisableModuleAntiWallhack()
{
	g_varcfa4 = 0;
	UnhookEvent(64976, 251, 0);
	UnhookEvent(64992, 251, 0);
	UnhookEvent(65008, 251, 0);
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.23556.HG_IsValidClient(var1, 1, 1))
		{
			25912[var1] = 0;
			26176[var1] = 0;
			new var2 = 0;
			while (var2 < 66)
			{
				35468[var2][var1] = 0;
				8224[var2][var1] = 1;
				var2++;
			}
			26968[var1] = 0;
			SDKUnhook(var1, 6, 189);
			SDKUnhook(var1, 32, 197);
			SDKUnhook(var1, 31, 195);
		}
	}
	new var3;
	var3 = GetEntityCount();
	new var4;
	var4 = MaxClients + 1;
	while (var4 < var3)
	{
		if (27240[var4])
		{
			27240[var4] = 0;
			SDKUnhook(var4, 6, 191);
		}
		var4++;
	}
	return 0;
}

.25176.EnableModuleAntiWallhack()
{
	g_varcfa4 = RoundToNearest(0.2 / GetTickInterval());
	new var1 = 0;
	while (var1 < 66)
	{
		new var2 = 0;
		while (var2 < 66)
		{
			8224[var1][var2] = 1;
			var2++;
		}
		var1++;
	}
	HookEvent(65020, 251, 0);
	HookEvent(65036, 251, 0);
	HookEvent(65052, 251, 0);
	return 0;
}

.25628.Hook_ModuleAntiWallhack(_arg0)
{
	if (!26968[_arg0])
	{
		if (.23556.HG_IsValidClient(_arg0, 1, 1))
		{
			26968[_arg0] = 1;
			.28952.AW_UpdateClientCache(_arg0);
			SDKHook(_arg0, 6, 189);
			SDKHook(_arg0, 32, 197);
			SDKHook(_arg0, 31, 195);
			new var1;
			var1 = GetEntityCount();
			new var2;
			var2 = MaxClients + 1;
			while (var2 < var1)
			{
				if (IsValidEdict(var2))
				{
					new var3;
					var3 = GetEntPropEnt(var2, 1, 65064, 0);
					if (1 <= var3 <= MaxClients)
					{
						27240[var2] = var3;
						if (_arg0 == var3)
						{
							SDKHook(var2, 6, 191);
						}
					}
				}
				var2++;
			}
		}
	}
	return 0;
}

.28952.AW_UpdateClientCache(_arg0)
{
	53160[_arg0] = GetClientTeam(_arg0);
	25912[_arg0] = IsPlayerAlive(_arg0);
	26176[_arg0] = IsFakeClient(_arg0);
	return 0;
}

.29160.AW_UpdateClientCachePos(_arg0)
{
	if (g_var6a64 == 82776[_arg0])
	{
		return 0;
	}
	82776[_arg0] = g_var6a64;
	GetClientMins(_arg0, 55556[_arg0]);
	GetClientMaxs(_arg0, 56612[_arg0]);
	GetClientAbsOrigin(_arg0, 57668[_arg0]);
	GetClientEyePosition(_arg0, 58724[_arg0]);
	56612[_arg0][2] *= 1.0;
	55556[_arg0][2] -= 56612[_arg0][2];
	new var1 = 57668[_arg0][2];
	var1 = var1[56612[_arg0][2]];
	if (IsFakeClient(_arg0))
	{
		return 0;
	}
	new var2 = 0;
	.36904.GetClientAbsVelocity(_arg0, var2[_arg0]);
	if (g_var6a60 == -1)
	{
		g_var6a60 = FindDataMapInfo(_arg0, 83304, 0, 0, 0);
	}
	new var3;
	var3 = GetTickInterval();
	new var4;
	var4 = GetEntDataFloat(_arg0, g_var6a60);
	new var5;
	var5 = RoundToNearest(var4 / var3) + -1;
	new var6;
	var6 = GetGameTickCount() + -1;
	new var7;
	var7 = var6 - g_var6a64;
	new var8 = 0;
	var8 += GetClientLatency(_arg0, 0);
	var8 += .3064.5*0(var3, var5);
	new var9 = 0;
	var9 = FloatAbs(var2[_arg0]) * 0.01;
	var9 + 4/* ERROR unknown load Binary */ = FloatAbs(var2[_arg0][1]) * 0.01;
	var9 + 8/* ERROR unknown load Binary */ = FloatAbs(var2[_arg0][2]) * 0.01;
	new var10 = 0;
	.3888.ScaleVector(var2[_arg0], var8 - .3064.5*0(var3, var7));
	.3304.AddVectors(57668[_arg0], var2[_arg0], var10);
	TR_TraceHullFilter(var10, var10, 83316, 83328, 24705, 185, 0);
	if (!(TR_DidHit(0)))
	{
		.3304.AddVectors(58724[_arg0], var2[_arg0], 58724[_arg0]);
	}
	if (var9 > 1.0)
	{
		55556[_arg0] *= var9;
		56612[_arg0] *= var9;
	}
	if (var9 + 4/* ERROR unknown load Binary */ > 1.0)
	{
		55556[_arg0][1] *= var9 + 4/* ERROR unknown load Binary */;
		56612[_arg0][1] *= var9 + 4/* ERROR unknown load Binary */;
	}
	if (var9 + 8/* ERROR unknown load Binary */ > 1.0)
	{
		55556[_arg0][2] *= var9 + 8/* ERROR unknown load Binary */;
		56612[_arg0][2] *= var9 + 8/* ERROR unknown load Binary */;
	}
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

.3064.5*0(_arg0, _arg1)
{
	return _arg0 * float(_arg1);
}

.3124.5/0(_arg0, _arg1)
{
	return _arg0 / float(_arg1);
}

.3184.5+0(_arg0, _arg1)
{
	return _arg0 + float(_arg1);
}

.3244.5-0(_arg0, _arg1)
{
	return _arg0 - float(_arg1);
}

.3304.AddVectors(_arg0, _arg1, _arg2)
{
	_arg2 = _arg0 + _arg1;
	_arg2 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */ + _arg1 + 4/* ERROR unknown load Binary */;
	_arg2 + 8/* ERROR unknown load Binary */ = _arg0 + 8/* ERROR unknown load Binary */ + _arg1 + 8/* ERROR unknown load Binary */;
	return 0;
}

.33404.AW_IsAbleToSee(_arg0, _arg1)
{
	if (.34840.AW_IsFOV(58724[_arg1], 59780[_arg1], 57668[_arg0]))
	{
		if (.36440.AW_IsPointVisible(58724[_arg1], 57668[_arg0]))
		{
			return 1;
		}
		if (.35204.IsFwdVecVisible(58724[_arg1], 59780[_arg0], 58724[_arg0]))
		{
			return 1;
		}
		GetClientMins(_arg0, 55556[_arg0]);
		GetClientMaxs(_arg0, 56612[_arg0]);
		new var1 = 55556[_arg0];
		var1 = .3244.5-0(var1, 5);
		new var2 = 55556[_arg0][1];
		var2 = .3244.5-0(var2, 30);
		new var3 = 56612[_arg0];
		var3 = .3184.5+0(var3, 5);
		new var4 = 56612[_arg0][1];
		var4 = .3184.5+0(var4, 5);
		new var5 = 0;
		GetEntPropVector(_arg0, 1, 83340, var5, 0);
		new var6 = 0;
		new var7 = 0;
		.3304.AddVectors(var5, 55556[_arg0], var6);
		.3304.AddVectors(var5, 56612[_arg0], var7);
		if (.35412.AW_IsBoxVisible(var6, var7, 58724[_arg1]))
		{
			return 1;
		}
	}
	return 0;
}

.34840.AW_IsFOV(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	new var2 = 0;
	GetAngleVectors(_arg1, var1, NULL_VECTOR, NULL_VECTOR);
	.3596.SubtractVectors(_arg2, _arg0, var2);
	NormalizeVector(var2, var2);
	if (GetVectorDistance(_arg0, _arg2, 0) < 75.0)
	{
		return 1;
	}
	return GetVectorDotProduct(var2, var1) > 0.0;
}

.35204.IsFwdVecVisible(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	GetAngleVectors(_arg1, var1, NULL_VECTOR, NULL_VECTOR);
	.3888.ScaleVector(var1, 1114636288);
	.3304.AddVectors(_arg2, var1, var1);
	return .36440.AW_IsPointVisible(_arg0, var1);
}

.35412.AW_IsBoxVisible(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	new var2 = 0;
	while (var2 < 4)
	{
		.5336.Array_Copy(_arg0, var1[var2], 3);
		.5336.Array_Copy(_arg1, var1[var2 + 4], 3);
		var2++;
	}
	new var3 = var1 + 4;
	var3 + var3/* ERROR unknown load Binary */ = _arg1;
	new var4 = var1 + 8;
	var4 + var4/* ERROR unknown load Binary */ = _arg1;
	new var5 = var1 + 8;
	var5 + var5 + 4/* ERROR unknown load Binary */ = _arg1 + 4/* ERROR unknown load Binary */;
	new var6 = var1 + 12;
	var6 + var6 + 4/* ERROR unknown load Binary */ = _arg1 + 4/* ERROR unknown load Binary */;
	new var7 = var1 + 16;
	var7 + var7/* ERROR unknown load Binary */ = _arg0;
	new var8 = var1 + 16;
	var8 + var8 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */;
	new var9 = var1 + 20;
	var9 + var9 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */;
	new var10 = var1 + 28;
	var10 + var10/* ERROR unknown load Binary */ = _arg0;
	new var11 = 0;
	while (var11 < 8)
	{
		if (.36440.AW_IsPointVisible(var1[var11], _arg2))
		{
			return 1;
		}
		var11++;
	}
	return 0;
}

.3596.SubtractVectors(_arg0, _arg1, _arg2)
{
	_arg2 = _arg0 - _arg1;
	_arg2 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */ - _arg1 + 4/* ERROR unknown load Binary */;
	_arg2 + 8/* ERROR unknown load Binary */ = _arg0 + 8/* ERROR unknown load Binary */ - _arg1 + 8/* ERROR unknown load Binary */;
	return 0;
}

.36440.AW_IsPointVisible(_arg0, _arg1)
{
	TR_TraceRayFilter(_arg0, _arg1, 24705, 0, 183, 0);
	return TR_GetFraction(0) > 0.995;
}

.36904.GetClientAbsVelocity(_arg0, _arg1)
{
	new var1;
	if (g_var145e0 == -1 && (g_var145e0 = FindDataMapInfo(_arg0, 83428, 0, 0, 0)) == -1)
	{
		.37188.ZeroVector(_arg1);
		return 0;
	}
	GetEntDataVector(_arg0, g_var145e0, _arg1);
	return 1;
}

.37188.ZeroVector(_arg0)
{
	_arg0 + 8/* ERROR unknown load Binary */ = 0;
	_arg0 + 4/* ERROR unknown load Binary */ = 0;
	_arg0 = 0;
	return 0;
}

.37284.DisableModuleFixSmoke()
{
	.37448.UnhookModuleFixSmoke();
	CloseHandle(g_var1ce4);
	g_var1ce4 = 0;
	UnhookEvent(83448, 75, 1);
	UnhookEvent(83472, 75, 1);
	return 0;
}

.37448.UnhookModuleFixSmoke()
{
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.23556.HG_IsValidClient(var1, 1, 1))
		{
			if (26440[var1])
			{
				26440[var1] = 0;
				SDKUnhook(var1, 6, 225);
			}
		}
	}
	return 0;
}

.37728.EnableModuleFixSmoke()
{
	g_var1ce4 = ArrayList.ArrayList(1, 0);
	HookEvent(83496, 75, 1);
	HookEvent(83520, 75, 1);
	return 0;
}

.37872.HookModuleFixSmoke()
{
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.23556.HG_IsValidClient(var1, 1, 1))
		{
			if (!26440[var1])
			{
				26440[var1] = 1;
				SDKHook(var1, 6, 225);
			}
		}
	}
	return 0;
}

.38156.OnSmokeEvent(_arg0, _arg1)
{
	if (_arg1 + 13/* ERROR unknown load Binary */ == 100)
	{
		g_vareda4 = GetGameTime();
		CreateTimer(1099431936, 231, 0, 0);
		.37872.HookModuleFixSmoke();
		ArrayList.Push(g_var1ce4, Event.GetInt(_arg0, 83544, 0));
	}
	else
	{
		g_vard0b4 += 1;
		if (ArrayList.Length.get(g_var1ce4) == g_vard0b4)
		{
			ArrayList.Clear(g_var1ce4);
			g_vard0b4 = 0;
		}
	}
	return 0;
}

.3888.ScaleVector(_arg0, _arg1)
{
	_arg0 *= _arg1;
	_arg0 + 4/* ERROR unknown load Binary */ *= _arg1;
	_arg0 + 8/* ERROR unknown load Binary */ *= _arg1;
	return 0;
}

.39460.IsAbleToSeeSmoke(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	new var2 = 0;
	GetEntDataVector(_arg1, g_vard0b8, 83592);
	GetClientEyePosition(_arg1, var1);
	GetClientEyePosition(_arg0, var2);
	GetEntDataVector(_arg0, g_vard0b8, 83604);
	GetEntDataVector(_arg2, g_vard0b8, 83616);
	0/* ERROR unknown load Constant */ = 83616 + 8/* ERROR unknown load Binary */;
	0/* ERROR unknown load Constant */ = var1 + 8/* ERROR unknown load Binary */;
	if (.39956.IsLineBlockedBySmoke(83616, var1, var2))
	{
		return 1;
	}
	return 0;
}

.39956.IsLineBlockedBySmoke(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	new var2 = 0;
	.3596.SubtractVectors(_arg2, _arg1, var2);
	new var3;
	var3 = NormalizeVector(var2, var2);
	new var4 = 1179558912;
	new var5 = 0;
	new var6 = 0;
	.3596.SubtractVectors(_arg0, _arg1, var6);
	new var7;
	var7 = GetVectorDotProduct(var6, var2);
	new var8 = 0;
	if (!(var7 < 0.0))
	{
		if (!(var7 >= var3))
		{
			.3888.ScaleVector(var8, var7);
			.3304.AddVectors(_arg1, var8, var8);
		}
	}
	new var9 = 0;
	.3596.SubtractVectors(var8, _arg0, var9);
	new var10;
	var10 = GetVectorLength(var9, 1);
	if (var10 < var4)
	{
		new var11;
		var11 = GetVectorLength(var6, 1);
		.3596.SubtractVectors(_arg0, _arg2, var5);
		new var12;
		var12 = GetVectorLength(var5, 1);
		if (var11 < var4)
		{
			if (var12 < var4)
			{
				.3596.SubtractVectors(_arg2, _arg1, var5);
				var1 += GetVectorLength(var5, 0);
			}
			else
			{
				new var13;
				var13 = SquareRoot(var4 - var10);
				.3596.SubtractVectors(var8, _arg1, var5);
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
				.3596.SubtractVectors(_arg2, _arg0, var15);
				.3596.SubtractVectors(var8, _arg2, var5);
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
	if (var1 > 0.0)
	{
		return 1;
	}
	return 0;
}

.4100.StrEqual(_arg0, _arg1, _arg2)
{
	return strcmp(_arg0, _arg1, _arg2) == 0;
}

.4152.CanTestFeatures()
{
	return LibraryExists(2280);
}

.4188.GetEntityMoveType(_arg0)
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

.42320.DisableModuleFixFlash()
{
	.42404.UnhookModuleFixFlash();
	UnhookEvent(83628, 97, 1);
	return 0;
}

.42404.UnhookModuleFixFlash()
{
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.23556.HG_IsValidClient(var1, 1, 1))
		{
			if (26704[var1])
			{
				26704[var1] = 0;
				SDKUnhook(var1, 6, 223);
			}
		}
	}
	return 0;
}

.42684.EnableModuleFixFlash()
{
	HookEvent(83644, 97, 1);
	return 0;
}

.42748.HookModuleFixFlash()
{
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.23556.HG_IsValidClient(var1, 1, 1))
		{
			if (!26704[var1])
			{
				26704[var1] = 1;
				SDKHook(var1, 6, 223);
			}
		}
	}
	return 0;
}

.43032.Event_PlayerBlind(_arg0)
{
	new var1;
	var1 = GetClientOfUserId(Event.GetInt(_arg0, 83660, 0));
	if (IsPlayerAlive(var1))
	{
		.42748.HookModuleFixFlash();
		if (GetEntDataFloat(var1, g_vard0c0) < 255.0)
		{
			60840[var1] = 0;
			return 0;
		}
		new var2;
		var2 = GetEntDataFloat(var1, g_vard0bc);
		new var3;
		var3 = GetGameTime();
		if (var2 > 2.9)
		{
			60840[var1] = var3 + var2 - 2.9;
		}
		else
		{
			60840[var1] = var3 + var2 / 10.0;
		}
		CreateTimer(var2, 229, 0, 0);
		return 0;
	}
	return 0;
}

.44268.DisableModuleBlockAim()
{
	UnhookEvent(83668, 109, 1);
	UnhookEvent(83680, 109, 1);
	return 0;
}

.44376.EnableModuleBlockAim()
{
	HookEvent(83696, 109, 1);
	HookEvent(83708, 109, 1);
	return 0;
}

.44484.ModuleBlockAimCreateObject(_arg0)
{
	if (61380[_arg0])
	{
		return 0;
	}
	61116[_arg0] = CreateEntityByName(83724, -1);
	if (IsValidEntity(61116[_arg0]))
	{
		DispatchKeyValue(61116[_arg0], 83748, 83756);
		if (DispatchSpawn(61116[_arg0]))
		{
			SetVariantString(83796);
			AcceptEntityInput(61116[_arg0], 83808, _arg0, 61116[_arg0], 0);
			SetVariantInt(1);
			AcceptEntityInput(61116[_arg0], 83820, -1, -1, 0);
			SetVariantInt(1);
			AcceptEntityInput(61116[_arg0], 83836, -1, -1, 0);
			SetEntPropEnt(61116[_arg0], 0, 83864, _arg0, 0);
			SetEntPropFloat(61116[_arg0], 0, 83880, 1072483533, 0);
			.4788.SetEntityRenderMode(61116[_arg0], 10);
			.4480.SetEntityMoveType(61116[_arg0], 0);
			SetEntProp(61116[_arg0], 0, 83896, 217, 4, 0);
			SetEntProp(61116[_arg0], 0, 83908, 1, 1, 0);
			SetEntProp(61116[_arg0], 1, 83924, 0, 2, 0);
			SetEntProp(61116[_arg0], 1, 83940, 10, 4, 0);
			61380[_arg0] = 61116[_arg0];
		}
	}
	return 0;
}

.4480.SetEntityMoveType(_arg0, _arg1)
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

.45728.ModuleBlockAimRemoveObject(_arg0)
{
	if (61380[_arg0])
	{
		new var1;
		if (61116[_arg0] != -1 && IsValidEntity(61116[_arg0]) && 61116[_arg0] == 61380[_arg0])
		{
			RemoveEntity(61116[_arg0]);
			61380[_arg0] = 0;
		}
		return 0;
	}
	return 0;
}

.46088.ePlayerAimBlock(_arg0, _arg1)
{
	new var1;
	var1 = GetClientOfUserId(Event.GetInt(_arg0, 83960, 0));
	if (var1)
	{
		if (_arg1 == 114)
		{
			Hook_SpawnPost(var1);
		}
		Hook_SpawnPost(var1);
	}
	return 0;
}

.4788.SetEntityRenderMode(_arg0, _arg1)
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
	SetEntProp(_arg0, 0, 2448, _arg1, 1, 0);
	return 0;
}

.5096.Math_Min(_arg0, _arg1)
{
	if (_arg0 < _arg1)
	{
		_arg0 = _arg1;
	}
	return _arg0;
}

.5164.Math_Max(_arg0, _arg1)
{
	if (_arg0 > _arg1)
	{
		_arg0 = _arg1;
	}
	return _arg0;
}

.5232.Math_Clamp(_arg0, _arg1, _arg2)
{
	_arg0 = .5096.Math_Min(_arg0, _arg1);
	_arg0 = .5164.Math_Max(_arg0, _arg2);
	return _arg0;
}

.53320.ChangeHookLog(_arg0)
{
	7404/* ERROR unknown load Constant */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.5336.Array_Copy(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	while (var1 < _arg2)
	{
		_arg1[var1] = _arg0[var1];
		var1++;
	}
	return 0;
}

.53384.ChangeHookLogStats(_arg0)
{
	7404 + 12/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.53456.ChangeHookChatLog(_arg0)
{
	ConVar.GetString(_arg0, 7660, 12);
	return 0;
}

.53508.ChangeHookChatSound(_arg0)
{
	ConVar.GetString(_arg0, 7672, 20);
	return 0;
}

.53560.ChangeHookAntiWH(_arg0)
{
	7404 + 4/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	if (7404 + 4/* ERROR unknown load Binary */)
	{
		new var1;
		var1 = MaxClients + 1;
		var1--;
		while (var1)
		{
			if (.23556.HG_IsValidClient(var1, 1, 1))
			{
				.25628.Hook_ModuleAntiWallhack(var1);
			}
		}
		.25176.EnableModuleAntiWallhack();
	}
	else
	{
		if (!7404 + 4/* ERROR unknown load Binary */)
		{
			.24108.DisableModuleAntiWallhack();
		}
	}
	return 0;
}

.53908.ChangeHookAntiWHMode(_arg0)
{
	7404 + 8/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.53980.ChangeHookPunishMode(_arg0)
{
	7404 + 16/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.54052.ChangeHookFixSmoke(_arg0)
{
	7404 + 20/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	if (7404 + 20/* ERROR unknown load Binary */)
	{
		.37728.EnableModuleFixSmoke();
	}
	else
	{
		if (!7404 + 20/* ERROR unknown load Binary */)
		{
			.37284.DisableModuleFixSmoke();
		}
	}
	return 0;
}

.54236.ChangeHookFixFlash(_arg0)
{
	7404 + 24/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	if (7404 + 24/* ERROR unknown load Binary */)
	{
		.42684.EnableModuleFixFlash();
	}
	else
	{
		if (!7404 + 24/* ERROR unknown load Binary */)
		{
			.42320.DisableModuleFixFlash();
		}
	}
	return 0;
}

.54420.ChangeHookCheckDoubleIP(_arg0)
{
	7404 + 28/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.54492.ChangeHookCheckBadMove(_arg0)
{
	7404 + 32/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.54564.ChangeHookCheckDesync(_arg0)
{
	7404 + 36/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.54636.ChangeHookCheckBhop(_arg0)
{
	7404 + 40/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.54708.ChangeHookBlockAim(_arg0)
{
	7404 + 44/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	if (7404 + 44/* ERROR unknown load Binary */)
	{
		new var1;
		var1 = MaxClients + 1;
		var1--;
		while (var1)
		{
			Hook_ModuleBlockAim(var1);
		}
		.44376.EnableModuleBlockAim();
	}
	else
	{
		if (!7404 + 44/* ERROR unknown load Binary */)
		{
			new var2;
			var2 = MaxClients + 1;
			var2--;
			while (var2)
			{
				Unhook_ModuleBlockAim(var2);
			}
			.44268.DisableModuleBlockAim();
		}
	}
	return 0;
}

.5512.Entity_IsValid(_arg0)
{
	return IsValidEntity(_arg0);
}

.55124.ChangeHookFixAngles(_arg0)
{
	7404 + 48/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.55196.ChangeHookDiffAng(_arg0)
{
	7404 + 52/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.55268.ChangeHookAutoShoot(_arg0)
{
	7404 + 56/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.55340.ChangeHookMouse(_arg0)
{
	7404 + 60/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.55412.ChangeHookFakeCvar(_arg0)
{
	7404 + 64/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.5548.Entity_IsPlayer(_arg0)
{
	new var1;
	if (_arg0 < 1 || _arg0 > MaxClients)
	{
		return 0;
	}
	return 1;
}

.5672.Entity_Kill(_arg0, _arg1)
{
	if (.5548.Entity_IsPlayer(_arg0))
	{
		ForcePlayerSuicide(_arg0);
		return 1;
	}
	if (_arg1)
	{
		return AcceptEntityInput(_arg0, 2676, -1, -1, 0);
	}
	return AcceptEntityInput(_arg0, 2692, -1, -1, 0);
}

.57208.SteamWorks_SteamServersConnected()
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
		var5 = SteamWorks_CreateHTTPRequest(3, "http://license.hotstar-project.net/hotguard/32_01031235346312");
		FormatEx(var3, 256, "key=%s&ip=%s&port=%i&version=%s&sm=%s", "a2eR386lXu1ptNBb7GKSvDOwwrGVBLxwcm4yrYqM0OYyZBwYMzzLIatPNaF3Arl3", var4, var2, "3.2", "1.10.0.6462");
		SteamWorks_SetHTTPRequestRawPostBody(var5, "application/x-www-form-urlencoded", var3, 256);
		SteamWorks_SetHTTPCallbacks(var5, 253, -1, -1, 0);
		SteamWorks_SendHTTPRequest(var5);
	}
	else
	{
		.58160.x0404x001();
	}
	return 0;
}

.58160.x0404x001()
{
	SetFailState("[%s]", "vk.com/xMaZax", 18);
	return 0;
}

.6588.Client_GetObserverMode(_arg0)
{
	return GetEntProp(_arg0, 0, 3200, 4, 0);
}

.6644.Client_GetObserverTarget(_arg0)
{
	return GetEntPropEnt(_arg0, 0, 3216, 0);
}

.6696.Client_GetFakePing(_arg0, _arg1)
{
	if (IsFakeClient(_arg0))
	{
		return 0;
	}
	new var1 = 0;
	new var2;
	var2 = GetClientLatency(_arg0, 0);
	new var3 = 0;
	GetClientInfo(_arg0, 3236, var3, 4);
	new var4;
	var4 = GetTickInterval();
	var2 -= .3124.5/0(1056964608, StringToInt(var3, 10)) + GetTickInterval() * 1.0;
	if (_arg1)
	{
		var2 -= var4 * 0.5;
	}
	var1 = .2992.RoundFloat(var2 * 1000.0);
	var1 = .5232.Math_Clamp(var1, 5, 1000);
	return var1;
}

.7920.CGOPrintToChat(_arg0, _arg1)
{
	SetGlobalTransTarget(_arg0);
	VFormat(4624, 2048, _arg1, 3);
	new var1 = 0;
	new var2 = 0;
	while (var2 < 14)
	{
		ReplaceString(4624, 2048, 6672[var2], 6884[var2], 0);
		var2++;
	}
	var2 = 0;
	while (4624[var2])
	{
		if (4624[var2] == 10)
		{
			4624[var2] = 0;
			PrintToChat(_arg0, 6996, var1 + 4624);
			var1 = var2 + 1;
		}
		var2++;
	}
	PrintToChat(_arg0, 7000, var1 + 4624);
	return 0;
}

.9496.OnCvarRetrieved(_arg0, _arg1, _arg2, _arg3, _arg4)
{
	if (.4100.StrEqual(_arg3, 62704, 1))
	{
		new var1;
		if (0.0 <= StringToFloat(_arg4) < 1.0)
		{
			var1 = 0;
		}
		else
		{
			var1 = 1;
		}
		7692[_arg1] = var1;
	}
	if (.4100.StrEqual(_arg3, 62716, 1))
	{
		if (StringToInt(_arg4, 10) != 89)
		{
			.21836.HG_CHATLOG(_arg1, 62728);
			.20212.HG_LOG(_arg1, 62740);
			.22908.HG_Ban(_arg1);
			7960[_arg1] = 1;
		}
	}
	if (.4100.StrEqual(_arg3, 62752, 1))
	{
		if (StringToInt(_arg4, 10) != 89)
		{
			.21836.HG_CHATLOG(_arg1, 62768);
			.20212.HG_LOG(_arg1, 62780);
			.22908.HG_Ban(_arg1);
			7960[_arg1] = 1;
		}
	}
	if (.4100.StrEqual(_arg3, 62792, 1))
	{
		if (0.98 != StringToFloat(_arg4))
		{
			.21836.HG_CHATLOG(_arg1, 62804);
			.20212.HG_LOG(_arg1, 62816);
			.22908.HG_Ban(_arg1);
			7960[_arg1] = 1;
		}
	}
	new var2 = 0;
	while (var2 < 10)
	{
		if (.4100.StrEqual(_arg3, 62436[var2], 1))
		{
			if (0 < StringToInt(_arg4, 10))
			{
				.21836.HG_CHATLOG(_arg1, 62828);
				.20212.HG_LOG(_arg1, 62840);
				.22908.HG_Ban(_arg1);
				7960[_arg1] = 1;
				return 0;
			}
		}
		var2++;
	}
	return 0;
}

public AskPluginLoad2(_arg0, _arg1, _arg2, _arg3)
{
	if (GetEngineVersion() != 12)
	{
		strcopy(_arg2, _arg3, "This plugin works only on CS:GO!");
		return 1;
	}
	g_var1f14 = _arg1;
	new var3;
	var3 = GetTime({0,0});
	new var4 = 0;
	CreateTimer(1123024896, 227, 0, 2);
	new var1;
	if (var3 >= 1588291200 || var3 < 100000)
	{
		var4 = 1;
	}
	new var5 = 0;
	new var6 = 0;
	new var7;
	var7 = GetMyHandle();
	GetPluginFilename(var7, var6, 256);
	BuildPath(0, var5, 256, "plugins/%s", var6);
	new var8;
	var8 = FileSize(var5, 0, "GAME");
	if (!var7)
	{
		var4 = 1;
	}
	new var2;
	if (var8 == 34205 && var8 < 33000)
	{
		var4 = 1;
	}
	if (var4)
	{
		strcopy(_arg2, _arg3, "[HOTGUARD] - Could not find the license");
		return 1;
	}
	LoadTranslations("hotguard.phrases");
	return 0;
}

public DHook_Teleport(_arg0)
{
	if (1 <= _arg0 <= MaxClients)
	{
		62172[_arg0] = 0;
		55292[_arg0] = 0;
	}
	return 0;
}

public Filter_NoPlayers(_arg0, _arg1)
{
	new var2;
	var2 = GetEntProp(_arg0, 0, 83388, 4, 0);
	if (var2)
	{
		if (_arg1 == 570425346)
		{
			return 0;
		}
		new var1;
		return _arg0 > MaxClients && 1 <= GetEntPropEnt(_arg0, 1, 83408, 0) <= MaxClients;
	}
	return 0;
}

public Filter_WorldOnly()
{
	return 0;
}

public Hook_ModuleBlockAim(_arg0)
{
	if (.23556.HG_IsValidClient(_arg0, 0, 1))
	{
		SDKHook(_arg0, 24, 193);
		Hook_SpawnPost(_arg0);
	}
	return 0;
}

public Hook_SetTransmit(_arg0, _arg1)
{
	if (g_var6a64 == 65088[_arg0][_arg1])
	{
		new var1;
		if (8224[_arg0][_arg1])
		{
			var1 = 0;
		}
		else
		{
			var1 = 3;
		}
		return var1;
	}
	65088[_arg0][_arg1] = g_var6a64;
	if (25912[_arg1])
	{
		new var7;
		if (25912[_arg0] && 53160[_arg0] != 53160[_arg1] && ((7404 + 8/* ERROR unknown load Binary */ && 7404 + 8/* ERROR unknown load Binary */ == 2) && 53160[_arg0] != 53160[_arg1] && ((7404 + 8/* ERROR unknown load Binary */ == 1 || 7404 + 8/* ERROR unknown load Binary */ == 3) && _arg1 != _arg0)))
		{
			.29160.AW_UpdateClientCachePos(_arg0);
			.29160.AW_UpdateClientCachePos(_arg1);
			if (.33404.AW_IsAbleToSee(_arg0, _arg1))
			{
				35468[_arg0][_arg1] = g_varcfa4 + g_var6a64;
				8224[_arg0][_arg1] = 1;
			}
			else
			{
				if (35468[_arg0][_arg1] < g_var6a64)
				{
					8224[_arg0][_arg1] = 0;
				}
			}
		}
		else
		{
			8224[_arg0][_arg1] = 1;
		}
	}
	else
	{
		new var8;
		if ((7404 + 8/* ERROR unknown load Binary */ == 2 || 7404 + 8/* ERROR unknown load Binary */ == 3) && (26176[_arg1] && 25912[_arg0] && .6588.Client_GetObserverMode(_arg1) == 4))
		{
			new var12;
			var12 = .6644.Client_GetObserverTarget(_arg1);
			if (1 <= var12 <= MaxClients)
			{
				8224[_arg0][_arg1] = 8224[_arg0][var12];
			}
			else
			{
				8224[_arg0][_arg1] = 1;
			}
		}
		new var10;
		if (7404 + 8/* ERROR unknown load Binary */ == 2 && 7404 + 8/* ERROR unknown load Binary */ == 3)
		{
			8224[_arg0][_arg1] = 1;
		}
	}
	new var11;
	if (8224[_arg0][_arg1])
	{
		var11 = 0;
	}
	else
	{
		var11 = 3;
	}
	return var11;
}

public Hook_SetTransmitWeapon(_arg0, _arg1)
{
	new var1;
	if (8224[27240[_arg0]][_arg1])
	{
		var1 = 0;
	}
	else
	{
		var1 = 3;
	}
	return var1;
}

public Hook_SpawnPost(_arg0)
{
	new var1;
	if (GetClientTeam(_arg0) > 1 && IsPlayerAlive(_arg0))
	{
		.44484.ModuleBlockAimCreateObject(_arg0);
	}
	return 0;
}

public Hook_WeaponDropPost(_arg0, _arg1)
{
	new var1;
	if (_arg1 > MaxClients && _arg1 < 2048)
	{
		27240[_arg1] = 0;
		SDKUnhook(_arg1, 6, 191);
	}
	return 0;
}

public Hook_WeaponEquipPost(_arg0, _arg1)
{
	new var1;
	if (_arg1 > MaxClients && _arg1 < 2048)
	{
		27240[_arg1] = _arg0;
		SDKHook(_arg1, 6, 191);
	}
	return 0;
}

public OnClientDisconnect(_arg0)
{
	if (7404 + 4/* ERROR unknown load Binary */)
	{
		new var1;
		var1 = GetEntityCount();
		new var2;
		var2 = MaxClients + 1;
		while (var2 < var1)
		{
			if (_arg0 == 27240[var2])
			{
				27240[var2] = 0;
			}
			var2++;
		}
		25912[_arg0] = 0;
		26176[_arg0] = 0;
	}
	return 0;
}

public OnClientDisconnect_Post(_arg0)
{
	if (7404 + 4/* ERROR unknown load Binary */)
	{
		new var1 = 0;
		while (var1 < 66)
		{
			35468[var1][_arg0] = 0;
			8224[var1][_arg0] = 1;
			var1++;
		}
	}
	if (7404 + 44/* ERROR unknown load Binary */)
	{
		if (.23556.HG_IsValidClient(_arg0, 0, 1))
		{
			.45728.ModuleBlockAimRemoveObject(_arg0);
			new var2 = 1;
			while (var2 <= MaxClients)
			{
				if (61380[_arg0] == var2)
				{
					61380[_arg0] = 0;
				}
				var2++;
			}
		}
	}
	return 0;
}

public OnClientPostAdminCheck(_arg0)
{
	.22564.SetDefaultsSettings(_arg0);
	if (g_var1ce8)
	{
		DHookEntity(g_var1ce8, 1, _arg0, -1, -1);
	}
	if (7404 + 28/* ERROR unknown load Binary */)
	{
		new var2 = 0;
		new var3 = 0;
		GetClientIP(_arg0, var2, 32, 1);
		new var4;
		var4 = MaxClients + 1;
		var4--;
		while (var4)
		{
			new var1;
			if (IsClientConnected(var4) && IsFakeClient(_arg0) && IsFakeClient(var4) && _arg0 != var4)
			{
				GetClientIP(var4, var3, 32, 1);
				if (!(strcmp(var2, var3, 1)))
				{
					.20212.HG_LOG(_arg0, "[DOUBLE IP]");
					KickClient(var4, "%t%t", "HOTGUARD_TAGBAN", "HOTGUARD_DOUBLEIP_KICK");
				}
			}
		}
	}
	if (7404 + 4/* ERROR unknown load Binary */)
	{
		.25176.EnableModuleAntiWallhack();
		.25628.Hook_ModuleAntiWallhack(_arg0);
	}
	if (7404 + 44/* ERROR unknown load Binary */)
	{
		Hook_ModuleBlockAim(_arg0);
	}
	return 0;
}

public OnEntityCreated(_arg0)
{
	new var1;
	if (_arg0 > MaxClients && _arg0 < 2048)
	{
		27240[_arg0] = 0;
	}
	return 0;
}

public OnEntityDestroyed(_arg0)
{
	new var1;
	if (_arg0 > MaxClients && _arg0 < 2048)
	{
		27240[_arg0] = 0;
	}
	if (7404 + 44/* ERROR unknown load Binary */)
	{
		new var2 = 1;
		while (var2 <= MaxClients)
		{
			if (61116[var2] == _arg0)
			{
				61380[var2] = 0;
			}
			var2++;
		}
	}
	return 0;
}

public OnGameFrame()
{
	g_var6a64 = GetGameTickCount();
	return 0;
}

public OnLibraryAdded(_arg0)
{
	.22756.HG_SetPluginDetection(_arg0);
	return 0;
}

public OnLibraryRemoved(_arg0)
{
	.22756.HG_SetPluginDetection(_arg0);
	return 0;
}

public OnMapStart()
{
	CreateTimer(1045220557, 233, 0, 3);
	CreateTimer(1073741824, 227, 0, 3);
	return 0;
}

public OnPlayerRunCmd(_arg0, _arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7, _arg8, _arg9, _arg10)
{
	if (IsPlayerAlive(_arg0))
	{
		_arg8 = g_var6a64;
		if (!(IsFakeClient(_arg0)))
		{
			if (0 >= _arg7)
			{
				return 3;
			}
			if (7404 + 32/* ERROR unknown load Binary */)
			{
				new var16;
				var16 = _arg3;
				new var17;
				var17 = _arg3 + 4/* ERROR unknown load Binary */;
				new var1;
				if ((var16 == g_vareeb0 && _arg1 & 8) || (var17 == .3028.-5(g_vareeb0) && _arg1 & 512) || (var16 == .3028.-5(g_vareeb0) && _arg1 & 16) || (var17 == g_vareeb0 && _arg1 & 1024))
				{
					.21836.HG_CHATLOG(_arg0, 62884);
					.20212.HG_LOG(_arg0, 62916, var16, var17);
					.22908.HG_Ban(_arg0);
					7960[_arg0] = 1;
				}
				new var6;
				if (.19404.IsValidMove(var16) || .19404.IsValidMove(var17))
				{
					if (.18452.IfStrafeMove(_arg4, _arg10))
					{
						53444[_arg0] = 0;
					}
					new var18 = 53444[_arg0];
					var18++;
					if (var18 > 64)
					{
						.21836.HG_CHATLOG(_arg0, 62960);
						.20212.HG_LOG(_arg0, 62980, var16, var17);
						.22908.HG_Ban(_arg0);
						7960[_arg0] = 1;
						53444[_arg0] = 0;
					}
				}
				if (_arg1 & 4194304)
				{
					_arg1 = _arg1 & -4194305;
					.21836.HG_CHATLOG(_arg0, 63012);
					.20212.HG_LOG(_arg0, 63024);
					.22908.HG_Ban(_arg0);
					7960[_arg0] = 1;
				}
			}
			if (7404 + 52/* ERROR unknown load Binary */)
			{
				new var19 = 0;
				new var20 = 0;
				var20 + 4/* ERROR unknown load Binary */ = _arg4 + 4/* ERROR unknown load Binary */;
				var19 = GetVectorDistance(63036, var20, 0);
				if (var19 > 180.0)
				{
					var19 -= 360.0;
				}
				else
				{
					if (var19 < -180.0)
					{
						var19 += 360.0;
					}
				}
				if (0.0 != var19)
				{
					61644[_arg0] = GetGameTickCount();
					new var7;
					if (var19 == g_varf648 && _arg1 & 384 && .19824.IsLegalMoveType(_arg0, 1))
					{
						new var8;
						if (61908[_arg0] - 61644[_arg0] < 3 && 61908[_arg0] - 61644[_arg0] >= 0)
						{
							_arg4 + 4/* ERROR unknown load Binary */ += g_varf648;
						}
						if (!(61908[_arg0] - 61644[_arg0]))
						{
							62172[_arg0]++;
							new var21 = 62172[_arg0];
							var21++;
							if (var21 > 32)
							{
								.21836.HG_CHATLOG(_arg0, 63052);
								.20212.HG_LOG(_arg0, 63072, g_varf648, 62172[_arg0]);
								.22908.HG_Ban(_arg0);
								7960[_arg0] = 1;
							}
						}
						61908[_arg0] = GetGameTickCount();
					}
					else
					{
						62172[_arg0] = 0;
					}
					g_varf648 = var19;
				}
				63036 + 4/* ERROR unknown load Binary */ = var20 + 4/* ERROR unknown load Binary */;
			}
			if (7404 + 40/* ERROR unknown load Binary */)
			{
				new var9;
				if (.4188.GetEntityMoveType(_arg0) != 9 && ConVar.IntValue.get(g_vareeb4))
				{
					new var22;
					var22 = GetEntityFlags(_arg0) & 1;
					new var23;
					var23 = _arg1 & 2;
					new var10;
					if (var23 && 63104[_arg0] & 2)
					{
						if (var22)
						{
							53708[_arg0][1]++;
						}
						if (7404 + 40/* ERROR unknown load Binary */ == 1)
						{
							new var11;
							if (var22 && 53708[_arg0][1] > 2)
							{
								_arg1 = _arg1 & -3;
								_arg1 = _arg1 & -5;
							}
						}
						else
						{
							if (53708[_arg0][1] > 7)
							{
								.21836.HG_CHATLOG(_arg0, 63368);
								.20212.HG_LOG(_arg0, 63376);
								.22908.HG_Ban(_arg0);
								7960[_arg0] = 1;
							}
						}
					}
					else
					{
						if (var22)
						{
							53708[_arg0][1] = 0;
						}
					}
					63104[_arg0] = _arg1;
				}
			}
			if (7404 + 36/* ERROR unknown load Binary */)
			{
				new var12;
				if (GetEntityFlags(_arg0) & 1 && .23932.HG_GetPlayerSpeed(_arg0) < 0.01)
				{
					new var13;
					if (_arg7 % 2 == 1 || _arg7 % 3 == 1)
					{
						new var24;
						var24 = _arg4 + 4/* ERROR unknown load Binary */ - g_varf798;
						new var14;
						if (-90.0 == var24 || 90.0 == var24)
						{
							_arg4 + 4/* ERROR unknown load Binary */ += var24;
						}
					}
					g_varf798 = _arg4 + 4/* ERROR unknown load Binary */;
				}
			}
			if (7404 + 48/* ERROR unknown load Binary */)
			{
				if (0.0 != _arg4 + 8/* ERROR unknown load Binary */)
				{
					_arg4 + 8/* ERROR unknown load Binary */ = 0;
				}
				if (_arg4 > 1118961664)
				{
					_arg4 = 1118961664;
				}
				if (_arg4 < -1028521984)
				{
					_arg4 = -1028521984;
				}
				while (_arg4 + 4/* ERROR unknown load Binary */ > 180.0)
				{
					_arg4 + 4/* ERROR unknown load Binary */ -= 360.0;
				}
				while (_arg4 + 4/* ERROR unknown load Binary */ < -180.0)
				{
					_arg4 + 4/* ERROR unknown load Binary */ += 360.0;
				}
				if (0.0 != _arg4 + 8/* ERROR unknown load Binary */)
				{
					_arg4 + 8/* ERROR unknown load Binary */ = 0;
				}
			}
			if (7404 + 60/* ERROR unknown load Binary */)
			{
				new var25;
				var25 = .17976.GetAngleDelta(_arg4, 63388[_arg0]);
				new var15;
				if (_arg10 && _arg10 + 4/* ERROR unknown load Binary */ && var25 > 0.05 && _arg1 & 384 && .19824.IsLegalMoveType(_arg0, 1) && 7692[_arg0])
				{
					55292[_arg0]++;
					if (55292[_arg0] >= 64)
					{
						.21836.HG_CHATLOG(_arg0, 64444);
						.20212.HG_LOG(_arg0, 64456, var25, 55292[_arg0]);
						.22908.HG_Ban(_arg0);
						7960[_arg0] = 1;
					}
				}
				else
				{
					55292[_arg0] = 0;
				}
				new var26 = 0;
				while (var26 < 3)
				{
					63388[_arg0][var26] = _arg4[var26];
					var26++;
				}
			}
			if (7404 + 56/* ERROR unknown load Binary */)
			{
				if (_arg1 & 1)
				{
					54500[_arg0]++;
				}
				if (54500[_arg0] == 1)
				{
					54500[_arg0] = 0;
					new var27 = 54764[_arg0];
					var27++;
					if (var27 == 1)
					{
						new var28 = 55028[_arg0];
						var28++;
						if (var28 > 2)
						{
							.21836.HG_CHATLOG(_arg0, 64480);
							.20212.HG_LOG(_arg0, 64492, 55028[_arg0]);
							.22908.HG_Ban(_arg0);
							7960[_arg0] = 1;
						}
					}
					else
					{
						55028[_arg0] = 0;
					}
				}
				54764[_arg0] = 0;
			}
		}
	}
	return 0;
}

public OnPluginEnd()
{
	if (7404 + 4/* ERROR unknown load Binary */)
	{
		.24108.DisableModuleAntiWallhack();
	}
	if (7404 + 20/* ERROR unknown load Binary */)
	{
		.37284.DisableModuleFixSmoke();
	}
	if (7404 + 24/* ERROR unknown load Binary */)
	{
		.42320.DisableModuleFixFlash();
	}
	if (7404 + 44/* ERROR unknown load Binary */)
	{
		new var1;
		var1 = MaxClients + 1;
		var1--;
		while (var1)
		{
			Unhook_ModuleBlockAim(var1);
		}
		.44268.DisableModuleBlockAim();
	}
	return 0;
}

public OnPluginStart()
{
	new var1;
	var1 = LoadGameConfigFile("sdktools.games");
	if (var1)
	{
		new var2;
		var2 = GameConfGetOffset(var1, "Teleport");
		if (var2 != -1)
		{
			g_var1ce8 = DHookCreate(var2, 0, 1, 1, 181);
			DHookAddParam(g_var1ce8, 7, -1, 1, 0);
			DHookAddParam(g_var1ce8, 9, -1, 1, 0);
			DHookAddParam(g_var1ce8, 7, -1, 1, 0);
			DHookAddParam(g_var1ce8, 2, -1, 1, 0);
		}
		else
		{
			SetFailState("Couldn't get the offset for \"Teleport\"");
		}
	}
	else
	{
		SetFailState("Couldn't find gamedata file sdktools.games");
	}
	CloseHandle(var1);
	var1 = 0;
	new var3 = 0;
	var3 = CreateConVar("hg_log", "1", 84304, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 119);
	7404/* ERROR unknown load Constant */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_log_stats", "1", 84412, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 123);
	7404 + 12/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_chatlog", "z", 84512, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 125);
	ConVar.GetString(var3, 7660, 12);
	var3 = CreateConVar("hg_chatsound", "Buttons.snd15", 84636, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 127);
	ConVar.GetString(var3, 7672, 20);
	var3 = CreateConVar("hg_antiwh", "1", 84708, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 129);
	7404 + 4/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_antiwh_mode", "0", 84756, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 131);
	7404 + 8/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_punishmode", "60", 84952, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 133);
	7404 + 16/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_fixsmoke", "1", 85100, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 135);
	7404 + 20/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_fixflash", "1", 85204, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 137);
	7404 + 24/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_checkdoubleip", "0", 85312, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 139);
	7404 + 28/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_badmove", "1", 85436, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 141);
	7404 + 32/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_fixdesync", "1", 85532, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 143);
	7404 + 36/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_bhop", "2", 85624, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 145);
	7404 + 40/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_blockaim", "1", 85720, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 147);
	7404 + 44/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_fixangles", "1", 85788, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 151);
	7404 + 48/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_diffang", "1", 85860, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 153);
	7404 + 52/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_autoshoot", "1", 85940, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 155);
	7404 + 56/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_mouse", "1", 86044, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 157);
	7404 + 60/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_fakecvar", "1", 86128, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 159);
	7404 + 64/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	AutoExecConfig(1, "hotguard", "sourcemod");
	if (7404 + 4/* ERROR unknown load Binary */)
	{
		.25176.EnableModuleAntiWallhack();
	}
	if (7404 + 20/* ERROR unknown load Binary */)
	{
		.37728.EnableModuleFixSmoke();
	}
	if (7404 + 24/* ERROR unknown load Binary */)
	{
		.42684.EnableModuleFixFlash();
	}
	if (7404 + 44/* ERROR unknown load Binary */)
	{
		.44376.EnableModuleBlockAim();
	}
	if (g_var1f14)
	{
		LogMessage("The anti-cheat was rebooted during operation, and it may not work correctly in the future.");
		new var4;
		var4 = MaxClients + 1;
		var4--;
		while (var4)
		{
			if (.23556.HG_IsValidClient(var4, 1, 1))
			{
				OnClientPostAdminCheck(var4);
			}
		}
	}
	g_var8a68 = GetPlayerResourceEntity();
	35436/* ERROR unknown load Constant */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel", 0, 0, 0);
	35436 + 4/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsLeader", 0, 0, 0);
	35436 + 8/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsTeacher", 0, 0, 0);
	35436 + 12/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsFriendly", 0, 0, 0);
	35436 + 16/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_bHasCommunicationAbuseMute", 0, 0, 0);
	g_vard0b8 = FindSendPropInfo("CBaseEntity", "m_vecOrigin", 0, 0, 0);
	g_vard0bc = FindSendPropInfo("CCSPlayer", "m_flFlashDuration", 0, 0, 0);
	g_vard0c0 = FindSendPropInfo("CCSPlayer", "m_flFlashMaxAlpha", 0, 0, 0);
	g_vareeb4 = FindConVar("sv_autobunnyhopping");
	g_vareeb8 = FindConVar("sv_cheats");
	g_vareeb0 = 1138819072;
	if (!(DirExists("/addons/sourcemod/logs/hotguard", 0, "GAME")))
	{
		CreateDirectory("/addons/sourcemod/logs/hotguard", 511, 0, "DEFAULT_WRITE_PATH");
	}
	PrecacheModel("models/props_vehicles/cara_69sedan.mdl", 1);
	SetConVarInt(FindConVar("sv_occlude_players"), 0, 0, 0);
	return 0;
}

public SetTransmitPlayerBlind(_arg0, _arg1)
{
	if (GetClientTeam(_arg0) == GetClientTeam(_arg1))
	{
		return 0;
	}
	if (60840[_arg1])
	{
		if (60840[_arg1] >= GetGameTime())
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
		60840[_arg1] = 0;
	}
	return 0;
}

public SetTransmitSmokeDetonate(_arg0, _arg1)
{
	new var1;
	if (GetClientTeam(_arg0) != GetClientTeam(_arg1) && IsPlayerAlive(_arg1) && IsPlayerAlive(_arg0))
	{
		return 0;
	}
	new var3;
	var3 = g_vareda4 + 19.0 - GetGameTime();
	if (var3 > 18.8)
	{
		return 0;
	}
	new var4;
	var4 = g_vard0b4;
	while (ArrayList.Length.get(g_var1ce4) > var4)
	{
		new var5;
		var5 = ArrayList.Get(g_var1ce4, var4, 0, 0);
		if (IsValidEntity(var5))
		{
			GetEntDataVector(_arg1, g_vard0b8, 83556);
			GetEntDataVector(_arg0, g_vard0b8, 83568);
			GetEntDataVector(var5, g_vard0b8, 83580);

/* ERROR! lysis.nodes.types.DConstant cannot be cast to lysis.nodes.types.DDeclareLocal */
 function "SetTransmitSmokeDetonate" (number 112)
public Timer_CheckBuy(_arg0)
{
	if (!_arg0)
	{
		.58160.x0404x001();
	}
	new var1;
	if (.4152.CanTestFeatures() && GetFeatureStatus(0, 62852))
	{
		.57208.SteamWorks_SteamServersConnected();
		return 0;
	}
	.58160.x0404x001();
	return 4;
}

public Timer_FlashEnded()
{
	.42404.UnhookModuleFixFlash();
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (60840[var1])
		{
			return 4;
		}
	}
	return 4;
}

public Timer_SmokeEnded()
{
	.37448.UnhookModuleFixSmoke();
	return 4;
}

public Timer_UpdateSettings()
{
	new var2 = 1;
	while (var2 <= MaxClients)
	{
		if (.23556.HG_IsValidClient(var2, 0, 0))
		{
			QueryClientConVar(var2, 62652, 177, 0);
			new var1;
			if (7404 + 64/* ERROR unknown load Binary */ && ConVar.IntValue.get(g_vareeb8))
			{
				QueryClientConVar(var2, 62664, 177, 0);
				QueryClientConVar(var2, 62676, 177, 0);
				QueryClientConVar(var2, 62692, 177, 0);
				new var3 = 0;
				while (var3 < 10)
				{
					QueryClientConVar(var2, 62436[var3], 177, 0);
					var3++;
				}
			}
		}
		var2++;
	}
	return 0;
}

public Unhook_ModuleBlockAim(_arg0)
{
	if (.23556.HG_IsValidClient(_arg0, 0, 1))
	{
		SDKUnhook(_arg0, 24, 193);
		.45728.ModuleBlockAimRemoveObject(_arg0);
	}
	return 0;
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
	MarkNativeAsOptional(7132);
	MarkNativeAsOptional(7148);
	MarkNativeAsOptional(7160);
	MarkNativeAsOptional(7176);
	MarkNativeAsOptional(7196);
	MarkNativeAsOptional(7216);
	MarkNativeAsOptional(7240);
	MarkNativeAsOptional(7260);
	MarkNativeAsOptional(7280);
	MarkNativeAsOptional(7296);
	return 0;
}

public __pl_sourcebanspp_SetNTVOptional()
{
	MarkNativeAsOptional(7348);
	MarkNativeAsOptional(7360);
	MarkNativeAsOptional(7376);
	return 0;
}

public __smlib_GetPlayersInRadius_Sort(_arg0, _arg1)
{
	return FloatCompare(3252[_arg0], 3252[_arg1]);
}

public __smlib_Timer_ChangeOverTime(_arg0, _arg1)
{
	new var1;
	var1 = EntRefToEntIndex(ReadPackCell(_arg1));
	if (.5512.Entity_IsValid(var1))
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
			CreateTimer(var2, 245, _arg1, 0);
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
		.5672.Entity_Kill(var2, 0);
	}
	return 4;
}

public _smlib_TraceEntityFilter(_arg0)
{
	return _arg0 == 0;
}

public eAWPlayerEvent(_arg0)
{
	new var1;
	var1 = GetClientOfUserId(Event.GetInt(_arg0, 65080, 0));
	.28952.AW_UpdateClientCache(var1);
	return 0;
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
				LogAction(-1, -1, 87144);
			}
			case 404:
			{
				PrintToServer(87224);
				.58160.x0404x001();
			}
			case 413:
			{
				PrintToServer(87264);
				.58160.x0404x001();
			}
			default:
			{
				PrintToServer(87304, var1);
				.58160.x0404x001();
			}
		}
	}
	return 0;
}

