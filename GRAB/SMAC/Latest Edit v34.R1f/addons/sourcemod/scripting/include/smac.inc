#if defined _smac_included
  #endinput
#endif
#define _smac_included

#include <smac_stocks>

/* Globals */
#define SMAC_VERSION	"v34.R1f"
#define SMAC_URL		"http://hlmod.ru/forum/showthread.php?p=185360"
#define SMAC_AUTHOR		"Danyas"


enum DetectionType {
	Detection_Unknown = 0,
	Detection_Aimbot = 100,
	Detection_AutoTrigger = 200,
	Detection_NameChangeSpam = 300,
	Detection_CommandSpamming = 400,
	Detection_BannedCommand,
	Detection_CvarViolation = 500,
	Detection_UserCmdReuse = 600,
	Detection_UserCmdTamperingTickcount,
	Detection_UserCmdTamperingButtons,
	Detection_Eyeangles,
	Detection_Speedhack = 700,
	Detection_Spinhack = 800,
	
};

/* Natives */
native GameType:SMAC_GetGameType();
native SMAC_Log(const String:format[], any:...);
native SMAC_LogAction(client, const String:format[], any:...);
native SMAC_Ban(client, const String:reason[], any:...);
native SMAC_PrintAdminNotice(const String:format[], any:...);
native Handle:SMAC_CreateConVar(const String:name[], const String:defaultValue[], const String:description[]="", flags=0, bool:hasMin=false, Float:min=0.0, bool:hasMax=false, Float:max=0.0);
native Action:SMAC_CheatDetected(client, DetectionType:type = Detection_Unknown, Handle:info = INVALID_HANDLE);

/* Forwards */
forward Action:SMAC_OnCheatDetected(client, const String:module[], DetectionType:type, Handle:info);


public SharedPlugin:__pl_smac = 
{
	name = "smac",
	file = "smac.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_smac_SetNTVOptional()
{
	MarkNativeAsOptional("SMAC_GetGameType");
	MarkNativeAsOptional("SMAC_Log");
	MarkNativeAsOptional("SMAC_LogAction");
	MarkNativeAsOptional("SMAC_Ban");
	MarkNativeAsOptional("SMAC_PrintAdminNotice");
	MarkNativeAsOptional("SMAC_CreateConVar");
	MarkNativeAsOptional("SMAC_CheatDetected");
}
#endif
