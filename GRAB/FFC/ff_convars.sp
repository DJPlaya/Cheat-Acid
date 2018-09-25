// Forlix FloodCheck
// http://forlix.org/, df@forlix.org
//
// Copyright (c) 2008-2013 Dominik Friedrichs

// convar defaults
#define FLOOD_CHAT_INTERVAL     "4"
#define FLOOD_CHAT_NUM          "3"

#define FLOOD_HARD_INTERVAL     "2"
#define FLOOD_HARD_NUM          "200"
#define FLOOD_HARD_BAN_TIME     "150"

#define FLOOD_NAME_INTERVAL     "120"
#define FLOOD_NAME_NUM          "3"
#define FLOOD_NAME_BAN_TIME     "150"

#define FLOOD_CONNECT_INTERVAL  "5"
#define FLOOD_CONNECT_NUM       "2"
#define FLOOD_CONNECT_BAN_TIME  "50"

#define EXCLUDE_CHAT_TRIGGERS   "1"
#define MUTE_VOICE_LOOPBACK     "1"

static Handle:h_chat_interval = INVALID_HANDLE;
static Handle:h_chat_num = INVALID_HANDLE;

static Handle:h_hard_interval = INVALID_HANDLE;
static Handle:h_hard_num = INVALID_HANDLE;
static Handle:h_hard_ban_time = INVALID_HANDLE;

static Handle:h_name_interval = INVALID_HANDLE;
static Handle:h_name_num = INVALID_HANDLE;
static Handle:h_name_ban_time = INVALID_HANDLE;

static Handle:h_connect_interval = INVALID_HANDLE;
static Handle:h_connect_num = INVALID_HANDLE;
static Handle:h_connect_ban_time = INVALID_HANDLE;

static Handle:h_exclude_chat_triggers = INVALID_HANDLE;
static Handle:h_mute_voice_loopback = INVALID_HANDLE;


SetupConVars()
{
  new Handle:version_cvar = CreateConVar(PLUGIN_VERSION_CVAR,
  PLUGIN_VERSION,
  "Forlix FloodCheck plugin version",
  FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_PRINTABLEONLY);

  SetConVarString(version_cvar, PLUGIN_VERSION, false, false);

  h_chat_interval = CreateConVar("forlix_floodcheck_chat_interval",
  FLOOD_CHAT_INTERVAL,
  "Minimum average interval in seconds between a players chat- and radio-messages (0 to disable)",
  0, true, 0.0, true, 20.0);

  h_chat_num = CreateConVar("forlix_floodcheck_chat_num",
  FLOOD_CHAT_NUM,
  "Player is considered spamming after undershooting <forlix_floodcheck_chat_interval> this many times",
  0, true, 1.0, true, 75.0);

  h_hard_interval = CreateConVar("forlix_floodcheck_hard_interval",
  FLOOD_HARD_INTERVAL,
  "Time in seconds in which <forlix_floodcheck_hard_num> commands are allowed (0 to disable)",
  0, true, 0.0, true, 20.0);

  h_hard_num = CreateConVar("forlix_floodcheck_hard_num",
  FLOOD_HARD_NUM,
  "Maximum number of client commands allowed in <forlix_floodcheck_hard_interval> seconds",
  0, true, 10.0, true, 750.0);

  h_hard_ban_time = CreateConVar("forlix_floodcheck_hard_ban_time",
  FLOOD_HARD_BAN_TIME,
  "Number of minutes a client is banned for when hard-flooding",
  0, true, 1.0, true, 20160.0);

  h_name_interval = CreateConVar("forlix_floodcheck_name_interval",
  FLOOD_NAME_INTERVAL,
  "Time in seconds in which <forlix_floodcheck_name_num> name changes are allowed (0 to disable)",
  0, true, 0.0, true, 600.0);

  h_name_num = CreateConVar("forlix_floodcheck_name_num",
  FLOOD_NAME_NUM,
  "Maximum number of name changes allowed in <forlix_floodcheck_name_interval> seconds",
  0, true, 1.0, true, 20.0);

  h_name_ban_time = CreateConVar("forlix_floodcheck_name_ban_time",
  FLOOD_NAME_BAN_TIME,
  "Number of minutes a client is banned for when name-flooding",
  0, true, 1.0, true, 20160.0);

  h_connect_interval = CreateConVar("forlix_floodcheck_connect_interval",
  FLOOD_CONNECT_INTERVAL,
  "Time in seconds in which <forlix_floodcheck_connect_num> connects are allowed (0 to disable)",
  0, true, 0.0, true, 60.0);

  h_connect_num = CreateConVar("forlix_floodcheck_connect_num",
  FLOOD_CONNECT_NUM,
  "Maximum number of connects allowed in <forlix_floodcheck_connect_interval> seconds",
  0, true, 1.0, true, 20.0);

  h_connect_ban_time = CreateConVar("forlix_floodcheck_connect_ban_time",
  FLOOD_CONNECT_BAN_TIME,
  "Number of seconds a client is IP-banned for when connect-flooding",
  0, true, 5.0, true, 600.0);

  h_exclude_chat_triggers = CreateConVar("forlix_floodcheck_exclude_chat_triggers",
  EXCLUDE_CHAT_TRIGGERS,
  "Excludes (1) or includes (0) SourceMod chat triggers in the chat flood detection",
  0, true, 0.0, true, 1.0);

  h_mute_voice_loopback = CreateConVar("forlix_floodcheck_mute_voice_loopback",
  MUTE_VOICE_LOOPBACK,
  "Mute players enabling voice_loopback (1) or allow its use (0)",
  0, true, 0.0, true, 1.0);

  HookConVarChange(h_chat_interval, MyConVarChanged);
  HookConVarChange(h_chat_num, MyConVarChanged);

  HookConVarChange(h_hard_interval, MyConVarChanged);
  HookConVarChange(h_hard_num, MyConVarChanged);
  HookConVarChange(h_hard_ban_time, MyConVarChanged);

  HookConVarChange(h_name_interval, MyConVarChanged);
  HookConVarChange(h_name_num, MyConVarChanged);
  HookConVarChange(h_name_ban_time, MyConVarChanged);

  HookConVarChange(h_connect_interval, MyConVarChanged);
  HookConVarChange(h_connect_num, MyConVarChanged);
  HookConVarChange(h_connect_ban_time, MyConVarChanged);

  HookConVarChange(h_exclude_chat_triggers, MyConVarChanged);
  HookConVarChange(h_mute_voice_loopback, MyConVarChanged);

  // manually trigger convar readout
  MyConVarChanged(INVALID_HANDLE, "0", "0");

  return;
}


public MyConVarChanged(Handle:convar,
                       const String:oldValue[],
                       const String:newValue[])
{
  chat_interval = GetConVarFloat(h_chat_interval);
  chat_num = GetConVarInt(h_chat_num);

  hard_interval = GetConVarFloat(h_hard_interval);
  hard_num = GetConVarInt(h_hard_num);
  hard_ban_time = GetConVarInt(h_hard_ban_time);

  name_interval = GetConVarFloat(h_name_interval);
  name_num = GetConVarInt(h_name_num);
  name_ban_time = GetConVarInt(h_name_ban_time);

  connect_interval = GetConVarFloat(h_connect_interval);
  connect_num = GetConVarInt(h_connect_num);
  connect_ban_time = GetConVarInt(h_connect_ban_time);

  exclude_chat_triggers = GetConVarInt(h_exclude_chat_triggers);
  mute_voice_loopback = GetConVarInt(h_mute_voice_loopback);

  Query_VoiceLoopback_All();
  return;
}
