/*
** ATTENTION
** THE PRODUCED CODE, IS NOT ABLE TO COMPILE!
** THE DECOMPILER JUST TRIES TO GIVE YOU A POSSIBILITY
** TO LOOK HOW A PLUGIN DOES IT'S JOB AND LOOK FOR
** POSSIBLE MALICIOUS CODE.
**
** ALL CONVERSIONS ARE WRONG! AT EXAMPLE:
** SetEntityRenderFx(client, RenderFx 0);  →  SetEntityRenderFx(client, view_as<RenderFx>0);  →  SetEntityRenderFx(client, RENDERFX_NONE);
*/

 PlVers __version = 5;
 float NULL_VECTOR[3];
 char NULL_STRING[1];
 Extension __ext_core = 68;
 int MaxClients;
 Extension __ext_sdktools = 2280;
 SharedPlugin __pl_sourcebanspp = 2324;
public Plugin myinfo =
{
	name = "Anti-Cheat",
	description = "Anti-Cheat Plugin",
	author = "Anonymous",
	version = "1.00",
	url = ""
};
 int prev_buttons[66];
 int g_iCmdNum[66];
 bool g_bTurn[66];
 int g_iPerfectStrafes[66];
 bool g_bOnGround[66];
 int g_iJumpsSent[66];
 int g_iBhop[66];
 bool g_bAutoBhopEnabled[66];
 float prev_sidemove[66];
 int g_iSilentStrafe[66];
 float g_fJumpPos[66];
 int g_iMacro[66];
 int g_iMousedx_Value[66];
 int g_iMousedx_Count[66];
 int g_iAutoHotKey[66];
 int g_iTicksOnPlayer[66];
 int g_iPrev_TicksOnPlayer[66];
 int g_iTriggerBotCount[66];
