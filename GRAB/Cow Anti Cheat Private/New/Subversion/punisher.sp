#define PLUGIN_VERSION "2.3"

#include <sdktools>
#include <cstrike>
#include <smlib/clients>
#undef REQUIRE_PLUGIN
#include <sourcebanspp>
#define REQUIRE_PLUGIN

public Plugin myinfo = 
{
	name = "Punisher",
	author = "Playa (Formerly CodingCow)",
	description = "Customized Anti-Cheat Solution for the ZZK Community",
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

//- ConVars -//

Handle g_hCVar_AutoBhop, g_hCVar_SidemoveCombo, g_hCVar_OptimizerCheck, g_hCVar_PerfectStrafe, g_hCVar_SilentStrafe, g_hCVar_AHK_Check, g_hCVar_MacroCheck, g_hCVar_EdgeJump,  g_hCVar_JumpBug, g_hCVar_AutoShoot, g_hCVar_TriggerBot, g_hCVar_AntiAim, g_hCVar_Prefix;
char g_cPrefix[32];
bool g_bAutoBhop, g_bSidemoveCombo, g_bOptimizerCheck, g_bPerfectStrafe, g_bSilentStrafe, g_bAHK_Check, g_bMacroCheck, g_bEdgeJump, g_bJumpBug, g_bAutoShoot, g_bTriggerBot, g_bAntiAim;

public void OnPluginStart()
{
	//- ConVars -//
	g_hCVar_AutoBhop = CreateConVar("punisher_detect_autobhop", "1.0", "Enable Detection Routine for AutoBhop", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_SidemoveCombo = CreateConVar("punisher_detect_sidemove_combo", "0.0", "Enable Detection Mechanism for Sidemove and Combo Cheats", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_OptimizerCheck = CreateConVar("punisher_detect_optimizers", "0.0", "Enable Detection Mechanism for Optimizers", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_PerfectStrafe = CreateConVar("punisher_detect_perfectstrafe", "1.0", "Enable Detection Mechanism for Perfect Strafes", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_SilentStrafe = CreateConVar("punisher_detect_silentstrafe", "1.0", "Enable Detection Mechanism for Silent Strafes", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_AHK_Check = CreateConVar("punisher_detect_ahk", "0.0", "Enable Detection Mechanism for AutoHotKey", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_MacroCheck = CreateConVar("punisher_detect_macros", "0.0", "Enable Detection Mechanism for Macros", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_EdgeJump = CreateConVar("punisher_detect_edgejump", "1.0", "Enable Detection Mechanism for Edge Jump", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_JumpBug = CreateConVar("punisher_detect_jumpbug", "0.0", "Enable Detection Mechanism for Jump Bugging", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_AutoShoot = CreateConVar("punisher_detect_autoshoot", "0.0", "Enable Detection Mechanism for Auto Shoot", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_TriggerBot = CreateConVar("punisher_detect_triggerbot", "1.0", "Enable Detection Mechanism for Trigger Bots", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	g_hCVar_AntiAim = CreateConVar("punisher_detect_antiaim", "1.0", "Enable Detection Mechanism for Anti Aim", FCVAR_UNLOGGED, true, 0.0, true, 1.0);
	
	g_hCVar_Prefix = CreateConVar("punisher_prefix", "[Punisher]", "The Prefix shown at the start Messages from this Plugins", FCVAR_UNLOGGED, true, 0.0, true, 32.0);
	
	HookConVarChange(g_hCVar_AutoBhop, ConVarChanged_AutoBhop);
	HookConVarChange(g_hCVar_SidemoveCombo, ConVarChanged_SidemoveCombo);
	HookConVarChange(g_hCVar_OptimizerCheck, ConVarChanged_OptimizerCheck);
	HookConVarChange(g_hCVar_PerfectStrafe, ConVarChanged_PerfectStrafe);
	HookConVarChange(g_hCVar_SilentStrafe, ConVarChanged_SilentStrafe);
	HookConVarChange(g_hCVar_AHK_Check, ConVarChanged_AHK_Check);
	HookConVarChange(g_hCVar_MacroCheck, ConVarChanged_MacroCheck);
	HookConVarChange(g_hCVar_EdgeJump, ConVarChanged_EdgeJump);
	HookConVarChange(g_hCVar_JumpBug, ConVarChanged_JumpBug);
	HookConVarChange(g_hCVar_AutoShoot, ConVarChanged_AutoShoot);
	HookConVarChange(g_hCVar_TriggerBot, ConVarChanged_TriggerBot);
	HookConVarChange(g_hCVar_AntiAim, ConVarChanged_AntiAim);
	
	HookConVarChange(g_hCVar_Prefix, ConVarChanged_Prefix);
	
	AutoExecConfig(true, "CowAC"); // Executing after the Hooks so we do trigger an Backend Var Update
	
	CreateTimer(0.05, getSettings, _, TIMER_REPEAT);
	CreateTimer(60.0, resetAntiAim, _, TIMER_REPEAT);
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(Client_IsValid(i))
		{
			SetDefaults(i);
		}
	}
}

//- ConVar Hooks -//

public void ConVarChanged_AutoBhop(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bAutoBhop = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_SidemoveCombo(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bSidemoveCombo = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_OptimizerCheck(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bOptimizerCheck = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_PerfectStrafe(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bPerfectStrafe = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_SilentStrafe(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bSilentStrafe = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_AHK_Check(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bAHK_Check = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_MacroCheck(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bMacroCheck = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_EdgeJump(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bEdgeJump = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_JumpBug(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bJumpBug = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_AutoShoot(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bAutoShoot = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_TriggerBot(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bTriggerBot = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_AntiAim(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	g_bAntiAim = view_as<bool>(StringToInt(cNewValue));
}

public void ConVarChanged_Prefix(Handle hConVar, const char[] cOldValue, const char[] cNewValue)
{
	GetConVarString(hConVar, g_cPrefix, 32);
}


public void OnClientPutInServer(int client)
{
	if(Client_IsValid(client))
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
		if(Client_IsValid(i))
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
	if(Client_IsValid(client))
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
		
		if (g_bAutoBhop)
			if (!g_bAutoBhopEnabled[client])
				CheckBhop(client, buttons);
				
		if (g_bSidemoveCombo)
			SidemoveCombo(client, vel[1], buttons);
			
		if (g_bOptimizerCheck)
			OptimizerCheck(client, angles);
			
		if (g_bPerfectStrafe)
			CheckPerfectStrafe(client, buttons, mouse[0], vel[1]);
			
		if (g_bSilentStrafe)
			CheckSilentStrafe(client, vel[1], vel[0]);
			
		if (g_bAHK_Check)
			CheckAHK(client, mouse[0]);
			
		if (g_bMacroCheck)
			CheckMacro(client, buttons);
			
		if (g_bEdgeJump)
			CheckEdgeJump(client, buttons);
			
		if (g_bJumpBug)
			CheckJumpBug(client, buttons);
			
		if (g_bAutoShoot)
			CheckAutoShoot(client, buttons);
			
		if (g_bTriggerBot)
			CheckTriggerBot(client, buttons, trace);
			
		if (g_bAntiAim)
			CheckAntiAim(client, angles, buttons);
			
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
		PrintToChatAdmins("%s Bhop Cheat Detected (\x04%N\x01) - \x0EBAN", g_cPrefix, client);
		char cBuffer[32];
		Format(cBuffer, 32, "%s Bhop Cheat", g_cPrefix);
		SBPP_BanPlayer(0, client, 0, cBuffer);
		
		g_iPerfectBhopCount[client] = 0;
	}
}

public void SidemoveCombo(int client, float sidemove, int buttons)
{
	if((sidemove > 0 && !(buttons & IN_MOVERIGHT)) || (sidemove < 0 && !(buttons & IN_MOVELEFT)))
	{
		PrintToChatAdmins("%s Invalid Sidemove/Button Combo (\x04%N\x01) - \x0ESuspicion", g_cPrefix, client);
	}
}

public void OptimizerCheck(int client, float angles[3])
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
				PrintToChatAdmins("%s Possible Optimizer \x02(%.2f% Gain\x02) \x01(\x04%N\x01) - \x0ESuspicion", g_cPrefix, g_fAvgGain[client], client);
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
		PrintToChatAdmins("%s Perfect Strafe Detected (\x04%N\x01) - \x0EBAN", g_cPrefix, client);
		char cBuffer[32];
		Format(cBuffer, 32, "%s Perfect Strafe", g_cPrefix);
		SBPP_BanPlayer(0, client, 0, cBuffer);
		
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
		PrintToChatAdmins("%s Silent-Strafe Detected (\x04%N\x01) - \x0EBAN", g_cPrefix, client);
		char cBuffer[32];
		Format(cBuffer, 32, "%s Silent-Strafe", g_cPrefix);
		SBPP_BanPlayer(0, client, 0, cBuffer);
		
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
				PrintToChatAdmins("%s Invalid Mousedx Detected (\x04%N\x01) - \x0ESuspicion", g_cPrefix, client);
				
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
			PrintToChatAdmins("%s Macro Detected (\x04%N\x01) - \x0ESuspicion", g_cPrefix, client);
			
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
				PrintToChatAdmins("%s Edge Jump Detected (\x04%N\x01) - \x0ESuspicion", g_cPrefix, client);
				
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
			PrintToChatAdmins("%s \x04%N \x01JumpBug Suspicion", g_cPrefix, client);
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
		PrintToChatAdmins("%s AutoShoot Detected (\x04%N\x01)", g_cPrefix, client);
		
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
					PrintToChatAdmins("%s Possible Triggerbot/Aimbot Detected (\x04%N\x01) - \x0ESuspicion", g_cPrefix, client);
					
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
		PrintToChatAdmins("%s Triggerbot/Aimbot Detected (\x04%N\x01) - \x0EBAN", g_cPrefix, client);
		char cBuffer[32];
		Format(cBuffer, 32, "%s Triggerbot/Aimbot", g_cPrefix);
		SBPP_BanPlayer(0, client, 0, cBuffer);
		
		g_iTriggerBotCount[client] = 0;
 	}
}

public void CheckAntiAim(int client, float angles[3], int buttons)
{
	/* Fake up/down */
	if(FloatAbs(prev_angles[client][0]) == 89.00 && FloatAbs(NormalizeAngle(angles[0] - prev_angles[client][0])) >= 20.00 && buttons & IN_ATTACK && !(prev_buttons[client] & IN_ATTACK))
		PrintToChatAdmins("%s Fake Up/Down Detected (\x04%N\x01)", g_cPrefix, client);
		
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
			PrintToChatAdmins("%s Anti-Aim Detected (\x04%N\x01) - \x0ESuspicion", g_cPrefix, client);
			
			g_iAntiAim[client] = 0;
			g_iAntiAimCount[client]++;
			
			if(g_iAntiAimCount[client] >= 5)
			{
				//LogPlayerBan(client, "Anti-Aim");
				char cBuffer[32];
				Format(cBuffer, 32, "%s Anti-Aim", g_cPrefix);
				SBPP_BanPlayer(0, client, 0, cBuffer);
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
	if(Client_IsValid(client))
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

//- Stocks -//

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

/*
* Sends an Message to all online Admins
* 
* @param cMessage		The Message to send.
* @param ...			Variable number of format parameters.
*/
PrintToChatAdmins(const char[] cMessage, any ...)
{
	char cBuffer[256];
	VFormat(cBuffer, sizeof(cBuffer), cMessage, 2);
	
	for (int i = 1; i <= MaxClients; i++)
		if (Client_IsValid(i))
			if (CheckCommandAccess(i, "anticheat_print_override", ADMFLAG_GENERIC))
				PrintToChat(i, "%s %s", cBuffer);
}