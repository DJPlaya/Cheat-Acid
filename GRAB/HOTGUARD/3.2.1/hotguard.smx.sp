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
	date = "04/14/2020",
	time = "22:58:31"
};
public Plugin:myinfo =
{
	name = "HotGuard AntiCheat",
	description = "Server anti-cheat system",
	author = "MaZa",
	version = "3.2.1",
	url = "vk.com/xMaZax"
};
new g_varecac;
new g_vareca4;
new g_var8b74 = -1;
new g_vard1bc;
new g_vard0b0;
new g_var6a68;
new g_var6a64 = -1;
new g_var144c0 = -1;
new g_var1ce4;
new g_vareb98;
new g_vard1c0;
new g_vard1c4;
new g_var8fc;
new g_vard1cc;
new g_vard1c8;
new g_var944;
new g_var98c;
new g_var1f18;
new g_var1ce8;
new g_varf544;
new g_vareca8;
new g_varf694;
new g_var1e0c;
.17448.GetAngleDelta(_arg0, _arg1)
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

.17924.IfStrafeMove(_arg0, _arg1)
{
	new var7 = 0;
	new var1;
	if ((64220/* ERROR unknown load Constant */ == _arg0 && 64220 + 4/* ERROR unknown load Binary */ == _arg0 + 4/* ERROR unknown load Binary */ && 64220 + 4/* ERROR unknown load Binary */ == _arg0 + 4/* ERROR unknown load Binary */) && (_arg1 > 0 || _arg1 + 4/* ERROR unknown load Binary */ > 0))
	{
		var7 = 1;
	}
	else
	{
		new var4;
		if ((64220/* ERROR unknown load Constant */ != _arg0 || 64220 + 4/* ERROR unknown load Binary */ != _arg0 + 4/* ERROR unknown load Binary */ || 64220 + 4/* ERROR unknown load Binary */ != _arg0 + 4/* ERROR unknown load Binary */) && (_arg1 && _arg1 + 4/* ERROR unknown load Binary */))
		{
			var7 = 0;
		}
	}
	64220/* ERROR unknown load Constant */ = _arg0;
	64220 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */;
	64220 + 8/* ERROR unknown load Binary */ = _arg0 + 8/* ERROR unknown load Binary */;
	return var7;
}

.18876.IsValidMove(_arg0)
{
	if (ConVar.IntValue.get(g_varecac))
	{
		return 1;
	}
	_arg0 = FloatAbs(_arg0);
	new var1;
	return 0 == _arg0 || _arg0 == g_vareca4 || _arg0 == g_vareca4 * 0.75 || _arg0 == g_vareca4 * 0.5 || _arg0 == g_vareca4 * 0.25;
}

.19296.IsLegalMoveType(_arg0, _arg1)
{
	new var4;
	var4 = .4188.GetEntityMoveType(_arg0);
	new var5;
	var5 = GetEntityFlags(_arg0);
	new var1;
	return (_arg1 && GetEntProp(_arg0, 1, 64232, 4, 0) < 2) && (var5 & 64 && var5 & 32 && (var4 == 2 || var4 == 1 || var4 == 9));
}