public void __ext_core_SetNTVOptional()
{
	MarkNativeAsOptional("GetFeatureStatus");
	MarkNativeAsOptional("RequireFeature");
	MarkNativeAsOptional("AddCommandListener");
	MarkNativeAsOptional("RemoveCommandListener");
	MarkNativeAsOptional("BfWriteBool");
	MarkNativeAsOptional("BfWriteByte");
	MarkNativeAsOptional("BfWriteChar");
	MarkNativeAsOptional("BfWriteShort");
	MarkNativeAsOptional("BfWriteWord");
	MarkNativeAsOptional("BfWriteNum");
	MarkNativeAsOptional("BfWriteFloat");
	MarkNativeAsOptional("BfWriteString");
	MarkNativeAsOptional("BfWriteEntity");
	MarkNativeAsOptional("BfWriteAngle");
	MarkNativeAsOptional("BfWriteCoord");
	MarkNativeAsOptional("BfWriteVecCoord");
	MarkNativeAsOptional("BfWriteVecNormal");
	MarkNativeAsOptional("BfWriteAngles");
	MarkNativeAsOptional("BfReadBool");
	MarkNativeAsOptional("BfReadByte");
	MarkNativeAsOptional("BfReadChar");
	MarkNativeAsOptional("BfReadShort");
	MarkNativeAsOptional("BfReadWord");
	MarkNativeAsOptional("BfReadNum");
	MarkNativeAsOptional("BfReadFloat");
	MarkNativeAsOptional("BfReadString");
	MarkNativeAsOptional("BfReadEntity");
	MarkNativeAsOptional("BfReadAngle");
	MarkNativeAsOptional("BfReadCoord");
	MarkNativeAsOptional("BfReadVecCoord");
	MarkNativeAsOptional("BfReadVecNormal");
	MarkNativeAsOptional("BfReadAngles");
	MarkNativeAsOptional("BfGetNumBytesLeft");
	MarkNativeAsOptional("BfWrite.WriteBool");
	MarkNativeAsOptional("BfWrite.WriteByte");
	MarkNativeAsOptional("BfWrite.WriteChar");
	MarkNativeAsOptional("BfWrite.WriteShort");
	MarkNativeAsOptional("BfWrite.WriteWord");
	MarkNativeAsOptional("BfWrite.WriteNum");
	MarkNativeAsOptional("BfWrite.WriteFloat");
	MarkNativeAsOptional("BfWrite.WriteString");
	MarkNativeAsOptional("BfWrite.WriteEntity");
	MarkNativeAsOptional("BfWrite.WriteAngle");
	MarkNativeAsOptional("BfWrite.WriteCoord");
	MarkNativeAsOptional("BfWrite.WriteVecCoord");
	MarkNativeAsOptional("BfWrite.WriteVecNormal");
	MarkNativeAsOptional("BfWrite.WriteAngles");
	MarkNativeAsOptional("BfRead.ReadBool");
	MarkNativeAsOptional("BfRead.ReadByte");
	MarkNativeAsOptional("BfRead.ReadChar");
	MarkNativeAsOptional("BfRead.ReadShort");
	MarkNativeAsOptional("BfRead.ReadWord");
	MarkNativeAsOptional("BfRead.ReadNum");
	MarkNativeAsOptional("BfRead.ReadFloat");
	MarkNativeAsOptional("BfRead.ReadString");
	MarkNativeAsOptional("BfRead.ReadEntity");
	MarkNativeAsOptional("BfRead.ReadAngle");
	MarkNativeAsOptional("BfRead.ReadCoord");
	MarkNativeAsOptional("BfRead.ReadVecCoord");
	MarkNativeAsOptional("BfRead.ReadVecNormal");
	MarkNativeAsOptional("BfRead.ReadAngles");
	MarkNativeAsOptional("BfRead.BytesLeft.get");
	MarkNativeAsOptional("PbReadInt");
	MarkNativeAsOptional("PbReadFloat");
	MarkNativeAsOptional("PbReadBool");
	MarkNativeAsOptional("PbReadString");
	MarkNativeAsOptional("PbReadColor");
	MarkNativeAsOptional("PbReadAngle");
	MarkNativeAsOptional("PbReadVector");
	MarkNativeAsOptional("PbReadVector2D");
	MarkNativeAsOptional("PbGetRepeatedFieldCount");
	MarkNativeAsOptional("PbSetInt");
	MarkNativeAsOptional("PbSetFloat");
	MarkNativeAsOptional("PbSetBool");
	MarkNativeAsOptional("PbSetString");
	MarkNativeAsOptional("PbSetColor");
	MarkNativeAsOptional("PbSetAngle");
	MarkNativeAsOptional("PbSetVector");
	MarkNativeAsOptional("PbSetVector2D");
	MarkNativeAsOptional("PbAddInt");
	MarkNativeAsOptional("PbAddFloat");
	MarkNativeAsOptional("PbAddBool");
	MarkNativeAsOptional("PbAddString");
	MarkNativeAsOptional("PbAddColor");
	MarkNativeAsOptional("PbAddAngle");
	MarkNativeAsOptional("PbAddVector");
	MarkNativeAsOptional("PbAddVector2D");
	MarkNativeAsOptional("PbRemoveRepeatedFieldValue");
	MarkNativeAsOptional("PbReadMessage");
	MarkNativeAsOptional("PbReadRepeatedMessage");
	MarkNativeAsOptional("PbAddMessage");
	MarkNativeAsOptional("Protobuf.ReadInt");
	MarkNativeAsOptional("Protobuf.ReadInt64");
	MarkNativeAsOptional("Protobuf.ReadFloat");
	MarkNativeAsOptional("Protobuf.ReadBool");
	MarkNativeAsOptional("Protobuf.ReadString");
	MarkNativeAsOptional("Protobuf.ReadColor");
	MarkNativeAsOptional("Protobuf.ReadAngle");
	MarkNativeAsOptional("Protobuf.ReadVector");
	MarkNativeAsOptional("Protobuf.ReadVector2D");
	MarkNativeAsOptional("Protobuf.GetRepeatedFieldCount");
	MarkNativeAsOptional("Protobuf.SetInt");
	MarkNativeAsOptional("Protobuf.SetInt64");
	MarkNativeAsOptional("Protobuf.SetFloat");
	MarkNativeAsOptional("Protobuf.SetBool");
	MarkNativeAsOptional("Protobuf.SetString");
	MarkNativeAsOptional("Protobuf.SetColor");
	MarkNativeAsOptional("Protobuf.SetAngle");
	MarkNativeAsOptional("Protobuf.SetVector");
	MarkNativeAsOptional("Protobuf.SetVector2D");
	MarkNativeAsOptional("Protobuf.AddInt");
	MarkNativeAsOptional("Protobuf.AddInt64");
	MarkNativeAsOptional("Protobuf.AddFloat");
	MarkNativeAsOptional("Protobuf.AddBool");
	MarkNativeAsOptional("Protobuf.AddString");
	MarkNativeAsOptional("Protobuf.AddColor");
	MarkNativeAsOptional("Protobuf.AddAngle");
	MarkNativeAsOptional("Protobuf.AddVector");
	MarkNativeAsOptional("Protobuf.AddVector2D");
	MarkNativeAsOptional("Protobuf.RemoveRepeatedFieldValue");
	MarkNativeAsOptional("Protobuf.ReadMessage");
	MarkNativeAsOptional("Protobuf.ReadRepeatedMessage");
	MarkNativeAsOptional("Protobuf.AddMessage");
	VerifyCoreVersion();
	return void 0;
}

