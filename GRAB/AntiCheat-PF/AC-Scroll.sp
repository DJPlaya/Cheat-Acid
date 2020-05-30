#include <sourcemod>
#include <sdktools>
#include <AC-Helper>

#pragma newdecls required
#pragma semicolon 1

#define DESC1 "Scripted jumps (patt0)" // 100% pos, no matter what sp is
#define DESC2 "Scripted jumps (patt1)" // 95%+ pos, no matter what sp is
#define DESC3 "Scripted jumps (patt2)" // 85%+ pos, no matter what sp is
#define DESC4 "Scripted jumps (patt3)" // 80%+ pos, no matter what sp is
#define DESC5 "Scripted jumps (patt4)" // 75%+ pos, inhumanly consistent sp
#define DESC6 "Scripted jumps (patt5)" // 70%+ pos, obvously random sp
#define DESC7 "Scripted jumps (patt6)" // 40%+ pos, no sp before touching ground
#define DESC8 "Scripted jumps (patt7)" // 40%+ pos, no sp after touching ground
#define DESC9 "Scripted jumps (patt8)" // 50%+ pos, same sp before and after touching ground
#define DESC10 "Scroll macro (patt0)" // sp 19+ (hyper scroll or similar)
#define DESC11 "Scroll cheat (patt0)" // ticks between scrolls is perfect
#define DESC12 "Scroll cheat (patt1)" // average ground ticks are inhuman

// Sample size of scrolls it checks to punish.
// Decrease to make anticheat more sensitive.
#define SAMPLE_SIZE_MIN 40
#define SAMPLE_SIZE_MAX 55

// Ammount of ticks between jumps to not count one
#define TICKS_NOT_COUNT_JUMP 8

// Max airtime before we ignore scrolls.
// Stops false detections on surfs and while falling... cough cow cough...
#define TICKS_NOT_COUNT_AIR 105

ConVar g_svAutoBhop = null;

bool g_bAutoBhop = false
	 , g_bPreviousGround[MAXPLAYERS+1] = {true, ...};

int g_iSampleSize = 45
	, g_iGroundTicks[MAXPLAYERS+1]
	, g_iReleaseTick[MAXPLAYERS+1]
	, g_iAirTicks[MAXPLAYERS+1]
	, g_iPreviousButtons[MAXPLAYERS+1]
	, g_iCurrentJump[MAXPLAYERS+1];

ArrayList g_aJumpStats[MAXPLAYERS+1];

public Plugin myinfo = {
	name = "AC Scroll Module",
	author = "hiiamu",
	description = "scroll module for AC",
	version = "0.1.0",
	url = "/id/hiiamu"
}

// enums for jummping checks
enum {
	StatsArray_Scrolls,      //Scrolls before the jump
	StatsArray_BeforeGround, // Scrolls before touching ground (33 units above ground)
	StatsArray_AfterGround,  // Scrolls after touching ground (33 units above ground)
	StatsArray_AverageTicks, // Average ticks between each +jump input
	StatsArray_PerfectJump,  // Did they perf?
	STATSARRAY_SIZE
}

enum {
	State_Nothing,
	State_Landing,
	State_Jumping,
	State_Pressing,
	State_Releasing
}

any g_aStatsArray[MAXPLAYERS+1][STATSARRAY_SIZE];

public void OnPluginStart() {
	g_svAutoBhop = FindConVar("sv_autobunnyhopping");

	if(g_svAutoBhop != null)
		g_svAutoBhop.AddChangeHook(OnAutoBhopChanged);

	for(int i = 1; i <= MaxClients; i++) {
		if(IsClientInGame(i))
			OnClientPutInServer(i);
	}
	RegConsoleCmd("sm_scrolls", Client_PrintScrollStats, "Prints scroll stats for given player.");
}

public void OnMapStart() {
	g_iSampleSize = GetRandomInt(SAMPLE_SIZE_MIN, SAMPLE_SIZE_MAX);
}

public void OnClientPutInServer(int client) {
	g_aJumpStats[client] = new ArrayList(STATSARRAY_SIZE);
	g_iCurrentJump[client] = 0;
	ResetScrollStats(client);
}

public void OnClientDisconnect(int client) {
	delete g_aJumpStats[client];
}

public void OnAutoBhopChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	g_bAutoBhop = view_as<bool>(StringToInt(newValue));
}

