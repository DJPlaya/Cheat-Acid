#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "CodingCow"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#undef REQUIRE_PLUGIN
#include <sourcebanspp>

public Plugin myinfo = 
{
	name = "AntiCheat",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

/* Client Variables */
char g_steamid[MAXPLAYERS + 1][32];
float g_Sensitivity[MAXPLAYERS + 1];
float g_mYaw[MAXPLAYERS + 1];
int g_iCmdNum[MAXPLAYERS + 1];
int prev_buttons[MAXPLAYERS + 1];
float prev_sidemove[MAXPLAYERS + 1];
float prev_forwardmove[MAXPLAYERS + 1];
float prev_angles[MAXPLAYERS + 1][3];
float saved_angles[MAXPLAYERS + 1][20];
int i_saved[MAXPLAYERS + 1];
int prev_flags[MAXPLAYERS + 1];
bool g_bTurn[MAXPLAYERS + 1];
float g_fJumpPos[MAXPLAYERS + 1];
int g_iMousedx_Value[MAXPLAYERS + 1];
int g_iMousedx_Count[MAXPLAYERS + 1];
int g_iTicksOnPlayer[MAXPLAYERS + 1];
int g_iPrev_TicksOnPlayer[MAXPLAYERS + 1];
bool g_bFirstShot[MAXPLAYERS + 1];
int g_iLastShotTick[MAXPLAYERS + 1];
bool g_bShootSpam[MAXPLAYERS + 1];
int g_iTicksOnGround[MAXPLAYERS + 1];
int g_iPrev_TicksOnGround[MAXPLAYERS + 1];
bool g_bAutoBhopEnabled[MAXPLAYERS + 1];
float g_fAvgGain[MAXPLAYERS + 1];
int g_iAirTicks[MAXPLAYERS + 1];
bool g_bOnEdge[MAXPLAYERS + 1];

/* Client Detection Variables */
int g_iPerfectBhopCount[MAXPLAYERS + 1];
int g_iPerfectStrafes[MAXPLAYERS + 1];
int g_iSilentStrafes[MAXPLAYERS + 1];
int g_iAHKStrafeDetection[MAXPLAYERS + 1];
int g_iMacroCount[MAXPLAYERS + 1];
int g_iEdgeJumpCount[MAXPLAYERS + 1];
int g_iTriggerBotCount[MAXPLAYERS + 1];
int g_iAutoShoot[MAXPLAYERS + 1];
int g_iAntiAim[MAXPLAYERS + 1];
int g_iAntiAimCount[MAXPLAYERS + 1];

public void OnPluginStart()
{
	CreateTimer(0.05, getSettings, _, TIMER_REPEAT);
	CreateTimer(60.0, resetAntiAim, _, TIMER_REPEAT);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			SetDefaults(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	if(IsValidClient(client))
	{
		SetDefaults(client);
	}
}

public void SetDefaults(int client)
{
	/* Set Defaults */
	//Client Variables
	GetClientAuthId(client, AuthId_Steam2, g_steamid[client], 32);
	g_Sensitivity[client] = 0.0;
	g_mYaw[client] = 0.022;
	g_iCmdNum[client] = 0;
	prev_buttons[client] = 0;
	prev_sidemove[client] = 0.0;
	prev_forwardmove[client] = 0.0;
	prev_flags[client] = 0;
	g_bTurn[client] = true;
	g_fJumpPos[client] = 0.0;
	g_iMousedx_Value[client] = 0;
	g_iMousedx_Count[client] = 0;
	g_iTicksOnPlayer[client] = 0;
	g_iPrev_TicksOnPlayer[client] = 0;
	g_bFirstShot[client] = true;
	g_iLastShotTick[client] = 0;
	g_bShootSpam[client] = false;
	g_iTicksOnGround[client] = 0;
	g_iPrev_TicksOnGround[client] = 0;
	g_bAutoBhopEnabled[client] = false;
	g_fAvgGain[client] = 0.0;
	g_iAirTicks[client] = 0;
	g_bOnEdge[client] = false;
	//Detection Variables
	g_iPerfectBhopCount[client] = 0;
	g_iPerfectStrafes[client] = 0;
	g_iSilentStrafes[client] = 0;
	g_iAHKStrafeDetection[client] = 0;
	g_iMacroCount[client] = 0;
	g_iEdgeJumpCount[client] = 0;
	g_iTriggerBotCount[client] = 0;
	g_iAutoShoot[client] = 0;
	g_iAntiAim[client] = 0;
	g_iAntiAimCount[client] = 0;
	
	for (int i = 0; i < 3; i++)
	{
		prev_angles[client][i] = 0.0;
	}
	
	for (int i = 0; i < 20; i++)
	{
		saved_angles[client][i] = 0.0;
	}
	
	i_saved[client] = 0;
}

public Action getSettings(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			QueryClientConVar(i, "sensitivity", ConVar_QueryClient, i);
			QueryClientConVar(i, "m_yaw", ConVar_QueryClient, i);
			QueryClientConVar(i, "sv_autobunnyhopping", ConVar_QueryClient, i);
		}
	}
}