public bool StrEqual(char str1[], char str2[], bool caseSensitive)
{
	return strcmp(str1, str2, caseSensitive) == 0;
}

public void OnPluginStart()
{
	CreateTimer(0,05, getSettings, any 0, 1);
	PrintToServer("[Anti-Cheat] Running...");
	return void 0;
}

public void OnClientPutInServer(int client)
{
	prev_buttons[client] = 0;
	g_iCmdNum[client] = 0;
	g_bTurn[client] = 1;
	g_iPerfectStrafes[client] = 0;
	g_bOnGround[client] = 1;
	g_iJumpsSent[client] = 0;
	g_iBhop[client] = 0;
	g_bAutoBhopEnabled[client] = 0;
	prev_sidemove[client] = 0;
	g_iSilentStrafe[client] = 0;
	g_fJumpPos[client] = 0;
	g_iMacro[client] = 0;
	g_iMousedx_Value[client] = 0;
	g_iMousedx_Count[client] = 0;
	g_iAutoHotKey[client] = 0;
	g_iTicksOnPlayer[client] = 0;
	g_iPrev_TicksOnPlayer[client] = 0;
	g_iTriggerBotCount[client] = 0;
	return void 0;
}

public Action getSettings(Handle timer)
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (IsValidClient(i, false, true))
		{
			QueryClientConVar(i, "sv_autobunnyhopping", ConVarQueryFinished 13, i);
			i++;
		}
		i++;
	}
	return Action 0;
}

public void ConVar_QueryClient(QueryCookie cookie, int client, ConVarQueryResult result, char cvarName[], char cvarValue[])
{
	if (IsValidClient(client, false, true))
	{
		if (result)
		{
		}
		else
		{
			if (StrEqual("sv_autobunnyhopping", cvarName, true))
			{
				if (0 < StringToInt(cvarValue, 10))
				{
					g_bAutoBhopEnabled[client] = 1;
				}
				g_bAutoBhopEnabled[client] = 0;
			}
		}
	}
	return void 0;
}

