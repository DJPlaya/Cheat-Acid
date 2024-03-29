#if defined _smac_stocks_included
  #endinput
#endif
#define _smac_stocks_included

/**
 * Preprocessor directives
 */
 
#define MAX_MAPNAME_LENGTH	32
#define MAX_AUTHID_LENGTH	64

// Hud Element hiding flags
#define HIDEHUD_WEAPONSELECTION		(1 << 0)	// Hide ammo count & weapon selection
#define HIDEHUD_FLASHLIGHT			(1 << 1)
#define HIDEHUD_ALL					(1 << 2)
#define HIDEHUD_HEALTH				(1 << 3)	// Hide health & armor / suit battery
#define HIDEHUD_PLAYERDEAD			(1 << 4)	// Hide when local player's dead
#define HIDEHUD_NEEDSUIT			(1 << 5)	// Hide when the local player doesn't have the HEV suit
#define HIDEHUD_MISCSTATUS			(1 << 6)	// Hide miscellaneous status elements (trains, pickup history, death notices, etc)
#define HIDEHUD_CHAT				(1 << 7)	// Hide all communication elements (saytext, voice icon, etc)
#define HIDEHUD_CROSSHAIR			(1 << 8)	// Hide crosshairs
#define HIDEHUD_VEHICLE_CROSSHAIR	(1 << 9)	// Hide vehicle crosshair
#define HIDEHUD_INVEHICLE			(1 << 10)
#define HIDEHUD_BONUS_PROGRESS		(1 << 11)	// Hide bonus progress display (for bonus map challenges)
#define HIDEHUD_BITCOUNT			12

// Fade UserMessage bits
#define FFADE_IN		0x0001	// Just here so we don't pass 0 into the function
#define FFADE_OUT		0x0002	// Fade out (not in)
#define FFADE_MODULATE	0x0004	// Modulate (don't blend)
#define FFADE_STAYOUT	0x0008	// ignores the duration, stays faded out until new ScreenFade message received
#define FFADE_PURGE		0x0010	// Purges all other fades, replacing them with this one

// Macros
#define IS_CLIENT(%1)	(1 <= %1 <= MaxClients)
#define TIME_TO_TICK(%1)	(RoundToNearest((%1) / GetTickInterval()))
#define TICK_TO_TIME(%1)	((%1) * GetTickInterval())

// Spectator movement modes
enum {
	OBS_MODE_NONE = 0,	// not in spectator mode
	OBS_MODE_DEATHCAM,	// special mode for death cam animation
	OBS_MODE_FREEZECAM,	// zooms to a target, and freeze-frames on them
	OBS_MODE_FIXED,		// view from a fixed camera position
	OBS_MODE_IN_EYE,	// follow a player in first person view
	OBS_MODE_CHASE,		// follow a player in third person view
	OBS_MODE_ROAMING,	// free roaming
};

/**
 * General
 */
stock GetPluginBasename(Handle:plugin, String:buffer[], maxlength)
{
	GetPluginFilename(plugin, buffer, maxlength);
	
	new check = -1;
	if ((check = FindCharInString(buffer, '/', true)) != -1 ||
		(check = FindCharInString(buffer, '\\', true)) != -1)
	{
		Format(buffer, maxlength, "%s", buffer[check+1]);
	}
}

stock bool:IsConVarDefault(Handle:convar)
{
	decl String:sDefaultVal[16], String:sCurrentVal[16];
	GetConVarDefault(convar, sDefaultVal, sizeof(sDefaultVal));
	GetConVarString(convar, sCurrentVal, sizeof(sCurrentVal));
	
	return StrEqual(sDefaultVal, sCurrentVal);
}

stock StringToLower(String:input[])
{
	new length = strlen(input);
	
	for (new i = 0; i < length; i++)
	{
		input[i] = CharToLower(input[i]);
	}
}

/**
 * Clients
 */
stock bool:IsClientNew(client)
{
	// Client must be ingame.
	return IsFakeClient(client) || GetGameTime() > GetClientTime(client);
}