public Action resetAntiAim(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iAntiAimCount[i] = 0;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(IsValidClient(client, false, false))
	{
		if(prev_flags[client] & FL_ONGROUND && !(GetEntityFlags(client) & FL_ONGROUND))
		{
			float vec[3];
			GetClientAbsOrigin(client, vec);
			
			g_fJumpPos[client] = vec[2];
		}
		
		if(GetEntityFlags(client) & FL_ONGROUND)
		{
			g_iTicksOnGround[client]++;
		}
		else
		{
			g_iTicksOnGround[client] = 0;
		}
		
		float vOrigin[3], AnglesVec[3], EndPoint[3];
	
		float Distance = 999999.0;
		
		GetClientEyePosition(client,vOrigin);
		GetAngleVectors(angles, AnglesVec, NULL_VECTOR, NULL_VECTOR);
		
		EndPoint[0] = vOrigin[0] + (AnglesVec[0]*Distance);
		EndPoint[1] = vOrigin[1] + (AnglesVec[1]*Distance);
		EndPoint[2] = vOrigin[2] + (AnglesVec[2]*Distance);
		
		Handle trace = TR_TraceRayFilterEx(vOrigin, EndPoint, MASK_SHOT, RayType_EndPoint, TraceEntityFilterPlayer, client);
		
		if(!g_bAutoBhopEnabled[client])
		{
			CheckBhop(client, buttons);
		}
		//Invalids(client, vel[1], buttons);
		//CheckGain(client, angles);
		CheckPerfectStrafe(client, buttons, mouse[0], vel[1]);
		CheckSilentStrafe(client, vel[1], vel[0]);
		CheckAHK(client, mouse[0]);
		//CheckMacro(client, buttons);
		CheckEdgeJump(client, buttons);
		//CheckJumpBug(client, buttons);
		//CheckAutoShoot(client, buttons);
		CheckTriggerBot(client, buttons, trace);
		CheckAntiAim(client, angles, buttons);
		//CheckAimbot(client, buttons, )
		
		delete trace;
		
		prev_buttons[client] = buttons;
		prev_sidemove[client] = vel[1];
		prev_forwardmove[client] = vel[0];
		prev_angles[client] = angles;
		prev_flags[client] = GetEntityFlags(client);
		g_iCmdNum[client]++;
	}
}

public void CheckBhop(int client, int buttons)
{
	if((g_iTicksOnGround[client] == 1 || g_iTicksOnGround[client] == g_iPrev_TicksOnGround[client]) && GetEntityFlags(client) & FL_ONGROUND && buttons & IN_JUMP && !(prev_buttons[client] & IN_JUMP))
	{
		g_iPerfectBhopCount[client]++;
		
		g_iPrev_TicksOnGround[client] = g_iTicksOnGround[client];
	}
	else if(g_iTicksOnGround[client] >= g_iPrev_TicksOnGround[client] && GetEntityFlags(client) & FL_ONGROUND)
	{
		g_iPerfectBhopCount[client] = 0;
	}
	
	if(g_iPerfectBhopCount[client] >= 12)
	{
		char message[64];
		Format(message, sizeof(message), "[\x02Anti-Cheat\x01] Bhop Hack Detected (\x04%N\x01) - \x0EBAN", client);
		PrintToAdmins(message);
		
		SBPP_BanPlayer(0, client, 0, "[Anti-Cheat] Bhop Hack Detected");
		
		g_iPerfectBhopCount[client] = 0;
	}
}

