// Forlix FloodCheck
// http://forlix.org/, df@forlix.org
//
// Copyright (c) 2008-2013 Dominik Friedrichs


public Action:Event_PlayerConnect(Handle:event,
                                  const String:Event_type[],
                                  bool:dontBroadcast)
{
  decl String:str_ipport[MAX_IPPORT_LEN];
  decl String:name[MAX_NAME_LEN];

  GetEventString(event, "address", str_ipport, sizeof(str_ipport));

  // doing this check in OnClientConnect does not catch
  // clients connecting and disconnecting really quickly
  FloodCheckConnect(str_ipport, GetEventInt(event, "userid"));

  GetEventString(event, "name", name, sizeof(name));
  MakeStringPrintable(name, sizeof(name), NAME_STR_EMPTY);

  SetEventString(event, "name", name);
  return(Plugin_Continue);
}


public Action:Event_PlayerChangename(Handle:event,
                                     const String:Event_type[],
                                     bool:dontBroadcast)
{
  decl String:newname[MAX_NAME_LEN];

  new client = GetClientOfUserId(GetEventInt(event, "userid"));
  FloodCheckName(client);

  GetEventString(event, "newname", newname, sizeof(newname));
  MakeStringPrintable(newname, sizeof(newname), NAME_STR_EMPTY);

  SetEventString(event, "newname", newname);
  return(Plugin_Continue);
}


public Action:Event_PlayerDisconnect(Handle:event,
                                     const String:Event_type[],
                                     bool:dontBroadcast)
{
  decl String:name[MAX_NAME_LEN];
  decl String:reason[MAX_MSG_LEN];

  GetEventString(event, "name", name, sizeof(name));
  GetEventString(event, "reason", reason, sizeof(reason));

  MakeStringPrintable(name, sizeof(name), NAME_STR_EMPTY);
  MakeStringPrintable(reason, sizeof(reason), REASON_STR_EMPTY);

  TruncateString(reason, strlen(reason), REASON_TRUNCATE_LEN);

  SetEventString(event, "name", name);
  SetEventString(event, "reason", reason);

  return(Plugin_Continue);
}
