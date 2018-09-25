// Forlix FloodCheck
// http://forlix.org/, df@forlix.org
//
// Copyright (c) 2008-2013 Dominik Friedrichs


Query_VoiceLoopback(client)
{
  if(!mute_voice_loopback)
    return;

  QueryClientConVar(client, "voice_loopback", Query_VoiceLoopback_Callback);
  return;
}


public Query_VoiceLoopback_Callback(QueryCookie:cookie,
                                    client,
                                    ConVarQueryResult:result,
                                    const String:cvarName[],
                                    const String:cvarValue[])
{
  if(result != ConVarQuery_Okay
  || !IsClientInGame(client))
    return;

  if(StringToInt(cvarValue)
  && !(GetClientListeningFlags(client) & VOICE_MUTED))
  // loopback on and client not already muted
  {
    SetClientListeningFlags(client, VOICE_MUTED);
    PrintToChat(client, VOICE_LOOPBACK_MSG);

    LogToGame(LOG_MSG_LOOPBACK_MUTE, client);
  }

  return;
}


Query_VoiceLoopback_All()
{
  if(!mute_voice_loopback)
    return;

  for(new client = 1; client <= MaxClients; client++)
  if(IsClientInGame(client))
    QueryClientConVar(client, "voice_loopback", Query_VoiceLoopback_Callback);

  return;
}