public void Invalids(int client, float sidemove, int buttons)
{
	if((sidemove > 0 && !(buttons & IN_MOVERIGHT)) || (sidemove < 0 && !(buttons & IN_MOVELEFT)))
	{
		char message[64];
		Format(message, sizeof(message), "[\x02Anti-Cheat\x01] Invalid Sidemove/Button Combo (\x04%N\x01) - \x0ESuspicion", client);
		PrintToAdmins(message);
		
		//LogPlayer(client, "Invalid Sidemove/Button Combo");
		//DiscordLog(client, "Invalid Sidemove/Button Combo");
	}
}

public void CheckGain(int client, float angles[3])
{
	if(!(GetEntityFlags(client) & FL_ONGROUND))
	{	
		float delta = NormalizeAngle(angles[1] - prev_angles[client][1]);
		
		float vel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
		float speed = SquareRoot(Pow(vel[0],2.0)+Pow(vel[1],2.0));
		
		float PerfAngle = RadToDeg(ArcTangent(30 / speed));
		
		float Percentage = FloatAbs(delta) / PerfAngle;

		g_fAvgGain[client] += Percentage;
		
		g_iAirTicks[client]++;
	}
	else
	{
		if(g_iAirTicks[client] > 0)
		{		
			g_fAvgGain[client] /= g_iAirTicks[client];
			
			if(g_fAvgGain[client] >= 0.8 && g_fAvgGain[client] <= 1.2)
			{
				PrintToChatAll("Possible Optimizer \x02(%.2f% Gain\x02) \x01(\x04%N\x01) - \x0ESuspicion", g_fAvgGain[client], client);
			}
		}
		
		g_iAirTicks[client] = 0;
		g_fAvgGain[client] = 0.0;
	}
}

public void CheckPerfectStrafe(int client, int buttons, int mousedx, float sidemove)
{
	if(!(GetEntityFlags(client) & FL_ONGROUND))
	{
		if (mousedx > 0 && g_bTurn[client])
		{
			if(!(prev_buttons[client] & IN_MOVERIGHT) && buttons & IN_MOVERIGHT && !(buttons & IN_MOVELEFT))
			{
				g_iPerfectStrafes[client]++;
			}
			else
			{
				g_iPerfectStrafes[client] = 0;
			}
			
			g_bTurn[client] = false;
		}
		else if (mousedx < 0 && !g_bTurn[client])
		{
			if(!(prev_buttons[client] & IN_MOVELEFT) && buttons & IN_MOVELEFT && !(buttons & IN_MOVERIGHT))
			{
				g_iPerfectStrafes[client]++;
			}
			else
			{
				g_iPerfectStrafes[client] = 0;
			}
			
			g_bTurn[client] = true;
		}
	}
	
	if(g_iPerfectStrafes[client] >= 16)
	{
		char message[64];
		Format(message, sizeof(message), "[\x02Anti-Cheat\x01] Perfect Strafe Detected (\x04%N\x01) - \x0EBAN", client);
		PrintToAdmins(message);
		
		SBPP_BanPlayer(0, client, 0, "[Anti-Cheat] Perfect Strafe Detected");
		
		g_iPerfectStrafes[client] = 0;
	}
}

public void CheckSilentStrafe(int client, float sidemove, float forwardmove)
{
	if(!(GetEntityFlags(client) & FL_ONGROUND))
	{
		if(((sidemove > 0 && prev_sidemove[client] < 0) || (sidemove < 0 && prev_sidemove[client] > 0)) || ((forwardmove > 0 && prev_forwardmove[client] < 0) || (forwardmove < 0 && prev_forwardmove[client] > 0)))
		{
			g_iSilentStrafes[client]++;
		}
		else
		{
			g_iSilentStrafes[client] = 0;
		}
	}
	
	if(g_iSilentStrafes[client] >= 10)
	{
		char message[64];
		Format(message, sizeof(message), "[\x02Anti-Cheat\x01] Silent-Strafe Detected (\x04%N\x01)  - \x0EBAN", client);
		PrintToAdmins(message);
		
		SBPP_BanPlayer(0, client, 0, "[Anti-Cheat] Silent-Strafe Detected");
		
		g_iSilentStrafes[client] = 0;
	}
}

