// Forlix FloodCheck
// http://forlix.org/, df@forlix.org
//
// Copyright (c) 2008-2013 Dominik Friedrichs

#define REMOVEFILTER_INTERVAL   2.5
#define IP_LEN_MIN              7
// 0.0.0.0:0 - shortest IP-port string
// ^0     ^7

static Handle:h_ipfilters = INVALID_HANDLE;


FloodCheckConnect_PluginStart()
{
  h_ipfilters = CreateArray(MAX_IPPORT_LEN+32);
  CreateTimer(REMOVEFILTER_INTERVAL, Timer_RemoveExpiredIPFilters, INVALID_HANDLE, TIMER_REPEAT);

  return;
}


FloodCheckConnect_PluginEnd()
{
  // remove all ip filters
  new filternum = GetArraySize(h_ipfilters);

  for(new i = 0; i < filternum; i++)
  {
    decl String:str_ip_exptime[MAX_IPPORT_LEN+32];
    GetArrayString(h_ipfilters, i, str_ip_exptime, sizeof(str_ip_exptime));

    new ip_len = FindCharInString(str_ip_exptime, '_');

    if(ip_len < IP_LEN_MIN)
      continue;

    str_ip_exptime[ip_len] = '\0';
    ServerCommand("removeip %s", str_ip_exptime);
  }

  CloseHandle(h_ipfilters);
  return;
}


bool:FloodCheckConnect(const String:str_ipport[],
                       userid)
{
  static connect_ip_index = 0;
  static String:connect_ip[CONNECT_TRACK][MAX_IPPORT_LEN];
  static Float:connect_lasttime[CONNECT_TRACK];
  static connect_cnt[CONNECT_TRACK];

  if(!connect_interval)
    return(false);

  new ip_len = FindCharInString(str_ipport, ':');

  if(ip_len < IP_LEN_MIN)
    return(false);

  decl String:str_ip[MAX_IPPORT_LEN];
  strcopy(str_ip, ip_len+1, str_ipport);

  new Float:time_c = GetTickedTime();
  new ti = -1;

  for(new i = 0; i < CONNECT_TRACK; i++)
  if(!strcmp(connect_ip[i], str_ip))
  {
    ti = i;
    break;
  }

  if(ti < 0
  || time_c >= connect_lasttime[ti] + connect_interval)
  // IP was not found in ring buffer
  // or its tracking object has expired
  {
    if(ti >= 0)
    // forget the old object if it exists
      connect_ip[ti][0] = '\0';

    // get a fresh object at the beginning of the ring buffer,
    // overwriting the oldest object in the buffer
    ti = connect_ip_index;

    strcopy(connect_ip[ti], sizeof(connect_ip[]), str_ip);
    connect_lasttime[ti] = time_c;
    connect_cnt[ti] = 0;

    if(++connect_ip_index >= CONNECT_TRACK)
    // ring buffer - when end is reached, continue at the beginning
      connect_ip_index = 0;
  }

  if(++connect_cnt[ti] <= connect_num)
  // count towards the threshold
    return(false);

  // ban this IP and clear it from the ring buffer
  connect_ip[ti][0] = '\0';

  // add a tracking object to make sure the filter is removed upon expiration
  if(!AddIPFilterTrackingObject(str_ip, connect_ban_time))
  // IP is already banned
    return(true);

  // format kick message
  decl String:kickmsg[MAX_MSG_LEN];

  if(connect_ban_time <= 60)
    Format(kickmsg, sizeof(kickmsg), FLOOD_CONNECT_MSG, "a minute");
  else
  {
    decl String:str_time[32];
    Format(str_time, sizeof(str_time), "%u minutes", RoundToCeil(connect_ban_time/60.0));
    Format(kickmsg, sizeof(kickmsg), FLOOD_CONNECT_MSG, str_time);
  }

  // this will actually be executed after the kickid below
  InsertServerCommand("addip %.3f %s", connect_ban_time/60.0, str_ip);

  // avoid IP-banned clients stuck in connection attempt and timing out
  // this is the only way of kicking a client that hasn't yet gotten a client index
  InsertServerCommand("kickid %u %s", userid, kickmsg);

  return(true);
}


bool:AddIPFilterTrackingObject(const String:str_ip[], duration)
{
  new filternum = GetArraySize(h_ipfilters);

  for(new i = 0; i < filternum; i++)
  {
    decl String:str_ip_exptime[MAX_IPPORT_LEN+32];
    GetArrayString(h_ipfilters, i, str_ip_exptime, sizeof(str_ip_exptime));

    new ip_len = FindCharInString(str_ip_exptime, '_');

    if(ip_len < IP_LEN_MIN)
      continue;

    str_ip_exptime[ip_len] = '\0';

    if(!strcmp(str_ip, str_ip_exptime))
    // IP is already banned
      return(false);
  }

  // add new tracking object for IP filter
  decl String:str_ip_exptime[MAX_IPPORT_LEN+32];
  Format(str_ip_exptime, sizeof(str_ip_exptime), "%s_%u", str_ip, GetTime()+duration);

  PushArrayString(h_ipfilters, str_ip_exptime);
  return(true);
}


public Action:Timer_RemoveExpiredIPFilters(Handle:timer)
{
  new filternum = GetArraySize(h_ipfilters);
  new time_c = GetTime();

  for(new i = 0; i < filternum; i++)
  {
    decl String:str_ip_exptime[MAX_IPPORT_LEN+32];
    GetArrayString(h_ipfilters, i, str_ip_exptime, sizeof(str_ip_exptime));

    new ip_len = FindCharInString(str_ip_exptime, '_');

    if(ip_len < IP_LEN_MIN)
    {
      RemoveFromArray(h_ipfilters, i--);
      filternum--;
      continue;
    }

    if(time_c < StringToInt(str_ip_exptime[ip_len+1]))
      continue;

    str_ip_exptime[ip_len] = '\0';
    ServerCommand("removeip %s", str_ip_exptime);

    RemoveFromArray(h_ipfilters, i--);
    filternum--;
  }

  return(Plugin_Continue);
}