public void OnConfigsExecuted() {
	if(g_svAutoBhop != null)
		g_bAutoBhop = g_svAutoBhop.BoolValue;
}

public Action Client_PrintScrollStats(int client, int args) {
	if(args < 1) {
		ReplyToCommand(client, "Proper Formatting: sm_scrolls <target>");
		return Plugin_Handled;
	}

	char[] szArgs = new char[MAX_TARGET_LENGTH];
	GetCmdArgString(szArgs, MAX_TARGET_LENGTH);

	int target = FindTarget(client, szArgs);

	if(target == -1)
		return Plugin_Handled;

	if(GetSamples(target) == 0) {
		ReplyToCommand(client, "%N does not have any scroll stats.", target);
		return Plugin_Handled;
	}

	char[] szScrollStats = new char[300];
	FormatScrolls(target, szScrollStats, 300);

	ReplyToCommand(client, "Scrolls for %N: %s", target, szScrollStats);

	return Plugin_Handled;
}

void FormatScrolls(int client, char[] buffer, int maxlength) {
	FormatEx(buffer, maxlength, "%i%% perfs, %i samples: {", GetPerfs(client), GetSamples(client));

	int iSize = g_aJumpStats[client].Length;
	int iEnd = (iSize >= g_iSampleSize) ? (iSize - g_iSampleSize):0;

	for(int i = iSize - 1; i >= iEnd; i--) {
		//TODO different format for a perf jump rather than no perf
		Format(buffer, maxlength, "%s %i", buffer, g_aJumpStats[client].Get(i, StatsArray_Scrolls));
	}

	int iPos = strlen(buffer) - 1;

	if(buffer[iPos] == ',')
		buffer[iPos] = ' ';

	StrCat(buffer, maxlength, "}");
}

int GetSamples(int client) {
	if(g_aJumpStats[client] == null)
		return 0;

	int iSize = g_aJumpStats[client].Length;
	int iEnd = (iSize >= g_iSampleSize) ? (iSize - g_iSampleSize):0;

	return (iSize - iEnd);
}

int GetPerfs(int client) {
	int iPerfs = 0;
	int iSize = g_aJumpStats[client].Length;
	int iEnd = (iSize >= g_iSampleSize) ? (iSize - g_iSampleSize):0;
	int iJumpCount = (iSize - iEnd);

	for(int i = iSize - 1; i >= iEnd; i--) {
		if(view_as<bool>(g_aJumpStats[client].Get(i, StatsArray_PerfectJump)))
			iPerfs++;
	}

	if(iJumpCount == 0)
		return 0;

	return RoundToZero((float(iPerfs) / iJumpCount) * 100);
}

void ResetScrollStats(int client) {
	for(int i = 0; i < STATSARRAY_SIZE; i++) {
		g_aStatsArray[client][i] = 0;
	}

	g_iReleaseTick[client] = GetGameTickCount();
	g_iAirTicks[client] = 0;
}

public bool TRFilter_NoPlayers(int entity, int mask, any data) {
	return (entity != view_as<int>(data) || (entity < 1 || entity > MaxClients));
}

float GetGroundDistance(int client) {
	if(GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == 0) {
		return 0.0;
	}

	float fPosition[3];
	GetClientAbsOrigin(client, fPosition);
	TR_TraceRayFilter(fPosition, view_as<float>({90.0, 0.0, 0.0}), MASK_PLAYERSOLID, RayType_Infinite, TRFilter_NoPlayers, client);
	float fGroundPosition[3];

	if(TR_DidHit() && TR_GetEndPosition(fGroundPosition)) {
		return GetVectorDistance(fPosition, fGroundPosition);
	}

	return 0.0;
}

public Action OnPlayerRunCmd(int client, int &buttons) {
	if(!IsValidClient(client))
		return Plugin_Continue;
	return SetupMove(client, buttons);
}

Action SetupMove(int client, int buttons) {
	if(g_bAutoBhop)
		return Plugin_Changed;

	bool bTouchingGround = ((GetEntityFlags(client) & FL_ONGROUND) > 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 2);

	if(bTouchingGround)
		g_iGroundTicks[client]++;

	float fAbsVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", fAbsVelocity);

	float fSpeed = (SquareRoot(Pow(fAbsVelocity[0], 2.0) + Pow(fAbsVelocity[1], 2.0)));

	if(fSpeed > 240.0 && IsMoveTypeLeagl(client, false))
		CollectScrollStats(client, bTouchingGround, buttons, fAbsVelocity[2]);

	else
		ResetScrollStats(client);

	g_bPreviousGround[client] = bTouchingGround;
	g_iPreviousButtons[client] = buttons;

	return Plugin_Continue;
}