public void CheckAHK(int client, int mouse)
{
	float vec[3];
	GetClientAbsOrigin(client, vec);
	
	if((mouse >= 10 || mouse <= -10) && g_fJumpPos[client] < vec[2])
	{
		if(mouse == g_iMousedx_Value[client] || mouse == g_iMousedx_Value[client] * -1)
		{
			g_iMousedx_Count[client]++;
		}
		else
		{
			g_iMousedx_Value[client] = mouse;
			g_iMousedx_Count[client] = 0;
		}
		
		if(g_iMousedx_Count[client] >= 16)
		{
			g_iMousedx_Count[client] = 0;
			g_iAHKStrafeDetection[client]++;
			
			if(g_iAHKStrafeDetection[client] >= 10)
			{
				char message[64];
				Format(message, sizeof(message), "[\x02Anti-Cheat\x01] Invalid Mousedx Detected (\x04%N\x01) - \x0ESuspicion", client);
				PrintToAdmins(message);
				
				g_iAHKStrafeDetection[client] = 0;
			}
		}
	}
}

public void CheckMacro(int client, int buttons)
{
	float vec[3];
	GetClientAbsOrigin(client, vec);
	
	if(buttons & IN_JUMP && !(prev_buttons[client] & IN_JUMP) && !(GetEntityFlags(client) & FL_ONGROUND) && !(GetEntityFlags(client) & FL_INWATER) && vec[2] > g_fJumpPos[client])
	{
		g_iMacroCount[client]++;
	}
	else if(GetEntityFlags(client) & FL_ONGROUND)
	{
		if(g_iMacroCount[client] >= 20)
		{
			char message[64];
			Format(message, sizeof(message), "[\x02Anti-Cheat\x01] Macro Detected (\x04%N\x01) - \x0ESuspicion", client);
			PrintToAdmins(message);
		}
			
		g_iMacroCount[client] = 0;
	}
}

float edge_pos[MAXPLAYERS + 1][3];
public void CheckEdgeJump(int client, int buttons)
{
	if(GetEntityMoveType(client) == MOVETYPE_LADDER || GetEntityMoveType(client) == MOVETYPE_NOCLIP)
		return;
	
	if(GetEntityFlags(client) & FL_ONGROUND && g_iTicksOnGround[client] > 20)
	{
		/*float startpos[3], angle[3], endpos[3], direction[3];

		GetClientEyeAngles(client, angle);
		GetClientAbsOrigin(client, startpos);
		
		GetAngleVectors(angle, direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(direction, 250.0);
		AddVectors(startpos, direction, endpos);*/
		
		float start[3], end[3];
		GetClientAbsOrigin(client, start);
		
		end = start;
		
		end[2] -= 32;
		
		Handle trace = TR_TraceRayFilterEx(start, end, MASK_SHOT, RayType_EndPoint, TraceEntityFilterPlayer, client);
		
		if(TR_GetFraction(trace) == 1.0)
		{
			if(!g_bOnEdge[client])
				GetClientAbsOrigin(client, edge_pos[client]);
				
			/*if(!g_bOnEdge[client])
				PrintToChat(client, "Edge");*/
			
			//FOR CHECKING DISTANCE BETWEEN EDGE AND JUMP
			/*if(buttons & IN_JUMP && !(prev_buttons[client] & IN_JUMP))
			{
				float pos[3];
				GetClientAbsOrigin(client, pos);
				
				PrintToChat(client, "Jumped after edge - %.2f units", GetVectorDistance(edge_pos[client], pos));
			}*/
			
			if (buttons & IN_JUMP && !(prev_buttons[client] & IN_JUMP) && !g_bOnEdge[client])
			{
				g_iEdgeJumpCount[client]++;
			}
			
			if(g_iEdgeJumpCount[client] >= 3)
			{
				char message[64];
				Format(message, sizeof(message), "[\x02Anti-Cheat\x01] Edge Jump Detected (\x04%N\x01) - \x0ESuspicion", client);
				PrintToAdmins(message);
				
				g_iEdgeJumpCount[client] = 0;
			}
				
			g_bOnEdge[client] = true;
		}
		else
			g_bOnEdge[client] = false;
		
		delete trace;
	}
}

