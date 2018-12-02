/*  Oryx AC: collects and analyzes statistics to find some cheaters in CS:S, CS:GO, and TF2 bunnyhop.
 *  Copyright (C) 2018  shavit.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

// This module is a complete rewrite, and doesn't work like the simple one written by Rusty.

#include <sourcemod>
#include <sdktools>
#include <oryx>

#undef REQUIRE_PLUGIN
#include <shavit>

#pragma newdecls required
#pragma semicolon 1

// Some features from my old anticheat.
#define DESC1 "Scripted jumps (havg)" // 91%+ perf over sample size
#define DESC2 "Scripted jumps (havgp)" // 87%+ perf, consistent scrolls
#define DESC3 "Scripted jumps (patt1)" // 85%+ perf, very consistent scrolls
#define DESC4 "Scripted jumps (patt2)" // 80%+ perf, inhumanly consistent scrolls
#define DESC5 "Scripted jumps (wpatt1)" // 75%+ perf, inhumanly consistent scrolls
#define DESC6 "Scripted jumps (wpatt2)" // 85%+ perf, obviously randomized scrolls

#define DESC7 "Scripted jumps (nobf)" // 40%+ perf, no scrolls before touching the ground
#define DESC8 "Scripted jumps (bf-af)" // 55%+ perf, same number of scrolls before and after touching the ground
#define DESC9 "Scripted jumps (noaf)" // 40%+ perf, no scrolls after leaving the ground

#define DESC10 "Scroll macro (highn)" // scrolls per jump are 17+, either high perf% (80%+) or consistent scrolls

// ORYX exclusive:
#define DESC11 "Scroll cheat (interval)" // interval between scrolls is consistent (<=2, and is over 3/4 of the jumps)

// TODO: Implement this:
#define DESC12 "Scroll cheat (ticks)" // average ticks on ground are inhuman

// Decrease this to make the scroll anticheat more sensitive.
// Samples will be taken from the last X jumps' data.
// If the number is too high, logs might be cut off due to the scroll patterns being too long.
#define SAMPLE_SIZE_MIN 45
#define SAMPLE_SIZE_MAX 55

// Amount of ticks between jumps to not count one.
#define TICKS_NOT_COUNT_JUMP 8

// Maximum airtime per jump in ticks before we stop measuring. This is to prevent low-gravity style bans and players spamming their scroll wheel while falling to purposely make the anti-cheat ban them.
#define TICKS_NOT_COUNT_AIR 135

// Fill scroll stats array with junk data.
// #define DEBUG_SCROLL 50

public Plugin myinfo = 
{
	name = "ORYX scroll module",
	author = "shavit",
	description = "Advanced bunnyhop script/macro detection.",
	version = ORYX_VERSION,
	url = "https://github.com/shavitush/Oryx-AC"
}

ConVar sv_autobunnyhopping = null;

bool gB_AutoBunnyhopping = false;
bool gB_Shavit = false;

int gI_SampleSize = 50;

enum
{
	StatsArray_Scrolls,
	StatsArray_BeforeGround,
	StatsArray_AfterGround,
	StatsArray_AverageTicks,
	StatsArray_PerfectJump,
	STATSARRAY_SIZE
}

enum
{
	State_Nothing,
	State_Landing,
	State_Jumping,
	State_Pressing,
	State_Releasing
}

// 5 cells:
// Scrolls before this jump.
// Scrolls before touching ground (33 units from ground).
// Scrolls after leaving ground (33 units from ground).
// Average ticks between each scroll input.
// Is it a perfect jump?
ArrayList gA_JumpStats[MAXPLAYERS+1];
any gA_StatsArray[MAXPLAYERS+1][STATSARRAY_SIZE];

int gI_GroundTicks[MAXPLAYERS+1];
int gI_ReleaseTick[MAXPLAYERS+1];
int gI_AirTicks[MAXPLAYERS+1];

bool gB_PreviousGround[MAXPLAYERS+1] = { true, ... }; // Initialized as trues to prevent the first data being wrong.
int gI_PreviousButtons[MAXPLAYERS+1];
int gI_CurrentJump[MAXPLAYERS+1];

char gS_LogPath[PLATFORM_MAX_PATH];

public void OnPluginStart()
{
	sv_autobunnyhopping = FindConVar("sv_autobunnyhopping");

	if(sv_autobunnyhopping != null)
	{
		sv_autobunnyhopping.AddChangeHook(OnAutoBunnyhoppingChanged);
	}

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}

	RegConsoleCmd("scroll_stats", Command_PrintScrollStats, "Print the scroll stat buffer for a given player.");

	LoadTranslations("common.phrases");

	gB_Shavit = LibraryExists("shavit");
	
	BuildPath(Path_SM, gS_LogPath, PLATFORM_MAX_PATH, "logs/oryx-ac-scroll.log"); 
}

public void OnMapStart()
{
	gI_SampleSize = GetRandomInt(SAMPLE_SIZE_MIN, SAMPLE_SIZE_MAX);
}

public void OnClientPutInServer(int client)
{
	gA_JumpStats[client] = new ArrayList(STATSARRAY_SIZE);
	gI_CurrentJump[client] = 0;
	ResetStatsArray(client);

	#if defined DEBUG_SCROLL
	gA_JumpStats[client].Resize(DEBUG_SCROLL);

	for(int i = 0; i < DEBUG_SCROLL; i++)
	{
		int scrolls = GetRandomInt(7, 15);
		int before = GetRandomInt(0, scrolls);
		int after = scrolls - before;

		gA_JumpStats[client].Set(i, scrolls, StatsArray_Scrolls);
		gA_JumpStats[client].Set(i, before, StatsArray_BeforeGround);
		gA_JumpStats[client].Set(i, after, StatsArray_AfterGround);
		gA_JumpStats[client].Set(i, GetRandomInt(1, 2), StatsArray_AverageTicks);
	}
	#endif
}

public void OnClientDisconnect(int client)
{
	delete gA_JumpStats[client];
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "shavit"))
	{
		gB_Shavit = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if(StrEqual(name, "shavit"))
	{
		gB_Shavit = false;
	}
}

public void OnAutoBunnyhoppingChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	gB_AutoBunnyhopping = view_as<bool>(StringToInt(newValue));
}

public void OnConfigsExecuted()
{
	if(sv_autobunnyhopping != null)
	{
		gB_AutoBunnyhopping = sv_autobunnyhopping.BoolValue;
	}
}

public Action Command_PrintScrollStats(int client, int args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "Usage: scroll_stats <target>");

		return Plugin_Handled;
	}
	
	char[] sArgs = new char[MAX_TARGET_LENGTH];
	GetCmdArgString(sArgs, MAX_TARGET_LENGTH);

	int target = FindTarget(client, sArgs);

	if(target == -1)
	{
		return Plugin_Handled;
	}

	if(GetSampledJumps(target) == 0)
	{
		ReplyToCommand(client, "\x03%N\x01 does not have recorded jump stats.", target);

		return Plugin_Handled;
	}

	char[] sScrollStats = new char[300];
	GetScrollStatsFormatted(target, sScrollStats, 300);

	ReplyToCommand(client, "Scroll stats for %N: %s", target, sScrollStats);

	return Plugin_Handled;
}

void GetScrollStatsFormatted(int client, char[] buffer, int maxlength)
{
	FormatEx(buffer, maxlength, "%d%% perfs, %d sampled jumps: {", GetPerfectJumps(client), GetSampledJumps(client));

	int iSize = gA_JumpStats[client].Length;
	int iEnd = (iSize >= gI_SampleSize)? (iSize - gI_SampleSize):0;

	for(int i = iSize - 1; i >= iEnd; i--)
	{
		Format(buffer, maxlength, "%s %d,", buffer, gA_JumpStats[client].Get(i, StatsArray_Scrolls));
	}

	// Beautify the text output so that the jumps are separated inside the curly braces, without irrelevant commas.
	int iPos = strlen(buffer) - 1;

	if(buffer[iPos] == ',')
	{
		buffer[iPos] = ' ';
	}

	StrCat(buffer, maxlength, "}");
}

int GetSampledJumps(int client)
{
	if(gA_JumpStats[client] == null)
	{
		return 0;
	}

	int iSize = gA_JumpStats[client].Length;
	int iEnd = (iSize >= gI_SampleSize)? (iSize - gI_SampleSize):0;

	return (iSize - iEnd);
}

int GetPerfectJumps(int client)
{
	int iPerfs = 0;
	int iSize = gA_JumpStats[client].Length;
	int iEnd = (iSize >= gI_SampleSize)? (iSize - gI_SampleSize):0;
	int iTotalJumps = (iSize - iEnd);

	for(int i = iSize - 1; i >= iEnd; i--)
	{
		if(view_as<bool>(gA_JumpStats[client].Get(i, StatsArray_PerfectJump)))
		{
			iPerfs++;
		}
	}

	if(iTotalJumps == 0) // Don't throw a divide-by-zero error.
	{
		return 0;
	}

	return RoundToZero((float(iPerfs) / iTotalJumps) * 100);
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if(gB_Shavit || !IsPlayerAlive(client) || IsFakeClient(client))
	{
		return Plugin_Continue;
	}

	return SetupMove(client, buttons);
}

public Action Shavit_OnUserCmdPre(int client, int &buttons, int &impulse, float vel[3], float angles[3], TimerStatus status, int track, int style, any stylesettings[STYLESETTINGS_SIZE])
{
	// Ignore autobhop styles.
	if(stylesettings[bAutobhop])
	{
		return Plugin_Continue;
	}

	return SetupMove(client, buttons);
}

void ResetStatsArray(int client)
{
	for(int i = 0; i < STATSARRAY_SIZE; i++)
	{
		gA_StatsArray[client][i] = 0;
	}

	gI_ReleaseTick[client] = GetGameTickCount();
	gI_AirTicks[client] = 0;
}

public bool TRFilter_NoPlayers(int entity, int mask, any data)
{
	return (entity != view_as<int>(data) || (entity < 1 || entity > MaxClients));
}

float GetGroundDistance(int client)
{
	if(GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == 0)
	{
		return 0.0;
	}

	float fPosition[3];
	GetClientAbsOrigin(client, fPosition);
	TR_TraceRayFilter(fPosition, view_as<float>({90.0, 0.0, 0.0}), MASK_PLAYERSOLID, RayType_Infinite, TRFilter_NoPlayers, client);

	float fGroundPosition[3];

	if(TR_DidHit() && TR_GetEndPosition(fGroundPosition))
	{
		return GetVectorDistance(fPosition, fGroundPosition);
	}

	return 0.0;
}

Action SetupMove(int client, int buttons)
{
	if((sv_autobunnyhopping != null && gB_AutoBunnyhopping) || Oryx_CanBypass(client))
	{
		return Plugin_Continue;
	}

	bool bOnGround = ((GetEntityFlags(client) & FL_ONGROUND) > 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 2);

	if(bOnGround)
	{
		gI_GroundTicks[client]++;
	}

	float fAbsVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);

	float fSpeed = (SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0)));

	// Player isn't really playing but is just trying to make the anticheat go nuts.
	if(fSpeed > 225.0 && IsLegalMoveType(client, false))
	{
		CollectJumpStats(client, bOnGround, buttons, fAbsVelocity[2]);
	}

	else
	{
		ResetStatsArray(client);
	}

	gB_PreviousGround[client] = bOnGround;
	gI_PreviousButtons[client] = buttons;

	return Plugin_Continue;
}

void CollectJumpStats(int client, bool bOnGround, int buttons, float fAbsVelocityZ)
{
	// States
	int iGroundState = State_Nothing;
	int iButtonState = State_Nothing;

	if(bOnGround && !gB_PreviousGround[client])
	{
		iGroundState = State_Landing;
	}

	else if(!bOnGround && gB_PreviousGround[client])
	{
		iGroundState = State_Jumping;
	}

	if((buttons & IN_JUMP) > 0 && (gI_PreviousButtons[client] & IN_JUMP) == 0)
	{
		iButtonState = State_Pressing;
	}

	else if((buttons & IN_JUMP) == 0 && (gI_PreviousButtons[client] & IN_JUMP) > 0)
	{
		iButtonState = State_Releasing;
	}

	int iTicks = GetGameTickCount();

	if(iButtonState == State_Pressing)
	{
		gA_StatsArray[client][StatsArray_Scrolls]++;
		gA_StatsArray[client][StatsArray_AverageTicks] += (iTicks - gI_ReleaseTick[client]);
		
		if(bOnGround)
		{
			if((buttons & IN_JUMP) > 0)
			{
				gA_StatsArray[client][StatsArray_PerfectJump] = !gB_PreviousGround[client];
			}
		}

		else
		{
			float fDistance = GetGroundDistance(client);

			if(fDistance < 33.0)
			{
				if(fAbsVelocityZ > 0.0 && gI_CurrentJump[client] > 1)
				{
					// 'Inject' data into the previous recorded jump.
					int iJump = (gI_CurrentJump[client] - 1);
					int iAfter = gA_JumpStats[client].Get(iJump, StatsArray_AfterGround);
					gA_JumpStats[client].Set(iJump, iAfter + 1, StatsArray_AfterGround);
				}

				else if(fAbsVelocityZ < 0.0)
				{
					gA_StatsArray[client][StatsArray_BeforeGround]++;
				}
			}
		}
	}

	else if(iButtonState == State_Releasing)
	{
		gI_ReleaseTick[client] = iTicks;
	}

	if(!bOnGround && gI_AirTicks[client]++ > TICKS_NOT_COUNT_AIR)
	{
		ResetStatsArray(client);

		return;
	}

	if(iGroundState == State_Landing)
	{
		int iScrolls = gA_StatsArray[client][StatsArray_Scrolls];

		if(iScrolls == 0)
		{
			ResetStatsArray(client);

			return;
		}

		if(gI_GroundTicks[client] < TICKS_NOT_COUNT_JUMP)
		{
			int iJump = gI_CurrentJump[client];
			gA_JumpStats[client].Resize(iJump + 1);

			gA_JumpStats[client].Set(iJump, iScrolls, StatsArray_Scrolls);
			gA_JumpStats[client].Set(iJump, gA_StatsArray[client][StatsArray_BeforeGround], StatsArray_BeforeGround);
			gA_JumpStats[client].Set(iJump, 0, StatsArray_AfterGround);
			gA_JumpStats[client].Set(iJump, (gA_StatsArray[client][StatsArray_AverageTicks] / iScrolls), StatsArray_AverageTicks);
			gA_JumpStats[client].Set(iJump, gA_StatsArray[client][StatsArray_PerfectJump], StatsArray_PerfectJump);

			#if defined DEBUG
			PrintToChat(client, "{ %d, %d, %d, %d, %d, %d }", gA_StatsArray[client][StatsArray_Scrolls],
				gA_StatsArray[client][StatsArray_BeforeGround],
				(iJump > 0)? gA_JumpStats[client].Get(iJump - 1, gA_StatsArray[client][StatsArray_AfterGround]):0,
				gA_StatsArray[client][StatsArray_GroundTicks],
				(gA_StatsArray[client][StatsArray_AverageTicks] / iScrolls),
				gA_StatsArray[client][StatsArray_PerfectJump]);
			#endif

			gI_CurrentJump[client]++;
		}

		gI_GroundTicks[client] = 0;
		
		ResetStatsArray(client);
	}

	else if(iGroundState == State_Jumping && gI_CurrentJump[client] >= gI_SampleSize)
	{
		AnalyzeStats(client);
	}
}

int Min(int a, int b)
{
	return (a < b)? a:b;
}

int Max(int a, int b)
{
	return (a > b)? a:b;
}

int Abs(int num)
{
	return (num < 0)? -num:num;
}

void AnalyzeStats(int client)
{
	int iPerfs = GetPerfectJumps(client);

	// "Pattern analysis"
	int iVeryHighNumber = 0;
	int iSameAsNext = 0;
	int iCloseToNext = 0;
	int iBadIntervals = 0;
	int iLowBefores = 0;
	int iLowAfters = 0;
	int iSameBeforeAfter = 0;

	for(int i = (gI_CurrentJump[client] - gI_SampleSize); i < gI_CurrentJump[client] - 1; i++)
	{
		// TODO: Cache iNextScrolls for the next time this code is ran. I'm tired and can't really think right now..
		int iCurrentScrolls = gA_JumpStats[client].Get(i, StatsArray_Scrolls);
		int iTicks = gA_JumpStats[client].Get(i, StatsArray_AverageTicks);
		int iBefores = gA_JumpStats[client].Get(i, StatsArray_BeforeGround);
		int iAfters = gA_JumpStats[client].Get(i, StatsArray_AfterGround);

		if(i != gI_SampleSize - 1)
		{
			int iNextScrolls = gA_JumpStats[client].Get(i + 1, StatsArray_Scrolls);

			if(iCurrentScrolls == iNextScrolls)
			{
				iSameAsNext++;
			}

			if(Abs(Max(iCurrentScrolls, iNextScrolls) - Min(iCurrentScrolls, iNextScrolls)) <= 2)
			{
				iCloseToNext++;
			}
		}

		if(iCurrentScrolls >= 17)
		{
			iVeryHighNumber++;
		}

		if(iTicks <= 2)
		{
			iBadIntervals++;
		}

		if(iBefores <= 1)
		{
			iLowBefores++;
		}

		if(iAfters <= 1)
		{
			iLowAfters++;
		}

		if(iBefores == iAfters)
		{
			iSameBeforeAfter++;
		}
	}

	float fIntervals = (float(iBadIntervals) / gI_SampleSize);

	bool bTriggered = true;

	char[] sScrollStats = new char[300];
	GetScrollStatsFormatted(client, sScrollStats, 300);

	// Ugly code below, I know.
	if(iPerfs >= 91)
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC1 ... "): %s", client, sScrollStats);
		Oryx_Trigger(client, TRIGGER_DEFINITIVE, DESC1);
	}

	else if(iPerfs >= 87 && (iSameAsNext >= 13 || iCloseToNext >= 18))
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC2 ... "): %s", client, sScrollStats);
		Oryx_Trigger(client, TRIGGER_DEFINITIVE, DESC2);
	}

	else if(iPerfs >= 85 && iSameAsNext >= 13)
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC3 ... "): %s", client, sScrollStats);
		Oryx_Trigger(client, TRIGGER_DEFINITIVE, DESC3);
	}

	else if(iPerfs >= 80 && iSameAsNext >= 15)
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC4 ... "): %s", client, sScrollStats);
		Oryx_Trigger(client, TRIGGER_HIGH, DESC4);
	}

	else if(iPerfs >= 75 && iVeryHighNumber >= 4 && iSameAsNext >= 3 && iCloseToNext >= 10)
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC5 ... "): %s", client, sScrollStats);
		Oryx_Trigger(client, TRIGGER_HIGH, DESC5);
	}

	else if(iPerfs >= 85 && iCloseToNext >= 16)
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC6 ... "): %s", client, sScrollStats);
		Oryx_Trigger(client, TRIGGER_HIGH, DESC6);
	}

	else if(iPerfs >= 40 && iLowBefores >= 45)
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC7 ... ") (%d): %s", client, iLowBefores, sScrollStats);
		Oryx_Trigger(client, TRIGGER_MEDIUM, DESC7);
	}

	else if(iPerfs >= 55 && iSameBeforeAfter >= 25)
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC8 ... ") (bf %d | af %d | bfaf %d): %s", client, iLowBefores, iLowAfters, iSameBeforeAfter, sScrollStats);
		Oryx_Trigger(client, TRIGGER_HIGH_NOKICK, DESC8);
	}

	else if(iPerfs >= 40 && iLowAfters >= 45)
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC9 ... ") (%d): %s", client, iLowAfters, sScrollStats);
		Oryx_Trigger(client, TRIGGER_LOW, DESC9);
	}

	else if(iVeryHighNumber >= 15 && (iCloseToNext >= 13 || iPerfs >= 80))
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC10 ... "): %s", client, sScrollStats);
		Oryx_Trigger(client, TRIGGER_HIGH, DESC10);
	}

	else if(fIntervals > 0.75)
	{
		LogToFileEx(gS_LogPath, "%L - (" ... DESC11 ... ", intervals: %.2f): %s", client, fIntervals, sScrollStats);
		Oryx_Trigger(client, TRIGGER_MEDIUM, DESC11);
	}

	else
	{
		bTriggered = false;
	}

	if(bTriggered)
	{
		// Hard reset stats after logging, to prevent spam.
		ResetStatsArray(client);
		gI_CurrentJump[client] = 0;
		gA_JumpStats[client].Clear();
	}
}