void CollectScrollStats(int client, bool bTouchingGround, int buttons, float fAbsVelocityZ) {
	int iGroundState = State_Nothing;
	int iButtonState = State_Nothing;

	if(bTouchingGround && !g_bPreviousGround[client])
		iGroundState = State_Landing;

	else if(!bTouchingGround && g_bPreviousGround[client])
		iGroundState = State_Jumping;

	if((buttons & IN_JUMP) > 0 && (g_iPreviousButtons[client] & IN_JUMP) == 0)
		iButtonState = State_Pressing;

	else if((buttons & IN_JUMP) == 0 && (g_iPreviousButtons[client] & IN_JUMP) > 0)
		iButtonState = State_Releasing;

	int iTicks = GetGameTickCount();

	if(iButtonState == State_Pressing) {
		g_aStatsArray[client][StatsArray_Scrolls]++;
		g_aStatsArray[client][StatsArray_AverageTicks] += (iTicks - g_iReleaseTick[client]);

		if(bTouchingGround) {
			if((buttons & IN_JUMP) > 0)
				g_aStatsArray[client][StatsArray_PerfectJump] = !g_bPreviousGround[client];
		}

		else {
			float fDistance = GetGroundDistance(client);

			if(fDistance < 33.0) {
				if(fAbsVelocityZ > 0.0 && g_iCurrentJump[client] > 1) {
					// updating previous jump with StatsArray_AfterGround data.
					int iJump = (g_iCurrentJump[client] - 1);
					int iAfter = g_aJumpStats[client].Get(iJump, StatsArray_AfterGround);
					g_aJumpStats[client].Set(iJump, iAfter + 1, StatsArray_AfterGround);
				}
				else if(fAbsVelocityZ < 0.0)
					g_aStatsArray[client][StatsArray_BeforeGround]++;
			}
		}
	}

	else if(iButtonState == State_Releasing) {
		g_iReleaseTick[client] = iTicks;
	}

	if(!bTouchingGround && g_iAirTicks[client]++ > TICKS_NOT_COUNT_AIR) {
		ResetScrollStats(client);
		return;
	}

	if(iGroundState == State_Landing) {
		int iScrolls = g_aStatsArray[client][StatsArray_Scrolls];

		if(iScrolls == 0) {
			ResetScrollStats(client);
			return;
		}

		if(g_iGroundTicks[client] < TICKS_NOT_COUNT_JUMP) {
			int iJump = g_iCurrentJump[client];
			g_aJumpStats[client].Resize(iJump + 1);

			g_aJumpStats[client].Set(iJump, iScrolls, StatsArray_Scrolls);
			g_aJumpStats[client].Set(iJump, g_aStatsArray[client][StatsArray_BeforeGround], StatsArray_BeforeGround);
			g_aJumpStats[client].Set(iJump, 0, StatsArray_AfterGround);
			g_aJumpStats[client].Set(iJump, (g_aStatsArray[client][StatsArray_AverageTicks] / iScrolls), StatsArray_AverageTicks);
			g_aJumpStats[client].Set(iJump, g_aStatsArray[client][StatsArray_PerfectJump], StatsArray_PerfectJump);

			g_iCurrentJump[client]++;
		}

		g_iGroundTicks[client] = 0;

		ResetScrollStats(client);
	}
	else if(iGroundState == State_Jumping && g_iCurrentJump[client] >= g_iSampleSize)
		AnalyzeStats(client);
}

int Min(int a, int b) {
	return (a < b) ? a:b;
}

int Max(int a, int b) {
	return (a > b) ? a:b;
}

int Abs(int num) {
	return (num < 0) ? -num:num;
}