public Action OnPlayerRunCmd(int client, &int buttons, &int impulse, float vel[3], float angles[3], &int weapon, &int subtype, &int cmdnum, &int tickcount, &int seed, int mouse[2])
{
	if (IsValidClient(client, false, false))
	{
		int flags = GetEntityFlags(client);
		if (flags & 1)
		{
			float pos[3];
			GetClientAbsOrigin(client, pos);
			g_fJumpPos[client] = pos[8];
		}
		float vOrigin[3];
		float AnglesVec[3];
		float EndPoint[3];
		float Distance = 1232348144;
		GetClientEyePosition(client, vOrigin);
		GetAngleVectors(angles, AnglesVec, NULL_VECTOR, NULL_VECTOR);
		EndPoint[0] = FloatAdd(vOrigin[0], FloatMul(AnglesVec[0], Distance));
		EndPoint[4] = FloatAdd(vOrigin[4], FloatMul(AnglesVec[4], Distance));
		EndPoint[8] = FloatAdd(vOrigin[8], FloatMul(AnglesVec[8], Distance));
		Handle trace = TR_TraceRayFilterEx(vOrigin, EndPoint, 1174421507, RayType 0, TraceEntityFilter 29, client);
		PerfectStrafe(client, buttons, flags, vel[4], mouse[0]);
		if (!g_bAutoBhopEnabled[client][0][0])
		{
			Bhop(client, buttons, flags);
		}
		SilentStrafe(client, flags, vel[4]);
		Macro(client, buttons, flags);
		AutoHotKey(client, mouse[0]);
		CheckTriggerBot(client, buttons, trace);
		prev_buttons[client] = buttons;
		prev_sidemove[client] = vel[4];
		g_iCmdNum[client]++;
		CloseHandle(trace);
		trace = 0;
	}
	return Action 0;
}

public void PerfectStrafe(int client, int buttons, int flags, float sidemove, int mousedx)
{
	int var1;
	if (!flags & 1)
	{
		int var2;
		if (mousedx > 0)
		{
			int var3;
			if (!prev_buttons[client][0][0] & 1024)
			{
				g_iPerfectStrafes[client]++;
			}
			else
			{
				g_iPerfectStrafes[client] = 0;
			}
			g_bTurn[client] = 0;
		}
		int var4;
		if (mousedx < 0)
		{
			int var5;
			if (!prev_buttons[client][0][0] & 512)
			{
				g_iPerfectStrafes[client]++;
			}
			else
			{
				g_iPerfectStrafes[client] = 0;
			}
			g_bTurn[client] = 1;
		}
	}
	if (g_iPerfectStrafes[client][0][0] >= 16)
	{
		g_iPerfectStrafes[client] = 0;
		AntiCheat_Ban(client, "Strafe Hack");
	}
	return void 0;
}

public void Bhop(int client, int buttons, int flags)
{
	int var1;
	if (!flags & 1)
	{
		g_bOnGround[client] = 0;
		int var2;
		if (!prev_buttons[client][0][0] & 2)
		{
			g_iJumpsSent[client]++;
		}
	}
	else
	{
		int var3;
		if (flags & 1)
		{
			if (g_iJumpsSent[client][0][0] <= 1)
			{
				g_iBhop[client]++;
			}
			g_iJumpsSent[client] = 0;
			g_bOnGround[client] = 1;
			if (g_iBhop[client][0][0] >= 10)
			{
				g_iBhop[client] = 0;
				AntiCheat_Ban(client, "Bhop Assistance");
			}
		}
		g_iBhop[client] = 0;
	}
	return void 0;
}

public void SilentStrafe(int client, int flags, float sidemove)
{
	int var1;
	if (!flags & 1)
	{
		int var2;
		if (__FLOAT_EQ__(450, sidemove))
		{
			g_iSilentStrafe[client]++;
		}
		else
		{
			int var3;
			if (__FLOAT_EQ__(-450, sidemove))
			{
				g_iSilentStrafe[client]++;
			}
			g_iSilentStrafe[client] = 0;
		}
	}
	else
	{
		if (flags & 1)
		{
			g_iSilentStrafe[client] = 0;
		}
	}
	if (g_iSilentStrafe[client][0][0] >= 10)
	{
		g_iSilentStrafe[client] = 0;
		AntiCheat_Ban(client, "Silent Strafe");
	}
	return void 0;
}