stock bool:GetClientAbsVelocity(client, Float:velocity[3])
{
	static offset = -1;
	
	if (offset == -1 && (offset = FindDataMapOffs(client, "m_vecAbsVelocity")) == -1)
	{
		ZeroVector(velocity);
		return false;
	}
	
	GetEntDataVector(client, offset, velocity);
	return true;
}

stock GetClientHudFlags(client)
{
	return GetEntProp(client, Prop_Send, "m_iHideHUD");
}

stock GetClientObserverMode(client)
{
	static offset = -1;
	
	if (offset == -1 && (offset = FindSendPropOffs("CBasePlayer", "m_iObserverMode")) == -1)
	{
		return OBS_MODE_NONE;
	}
	
	return GetEntData(client, offset);
}

stock GetClientObserverTarget(client)
{
	static offset = -1;
	
	if (offset == -1 && (offset = FindSendPropOffs("CBasePlayer", "m_hObserverTarget")) == -1)
	{
		return -1;
	}
	
	return GetEntDataEnt2(client, offset);
}


/**
 * Math
 */
stock ZeroVector(Float:vec[3])
{
	vec[0] = vec[1] = vec[2] = 0.0;
}

stock bool:IsVectorZero(const Float:vec[3])
{
	return vec[0] == 0.0 && vec[1] == 0.0 && vec[2] == 0.0;
}

stock bool:IsVectorAlmostZero(const Float:vec[3], const Float:tolerance=0.1)
{
	return FloatAbs(vec[0]) <= tolerance && 
		FloatAbs(vec[1]) <= tolerance && 
		FloatAbs(vec[2]) <= tolerance;
}

stock bool:AreVectorsEqual(const Float:vec1[3], const Float:vec2[3])
{
	return vec1[0] == vec2[0] && vec1[1] == vec2[1] && vec1[2] == vec2[2];
}

stock bool:AreVectorsAlmostEqual(const Float:vec1[3], const Float:vec2[3], const Float:tolerance=0.1)
{
	return FloatAbs(vec1[0] - vec2[0]) <= tolerance && 
		FloatAbs(vec1[1] - vec2[1]) <= tolerance && 
		FloatAbs(vec1[2] - vec2[2]) <= tolerance;
}

stock AbsValue(value)
{
	return (value >= 0) ? value : -value;
}

stock any:MinValue(any:value, any:min)
{
	return (value < min) ? min : value;
}

stock any:MaxValue(any:value, any:max)
{
	return (value > max) ? max : value;
}

stock any:ClampValue(any:value, any:min, any:max)
{
	value = MinValue(value, min);
	value = MaxValue(value, max);
	
	return value;
}

stock IPToLong(const String:ip[])
{
	decl String:pieces[4][4];

	if (ExplodeString(ip, ".", pieces, sizeof(pieces), sizeof(pieces[])) != 4)
		return 0;

	return StringToInt(pieces[0]) << 24 | 
		StringToInt(pieces[1]) << 16 | 
		StringToInt(pieces[2]) << 8 | 
		StringToInt(pieces[3]);
}

stock LongToIP(ip, String:buffer[], size)
{
	FormatEx(buffer, size, "%d.%d.%d.%d", (ip >> 24) & 0xFF, (ip >> 16) & 0xFF, (ip >> 8) & 0xFF, ip & 0xFF);
}

stock MT_GetRandomInt(min, max)
{
	return RoundToNearest(GetURandomFloat() * float(max - min) + float(min));
}

stock Float:MT_GetRandomFloat(Float:min, Float:max)
{
	return GetURandomFloat() * (max - min) + min;
}

stock BfWriteSBitLong(Handle:bf, data, numBits)
{
	for (new i = 0; i < numBits; i++)
	{
		BfWriteBool(bf, !!(data & (1 << i)));
	}
}

stock BfReadSBitLong(Handle:bf, numBits)
{
	decl bits[numBits], ret, i;
	
	for (i = 0; i < numBits; i++)
	{
		bits[i] = BfReadBool(bf);
	}
	
	ret = bits[numBits-1] ? -1 : 0;
	
	for (i = numBits-1; i >= 0; i--)
	{
		ret <<= 1;
		ret |= bits[i];
	}
	
	return ret;
}