void AnalyzeStats(int client) {
	int iPerfs = GetPerfs(client);

	// ints for checking...
	int iHypeScroll = 0;
	int iSameScroll = 0;
	int iSimilarScroll = 0;
	int iBadScrolls = 0;
	int iGoodPre = 0;
	int iGoodPost = 0;
	int iSamePrePost = 0;

	for(int i = (g_iCurrentJump[client] - g_iSampleSize); i < g_iCurrentJump[client] - 1; i++) {
		int iCurrentScrolls = g_aJumpStats[client].Get(i, StatsArray_Scrolls);
		int iTicks = g_aJumpStats[client].Get(i, StatsArray_AverageTicks);
		int iPre = g_aJumpStats[client].Get(i, StatsArray_BeforeGround);
		int iPost = g_aJumpStats[client].Get(i, StatsArray_AfterGround);

		if(i != g_iSampleSize - 1) {
			int iNextScrolls = g_aJumpStats[client].Get(i + 1, StatsArray_Scrolls);

			if(iCurrentScrolls == iNextScrolls)
				iSameScroll++;

			if(Abs(Max(iCurrentScrolls, iNextScrolls) - Min(iCurrentScrolls, iNextScrolls)) <= 2)
				iSimilarScroll++;
		}

		if(iCurrentScrolls >= 19)
			iHypeScroll++;

		if(iTicks <= 2)
			iBadScrolls++;

		if(iPre <= 1)
			iGoodPre++;

		if(iPost == iPre)
			iSamePrePost++;
	}

	float fIntervals = (float(iBadScrolls) / g_iSampleSize);

	bool bDetection = true;

	char[] szScrollStats = new char[300];
	FormatScrolls(client, szScrollStats, 300);

	char szCheatInfo[512];
	Format(szCheatInfo, 512, "Perfs- %i | Before Ground- %i | Post Ground- %i | Same Pre/Post- %i | Intervals- %.2f | Pattern array- %s", iPerfs, iGoodPre, iGoodPost, iSamePrePost, fIntervals, szScrollStats);

	//im sorry
	if(iPerfs == 100) {
		AC_Trigger(client, T_DEF, DESC1);
		AC_NotifyDiscord(client, T_DEF, DESC1, szCheatInfo);
	}
	else if(iPerfs >= 95) {
		AC_Trigger(client, T_DEF, DESC2);
		AC_NotifyDiscord(client, T_DEF, DESC2, szCheatInfo);
	}
	else if(iPerfs >= 85) {
		AC_Trigger(client, T_DEF, DESC3);
		AC_NotifyDiscord(client, T_DEF, DESC3, szCheatInfo);
	}
	else if(iPerfs >= 80) {
		AC_Trigger(client, T_DEF, DESC4);
		AC_NotifyDiscord(client, T_DEF, DESC4, szCheatInfo);
	}
	else if(iPerfs >= 75 && (iSameScroll >= 10 || iSimilarScroll >= 15)) {
		AC_Trigger(client, T_DEF, DESC5);
		AC_NotifyDiscord(client, T_DEF, DESC5, szCheatInfo);
	}
	else if(iPerfs >= 70 && iHypeScroll >= 3 && iSameScroll >= 3 && iSimilarScroll >= 7) {
		AC_Trigger(client, T_DEF, DESC6);
		AC_NotifyDiscord(client, T_DEF, DESC6, szCheatInfo);
	}
	else if(iPerfs >= 40 && iGoodPre >= 40) {
		AC_Trigger(client, T_HIGH, DESC7);
		AC_NotifyDiscord(client, T_HIGH, DESC7, szCheatInfo);
	}
	else if(iPerfs >= 40 && iGoodPost >= 40) {
		AC_Trigger(client, T_HIGH, DESC8);
		AC_NotifyDiscord(client, T_HIGH, DESC8, szCheatInfo);
	}
	else if(iPerfs >= 50 && iSamePrePost >= 20) {
		AC_Trigger(client, T_HIGH, DESC9);
		AC_NotifyDiscord(client, T_HIGH, DESC9, szCheatInfo);
	}
	else if(iHypeScroll >= 15) {
		AC_Trigger(client, T_MED, DESC10);
		AC_NotifyDiscord(client, T_MED, DESC10, szCheatInfo);
	}
	else if(fIntervals > 0.5) {
		AC_Trigger(client, T_HIGH, DESC11);
		AC_NotifyDiscord(client, T_HIGH, DESC11, szCheatInfo);
	}
	else if(fIntervals > 1.0) {
		AC_Trigger(client, T_MED, DESC12);
		AC_NotifyDiscord(client, T_MED, DESC12, szCheatInfo);
	}
	else
		bDetection = false;

	if(bDetection) {
		ResetScrollStats(client);
		g_iCurrentJump[client] = 0;
		g_aJumpStats[client].Clear();
	}
}

bool IsValidClient(int client) {
	return (0 < client <= MaxClients && IsClientInGame(client));
}
