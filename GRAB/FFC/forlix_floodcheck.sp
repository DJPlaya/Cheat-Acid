// Forlix FloodCheck
// http://forlix.org/, df@forlix.org
//
// Copyright (c) 2008-2013 Dominik Friedrichs

#include "_main.inc"

static bool:late_load = false;


public APLRes:AskPluginLoad2(Handle:myself,
                             bool:late,
                             String:error[],
                             err_max)
{
  CreateNative("IsClientFlooding", Native_IsClientFlooding);

  late_load = late;
  return(APLRes_Success);
}


public OnPluginStart()
{
  RegPluginLibrary("forlix_floodcheck");

  // chat and radio flood checking
  RegConsoleCmd("say", FloodCheckChat);
  RegConsoleCmd("say_team", FloodCheckChat);

  HookEvent("player_connect", Event_PlayerConnect, EventHookMode_Pre);
  HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
  HookEvent("player_changename", Event_PlayerChangename, EventHookMode_Pre);

  // game-specific setup
  decl String:gamedir[16];
  GetGameFolderName(gamedir, sizeof(gamedir));

  if(StrEqual(gamedir, "cstrike"))
  // counter-strike: source
    SetupChatDetection_cstrike();
  else
  if(StrEqual(gamedir, "dod"))
  // day of defeat: source
    SetupChatDetection_dod();
  else
  if(StrEqual(gamedir, "tf"))
  // team fortress 2
    SetupChatDetection_tf();
  else
  // all other games
    SetupChatDetection_misc();

  SetupConVars();
  MarkCheats();

  FloodCheckConnect_PluginStart();

  if(late_load)
    Query_VoiceLoopback_All();

  late_load = false;
  return;
}


public OnPluginEnd()
{
  FloodCheckConnect_PluginEnd();
  return;
}


public bool:OnClientConnect(client,
                            String:rejectmsg[],
                            maxlen)
{
  if(!IsClientNameAllowed(client))
  {
    strcopy(rejectmsg, maxlen, MALFORMED_NAME_MSG);
    return(false);
  }

  return(true);
}


public OnClientSettingsChanged(client)
{
  if(!IsClientInGame(client)
  || IsFakeClient(client))
    return;

  Query_VoiceLoopback(client);

  if(!IsClientNameAllowed(client))
    KickClient(client, MALFORMED_NAME_MSG);

  // make sure client cant hardflood us with settingschanged
  FloodCheckHard(client);
  return;
}


public OnClientConnected(client)
{
  FloodCheckChat_Connect(client);
  FloodCheckHard_Connect(client);
  FloodCheckName_Connect(client);

  return;
}


public Action:OnClientCommand(client, args)
{
  FloodCheckHard(client);
  return(Plugin_Continue);
}