.19684.HG_LOG(_arg0, _arg1)
{
	if (7964[_arg0])
	{
		return 0;
	}
	if (7404/* ERROR unknown load Constant */)
	{
		if (.23112.HG_IsValidClient(_arg0, 0, 1))
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
				strcopy(var2, 16, 64248);
			}
			new var10;
			var10 = GetTime({0,0});
			FormatTime(var6, 12, 64276, var10);
			FormatTime(var7, 12, 64280, var10);
			GetCurrentMap(var1, 130);
			VFormat(var5, 1024, _arg1, 3);
			GetClientAuthId(_arg0, 1, var9, 32, 1);
			FormatEx(var3, 1024, 64292, var6, var1, _arg0, var9, var2, .6696.Client_GetFakePing(_arg0, 1), var5);
			BuildPath(0, var8, 256, 64324, var7);
			new var11;
			var11 = OpenFile(var8, 64356, 0, 64360);
			if (var11)
			{
				WriteFileLine(var11, var3);
				if (7404 + 12/* ERROR unknown load Binary */)
				{
					if (g_var8b74 != -1)
					{
						new var12;
						var12 = .23404.GetClientStats(_arg0, g_var8b74, 35704/* ERROR unknown load Constant */);
						FormatEx(var4, 1024, 64368, _arg0, var12, .23404.GetClientStats(_arg0, g_var8b74, 35704 + 4/* ERROR unknown load Binary */), .23404.GetClientStats(_arg0, g_var8b74, 35704 + 8/* ERROR unknown load Binary */), .23404.GetClientStats(_arg0, g_var8b74, 35704 + 12/* ERROR unknown load Binary */), .23404.GetClientStats(_arg0, g_var8b74, 35704 + 16/* ERROR unknown load Binary */));
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

.21308.HG_CHATLOG(_arg0, _arg1)
{
	if (7660)
	{
		new var2;
		var2 = MaxClients + 1;
		var2--;
		while (var2)
		{
			if (7964[var2])
			{
				return 0;
			}
			new var1;
			if (.23112.HG_IsValidClient(var2, 0, 1) && .21748.HG_CheckAdminImmunity(var2))
			{
				if (7672/* ERROR unknown load Constant */)
				{
					ClientCommand(var2, 64468, 7672);
				}
				.7920.CGOPrintToChat(var2, 64488, 64500, 64520, 64536, _arg0, 64564, _arg1);
			}
		}
		return 0;
	}
	return 0;
}

.21748.HG_CheckAdminImmunity(_arg0)
{
	new var1;
	var1 = GetUserFlagBits(_arg0);
	if (0 < var1)
	{
		if (strcmp(7660, 64584, 1))
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

.22032.SetDefaultsSettings(_arg0)
{
	26444[_arg0] = 0;
	26708[_arg0] = 0;
	26972[_arg0] = 0;
	61120[_arg0] = 0;
	60316[_arg0] = 0;
	7964[_arg0] = 0;
	return 0;
}

.22312.HG_SetPluginDetection(_arg0)
{
	if (.4100.StrEqual(_arg0, 64588, 1))
	{
		g_vard1bc = 1;
	}
	else
	{
		if (.4100.StrEqual(_arg0, 64604, 1))
		{
			g_vard1bc = 2;
		}
	}
	return 0;
}

.22464.HG_Ban(_arg0)
{
	new var1;
	if (7404 + 16/* ERROR unknown load Binary */ == -1 || 7404 + 16/* ERROR unknown load Binary */ == -3)
	{
		return 0;
	}
	if (7964[_arg0])
	{
		return 0;
	}
	new var2 = 0;
	FormatEx(var2, 129, 64620, 64628, 64644);
	if (7404 + 16/* ERROR unknown load Binary */ == -2)
	{
		KickClient(_arg0, var2);
		return 0;
	}
	switch (g_vard1bc)
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
			BanClient(_arg0, 7404 + 16/* ERROR unknown load Binary */, 1, var2, 64660, 64664, 0);
		}
	}
	return 0;
}

.23112.HG_IsValidClient(_arg0, _arg1, _arg2)
{
	new var3;
	if (1 <= _arg0 <= MaxClients && IsClientInGame(_arg0) && (IsFakeClient(_arg0) && _arg1) && (_arg2 && IsPlayerAlive(_arg0)))
	{
		return 0;
	}
	return 1;
}

.23404.GetClientStats(_arg0, _arg1, _arg2)
{
	return GetEntData(_arg1, _arg0 * 4 + _arg2, 4);
}

.23488.HG_GetPlayerSpeed(_arg0)
{
	new var1 = 0;
	GetEntPropVector(_arg0, 1, 64668, var1, 0);
	return GetVectorLength(var1, 0);
}

.23664.DisableModuleAntiWallhack()
{
	g_vard0b0 = 0;
	UnhookEvent(64688, 251, 0);
	UnhookEvent(64704, 251, 0);
	UnhookEvent(64720, 251, 0);
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.23112.HG_IsValidClient(var1, 1, 1))
		{
			25916[var1] = 0;
			26180[var1] = 0;
			new var2 = 0;
			while (var2 < 66)
			{
				35736[var2][var1] = 0;
				8228[var2][var1] = 1;
				var2++;
			}
			26972[var1] = 0;
			SDKUnhook(var1, 6, 187);
			SDKUnhook(var1, 32, 195);
			SDKUnhook(var1, 31, 193);
		}
	}
	new var3;
	var3 = GetEntityCount();
	new var4;
	var4 = MaxClients + 1;
	while (var4 < var3)
	{
		if (27508[var4])
		{
			27508[var4] = 0;
			SDKUnhook(var4, 6, 189);
		}
		var4++;
	}
	return 0;
}

.24732.EnableModuleAntiWallhack()
{
	g_vard0b0 = RoundToNearest(0.2 / GetTickInterval());
	new var1 = 0;
	while (var1 < 66)
	{
		new var2 = 0;
		while (var2 < 66)
		{
			8228[var1][var2] = 1;
			var2++;
		}
		var1++;
	}
	HookEvent(64732, 251, 0);
	HookEvent(64748, 251, 0);
	HookEvent(64764, 251, 0);
	return 0;
}

.25184.Hook_ModuleAntiWallhack(_arg0)
{
	if (!26972[_arg0])
	{
		if (.23112.HG_IsValidClient(_arg0, 1, 1))
		{
			26972[_arg0] = 1;
			.28508.AW_UpdateClientCache(_arg0);
			SDKHook(_arg0, 6, 187);
			SDKHook(_arg0, 32, 195);
			SDKHook(_arg0, 31, 193);
			new var1;
			var1 = GetEntityCount();
			new var2;
			var2 = MaxClients + 1;
			while (var2 < var1)
			{
				if (IsValidEdict(var2))
				{
					new var3;
					var3 = GetEntPropEnt(var2, 1, 64776, 0);
					if (1 <= var3 <= MaxClients)
					{
						27508[var2] = var3;
						if (_arg0 == var3)
						{
							SDKHook(var2, 6, 189);
						}
					}
				}
				var2++;
			}
		}
	}
	return 0;
}

.28508.AW_UpdateClientCache(_arg0)
{
	53428[_arg0] = GetClientTeam(_arg0);
	25916[_arg0] = IsPlayerAlive(_arg0);
	26180[_arg0] = IsFakeClient(_arg0);
	return 0;
}

.28716.AW_UpdateClientCachePos(_arg0)
{
	if (g_var6a68 == 82488[_arg0])
	{
		return 0;
	}
	82488[_arg0] = g_var6a68;
	GetClientMins(_arg0, 55032[_arg0]);
	GetClientMaxs(_arg0, 56088[_arg0]);
	GetClientAbsOrigin(_arg0, 57144[_arg0]);
	GetClientEyePosition(_arg0, 58200[_arg0]);
	56088[_arg0][2] *= 1.0;
	55032[_arg0][2] -= 56088[_arg0][2];
	new var1 = 57144[_arg0][2];
	var1 = var1[56088[_arg0][2]];
	if (IsFakeClient(_arg0))
	{
		return 0;
	}
	new var2 = 0;
	.36488.GetClientAbsVelocity(_arg0, var2[_arg0]);
	if (g_var6a64 == -1)
	{
		g_var6a64 = FindDataMapInfo(_arg0, 83016, 0, 0, 0);
	}
	new var3;
	var3 = GetTickInterval();
	new var4;
	var4 = GetEntDataFloat(_arg0, g_var6a64);
	new var5;
	var5 = RoundToNearest(var4 / var3) + -1;
	new var6;
	var6 = GetGameTickCount() + -1;
	new var7;
	var7 = var6 - 27244[_arg0];
	new var8 = 0;
	var8 += GetClientLatency(_arg0, 0);
	var8 += .3064.5*0(var3, var5);
	new var9 = 0;
	var9 = FloatAbs(var2[_arg0]) * 0.01;
	var9 + 4/* ERROR unknown load Binary */ = FloatAbs(var2[_arg0][1]) * 0.01;
	var9 + 8/* ERROR unknown load Binary */ = FloatAbs(var2[_arg0][2]) * 0.01;
	new var10 = 0;
	.3888.ScaleVector(var2[_arg0], var8 - .3064.5*0(var3, var7));
	.3304.AddVectors(57144[_arg0], var2[_arg0], var10);
	TR_TraceHullFilter(var10, var10, 83028, 83040, 24705, 183, 0);
	if (!(TR_DidHit(0)))
	{
		.3304.AddVectors(58200[_arg0], var2[_arg0], 58200[_arg0]);
	}
	if (var9 > 1.0)
	{
		55032[_arg0] *= var9;
		56088[_arg0] *= var9;
	}
	if (var9 + 4/* ERROR unknown load Binary */ > 1.0)
	{
		55032[_arg0][1] *= var9 + 4/* ERROR unknown load Binary */;
		56088[_arg0][1] *= var9 + 4/* ERROR unknown load Binary */;
	}
	if (var9 + 8/* ERROR unknown load Binary */ > 1.0)
	{
		55032[_arg0][2] *= var9 + 8/* ERROR unknown load Binary */;
		56088[_arg0][2] *= var9 + 8/* ERROR unknown load Binary */;
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

.32988.AW_IsAbleToSee(_arg0, _arg1)
{
	if (.34424.AW_IsFOV(58200[_arg1], 59256[_arg1], 57144[_arg0]))
	{
		if (.36024.AW_IsPointVisible(58200[_arg1], 57144[_arg0]))
		{
			return 1;
		}
		if (.34788.IsFwdVecVisible(58200[_arg1], 59256[_arg0], 58200[_arg0]))
		{
			return 1;
		}
		GetClientMins(_arg0, 55032[_arg0]);
		GetClientMaxs(_arg0, 56088[_arg0]);
		new var1 = 55032[_arg0];
		var1 = .3244.5-0(var1, 5);
		new var2 = 55032[_arg0][1];
		var2 = .3244.5-0(var2, 30);
		new var3 = 56088[_arg0];
		var3 = .3184.5+0(var3, 5);
		new var4 = 56088[_arg0][1];
		var4 = .3184.5+0(var4, 5);
		new var5 = 0;
		GetEntPropVector(_arg0, 1, 83052, var5, 0);
		new var6 = 0;
		new var7 = 0;
		.3304.AddVectors(var5, 55032[_arg0], var6);
		.3304.AddVectors(var5, 56088[_arg0], var7);
		if (.34996.AW_IsBoxVisible(var6, var7, 58200[_arg1]))
		{
			return 1;
		}
	}
	return 0;
}

.3304.AddVectors(_arg0, _arg1, _arg2)
{
	_arg2 = _arg0 + _arg1;
	_arg2 + 4/* ERROR unknown load Binary */ = _arg0 + 4/* ERROR unknown load Binary */ + _arg1 + 4/* ERROR unknown load Binary */;
	_arg2 + 8/* ERROR unknown load Binary */ = _arg0 + 8/* ERROR unknown load Binary */ + _arg1 + 8/* ERROR unknown load Binary */;
	return 0;
}

.34424.AW_IsFOV(_arg0, _arg1, _arg2)
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

.34788.IsFwdVecVisible(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	GetAngleVectors(_arg1, var1, NULL_VECTOR, NULL_VECTOR);
	.3888.ScaleVector(var1, 1114636288);
	.3304.AddVectors(_arg2, var1, var1);
	return .36024.AW_IsPointVisible(_arg0, var1);
}

.34996.AW_IsBoxVisible(_arg0, _arg1, _arg2)
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
		if (.36024.AW_IsPointVisible(var1[var11], _arg2))
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

.36024.AW_IsPointVisible(_arg0, _arg1)
{
	TR_TraceRayFilter(_arg0, _arg1, 24705, 0, 181, 0);
	return TR_GetFraction(0) > 0.995;
}

.36488.GetClientAbsVelocity(_arg0, _arg1)
{
	new var1;
	if (g_var144c0 == -1 && (g_var144c0 = FindDataMapInfo(_arg0, 83140, 0, 0, 0)) == -1)
	{
		.36772.ZeroVector(_arg1);
		return 0;
	}
	GetEntDataVector(_arg0, g_var144c0, _arg1);
	return 1;
}

.36772.ZeroVector(_arg0)
{
	_arg0 + 8/* ERROR unknown load Binary */ = 0;
	_arg0 + 4/* ERROR unknown load Binary */ = 0;
	_arg0 = 0;
	return 0;
}

.36868.DisableModuleFixSmoke()
{
	.37032.UnhookModuleFixSmoke();
	CloseHandle(g_var1ce4);
	g_var1ce4 = 0;
	UnhookEvent(83160, 75, 1);
	UnhookEvent(83184, 75, 1);
	return 0;
}

.37032.UnhookModuleFixSmoke()
{
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.23112.HG_IsValidClient(var1, 1, 1))
		{
			if (26444[var1])
			{
				26444[var1] = 0;
				SDKUnhook(var1, 6, 225);
			}
		}
	}
	return 0;
}

.37312.EnableModuleFixSmoke()
{
	g_var1ce4 = ArrayList.ArrayList(1, 0);
	HookEvent(83208, 75, 1);
	HookEvent(83232, 75, 1);
	return 0;
}

.37456.HookModuleFixSmoke()
{
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.23112.HG_IsValidClient(var1, 1, 0))
		{
			if (!26444[var1])
			{
				26444[var1] = 1;
				SDKHook(var1, 6, 225);
			}
		}
	}
	return 0;
}