public void CheckJumpBug(int client, int buttons)
{
	if(GetEntityMoveType(client) == MOVETYPE_LADDER || GetEntityMoveType(client) == MOVETYPE_NOCLIP)
		return;
	
	float localPos[3];
	GetClientAbsOrigin(client, localPos);

	float EndPos[3];
	
	EndPos = localPos;

	EndPos[2] -= 30.0;
	
	Handle trace = TR_TraceRayFilterEx(localPos, EndPos, MASK_SHOT, RayType_EndPoint, TraceEntityFilterPlayer, client);
	
	if(TR_DidHit(trace))
	{
		float end_pos[3];
		TR_GetEndPosition(end_pos, trace);
		
		if(GetVectorDistance(localPos, end_pos) <= 4.0)
		{
			char message[64];
			Format(message, sizeof(message), "[\x02Anti-Cheat\x01] \x04%N \x01JumpBug Suspicion", client);
			PrintToAdmins(message);
		}
	}
	
	delete trace;
}

public void CheckAutoShoot(int client, int buttons)
{
	if(buttons & IN_ATTACK && !(prev_buttons[client] & IN_ATTACK))
	{
		if(g_bFirstShot[client])
		{	
			g_bFirstShot[client] = false;
			
			g_iLastShotTick[client] = g_iCmdNum[client];
		}
		else if(g_iCmdNum[client] - g_iLastShotTick[client] <= 10 && !g_bFirstShot[client])
		{
			g_bShootSpam[client] = true;
			g_iAutoShoot[client]++;
			g_iLastShotTick[client] = g_iCmdNum[client];
		}
		else
		{	
			g_iAutoShoot[client] = 0;
			g_bShootSpam[client] = false;
			g_bFirstShot[client] = true;
		}
	}
	
	if(g_iAutoShoot[client] >= 20)
	{
		char message[64];
		Format(message, sizeof(message), "[\x02Anti-Cheat\x01] AutoShoot Detected (\x04%N\x01)", client);
		PrintToAdmins(message);
		
		g_iAutoShoot[client] = 0;
		g_bShootSpam[client] = false;
		g_bFirstShot[client] = true;
	}
}
public void CheckTriggerBot(int client, int buttons, Handle trace)
{
	if (TR_DidHit(trace))
	{
		int target = TR_GetEntityIndex(trace);
		
		if (target > 0 && target <= MaxClients && GetClientTeam(target) != GetClientTeam(client) && IsPlayerAlive(target) && IsPlayerAlive(client) && !g_bShootSpam[client])
		{
			g_iTicksOnPlayer[client]++;
			
			if(buttons & IN_ATTACK && !(prev_buttons[client] & IN_ATTACK) && g_iTicksOnPlayer[client] <= 2)
			{
				g_iTriggerBotCount[client]++;
			}
			else if(buttons & IN_ATTACK && prev_buttons[client] & IN_ATTACK && g_iTicksOnPlayer[client] == 1)
			{
				if(g_iTriggerBotCount[client] >= 3)
			  	{
			  		char message[64];
					Format(message, sizeof(message), "[\x02Anti-Cheat\x01] Possible Triggerbot/Aimbot Detected (\x04%N\x01) - \x0ESuspicion", client);
					PrintToAdmins(message);
			 	}
				
				g_iTriggerBotCount[client] = 0;
			}
		}
		else
		{
			if(g_iTicksOnPlayer[client] > 0)
				g_iPrev_TicksOnPlayer[client] = g_iTicksOnPlayer[client];
			
			g_iTicksOnPlayer[client] = 0;
		}
	}
	
  	if(g_iTriggerBotCount[client] >= 5)
  	{
  		char message[64];
		Format(message, sizeof(message), "[\x02Anti-Cheat\x01] Triggerbot/Aimbot Detected (\x04%N\x01) - \x0EBAN", client);
		PrintToAdmins(message);
		
		SBPP_BanPlayer(0, client, 0, "[Anti-Cheat] Triggerbot/Aimbot Detected");
  		 	
  		g_iTriggerBotCount[client] = 0;
 	}
}

