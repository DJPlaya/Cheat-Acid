#if defined _btimes_timer_included
  #endinput
#endif
#define _btimes_timer_included

enum styleConfig
{
	String:Name[32],
	String:Name_Short[32],
	bool:Enabled,
	bool:TempEnabled,
	bool:AllowType[2],
	bool:Freestyle,
	bool:Freestyle_Unrestrict,
	bool:Freestyle_EzHop,
	bool:Freestyle_Auto,
	bool:Auto,
	bool:EzHop,
	Float:Gravity,
	Float:RunSpeed,
	Float:MaxVel,
	Float:MinFps,
	bool:CalcSync,
	bool:Prevent_Left,
	bool:Prevent_Right,
	bool:Prevent_Back,
	bool:Prevent_Forward,
	bool:Require_Left,
	bool:Require_Right,
	bool:Require_Back,
	bool:Require_Forward,
	bool:Hud_Style,
	bool:Hud_Strafes,
	bool:Hud_Jumps,
	bool:Count_Left_Strafe,
	bool:Count_Right_Strafe,
	bool:Count_Back_Strafe,
	bool:Count_Forward_Strafe,
	bool:Ghost_Use[2],
	bool:Ghost_Save[2],
	Float:PreSpeed,
	Float:SlowedSpeed,
	bool:Special,
	String:Special_Key[32],
	bool:GunJump,
	String:GunJump_Weapon[64],
	bool:UnrealPhys,
	AirAcceleration,
	bool:EnableBunnyhopping,
	StyleConfig
};

/*
* Gets a client's style (Normal, Sideways, etc..).
* 
* @param client        Client index
* 
* @return              The client's style.
*/
native int GetClientStyle(int client);

/*
* Gets the complete configuration for a specified style.
* 
* @param Style         The style to get a configuration for.
* @param Properties    The buffer to store all the style properties, (properties are listed in the StyleConfig enum)
* 
* @return              True if the style exists, false otherwise.
*/
native bool Style_GetConfig(int Style, any Properties[StyleConfig]);

public SharedPlugin __pl_btimes_timer =
{
	name = "timer",
	file = "bTimes-timer.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_btimes_timer_SetNTVOptional()
{
	MarkNativeAsOptional("GetClientStyle");
	MarkNativeAsOptional("Style_GetConfig");
}
#endif