public void Macro(int client, int buttons, int flags)
{
	int var1;
	if (!flags & 1)
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);
		int var2;
		if (__FLOAT_GE__(pos[8], g_fJumpPos[client][0][0]))
		{
			g_iMacro[client]++;
		}
	}
	else
	{
		if (flags & 1)
		{
			g_iMacro[client] = 0;
		}
	}
	if (g_iMacro[client][0][0] >= 30)
	{
		char message[128];
		Format(message, 128, "[\x02Anti-Cheat\x01] Possible Macro Detected from \x04%N", client);
		PrintToAdmins(message);
		g_iMacro[client] = 0;
	}
	return void 0;
}

public void AutoHotKey(int client, int mouse)
{
	float vec[3];
	GetClientAbsOrigin(client, vec);
	int var1;
	if (mouse >= 10)
	{
		g_iMousedx_Count[client] = 0;
		g_iAutoHotKey[client]++;
		if (g_iAutoHotKey[client][0][0] >= 10)
		{
			char message[64];
			Format(message, 64, "[\x02Anti-Cheat\x01] Possible AutoHotKey Detected from \x04%N", client);
			PrintToAdmins(message);
			g_iAutoHotKey[client] = 0;
			return void 0;
		}
		return void 0;
	}
	return void 0;
}

public void CheckTriggerBot(int client, int buttons, Handle trace)
{
	if (TR_DidHit(trace))
	{
		int target = TR_GetEntityIndex(trace);
		int var1;
		if (target > 0)
		{
			g_iTicksOnPlayer[client]++;
			int var2;
			if (buttons & 1)
			{
				g_iTriggerBotCount[client]++;
			}
			else
			{
				int var3;
				if (buttons & 1)
				{
					g_iTriggerBotCount[client] = 0;
				}
			}
		}
		else
		{
			if (0 < g_iTicksOnPlayer[client][0][0])
			{
				g_iPrev_TicksOnPlayer[client] = g_iTicksOnPlayer[client][0][0];
			}
			g_iTicksOnPlayer[client] = 0;
		}
	}
	else
	{
		if (0 < g_iTicksOnPlayer[client][0][0])
		{
			g_iPrev_TicksOnPlayer[client] = g_iTicksOnPlayer[client][0][0];
		}
		g_iTicksOnPlayer[client] = 0;
	}
	if (g_iTriggerBotCount[client][0][0] >= 5)
	{
		char message[64];
		Format(message, 64, "[\x02Defender\x01] Triggerbot/Aimbot Detected (\x04%N\x01) - \x14BAN", client);
		PrintToAdmins(message);
		AntiCheat_Ban(client, "Triggerbot/Aimbot");
		g_iTriggerBotCount[client] = 0;
	}
	return void 0;
}

public void AntiCheat_Ban(int client, char reason[])
{
	char message[128];
	Format(message, 128, "[\x02Anti-Cheat\x01] %s", reason);
	SBPP_BanPlayer(0, client, 0, message);
	return void 0;
}

public bool IsValidClient(int client, bool bAllowBots, bool bAllowDead)
{
	int var4 = client;
	int var3;
	if (!var4 <= MaxClients & 1 <= var4)
	{
		return false;
	}
	return true;
}

public bool TraceEntityFilterPlayer(int entity, int mask, any data)
{
	return entity != data;
}

public void PrintToAdmins(char message[])
{
	int i = 1;
	while (i <= MaxClients)
	{
		if (IsValidClient(i, false, true))
		{
			if (CheckCommandAccess(i, "anticheat_print_override", 2, false))
			{
				PrintToChat(i, message);
				i++;
			}
			i++;
		}
		i++;
	}
	return void 0;
}