.37740.OnSmokeEvent(_arg0, _arg1)
{
	if (_arg1 + 13/* ERROR unknown load Binary */ == 100)
	{
		g_vareb98 = GetGameTime();
		CreateTimer(1099431936, 231, 0, 0);
		.37456.HookModuleFixSmoke();
		ArrayList.Push(g_var1ce4, Event.GetInt(_arg0, 83256, 0));
	}
	else
	{
		g_vard1c0 += 1;
		if (ArrayList.Length.get(g_var1ce4) == g_vard1c0)
		{
			ArrayList.Clear(g_var1ce4);
			g_vard1c0 = 0;
		}
	}
	return 0;
}

.38796.IsAbleToSeeSmoke(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	new var2 = 0;
	new var3 = 0;
	GetClientEyePosition(_arg1, var2);
	GetClientEyePosition(_arg0, var3);
	GetEntDataVector(_arg2, g_vard1c4, var1);
	0/* ERROR unknown load Constant */ = var1 + 8/* ERROR unknown load Binary */;
	0/* ERROR unknown load Constant */ = var2 + 8/* ERROR unknown load Binary */;
	if (.39240.IsLineBlockedBySmoke(var1, var2, var3))
	{
		return 1;
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

.39240.IsLineBlockedBySmoke(_arg0, _arg1, _arg2)
{
	new var1 = 0;
	new var2 = 0;
	.3596.SubtractVectors(_arg2, _arg1, var2);
	new var3;
	var3 = NormalizeVector(var2, var2);
	new var4 = 1178534912;
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

.41604.DisableModuleFixFlash()
{
	.41688.UnhookModuleFixFlash();
	UnhookEvent(83304, 97, 1);
	return 0;
}

.41688.UnhookModuleFixFlash()
{
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.23112.HG_IsValidClient(var1, 1, 0))
		{
			if (26708[var1])
			{
				26708[var1] = 0;
				SDKUnhook(var1, 6, 223);
			}
		}
	}
	return 0;
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

.41968.EnableModuleFixFlash()
{
	HookEvent(83320, 97, 1);
	return 0;
}

.42032.HookModuleFixFlash()
{
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (.23112.HG_IsValidClient(var1, 1, 1))
		{
			if (!26708[var1])
			{
				26708[var1] = 1;
				SDKHook(var1, 6, 223);
			}
		}
	}
	return 0;
}

.42316.Event_PlayerBlind(_arg0)
{
	new var1;
	var1 = GetClientOfUserId(Event.GetInt(_arg0, 83336, 0));
	if (IsPlayerAlive(var1))
	{
		.42032.HookModuleFixFlash();
		if (GetEntDataFloat(var1, g_vard1cc) < 255.0)
		{
			60316[var1] = 0;
			return 0;
		}
		new var2;
		var2 = GetEntDataFloat(var1, g_vard1c8);
		new var3;
		var3 = GetGameTime();
		if (var2 > 2.9)
		{
			60316[var1] = var3 + var2 - 2.9;
		}
		else
		{
			60316[var1] = var3 + var2 / 10.0;
		}
		CreateTimer(var2, 229, 0, 0);
		return 0;
	}
	return 0;
}

.43608.DisableModuleBlockAim()
{
	UnhookEvent(83344, 109, 1);
	UnhookEvent(83356, 109, 1);
	return 0;
}

.43716.EnableModuleBlockAim()
{
	HookEvent(83372, 109, 1);
	HookEvent(83384, 109, 1);
	return 0;
}

.43824.ModuleBlockAimCreateObject(_arg0)
{
	if (61120[_arg0])
	{
		return 0;
	}
	60856[_arg0] = CreateEntityByName(83400, -1);
	if (IsValidEntity(60856[_arg0]))
	{
		DispatchKeyValue(60856[_arg0], 83424, 83432);
		if (DispatchSpawn(60856[_arg0]))
		{
			SetVariantString(83472);
			AcceptEntityInput(60856[_arg0], 83484, _arg0, 60856[_arg0], 0);
			SetVariantInt(1);
			AcceptEntityInput(60856[_arg0], 83496, -1, -1, 0);
			SetVariantInt(1);
			AcceptEntityInput(60856[_arg0], 83512, -1, -1, 0);
			SetEntPropEnt(60856[_arg0], 0, 83540, _arg0, 0);
			SetEntPropFloat(60856[_arg0], 0, 83556, 1072483533, 0);
			.4788.SetEntityRenderMode(60856[_arg0], 10);
			.4480.SetEntityMoveType(60856[_arg0], 0);
			SetEntProp(60856[_arg0], 0, 83572, 217, 4, 0);
			SetEntProp(60856[_arg0], 0, 83584, 1, 1, 0);
			SetEntProp(60856[_arg0], 1, 83600, 0, 2, 0);
			SetEntProp(60856[_arg0], 1, 83616, 10, 4, 0);
			61120[_arg0] = 60856[_arg0];
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

.45068.ModuleBlockAimRemoveObject(_arg0)
{
	if (61120[_arg0])
	{
		new var1;
		if (60856[_arg0] != -1 && IsValidEntity(60856[_arg0]) && 60856[_arg0] == 61120[_arg0])
		{
			RemoveEntity(60856[_arg0]);
			61120[_arg0] = 0;
		}
		return 0;
	}
	return 0;
}

.45428.ePlayerAimBlock(_arg0, _arg1)
{
	new var1;
	var1 = GetClientOfUserId(Event.GetInt(_arg0, 83636, 0));
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

.52736.ChangeHookLog(_arg0)
{
	7404/* ERROR unknown load Constant */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.52800.ChangeHookLogStats(_arg0)
{
	7404 + 12/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.52872.ChangeHookChatLog(_arg0)
{
	ConVar.GetString(_arg0, 7660, 12);
	return 0;
}

.52924.ChangeHookChatSound(_arg0)
{
	ConVar.GetString(_arg0, 7672, 20);
	return 0;
}

.52976.ChangeHookAntiWH(_arg0)
{
	7404 + 4/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	if (7404 + 4/* ERROR unknown load Binary */)
	{
		new var1;
		var1 = MaxClients + 1;
		var1--;
		while (var1)
		{
			if (.23112.HG_IsValidClient(var1, 1, 1))
			{
				.25184.Hook_ModuleAntiWallhack(var1);
			}
		}
		.24732.EnableModuleAntiWallhack();
	}
	else
	{
		if (!7404 + 4/* ERROR unknown load Binary */)
		{
			.23664.DisableModuleAntiWallhack();
		}
	}
	return 0;
}

.53324.ChangeHookAntiWHMode(_arg0)
{
	7404 + 8/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
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

.53396.ChangeHookPunishMode(_arg0)
{
	7404 + 16/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.53468.ChangeHookFixSmoke(_arg0)
{
	7404 + 20/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	if (7404 + 20/* ERROR unknown load Binary */)
	{
		.37312.EnableModuleFixSmoke();
	}
	else
	{
		if (!7404 + 20/* ERROR unknown load Binary */)
		{
			.36868.DisableModuleFixSmoke();
		}
	}
	return 0;
}

.53652.ChangeHookFixFlash(_arg0)
{
	7404 + 24/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	if (7404 + 24/* ERROR unknown load Binary */)
	{
		.41968.EnableModuleFixFlash();
	}
	else
	{
		if (!7404 + 24/* ERROR unknown load Binary */)
		{
			.41604.DisableModuleFixFlash();
		}
	}
	return 0;
}

.53836.ChangeHookCheckDoubleIP(_arg0)
{
	7404 + 28/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.53908.ChangeHookCheckBadMove(_arg0)
{
	7404 + 32/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.53980.ChangeHookCheckDesync(_arg0)
{
	7404 + 36/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.54052.ChangeHookCheckBhop(_arg0)
{
	7404 + 40/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.54124.ChangeHookBlockAim(_arg0)
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
		.43716.EnableModuleBlockAim();
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
			.43608.DisableModuleBlockAim();
		}
	}
	return 0;
}

.54540.ChangeHookFixAngles(_arg0)
{
	7404 + 48/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.54612.ChangeHookDiffAng(_arg0)
{
	7404 + 52/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.54684.ChangeHookMouse(_arg0)
{
	7404 + 60/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.54756.ChangeHookFakeCvar(_arg0)
{
	7404 + 64/* ERROR unknown load Binary */ = ConVar.IntValue.get(_arg0);
	return 0;
}

.5512.Entity_IsValid(_arg0)
{
	return IsValidEntity(_arg0);
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

.56552.SteamWorks_SteamServersConnected()
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
		FormatEx(var3, 256, "key=%s&ip=%s&port=%i&version=%s&sm=%s", "<- API KEY REMOVED ->", var4, var2, "3.2.1", "1.10.0.6462");
		SteamWorks_SetHTTPRequestRawPostBody(var5, "application/x-www-form-urlencoded", var3, 256);
		SteamWorks_SetHTTPCallbacks(var5, 253, -1, -1, 0);
		SteamWorks_SendHTTPRequest(var5);
	}
	else
	{
		.57540.x0404x001();
	}
	return 0;
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

.57540.x0404x001()
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
	if (.4100.StrEqual(_arg3, 62444, 1))
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
		7696[_arg1] = var1;
	}
	if (.4100.StrEqual(_arg3, 62456, 1))
	{
		if (StringToInt(_arg4, 10) != 89)
		{
			.21308.HG_CHATLOG(_arg1, 62468);
			.19684.HG_LOG(_arg1, 62480);
			.22464.HG_Ban(_arg1);
			7964[_arg1] = 1;
		}
	}
	if (.4100.StrEqual(_arg3, 62492, 1))
	{
		if (StringToInt(_arg4, 10) != 89)
		{
			.21308.HG_CHATLOG(_arg1, 62508);
			.19684.HG_LOG(_arg1, 62520);
			.22464.HG_Ban(_arg1);
			7964[_arg1] = 1;
		}
	}
	if (.4100.StrEqual(_arg3, 62532, 1))
	{
		if (0.98 != StringToFloat(_arg4))
		{
			.21308.HG_CHATLOG(_arg1, 62544);
			.19684.HG_LOG(_arg1, 62556);
			.22464.HG_Ban(_arg1);
			7964[_arg1] = 1;
		}
	}
	new var2 = 0;
	while (var2 < 10)
	{
		if (.4100.StrEqual(_arg3, 62176[var2], 1))
		{
			if (0 < StringToInt(_arg4, 10))
			{
				.21308.HG_CHATLOG(_arg1, 62568);
				.19684.HG_LOG(_arg1, 62580);
				.22464.HG_Ban(_arg1);
				7964[_arg1] = 1;
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
	g_var1f18 = _arg1;
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
	if (var8 == 33962 && var8 < 33000)
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
		61912[_arg0] = 0;
		54768[_arg0] = 0;
	}
	return 0;
}

public Filter_NoPlayers(_arg0, _arg1)
{
	new var2;
	var2 = GetEntProp(_arg0, 0, 83100, 4, 0);
	if (var2)
	{
		if (_arg1 == 570425346)
		{
			return 0;
		}
		new var1;
		return _arg0 > MaxClients && 1 <= GetEntPropEnt(_arg0, 1, 83120, 0) <= MaxClients;
	}
	return 0;
}

public Filter_WorldOnly()
{
	return 0;
}

public Hook_ModuleBlockAim(_arg0)
{
	if (.23112.HG_IsValidClient(_arg0, 0, 1))
	{
		SDKHook(_arg0, 24, 191);
		Hook_SpawnPost(_arg0);
	}
	return 0;
}

public Hook_SetTransmit(_arg0, _arg1)
{
	if (g_var6a68 == 64800[_arg0][_arg1])
	{
		new var1;
		if (8228[_arg0][_arg1])
		{
			var1 = 0;
		}
		else
		{
			var1 = 3;
		}
		return var1;
	}
	64800[_arg0][_arg1] = g_var6a68;
	if (25916[_arg1])
	{
		new var7;
		if (25916[_arg0] && 53428[_arg0] != 53428[_arg1] && ((7404 + 8/* ERROR unknown load Binary */ && 7404 + 8/* ERROR unknown load Binary */ == 2) && 53428[_arg0] != 53428[_arg1] && ((7404 + 8/* ERROR unknown load Binary */ == 1 || 7404 + 8/* ERROR unknown load Binary */ == 3) && _arg1 != _arg0)))
		{
			.28716.AW_UpdateClientCachePos(_arg0);
			.28716.AW_UpdateClientCachePos(_arg1);
			if (.32988.AW_IsAbleToSee(_arg0, _arg1))
			{
				35736[_arg0][_arg1] = g_vard0b0 + g_var6a68;
				8228[_arg0][_arg1] = 1;
			}
			else
			{
				if (35736[_arg0][_arg1] < g_var6a68)
				{
					8228[_arg0][_arg1] = 0;
				}
			}
		}
		else
		{
			8228[_arg0][_arg1] = 1;
		}
	}
	else
	{
		new var8;
		if ((7404 + 8/* ERROR unknown load Binary */ == 2 || 7404 + 8/* ERROR unknown load Binary */ == 3) && (26180[_arg1] && 25916[_arg0] && .6588.Client_GetObserverMode(_arg1) == 4))
		{
			new var12;
			var12 = .6644.Client_GetObserverTarget(_arg1);
			if (1 <= var12 <= MaxClients)
			{
				8228[_arg0][_arg1] = 8228[_arg0][var12];
			}
			else
			{
				8228[_arg0][_arg1] = 1;
			}
		}
		new var10;
		if (7404 + 8/* ERROR unknown load Binary */ == 2 && 7404 + 8/* ERROR unknown load Binary */ == 3)
		{
			8228[_arg0][_arg1] = 1;
		}
	}
	new var11;
	if (8228[_arg0][_arg1])
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
	if (8228[27508[_arg0]][_arg1])
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
		.43824.ModuleBlockAimCreateObject(_arg0);
	}
	return 0;
}

public Hook_WeaponDropPost(_arg0, _arg1)
{
	new var1;
	if (_arg1 > MaxClients && _arg1 < 2048)
	{
		27508[_arg1] = 0;
		SDKUnhook(_arg1, 6, 189);
	}
	return 0;
}

public Hook_WeaponEquipPost(_arg0, _arg1)
{
	new var1;
	if (_arg1 > MaxClients && _arg1 < 2048)
	{
		27508[_arg1] = _arg0;
		SDKHook(_arg1, 6, 189);
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
			if (_arg0 == 27508[var2])
			{
				27508[var2] = 0;
			}
			var2++;
		}
		25916[_arg0] = 0;
		26180[_arg0] = 0;
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
			35736[var1][_arg0] = 0;
			8228[var1][_arg0] = 1;
			var1++;
		}
	}
	if (7404 + 44/* ERROR unknown load Binary */)
	{
		if (.23112.HG_IsValidClient(_arg0, 0, 1))
		{
			.45068.ModuleBlockAimRemoveObject(_arg0);
			new var2 = 1;
			while (var2 <= MaxClients)
			{
				if (61120[_arg0] == var2)
				{
					61120[_arg0] = 0;
				}
				var2++;
			}
		}
	}
	return 0;
}

public OnClientPostAdminCheck(_arg0)
{
	.22032.SetDefaultsSettings(_arg0);
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
					.19684.HG_LOG(_arg0, "[DOUBLE IP]");
					KickClient(var4, "%t%t", "HOTGUARD_TAGBAN", "HOTGUARD_DOUBLEIP_KICK");
				}
			}
		}
	}
	if (7404 + 4/* ERROR unknown load Binary */)
	{
		.24732.EnableModuleAntiWallhack();
		.25184.Hook_ModuleAntiWallhack(_arg0);
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
		27508[_arg0] = 0;
	}
	return 0;
}

public OnEntityDestroyed(_arg0)
{
	new var1;
	if (_arg0 > MaxClients && _arg0 < 2048)
	{
		27508[_arg0] = 0;
	}
	if (7404 + 44/* ERROR unknown load Binary */)
	{
		new var2 = 1;
		while (var2 <= MaxClients)
		{
			if (60856[var2] == _arg0)
			{
				61120[var2] = 0;
			}
			var2++;
		}
	}
	return 0;
}

public OnGameFrame()
{
	g_var6a68 = GetGameTickCount();
	return 0;
}

public OnLibraryAdded(_arg0)
{
	.22312.HG_SetPluginDetection(_arg0);
	return 0;
}

public OnLibraryRemoved(_arg0)
{
	.22312.HG_SetPluginDetection(_arg0);
	return 0;
}

public OnMapEnd()
{
	.37032.UnhookModuleFixSmoke();
	.41688.UnhookModuleFixFlash();
	return 0;
}

public OnMapStart()
{
	SetConVarInt(FindConVar("sv_occlude_players"), 0, 0, 0);
	SetConVarInt(FindConVar("sv_hibernate_when_empty"), 0, 0, 0);
	CreateTimer(1045220557, 233, 0, 3);
	CreateTimer(1101004800, 227, 0, 3);
	return 0;
}

public OnPlayerRunCmd(_arg0, _arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7, _arg8, _arg9, _arg10)
{
	27244[_arg0] = _arg8;
	60592[_arg0] = GetGameTime();
	if (IsPlayerAlive(_arg0))
	{
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
				if ((var16 == g_vareca4 && _arg1 & 8) || (var17 == .3028.-5(g_vareca4) && _arg1 & 512) || (var16 == .3028.-5(g_vareca4) && _arg1 & 16) || (var17 == g_vareca4 && _arg1 & 1024))
				{
					.21308.HG_CHATLOG(_arg0, 62624);
					.19684.HG_LOG(_arg0, 62656, var16, var17);
					.22464.HG_Ban(_arg0);
					7964[_arg0] = 1;
				}
				new var6;
				if (.18876.IsValidMove(var16) || .18876.IsValidMove(var17))
				{
					if (.17924.IfStrafeMove(_arg4, _arg10))
					{
						53712[_arg0] = 0;
					}
					new var18 = 53712[_arg0];
					var18++;
					if (var18 > 64)
					{
						.21308.HG_CHATLOG(_arg0, 62700);
						.19684.HG_LOG(_arg0, 62720, var16, var17);
						.22464.HG_Ban(_arg0);
						7964[_arg0] = 1;
						53712[_arg0] = 0;
					}
				}
				if (_arg1 & 4194304)
				{
					_arg1 = _arg1 & -4194305;
					.21308.HG_CHATLOG(_arg0, 62752);
					.19684.HG_LOG(_arg0, 62764);
					.22464.HG_Ban(_arg0);
					7964[_arg0] = 1;
				}
			}
			if (7404 + 52/* ERROR unknown load Binary */)
			{
				new var19 = 0;
				new var20 = 0;
				var20 + 4/* ERROR unknown load Binary */ = _arg4 + 4/* ERROR unknown load Binary */;
				var19 = GetVectorDistance(62776, var20, 0);
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
					61384[_arg0] = GetGameTickCount();
					new var7;
					if (var19 == g_varf544 && _arg1 & 384 && .19296.IsLegalMoveType(_arg0, 1))
					{
						new var8;
						if (61648[_arg0] - 61384[_arg0] < 3 && 61648[_arg0] - 61384[_arg0] >= 0)
						{
							_arg4 + 4/* ERROR unknown load Binary */ += g_varf544;
						}
						if (!(61648[_arg0] - 61384[_arg0]))
						{
							61912[_arg0]++;
							new var21 = 61912[_arg0];
							var21++;
							if (var21 > 64)
							{
								.21308.HG_CHATLOG(_arg0, 62792);
								.19684.HG_LOG(_arg0, 62812, g_varf544, 61912[_arg0]);
								.22464.HG_Ban(_arg0);
								7964[_arg0] = 1;
							}
						}
						61648[_arg0] = GetGameTickCount();
					}
					else
					{
						61912[_arg0] = 0;
					}
					g_varf544 = var19;
				}
				62776 + 4/* ERROR unknown load Binary */ = var20 + 4/* ERROR unknown load Binary */;
			}
			if (7404 + 40/* ERROR unknown load Binary */)
			{
				new var9;
				if (.4188.GetEntityMoveType(_arg0) != 9 && ConVar.IntValue.get(g_vareca8))
				{
					new var22;
					var22 = GetEntityFlags(_arg0) & 1;
					new var23;
					var23 = _arg1 & 2;
					new var10;
					if (var23 && 62844[_arg0] & 2)
					{
						if (var22)
						{
							53976[_arg0][1]++;
						}
						if (7404 + 40/* ERROR unknown load Binary */ == 1)
						{
							new var11;
							if (var22 && 53976[_arg0][1] > 2)
							{
								_arg1 = _arg1 & -3;
								_arg1 = _arg1 & -5;
							}
						}
						else
						{
							if (53976[_arg0][1] > 7)
							{
								.21308.HG_CHATLOG(_arg0, 63108);
								.19684.HG_LOG(_arg0, 63116);
								.22464.HG_Ban(_arg0);
								7964[_arg0] = 1;
							}
						}
					}
					else
					{
						if (var22)
						{
							53976[_arg0][1] = 0;
						}
					}
					62844[_arg0] = _arg1;
				}
			}
			if (7404 + 36/* ERROR unknown load Binary */)
			{
				new var12;
				if (GetEntityFlags(_arg0) & 1 && .23488.HG_GetPlayerSpeed(_arg0) < 0.01)
				{
					new var13;
					if (_arg7 % 2 == 1 || _arg7 % 3 == 1)
					{
						new var24;
						var24 = _arg4 + 4/* ERROR unknown load Binary */ - g_varf694;
						new var14;
						if (-90.0 == var24 || 90.0 == var24)
						{
							_arg4 + 4/* ERROR unknown load Binary */ += var24;
						}
					}
					g_varf694 = _arg4 + 4/* ERROR unknown load Binary */;
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
				var25 = .17448.GetAngleDelta(_arg4, 63128[_arg0]);
				new var15;
				if (_arg10 && _arg10 + 4/* ERROR unknown load Binary */ && var25 > 0.05 && _arg1 & 384 && .19296.IsLegalMoveType(_arg0, 1) && 7696[_arg0])
				{
					54768[_arg0]++;
					if (54768[_arg0] >= 64)
					{
						.21308.HG_CHATLOG(_arg0, 64184);
						.19684.HG_LOG(_arg0, 64196, var25, 54768[_arg0]);
						.22464.HG_Ban(_arg0);
						7964[_arg0] = 1;
					}
				}
				else
				{
					54768[_arg0] = 0;
				}
				new var26 = 0;
				while (var26 < 3)
				{
					63128[_arg0][var26] = _arg4[var26];
					var26++;
				}
			}
		}
	}
	return 0;
}

public OnPluginEnd()
{
	if (7404 + 4/* ERROR unknown load Binary */)
	{
		.23664.DisableModuleAntiWallhack();
	}
	if (7404 + 20/* ERROR unknown load Binary */)
	{
		.36868.DisableModuleFixSmoke();
	}
	if (7404 + 24/* ERROR unknown load Binary */)
	{
		.41604.DisableModuleFixFlash();
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
		.43608.DisableModuleBlockAim();
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
			g_var1ce8 = DHookCreate(var2, 0, 1, 1, 179);
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
	var3 = CreateConVar("hg_log", "1", 83984, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 119);
	7404/* ERROR unknown load Constant */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_log_stats", "1", 84092, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 121);
	7404 + 12/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_chatlog", "z", 84192, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 123);
	ConVar.GetString(var3, 7660, 12);
	var3 = CreateConVar("hg_chatsound", "Buttons.snd15", 84316, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 125);
	ConVar.GetString(var3, 7672, 20);
	var3 = CreateConVar("hg_antiwh", "1", 84388, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 127);
	7404 + 4/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_antiwh_mode", "0", 84436, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 129);
	7404 + 8/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_punishmode", "60", 84632, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 133);
	7404 + 16/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_fixsmoke", "1", 84780, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 135);
	7404 + 20/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_fixflash", "1", 84884, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 137);
	7404 + 24/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_checkdoubleip", "0", 84992, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 139);
	7404 + 28/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_badmove", "1", 85116, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 141);
	7404 + 32/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_fixdesync", "1", 85212, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 143);
	7404 + 36/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_bhop", "1", 85304, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 145);
	7404 + 40/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_blockaim", "1", 85352, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 147);
	7404 + 44/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_fixangles", "1", 85420, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 149);
	7404 + 48/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_diffang", "1", 85492, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 151);
	7404 + 52/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_mouse", "1", 85568, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 153);
	7404 + 60/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	var3 = CreateConVar("hg_fakecvar", "1", 85652, 0, 0, 0, 0, 0);
	ConVar.AddChangeHook(var3, 155);
	7404 + 64/* ERROR unknown load Binary */ = ConVar.IntValue.get(var3);
	AutoExecConfig(1, "hotguard", "sourcemod");
	if (7404 + 4/* ERROR unknown load Binary */)
	{
		.24732.EnableModuleAntiWallhack();
	}
	if (7404 + 20/* ERROR unknown load Binary */)
	{
		.37312.EnableModuleFixSmoke();
	}
	if (7404 + 24/* ERROR unknown load Binary */)
	{
		.41968.EnableModuleFixFlash();
	}
	if (7404 + 44/* ERROR unknown load Binary */)
	{
		.43716.EnableModuleBlockAim();
	}
	if (g_var1f18)
	{
		LogMessage("The anti-cheat was rebooted during operation, and it may not work correctly in the future.");
		.57540.x0404x001();
		new var4;
		var4 = MaxClients + 1;
		var4--;
		while (var4)
		{
			if (.23112.HG_IsValidClient(var4, 1, 1))
			{
				OnClientPostAdminCheck(var4);
			}
		}
	}
	g_var8b74 = GetPlayerResourceEntity();
	35704/* ERROR unknown load Constant */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicLevel", 0, 0, 0);
	35704 + 4/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsLeader", 0, 0, 0);
	35704 + 8/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsTeacher", 0, 0, 0);
	35704 + 12/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_nPersonaDataPublicCommendsFriendly", 0, 0, 0);
	35704 + 16/* ERROR unknown load Binary */ = FindSendPropInfo("CCSPlayerResource", "m_bHasCommunicationAbuseMute", 0, 0, 0);
	g_vard1c4 = FindSendPropInfo("CBaseEntity", "m_vecOrigin", 0, 0, 0);
	g_vard1c8 = FindSendPropInfo("CCSPlayer", "m_flFlashDuration", 0, 0, 0);
	g_vard1cc = FindSendPropInfo("CCSPlayer", "m_flFlashMaxAlpha", 0, 0, 0);
	g_vareca8 = FindConVar("sv_autobunnyhopping");
	g_varecac = FindConVar("sv_cheats");
	g_vareca4 = 1138819072;
	if (!(DirExists("/addons/sourcemod/logs/hotguard", 0, "GAME")))
	{
		CreateDirectory("/addons/sourcemod/logs/hotguard", 511, 0, "DEFAULT_WRITE_PATH");
	}
	PrecacheModel("models/props_vehicles/cara_69sedan.mdl", 1);
	SetConVarInt(FindConVar("sv_occlude_players"), 0, 0, 0);
	SetConVarInt(FindConVar("sv_hibernate_when_empty"), 0, 0, 0);
	return 0;
}

public SetTransmitPlayerBlind(_arg0, _arg1)
{
	new var1;
	if (GetClientTeam(_arg0) != GetClientTeam(_arg1) && IsPlayerAlive(_arg1))
	{
		return 0;
	}
	if (60316[_arg1])
	{
		if (60316[_arg1] >= GetGameTime())
		{
			new var2;
			if (_arg1 == _arg0)
			{
				var2 = 0;
			}
			else
			{
				var2 = 3;
			}
			return var2;
		}
		60316[_arg1] = 0;
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
	var2 = g_vareb98 + 19.0 - GetGameTime();
	if (var2 > 18.8)
	{
		return 0;
	}
	new var3;
	var3 = g_vard1c0;
	new var4 = 0;
	while (ArrayList.Length.get(g_var1ce4) != var3)
	{
		var3++;
		new var5 = ArrayList.Get(g_var1ce4, var3, 0, 0);
		var4 = var5;
		if (IsValidEntity(var5))
		{
			GetEntDataVector(_arg1, g_vard1c4, 83268);
			GetEntDataVector(_arg0, g_vard1c4, 83280);
			GetEntDataVector(var4, g_vard1c4, 83292);
			if (.38796.IsAbleToSeeSmoke(_arg0, _arg1, var4))
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
	}
	return 0;
}

public Timer_CheckBuy(_arg0)
{
	if (!_arg0)
	{
		.57540.x0404x001();
	}
	new var1;
	if (.4152.CanTestFeatures() && GetFeatureStatus(0, 62592))
	{
		.56552.SteamWorks_SteamServersConnected();
		return 0;
	}
	.57540.x0404x001();
	return 4;
}

public Timer_FlashEnded()
{
	.41688.UnhookModuleFixFlash();
	new var1;
	var1 = MaxClients + 1;
	var1--;
	while (var1)
	{
		if (60316[var1])
		{
			return 4;
		}
	}
	return 4;
}

public Timer_SmokeEnded()
{
	.37032.UnhookModuleFixSmoke();
	return 4;
}

public Timer_UpdateSettings()
{
	new var2 = 1;
	while (var2 <= MaxClients)
	{
		if (.23112.HG_IsValidClient(var2, 0, 0))
		{
			QueryClientConVar(var2, 62392, 175, 0);
			new var1;
			if (7404 + 64/* ERROR unknown load Binary */ && ConVar.IntValue.get(g_varecac))
			{
				QueryClientConVar(var2, 62404, 175, 0);
				QueryClientConVar(var2, 62416, 175, 0);
				QueryClientConVar(var2, 62432, 175, 0);
				new var3 = 0;
				while (var3 < 10)
				{
					QueryClientConVar(var2, 62176[var3], 175, 0);
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
	if (.23112.HG_IsValidClient(_arg0, 0, 1))
	{
		SDKUnhook(_arg0, 24, 191);
		.45068.ModuleBlockAimRemoveObject(_arg0);
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
	var1 = GetClientOfUserId(Event.GetInt(_arg0, 64792, 0));
	.28508.AW_UpdateClientCache(var1);
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
				if (!g_var1e0c)
				{
					LogAction(-1, -1, 86740);
				}
				g_var1e0c = 1;
			}
			case 404:
			{
				PrintToServer(86820);
				.57540.x0404x001();
			}
			case 413:
			{
				PrintToServer(86860);
				.57540.x0404x001();
			}
			default:
			{
				PrintToServer(86900, var1);
				.57540.x0404x001();
			}
		}
	}
	return 0;
}