public void CheckAntiAim(int client, float angles[3], int buttons)
{
	/* Fake up/down */
	if(FloatAbs(prev_angles[client][0]) == 89.00 && FloatAbs(NormalizeAngle(angles[0] - prev_angles[client][0])) >= 20.00 && buttons & IN_ATTACK && !(prev_buttons[client] & IN_ATTACK))
		PrintToChatAll("[\x02Anti-Cheat\x01] Fake Up/Down Detected (\x04%N\x01)", client);
	
	/* Spin and Wiggle */
	float delta = NormalizeAngle(angles[1] - prev_angles[client][1]);
	
	if(FloatAbs(g_Sensitivity[client] * g_mYaw[client]) < 0.8)
	{
		if(FloatAbs(delta) == 90.0 || FloatAbs(delta) == 180.0)
		{
			g_iAntiAim[client]++;
		}
		
		if(g_iAntiAim[client] >= 30)
		{
			char message[64];
			Format(message, sizeof(message), "[\x02Anti-Cheat\x01] Anti-Aim Detected (\x04%N\x01) - \x0ESuspicion", client);
			PrintToAdmins(message);
			
			PrintToChatAll("[\x02Anti-Cheat\x01] Anti-Aim Detected (\x04%N\x01) - \x0ESuspicion", client);
			
			g_iAntiAim[client] = 0;
			g_iAntiAimCount[client]++;
			
			if(g_iAntiAimCount[client] >= 5)
			{
				//LogPlayerBan(client, "Anti-Aim");
			}
		}
		
		if(i_saved[client] >= 19)
		{
			for (int i = 0; i < 20; i++)
			{
				saved_angles[client][i] = 0.0;
			}
			
			i_saved[client] = 0;
		}
		
		saved_angles[client][i_saved[client]] = delta;
		
		if(saved_angles[client][i_saved[client]] >= 90.0 && countOccurrences(client, saved_angles[client][i_saved[client]]) >= 5)
		{
			g_iAntiAim[client]++;
		}
		
		i_saved[client]++;
	}
}

public int countOccurrences(int client, float num)
{
	int count = 0;
	
	for (int i = 0; i < 20; i++)
	{
		if (saved_angles[client][i] == num)
		{
			count++;
		}
	}

	return count;
}

public void ConVar_QueryClient(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(IsValidClient(client))
	{
		if(result == ConVarQuery_Okay)
		{
			if(StrEqual("sensitivity", cvarName))
			{
				g_Sensitivity[client] = StringToFloat(cvarValue);
			}
			else if(StrEqual("m_yaw", cvarName))
			{
				g_mYaw[client] = StringToFloat(cvarValue);
			}
			else if(StrEqual("sv_autobunnyhopping", cvarName))
			{
				if(StringToInt(cvarValue) > 0)
					g_bAutoBhopEnabled[client] = true;
				else
					g_bAutoBhopEnabled[client] = false;
			}
		}
	}      
}

bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}

public float NormalizeAngle(float angle)
{
	float newAngle = angle;
	while (newAngle <= -180.0) newAngle += 360.0;
	while (newAngle > 180.0) newAngle -= 360.0;
	return newAngle;
}

public bool TraceEntityFilterPlayer(int entity, int mask, any data)
{
    return data != entity;
}

public void PrintToAdmins(const char[] message)
{
    for (int i = 1; i <= MaxClients; i++) 
    {
        if (IsValidClient(i))
        {
            if (CheckCommandAccess(i, "anticheat_print_override", ADMFLAG_GENERIC))
            {
                PrintToChat(i, message); 
            }
        }
    }
}