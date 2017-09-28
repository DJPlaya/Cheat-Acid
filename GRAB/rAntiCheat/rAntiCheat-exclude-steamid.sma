#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <colorchat>
#include <engine>

#pragma tabsize 0

/*
IDEA CENTER:
*******************************
***** TIME FOR CLEANING!! *****
*******************************

| root -|
		|-  Bhop  	-|
					 |- Look at how jwj works, even jumps or uneven jumps, or both, if both, you can't detect em, but they should be even.
		|-	Gstrafe	 |
					 |- Same here as the one above on Bhop. dwd scripts.

stock LogPlayer(id, szFmt[], any: ...)
{
	new iFile;
	if ((iFile = fopen(g_szLogFile, "a")))
	{
		new szTime[22], szName[MAX_NAME_LENGTH], szAuthID[32], szIP[32], szMessage[256];
		
		get_time("%m/%d/%Y - %H:%M:%S", szTime, charsmax(szTime));
		get_user_name(id, szName, MAX_NAME_LENGTH - 1);
		get_user_authid(id, szAuthID, charsmax(szAuthID));
		get_user_ip(id, szIP, charsmax(szIP), 1);
		
		vformat(szMessage, charsmax(szMessage), szFmt, 3);
		
		fprintf(iFile, "L %s: %s<%s><%s> %s^n", szTime, szName, szAuthID, szIP, szMessage);
		fclose(iFile);
	}
}
*/
/*
0 for alpha (status)
1 for beta (status)
2 for release candidate
3 for (final) release

r = Release
rc = Release Candidate ( meaning possible release version )
a = alpha
b = beta
*/

#define PLUGIN 	"rAntiCheat"
#define VERSION "1.5"
#define AUTHOR 	"Ranarrr"

#define magicmovevar 0.704		// 0.707106812

new g_CheckCvar[][] = {
    "fps_max","fps_modem","fps_override","cl_sidespeed","sv_cheats","cl_pitchspeed",
    "cl_forwardspeed","cl_backspeed","cl_yawspeed","developer","cl_filterstuffcmd"
};

new g_DefaultCvar[][] = {
    "fps_max 99.5","fps_modem 0","fps_override 0","cl_sidespeed 400",
    "cl_forwardspeed 400","cl_backspeed 400","cl_yawspeed 210","developer 0","cl_pitchspeed 225"
};

new bStrafeOn[33], bPluginPause, bBanned[33];

new Float:m_mx[33], Float:m_yaw[33], Float:m_oldyaw[33], Float:m_oldmx[33];

// For logging a player
new isbeinglogged[33], timetolog[33];

// Detection vars
new helperdetbuttons[33], helperdet[33], scriptdet[33], newstrdet[33], advhelperdet[33], filterstrdet[33]
, strafedetside[33], strafedetforward[33], perfbhopdet1[33], perfbhopdet2[33][2], scriptdet2[33], newstr2det[33];

// bhop variables
new Float:perfbhoppercent[33];
new numbhops[33], numbhops100[33];
// JWJ variables
new NoJumpFrames[33], JWJJumps[33];
// ---------------

// JumpBug detection
new bWouldTakeDMG[33], JumpTiming[33][2], DuckTiming[33][2], Float:flHadChance[33];
new Float:averagefps[33];
new averagefpsnum[33];
new Float:FPSToAverage[33][32];
new Float:DistToAvg[33][32];
// ----------------------------

// Movement
new Float:flForwardMove[33], Float:flSideMove[33];
new Float:flOldForwardmove[33], Float:flOldSideMove[33];
// --------------

// Exclude steamid
new Array:authIDs;
new txtlen, bShouldExclude;
// -------------------

// FPS
new Float:UserFPS[33], Float:AVGFPS[33][2];
// -------------------------

public plugin_init() {
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_forward( FM_CmdStart, "Player_CmdStart" );
	register_forward( FM_PlayerPreThink, "Player_PreThink" );
	register_forward( FM_PlayerPostThink, "Player_PostThink" );
	
	bPluginPause = false;
	bShouldExclude = true;
	
	authIDs = ArrayCreate( 32, 1 );
	//native read_file(const file[],line,text[],len,&txtlen);
	if( file_exists( "ex-SteamID" ) ) {
		new increment = 0;
		new stringtopush[32];
		while( !read_file( "ex-SteamID", increment++, stringtopush, charsmax( stringtopush ), txtlen ) ) {
			ArrayPushString(authIDs, stringtopush);
		}
	} else {
		bShouldExclude = false;
	}
	
	register_clcmd( "rRP", "startrecord", ADMIN_BAN, "Record player movement (sidemove, forwardmove, keys, duck and jump)" );
	register_clcmd( "rSRP", "stoprecord", ADMIN_BAN, "Stops recording specific player." );
	
	RegisterHam( Ham_Spawn, "player", "player_spawn", 1 );
	RegisterHam( Ham_Killed, "player", "player_spawn", 1 );
	
	set_task( 1.0, "check_cvars", 0, "", 0, "b" );
	set_task( 10.0, "bugfix", 0, "", 0, "d" );
return;
}

public Player_PreThink( id ) {
	if( !is_user_alive( id ) || pev( id, pev_flags ) & FL_FROZEN || pev( id, pev_maxspeed ) < 210.0 || pev( id, pev_maxspeed ) > 260 || ( get_user_team( id ) != 1 && get_user_team( id ) != 2 )
	|| is_user_bot( id ) || bBanned[id] )
		return;
		
	if( bShouldExclude ) {
		new SteamID[32], excludeSteamID[32];
		get_user_authid( id, SteamID, charsmax( SteamID ) );
		for(new i = 0; i < ArraySize( authIDs ); i++ ) {
		ArrayGetString( authIDs, i, excludeSteamID, charsmax( excludeSteamID ) );
			if( strcmp( SteamID, excludeSteamID ) == 0 ) {
				return;
			}
		}
	}
	
	static buttons, oldbuttons[33], flags, oldflags[33];
	buttons = pev( id, pev_button );
	flags = pev( id, pev_flags );
	
	static Float:flClientOldSpeed[33];
	new Float:angles[3], Float:oldangles[3];
	pev( id, pev_angles, angles );
	m_yaw[id] = angles[1];
	
	m_mx[id] = m_yaw[id] - m_oldyaw[id];
	
	if( m_yaw[id] > 0 ) {
		m_mx[id] -= m_mx[id] * 2;
	}
	
	// -1 == left, 1 == right
	if( m_oldyaw[id] < 0 && m_yaw[id] > 0 && m_oldyaw[id] < -170 ) {
		m_mx[id] = 1.0;
	}
	if(m_oldyaw[id] > 0 && m_yaw[id] < 0 && m_oldyaw[id] > 170 ) {
		m_mx[id] = -1.0;
	}
	
	if( m_mx[id] == m_oldmx[id] && ( flForwardMove[id] != 0 && flSideMove[id] != 0 ) )
		bStrafeOn[id] = true;
	else if( m_mx[id] != m_oldmx[id] && ( flForwardMove[id] != 0 && flSideMove[id] != 0 ) )
		bStrafeOn[id] = false;
	
	new Float:flSpeed[3];
	pev( id, pev_velocity, flSpeed );
	
	// Detecting jumpbug hack
	// Some credit: NumB
	if( DuckTiming[id][0] != 1 ) {
		if( oldbuttons[id] & IN_DUCK && !( buttons & IN_DUCK ) ) {
			DuckTiming[id][1] = -1;
			DuckTiming[id][0] = 1;
		}
	}
	if( DuckTiming[id][0] )
		++DuckTiming[id][1];
	if( buttons & IN_DUCK )
		DuckTiming[id][0] = -1;
	
	// ----------------
	
	if( JumpTiming[id][0] != 1 ) {
		if( !( oldbuttons[id] & IN_JUMP ) && buttons & IN_JUMP ) {
			JumpTiming[id][1] = -1;
			JumpTiming[id][0] = 1;
		}
	}
	
	if( JumpTiming[id][0] )
		++JumpTiming[id][1];
	if( !( buttons & IN_JUMP ) )
		JumpTiming[id][0] = -1;
	
	// ----------------
	
	if( flSpeed[2] <= -500.0 ) {
		bWouldTakeDMG[id] = true;
		
		if( pev( id, pev_flags ) & FL_DUCKING ) {
			static Float:flOrigin[3], Float:flOrigin2[3], Float:flUserOrigin[3];
			pev( id, pev_origin, flOrigin );
			flUserOrigin = flOrigin;
			
			flHadChance[0] = ( 36.0 - 2.0 + 0.03125 ); //36.03125;
			flOrigin2 = flOrigin;
			flOrigin2[2] -= ( flHadChance[0] * 2.0 );
			engfunc( EngFunc_TraceLine, flOrigin, flOrigin2, DONT_IGNORE_MONSTERS, id, 0 );
			flOrigin2[2] += flHadChance[0];
			get_tr2( 0, TR_flFraction, flUserOrigin[0] );
			if( flUserOrigin[0] <= 0.5 ) {
				get_tr2( 0, TR_vecEndPos, flOrigin );
				flOrigin[0] = ( flOrigin[2] - flOrigin2[2] );
				flOrigin[1] = ( flOrigin2[2] - flOrigin[2] );
				
				if( flOrigin[0] <= ( 2.0 - 0.03125 ) && flOrigin[0] >= 0.0 ) {
					flHadChance[id] = flOrigin[0];
					flHadChance[0] = ( flSpeed[2] * -1.0 );
				} else if( flOrigin[1] <= 0.03125 && flOrigin[1] >= 0.0 ) {
					flHadChance[id] = flOrigin[1];
					flHadChance[0] = ( flSpeed[2] * -1.0 );
				}
			}
			
			if( flHadChance[id] == 0.0 ) {
				if( flUserOrigin[0] != 1.0 ) {
					get_tr2( 0, TR_vecEndPos, flOrigin );
				}
			}
		}
		
		flHadChance[0] = flClientOldSpeed[id] = ( flSpeed[2] * -1.0 );
		
	} else {
		flHadChance[0] = flClientOldSpeed[id];
		flClientOldSpeed[id] = 0.0;
		
		if( bWouldTakeDMG[id] )
		{
			if( DuckTiming[id][0] && DuckTiming[id][1] )
				--DuckTiming[id][1];
			else
				DuckTiming[id][0] = 0;
			
			if( JumpTiming[id][0] && JumpTiming[id][1] )
				--JumpTiming[id][1];
			else
				JumpTiming[id][0] = 0;
		}
		
		bWouldTakeDMG[id] = false;
		flHadChance[id] = 0.0;
		
		DuckTiming[id][1] = 0;
		JumpTiming[id][1] = 0;
		
		DuckTiming[id][0] = 0;
		JumpTiming[id][0] = 0;
	}
	// ----------------------------------
	
	flSpeed[2] = 0.0;
	
	// Bhop detection by perfect bhops
	if( pev( id, pev_movetype ) != MOVETYPE_FLY ) {
		static groundframe[33];
		
		if( flags & FL_ONGROUND )
			++groundframe[id];
		else
			groundframe[id] = 0;
		
		if( groundframe[id] <= 5 && groundframe[id] > 0 && buttons & IN_JUMP && ~oldbuttons[id] & IN_JUMP )
			++numbhops[id];
		
		if( ~oldflags[id] & FL_ONGROUND & flags & FL_ONGROUND && ~oldbuttons[id] & IN_JUMP && buttons & IN_JUMP && vector_length( flSpeed ) < ( pev( id, pev_maxspeed ) * 1.2 ) ) {
			++perfbhopdet1[id];
			perfbhoppercent[id] = ( ( float( perfbhopdet1[id] ) / float( numbhops[id] ) ) * 100.0 );
			
			if( numbhops[id] > 99 ) {
				++numbhops100[id];
				if( perfbhoppercent[id] > 72.0 ) {
					new name[32], SteamID[32], IPaddr[32];
					get_user_name( id, name, charsmax( name ) );
					get_user_authid( id, SteamID, charsmax( SteamID ) );
					get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
					
					log_to_file( "rAntiCheat.log", "Bhop hack (#0001) detected on player %s, IP: %s, SteamID: %s, numbhops: %d, perfpercent: %f, numbhops100: %d", name, IPaddr, SteamID, numbhops[id], perfbhoppercent[id], numbhops100[id] );
					
					bBanned[id] = true;
					
					server_cmd( "amx_mban #%d 1440 ^"[^x03rAnti-Cheat^x01] Bhop hack (#0001) detected!^"", get_user_userid( id ) );
				}
				
				perfbhoppercent[id] = 0.0;
				perfbhopdet1[id] = 0;
				numbhops[id] = 0;
			}
		}
		
		if( vector_length( flSpeed ) >= ( pev( id, pev_maxspeed ) * 1.2 ) && groundframe[id] == 3 && buttons & IN_JUMP ) {
			++perfbhopdet1[id];
			perfbhoppercent[id] = ( ( float( perfbhopdet1[id] ) / float( numbhops[id] ) ) * 100.0 );
			
			if( ( ++perfbhopdet2[id][0] % 15 ) == 0 ) {
				if( ++perfbhopdet2[id][1] >= 3 ) {
					new name[32], SteamID[32], IPaddr[32];
					get_user_name( id, name, charsmax( name ) );
					get_user_authid( id, SteamID, charsmax( SteamID ) );
					get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
				
					log_to_file( "rAntiCheat.log", "Bhop hack (#0004) detected on player %s, IP: %s, SteamID: %s, numbhops: %d, perfpercent: %f, numbhops100: %d", name, IPaddr, SteamID, numbhops[id], perfbhoppercent[id], numbhops100[id] );
					
					isbeinglogged[id] = true;
					timetolog[id] = 5000;
					
					//bBanned[id] = true;
					
					//server_cmd( "amx_mban #%d 1440 ^"[^x03rAnti-Cheat^x01] Bhop hack (#0004) detected!^"", get_user_userid( id ) );
				}
			}
			
			if( numbhops[id] > 99 ) {
				++numbhops100[id];
				if( perfbhoppercent[id] > 72.0 ) {
					new name[32], SteamID[32], IPaddr[32];
					get_user_name( id, name, charsmax( name ) );
					get_user_authid( id, SteamID, charsmax( SteamID ) );
					get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
				
					log_to_file( "rAntiCheat.log", "Bhop hack (#0002) detected on player %s, IP: %s, SteamID: %s, numbhops: %d, perfpercent: %f, numbhops100: %d", name, IPaddr, SteamID, numbhops[id], perfbhoppercent[id], numbhops100[id] );
					
					bBanned[id] = true;
					
					server_cmd( "amx_mban #%d 1440 ^"[^x03rAnti-Cheat^x01] Bhop hack (#0002) detected!^"", get_user_userid( id ) );
				}
				
				perfbhoppercent[id] = 0.0;
				perfbhopdet1[id] = 0;
				numbhops[id] = 0;
			}
		} else {
			perfbhopdet2[id][0] = 0;
		}
	}
	// ----------------------------
	
	// HPP bhop hack detect
	/*static lastjump[33], bhophppdet[33];
	
	if( ~buttons & IN_JUMP && ~oldbuttons[id] & IN_JUMP )
		++lastjump[id];
	
	if( buttons & IN_JUMP && ~oldbuttons[id] & IN_JUMP && lastjump[id] >= 4 ) {
		lastjump[id] = 0;
		
		if( distance_to_ground( id ) <= 6 ) {
			if( ++bhophppdet[id] > 10 ) {
				bhophppdet[id] = 0;
				
				new name[32], SteamID[32], IPaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_authid( id, SteamID, charsmax( SteamID ) );
				get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
				
				log_to_file( "rAntiCheat.log", "Bhop hack (#0005) detected on player %s, IP: %s, SteamID: %s", name, IPaddr, SteamID );
				
				bBanned[id] = true;
				
				//ColorChat( 0, NORMAL, "[^x03rAnti-Cheat^x01] Bhop hack (#0005) detected on player %s!", name )
				
				//server_cmd( "amx_mban #%d 1440 ^"[^x03rAnti-Cheat^x01] Bhop hack (#0005) detected!^"", get_user_userid( id ) );
			}
		} else
			bhophppdet[id] = 0;
	}*/
	// --------------------------
	
	// Bhop detection by jwj / true wait false wait true bhop hacks
	if( buttons & IN_JUMP && ~oldbuttons[id] & IN_JUMP ) {
		NoJumpFrames[id] = 0;
		
		++JWJJumps[id];
		
		if( JWJJumps[id] >= 30 ) {
			new name[32], SteamID[32], IPaddr[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_authid( id, SteamID, charsmax( SteamID ) );
			get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
			
			log_to_file( "rAntiCheat.log", "Bhop hack (#0003) detected on player %s, IP: %s, SteamID: %s", name, IPaddr, SteamID );
			
			isbeinglogged[id] = true;
			timetolog[id] = 5000;
			
			//bBanned[id] = true;
			JWJJumps[id] = 0;
			
			//server_cmd( "amx_mban #%d 1440 ^"[^x03rAnti-Cheat^x01] Bhop hack (#0003) detected!^"", get_user_userid( id ) );
		}
	} else {
		++NoJumpFrames[id];
		
		if( NoJumpFrames[id] >= 5 ) {
			JWJJumps[id] = 0;
		}
	}
	// ------------------------------------
	
	// Strafe script detect no movement on pitch axis
	if( ( buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT || buttons & IN_FORWARD || buttons & IN_BACK ) && ~flags & FL_ONGROUND && pev( id, pev_movetype ) != MOVETYPE_FLY ) {
		if( ( m_mx[id] >= 2.0 || m_mx[id] <= -2.0 ) && angles[0] - oldangles[0] == 0.0 ) {
			if( scriptdet2[id] > 15 ) {
				client_cmd( id, "-left" );
				client_cmd( id, "-right" );
			}
			
			if( ++scriptdet2[id] >= 50 ) {
				new name[32], SteamID[32], IPaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_authid( id, SteamID, charsmax( SteamID ) );
				get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
				
				log_to_file( "rAntiCheat.log", "Strafe script (#0002) detected on player %s, IP: %s, SteamID: %s", name, IPaddr, SteamID );
				
				bBanned[id] = true;
				
				server_cmd( "amx_mban #%d 120 ^"[^x03rAnti-Cheat^x01] Strafe script (#0002) detected!^"", get_user_userid( id ) );
				
				scriptdet2[id] = 0;
			}
		} else
			scriptdet2[id] = 0;
	}
	// ------------------------------------------------
	
	oldangles[0] = angles[0];
	oldangles[1] = angles[1];
	oldflags[id] = flags;
	oldbuttons[id] = buttons;
}

public Player_PostThink( id ) {
	if( !is_user_alive( id ) || pev( id, pev_flags ) & FL_FROZEN || pev( id, pev_maxspeed ) < 210.0 || pev( id, pev_maxspeed ) > 260 || ( get_user_team( id ) != 1 && get_user_team( id ) != 2 )
	|| is_user_bot( id ) || bPluginPause || bBanned[id] )
		return;
	
	if( bShouldExclude ) {
		new SteamID[32], excludeSteamID[32];
		get_user_authid( id, SteamID, charsmax( SteamID ) );
		for(new i = 0; i < ArraySize( authIDs ); i++ ) {
		ArrayGetString( authIDs, i, excludeSteamID, charsmax( excludeSteamID ) );
			if( strcmp( SteamID, excludeSteamID ) == 0 ) {
				return;
			}
		}
	}
	
	/*&& pev( id, pev_button ) & IN_DUCK*/ /*|| pev( id, pev_movetype ) & ( MOVETYPE_FLY | MOVETYPE_NOCLIP )*/ 
	
	static buttons, oldbuttons[33];
	buttons = pev( id, pev_button );
	
	static Float:MovementSqroot;
	MovementSqroot = floatsqroot( flForwardMove[id] * flForwardMove[id] + flSideMove[id] * flSideMove[id] );
	
	// Check FPS
	static fpsdet[33];
	
	if( UserFPS[id] > 101.0 || UserFPS[id] <= 19.89 ) {
		if( ++fpsdet[id] >= 100 ) {
			new name[32], SteamID[32], IPaddr[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_authid( id, SteamID, charsmax( SteamID ) );
			get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
			
			fpsdet[id] = 0;
			
			log_to_file( "rAntiCheat.log", "FPS %f detected on player %s, IP: %s, SteamID: %s", UserFPS[id], name, IPaddr, SteamID );
			
			bBanned[id] = true;
			
			server_cmd( "amx_mban #%d 120 ^"[^x03rAnti-Cheat^x01] FPS %.2f detected!^"", get_user_userid( id ), UserFPS[id] );
		}
	} else
		fpsdet[id] = 0;
	// ---------------------
	
	static Float:fSpeed[3];
	pev( id, pev_velocity, fSpeed );
	
	if( UserFPS[id] > 48.0 && UserFPS[id] < 101.0 ) {
		AVGFPS[id][0] += UserFPS[id];
		++AVGFPS[id][1];
	}
	
	// JB detection
	if( bWouldTakeDMG[id] ) {
		if( distance_to_ground( id ) < ( fSpeed[2] / -10.0 ) ) {	
			averagefps[id] += UserFPS[id];
			FPSToAverage[id][averagefpsnum[id]] = UserFPS[id];
			DistToAvg[id][averagefpsnum[id]] = distance_to_ground( id );
			++averagefpsnum[id];
		}
	} else if( !bWouldTakeDMG[id] && averagefpsnum[id] ) {
		averagefpsnum[id] = 0;
		averagefps[id] = 0.0;
		for( new i = 0; i < averagefpsnum[id]; ++i ) {
			FPSToAverage[id][i] = 0.0;
			DistToAvg[id][i] = 0.0;
		}
	}
	
	if( bWouldTakeDMG[id] && !( oldbuttons[id] & IN_JUMP ) && buttons & IN_JUMP ) {
		JumpTiming[id][1] = 0;
		
		if( oldbuttons[id] & IN_DUCK && !DuckTiming[id][1] ) {
			if( !( pev( id, pev_flags ) & FL_DUCKING ) ) {
				if( fSpeed[2] > 200.0 ) {
					// made jb
					static Float:avgfps1[33], Float:avgfps2[33];
					avgfps1[id] = ( averagefps[id] / averagefpsnum[id] );
					avgfps2[id] = ( AVGFPS[id][0] / AVGFPS[id][1] );
					
					if( avgfps1[id] > 101.6 && averagefpsnum[id] > 1 ) {
						new name[32], tempname[32], SteamID[32], IPaddr[32];
						get_user_name( id, name, charsmax( name ) );
						get_user_authid( id, SteamID, charsmax( SteamID ) );
						get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
						
						copy( tempname, charsmax( tempname ), name );
						strcat( tempname, "-JB.log", sizeof( tempname ) );
						log_to_file( tempname, "Client: %s, %s, %s^n", name, IPaddr, SteamID );
						for( new i = 0; i < averagefpsnum[id]; ++i ) {
							log_to_file( tempname, "FPS %i: %f, %f", i + 1, FPSToAverage[id][i], DistToAvg[id][i] );
						}
						
						log_to_file( "rAntiCheat.log", "JumpBug hack (#0001) detected on player %s, IP: %s, SteamID: %s", name, IPaddr, SteamID );
						
						bBanned[id] = true;
						
						server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] JumpBug hack (#0001) detected!^"", get_user_userid( id ) );
						
					} else if( avgfps1[id] < avgfps2[id] - 3.5 && averagefpsnum[id] > 1 ) {
						new name[32], tempname[32], SteamID[32], IPaddr[32];
						get_user_name( id, name, charsmax( name ) );
						get_user_authid( id, SteamID, charsmax( SteamID ) );
						get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
						
						copy( tempname, charsmax( tempname ), name );
						strcat( tempname, "-JB.log", sizeof( tempname ) );
						log_to_file( tempname, "Client: %s, %s, %s^n", name, IPaddr, SteamID );
						for( new i = 0; i < averagefpsnum[id]; ++i ) {
							log_to_file( tempname, "FPS %i: %f, %f", i + 1, FPSToAverage[id][i], DistToAvg[id][i] );
						}
						
						log_to_file( "rAntiCheat.log", "JumpBug hack (#0002) detected on player %s, IP: %s, SteamID: %s", name, IPaddr, SteamID );
						
						bBanned[id] = true;
						
						server_cmd( "amx_mban #%d 300 ^"[^x03rAnti-Cheat^x01] JumpBug hack (#0002) detected!^"", get_user_userid( id ) );
					}
				}
			}
		}
	}
	
	// -------------------
	
	fSpeed[2] = 0.0;
	static value3 = 10;
	
	if( !bStrafeOn[id] ) {
		/*
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		- Strafe helper detector by button checking. idea, no time.
		- This works by checking if button presses are active when movement is active, if not, ban.
		- If you want to bypass this, just do cmd->buttons |= IN_BUTTON, whenever the correct movement is active.
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		*/
		if ( flSideMove[id] >= ( ( pev( id, pev_maxspeed ) ) * magicmovevar ) && !( buttons & IN_MOVERIGHT ) && vector_length( fSpeed ) > 0 ) {
			client_cmd( id, "+mlook" );
			if( ++helperdetbuttons[id] >= value3 ) {
				new name[32], SteamID[32], IPaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_authid( id, SteamID, charsmax( SteamID ) );
				get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
			
				log_to_file( "rAntiCheat.log", "Strafe helper (#0001) detected on player %s, SteamID: %s, IP: %s, sidemove: %f, forwardmove: %f", name, SteamID, IPaddr, flSideMove[id], flForwardMove[id] );
												
				bBanned[id] = true;
			
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper detected (#0001)^"", get_user_userid( id ) );
				
				helperdetbuttons[id] = 0;
			}
		} else if( flSideMove[id] <= -( ( pev( id, pev_maxspeed ) ) * magicmovevar ) && !( buttons & IN_MOVELEFT ) && vector_length( fSpeed ) > 0 ) {
			client_cmd( id, "+mlook" );
			if( ++helperdetbuttons[id] >= value3 ) {
				new name[32], SteamID[32], IPaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_authid( id, SteamID, charsmax( SteamID ) );
				get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
			
				log_to_file( "rAntiCheat.log", "Strafe helper (#0002) detected on player %s, SteamID: %s, IP: %s, sidemove: %f, forwardmove: %f", name, SteamID, IPaddr, flSideMove[id], flForwardMove[id] );
												
				bBanned[id] = true;
			
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper detected (#0002)^"", get_user_userid( id ) );
				
				helperdetbuttons[id] = 0;
			}
		}
		
		if ( flForwardMove[id] >= ( ( pev( id, pev_maxspeed ) ) * magicmovevar ) && ~buttons & IN_FORWARD && vector_length( fSpeed ) > 0 ) {
			client_cmd( id, "+mlook" );
			if( ++helperdetbuttons[id] >= value3 ) {
				new name[32], SteamID[32], IPaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_authid( id, SteamID, charsmax( SteamID ) );
				get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
			
				log_to_file( "rAntiCheat.log", "Strafe helper (#0003) detected on player %s, SteamID: %s, IP: %s, sidemove: %f, forwardmove: %f", name, SteamID, IPaddr, flSideMove[id], flForwardMove[id] );
												
				bBanned[id] = true;
			
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper detected (#0003)^"", get_user_userid( id ) );
				
				helperdetbuttons[id] = 0;
			}
		} else if( flForwardMove[id] <= -( ( pev( id, pev_maxspeed ) ) * magicmovevar ) && ~buttons & IN_BACK && vector_length( fSpeed ) > 0 ) {
			client_cmd( id, "+mlook" );
			if( ++helperdetbuttons[id] >= value3 ) {
				new name[32], SteamID[32], IPaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_authid( id, SteamID, charsmax( SteamID ) );
				get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
			
				log_to_file( "rAntiCheat.log", "Strafe helper (#0004) detected on player %s, SteamID: %s, IP: %s, sidemove: %f, forwardmove: %f", name, SteamID, IPaddr, flSideMove[id], flForwardMove[id] );
												
				bBanned[id] = true;
			
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper detected (#0004)^"", get_user_userid( id ) );
				
				helperdetbuttons[id] = 0;
			}
		}
		/*
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		*/
		
		/*
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		- Simple strafe helper detector
		- Just the most simple strafe helper detector. idea, no time.
		- This checks limits. You can never have > maxspeed.
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		*/
		if( vector_length( fSpeed ) > 264.0 ) {
			if( MovementSqroot > ( pev( id, pev_maxspeed ) ) || ( MovementSqroot < ( pev( id, pev_maxspeed ) * 0.51 && MovementSqroot != 0.0 ) ) || flForwardMove[id] > ( pev( id, pev_maxspeed ) )
			|| flSideMove[id] > ( pev( id, pev_maxspeed ) ) || flForwardMove[id] < -( pev( id, pev_maxspeed ) )	|| flSideMove[id] < -( pev( id, pev_maxspeed ) ) ) {
				if( ++helperdet[id] >= value3 ) {
					new name[32], SteamID[32], IPaddr[32];
					get_user_name( id, name, charsmax( name ) );
					get_user_authid( id, SteamID, charsmax( SteamID ) );
					get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
				
					log_to_file( "rAntiCheat.log", "Strafe helper (#0009) detected on player %s, SteamID: %s, IP: %s", name, SteamID, IPaddr );
					
					bBanned[id] = true;
					
					server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0009) detected^"", get_user_userid( id ) );
					
					helperdet[id] = 0;
				}
			}
		}
		/*
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		*/
	} else {
		helperdet[id] = 0;
		helperdetbuttons[id] = 0;
	}
	
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	- Advanced strafe helper idea, no time.
	- This works by checking if you are fully pressing one button, you can't be having any other movement.
	- So if you press fully D the sidemove is equal to 250.0, thus you can't have any forwardmove.
	- Simple fix, don't send any other movement while the other movement is fully active.
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	if( flSideMove[id] == ( pev( id, pev_maxspeed ) ) && flForwardMove[id] != 0 ) {
		if( ++advhelperdet[id] >= value3 ) {
			new name[32], SteamID[32], IPaddr[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_authid( id, SteamID, charsmax( SteamID ) );
			get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
		
			log_to_file( "rAntiCheat.log", "Strafe helper (#0005) detected on player %s, SteamID: %s, IP: %s, sidemove: %f, forwardmove: %f", name, SteamID, IPaddr, flSideMove[id], flForwardMove[id] );
			
			bBanned[id] = true;
			
			server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper detected (#0005)^"", get_user_userid( id ) );
		
			advhelperdet[id] = 0;
		}
	} else if( flSideMove[id] == -( pev( id, pev_maxspeed ) ) && flForwardMove[id] != 0 ) {
		if( ++advhelperdet[id] >= value3 ) {
			new name[32], SteamID[32], IPaddr[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_authid( id, SteamID, charsmax( SteamID ) );
			get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
		
			log_to_file( "rAntiCheat.log", "Strafe helper (#0006) detected on player %s, SteamID: %s, IP: %s, sidemove: %f, forwardmove: %f", name, SteamID, IPaddr, flSideMove[id], flForwardMove[id] );
			
			bBanned[id] = true;
			
			server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper detected (#0006)^"", get_user_userid( id ) );
		
			advhelperdet[id] = 0;
		}
	}
	
	if( flForwardMove[id] == ( pev( id, pev_maxspeed ) ) && flSideMove[id] != 0 ) {
		if( ++advhelperdet[id] >= value3 ) {
			new name[32], SteamID[32], IPaddr[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_authid( id, SteamID, charsmax( SteamID ) );
			get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
		
			log_to_file( "rAntiCheat.log", "Strafe helper (#0007) detected on player %s, SteamID: %s, IP: %s, sidemove: %f, forwardmove: %f", name, SteamID, IPaddr, flSideMove[id], flForwardMove[id] );
			
			bBanned[id] = true;
			
			server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper detected (#0007)^"", get_user_userid( id ) );
		
			advhelperdet[id] = 0;
		}
	} else if( flForwardMove[id] == -( pev( id, pev_maxspeed ) ) && flSideMove[id] != 0) {
		if( ++advhelperdet[id] >= value3 ) {
			new name[32], SteamID[32], IPaddr[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_authid( id, SteamID, charsmax( SteamID ) );
			get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
		
			log_to_file( "rAntiCheat.log", "Strafe helper (#0008) detected on player %s, SteamID: %s, IP: %s, sidemove: %f, forwardmove: %f", name, SteamID, IPaddr, flSideMove[id], flForwardMove[id] );
			
			bBanned[id] = true;
			
			server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper detected (#0008)^"", get_user_userid( id ) );
		
			advhelperdet[id] = 0;
		}
	}
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	
	
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	- Simple logging function, for "recording" a players movement, including jump and ducks.
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	if( isbeinglogged[id] ) {
		static bOnce[33], filename[32], numberofloggedmoves[33];
		
		if( !bOnce[id] ) {
			new name[32], ipaddr[32], steamid[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_authid( id, steamid, charsmax( steamid ) );
			get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
			
			new tempname[32];
			
			copy( tempname, sizeof( tempname ), name );
			
			replace_all( name, charsmax( name ), "#", "" );
			replace_all( name, charsmax( name ), "+", "" );
			
			copy( filename, sizeof( filename ), name );
			strcat( filename, ".log", sizeof( filename ) );
			
			log_to_file( filename, "Client: %s, IP: %s, SteamID: %s^n", tempname, ipaddr, steamid );
			
			bOnce[id] = true;
		}
		
		if( numberofloggedmoves[id] > timetolog[id] ) {
			isbeinglogged[id] = false;
			numberofloggedmoves[id] = 0;
			timetolog[id] = 0;
		}
		
		log_to_file( filename, "sdmv: %.0f ^t fwmv: %.0f ^t %s %s %s %s ^t %s ^t %s %.2f ^t %.2f"
		, flSideMove[id], flForwardMove[id], buttons & IN_FORWARD ? "W" : "-", buttons & IN_MOVELEFT ? "A" : "-", buttons & IN_BACK ? "S" : "-"
		, buttons & IN_MOVERIGHT ? "D" : "-", buttons & IN_DUCK ? "DUCK" : "----", buttons & IN_JUMP ? "JUMP" : "----", distance_to_ground( id ), vector_length( fSpeed ) );
		
		++numberofloggedmoves[id];
	}
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	
	
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	- Checks instant button press in other strafing direction.
	- Will log player when it detects something suspicious
	
		( P.S This might be buggy, cause it sometimes detect just really good players. ( better to be safe than sorry ) )
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	static strafeundetside[33], strafeundetforward[33], value = 4, value2 = 15; // 4 15
	
	if( !( pev( id, pev_flags ) & FL_ONGROUND ) && !isbeinglogged[id] ) {
		if( m_mx[id] > 0 ) { // move to the right
			if( flSideMove[id] > 0 && flOldSideMove[id] < 0 ) {
				if( ++strafedetside[id] > value2 ) {
					new name[32], SteamID[32], IPaddr[32];
					get_user_name( id, name, charsmax( name ) );
					get_user_authid( id, SteamID, charsmax( SteamID ) );
					get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
			
					log_to_file( "rAntiCheat.log", "Strafe helper (#0010) (CHECK LOGS) detected on player %s, SteamID: %s, IP: %s", name, SteamID, IPaddr );
					
					isbeinglogged[id] = true;
					timetolog[id] = 1999;
					
					strafedetside[id] = 0;
				}
			}
			
			if( flSideMove[id] == 0 ) {
				if( ++strafeundetside[id] >= value ) {
					strafedetside[id] = 0;
					strafeundetside[id] = 0;
				}
			}
			
			if( flForwardMove[id] > 0 && flOldForwardmove[id] < 0 ) {
				if( ++strafedetforward[id] > value2 ) {
					new name[32], SteamID[32], IPaddr[32];
					get_user_name( id, name, charsmax( name ) );
					get_user_authid( id, SteamID, charsmax( SteamID ) );
					get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
			
					log_to_file( "rAntiCheat.log", "Strafe helper (#0011) (CHECK LOGS) detected on player %s, SteamID: %s, IP: %s", name, SteamID, IPaddr );
					
					isbeinglogged[id] = true;
					timetolog[id] = 1999;
					
					strafedetforward[id] = 0;
				}
			}
			
			if( flForwardMove[id] == 0 ) {
				if( ++strafeundetforward[id] > value ) {
					strafedetforward[id] = 0;
					strafeundetforward[id] = 0;
				}
			}
		} else if( m_mx[id] < 0 ){ // move to the left
			if( flSideMove[id] < 0 && flOldSideMove[id] > 0 ) {
				if( ++strafedetside[id] > value2 ) {
					new name[32], SteamID[32], IPaddr[32];
					get_user_name( id, name, charsmax( name ) );
					get_user_authid( id, SteamID, charsmax( SteamID ) );
					get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
			
					log_to_file( "rAntiCheat.log", "Strafe helper (#0012) (CHECK LOGS) detected on player %s, SteamID: %s, IP: %s", name, SteamID, IPaddr );
					
					isbeinglogged[id] = true;
					timetolog[id] = 1999;
					
					strafedetside[id] = 0;
				}
			}
			
			if( flSideMove[id] == 0 ) {
				if( ++strafeundetside[id] > value ) {
					strafedetside[id] = 0;
					strafeundetside[id] = 0;
				}
			}
			
			if( flForwardMove[id] < 0 && flOldForwardmove[id] > 0 ) {
				if( ++strafedetforward[id] > value2 ) {
					new name[32], SteamID[32], IPaddr[32];
					get_user_name( id, name, charsmax( name ) );
					get_user_authid( id, SteamID, charsmax( SteamID ) );
					get_user_ip( id, IPaddr, charsmax( IPaddr ), 1 );
			
					log_to_file( "rAntiCheat.log", "Strafe helper (#0013) (CHECK LOGS) detected on player %s, SteamID: %s, IP: %s", name, SteamID, IPaddr );
					
					isbeinglogged[id] = true;
					timetolog[id] = 1999;
					
					strafedetforward[id] = 0;
				}
			}
			
			if( flForwardMove[id] == 0 ) {
				if( ++strafeundetforward[id] > value ) {
					strafedetforward[id] = 0;
					strafeundetforward[id] = 0;
				}
			}
		}
		if( m_mx[id] == m_oldmx[id] ) {
			strafedetside[id] = 0;
			strafedetforward[id] = 0;
		}
	}
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	
	
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	- Just a simple strafe script detector on the yaw axis.
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	static valueadelay = 50;
	
	if( ~pev( id, pev_flags ) & FL_ONGROUND && m_mx[id] != 0.0 && m_oldmx[id] != 0.0 && pev( id, pev_movetype ) != MOVETYPE_FLY ) {
		if( m_mx[id] == m_oldmx[id] && ( m_mx[id] >= 2 || m_mx[id] <= -2 ) ) {
			if( scriptdet[id] > 15 ) {
				client_cmd( id, "-left" );
				client_cmd( id, "-right" );
			}
			
			if( ++scriptdet[id] > valueadelay ) {
				new name[32];
				get_user_name( id, name, charsmax( name ) );
				
				log_to_file( "rAntiCheat.log", "Strafe script (#0001) detected on player %s, m_mx: %f, m_oldmx: %f", name, m_mx[id], m_oldmx[id] );
				
				bBanned[id] = true;
				
				server_cmd( "amx_mban #%d 120 ^"[^x03rAnti-Cheat^x01] Strafe script (#0001) detected^"", get_user_userid( id ) );
				
				scriptdet[id] = 0;
			}
		} else
			scriptdet[id] = 0;
	}
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	- Another new strafe helper  16.01.2017 redone cause it was false detecting filter strafe helper.
	- Idea: 13.01.2017, was away, so i couldn't write it. so i notated idea, then made it 15.01.2017, saw some bugs fixed them 16.01.2017 02:40.
	- Detects strafe helpers which "filters" bad input.
	- Common mistakes with this strafe helper includes ( but is not limited to ):
												-> Sets flags, but leaves sidemove/forwardmove to 0. ( this detects that. )
												-> Sets sidemove/forwardmove straight from 0 -> 250/-250, leaves the value 200/-200 out of the equation. ( bad mistake coders! )
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	if( !bStrafeOn[id] ) {
		if( buttons & IN_MOVERIGHT && !( buttons & IN_MOVELEFT ) && !( buttons & IN_BACK ) && !( buttons & IN_FORWARD ) && !( flSideMove[id] > 0.0 ) ) {
			if( ++filterstrdet[id] > 20 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0015) detected on player %s, SteamID: %s, IP: %s, sdmv: %f, fwmv: %f", name, steamid, ipaddr, flSideMove[id], flForwardMove[id] );
				
				bBanned[id] = true;
				
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0015) detected^"", get_user_userid( id ) );
				
				filterstrdet[id] = 0;
			}
		} else if( buttons & IN_MOVELEFT && !( buttons & IN_MOVERIGHT ) && !( buttons & IN_BACK ) && !( buttons & IN_FORWARD ) && !( flSideMove[id] < 0.0 ) ) {
			if( ++filterstrdet[id] > 20 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0016) detected on player %s, SteamID: %s, IP: %s, sdmv: %f, fwmv: %f", name, steamid, ipaddr, flSideMove[id], flForwardMove[id] );
				
				bBanned[id] = true;
				
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0016) detected^"", get_user_userid( id ) );
				
				filterstrdet[id] = 0;
			}
		} else if( buttons & IN_FORWARD && !( buttons & IN_BACK ) && !( buttons & IN_MOVELEFT ) && !( buttons & IN_MOVERIGHT ) && !( flForwardMove[id] > 0.0 ) ) {
			if( ++filterstrdet[id] > 20 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0017) detected on player %s, SteamID: %s, IP: %s, sdmv: %f, fwmv: %f", name, steamid, ipaddr, flSideMove[id], flForwardMove[id] );
				
				bBanned[id] = true;
				
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0017) detected^"", get_user_userid( id ) );
				
				filterstrdet[id] = 0;
			}
		} else if( buttons & IN_BACK && !( buttons & IN_FORWARD ) && !( buttons & IN_MOVELEFT ) && !( buttons & IN_MOVERIGHT ) && !( flForwardMove[id] < 0.0 ) ) {
			if( ++filterstrdet[id] > 20 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0018) detected on player %s, SteamID: %s, IP: %s, sdmv: %f, fwmv: %f", name, steamid, ipaddr, flSideMove[id], flForwardMove[id] );
				
				bBanned[id] = true;
				
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0018) detected^"", get_user_userid( id ) );
				
				filterstrdet[id] = 0;
			}
		}
	}
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	
	
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	- Got this strafe helper idea in the middle of the night working on the anticheat.. ( 16.01.2017 04:24 )
	- This works by detecting false button presses made by cheats.
	- Works on typical strafe helpers which sends buttons at right timing, but the player keeps strafing, so when strafe helper changes direction
		the player doesn't follow, so he presses the other button.
	- This is also bad coding from the developers side, you need to block input completely from other side of strafe to avoid being detected on this one.
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	if( !bStrafeOn[id] ) {
		if( buttons & IN_MOVELEFT && buttons & IN_MOVERIGHT && ( flSideMove[id] == pev( id, pev_maxspeed ) || flSideMove[id] == -( pev( id, pev_maxspeed ) ) ) ) {
			new name[32], steamid[32], ipaddr[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
			get_user_authid( id, steamid, charsmax( steamid ) );
			log_to_file( "rAntiCheat.log", "Strafe helper (#0019) detected on player %s, SteamID: %s, IP: %s, sdmv: %f, fwmv: %f %s %s %s %s", name, steamid, ipaddr, flSideMove[id], flForwardMove[id], buttons & IN_FORWARD ? "W" : "-", buttons & IN_MOVELEFT ? "A" : "-", buttons & IN_BACK ? "S" : "-", buttons & IN_MOVERIGHT ? "D" : "-" );
			
			bBanned[id] = true;
			
			server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0019) detected^"", get_user_userid( id ) );
		} else if( buttons & IN_BACK && buttons & IN_FORWARD && ( flForwardMove[id] == pev( id, pev_maxspeed ) || flForwardMove[id] == -( pev( id, pev_maxspeed ) ) ) ) {
			new name[32], steamid[32], ipaddr[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
			get_user_authid( id, steamid, charsmax( steamid ) );
			log_to_file( "rAntiCheat.log", "Strafe helper (#0020) detected on player %s, SteamID: %s, IP: %s, sdmv: %f, fwmv: %f %s %s %s %s", name, steamid, ipaddr, flSideMove[id], flForwardMove[id], buttons & IN_FORWARD ? "W" : "-", buttons & IN_MOVELEFT ? "A" : "-", buttons & IN_BACK ? "S" : "-", buttons & IN_MOVERIGHT ? "D" : "-" );
			
			bBanned[id] = true;
			
			server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0020) detected^"", get_user_userid( id ) );
		}
		
		if( buttons & IN_FORWARD && buttons & IN_MOVELEFT && !( buttons & IN_MOVERIGHT ) && !( buttons & IN_BACK ) && ( ( flSideMove[id] == pev( id, pev_maxspeed ) || flSideMove[id] == -( pev( id, pev_maxspeed ) ) )
			|| ( flForwardMove[id] == pev( id, pev_maxspeed ) || flForwardMove[id] == -( pev( id, pev_maxspeed ) ) ) ) ) {
			new name[32], steamid[32], ipaddr[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
			get_user_authid( id, steamid, charsmax( steamid ) );
			log_to_file( "rAntiCheat.log", "Strafe helper (#0021) detected on player %s, SteamID: %s, IP: %s, sdmv: %f, fwmv: %f %s %s %s %s", name, steamid, ipaddr, flSideMove[id], flForwardMove[id], buttons & IN_FORWARD ? "W" : "-", buttons & IN_MOVELEFT ? "A" : "-", buttons & IN_BACK ? "S" : "-", buttons & IN_MOVERIGHT ? "D" : "-" );
			
			bBanned[id] = true;
			
			server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0021) detected^"", get_user_userid( id ) );
		} else if( buttons & IN_BACK && buttons & IN_MOVERIGHT && !( buttons & IN_MOVELEFT ) && !( buttons & IN_FORWARD ) && ( ( flSideMove[id] == pev( id, pev_maxspeed ) || flSideMove[id] == -( pev( id, pev_maxspeed ) ) )
			|| ( flForwardMove[id] == pev( id, pev_maxspeed ) || flForwardMove[id] == -( pev( id, pev_maxspeed ) ) ) ) ) {
			new name[32], steamid[32], ipaddr[32];
			get_user_name( id, name, charsmax( name ) );
			get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
			get_user_authid( id, steamid, charsmax( steamid ) );
			log_to_file( "rAntiCheat.log", "Strafe helper (#0022) detected on player %s, SteamID: %s, IP: %s, sdmv: %f, fwmv: %f %s %s %s %s", name, steamid, ipaddr, flSideMove[id], flForwardMove[id], buttons & IN_FORWARD ? "W" : "-", buttons & IN_MOVELEFT ? "A" : "-", buttons & IN_BACK ? "S" : "-", buttons & IN_MOVERIGHT ? "D" : "-" );
			
			bBanned[id] = true;
			
			server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0022) detected^"", get_user_userid( id ) );
		}
	}
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	
	// New strafe helper 15.01.2017
	if( !bStrafeOn[id] ) {
		if( !( oldbuttons[id] & IN_BACK ) && !( buttons & IN_BACK ) &&  !( oldbuttons[id] & IN_MOVELEFT ) && !( buttons & IN_MOVELEFT ) && !( oldbuttons[id] & IN_MOVERIGHT )
			&& !( oldbuttons[id] & IN_FORWARD ) && !( buttons & IN_FORWARD ) && buttons & IN_MOVERIGHT && flSideMove[id] == ( pev( id, pev_maxspeed ) ) ) {
			if( ++newstrdet[id] > 9 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0023) detected on player %s, SteamID: %s, IP: %s", name, steamid, ipaddr );
				
				bBanned[id] = true;
				
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0023) detected^"", get_user_userid( id ) );
				
				newstrdet[id] = 0;
			}
		} else if( !( oldbuttons[id] & IN_BACK ) && !( buttons & IN_BACK ) && !( oldbuttons[id] & IN_MOVELEFT ) && !( oldbuttons[id] & IN_MOVERIGHT ) && !( buttons & IN_MOVERIGHT )
			&& !( oldbuttons[id] & IN_FORWARD ) && !( buttons & IN_FORWARD ) && buttons & IN_MOVELEFT && flSideMove[id] == -( pev( id, pev_maxspeed ) ) ) {
			if( ++newstrdet[id] > 9 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0024) detected on player %s, SteamID: %s, IP: %s", name, steamid, ipaddr );
				
				bBanned[id] = true;
				
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0024) detected^"", get_user_userid( id ) );
			
				newstrdet[id] = 0;
			}
		}
		
		if( !( oldbuttons[id] & IN_BACK ) && !( buttons & IN_BACK ) && !( oldbuttons[id] & IN_MOVELEFT ) && !( buttons & IN_MOVELEFT ) && !( oldbuttons[id] & IN_MOVERIGHT ) && !( buttons & IN_MOVERIGHT )
			&& !( oldbuttons[id] & IN_FORWARD ) && buttons & IN_FORWARD && flForwardMove[id] == ( pev( id, pev_maxspeed ) ) ) {
			if( ++newstrdet[id] > 9 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0025) detected on player %s, SteamID: %s, IP: %s", name, steamid, ipaddr );
				
				bBanned[id] = true;
				
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0025) detected^"", get_user_userid( id ) );
				
				newstrdet[id] = 0;
			}
		} else if( !( oldbuttons[id] & IN_BACK ) && !( oldbuttons[id] & IN_MOVELEFT ) && !( buttons & IN_MOVELEFT ) && !( oldbuttons[id] & IN_MOVERIGHT ) && !( buttons & IN_MOVERIGHT )
			&& !( oldbuttons[id] & IN_FORWARD ) && !( buttons & IN_FORWARD ) && buttons & IN_BACK && flForwardMove[id] == -( pev( id, pev_maxspeed ) ) ) {
			if( ++newstrdet[id] > 9 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0026) detected on player %s, SteamID: %s, IP: %s", name, steamid, ipaddr );
				
				bBanned[id] = true;
				
				server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0026) detected^"", get_user_userid( id ) );
			
				newstrdet[id] = 0;
			}
		}
	}
	// -----------------------------
	
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	- New strafe helper idea, got it after testing with senor vac or peersoon.. ( 31.01.2017 21:06 )
	- This works by detecting immediate movement, much like #0023 - #0026 does.
	- Bypass this by not sending immediately 250/-250 when already doing some strafes. unless it's A D or W S.
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	if( !bStrafeOn[id] && ~pev( id, pev_flags ) & FL_ONGROUND && !isbeinglogged[id] ) {
		if( ~oldbuttons[id] & IN_FORWARD && ~oldbuttons[id] & IN_BACK && ~oldbuttons[id] & IN_MOVELEFT && oldbuttons[id] & IN_MOVERIGHT
		&& ~buttons & IN_FORWARD && ~buttons & IN_MOVERIGHT && ~buttons & IN_BACK && buttons & IN_MOVELEFT && flSideMove[id] < -200.0 ) {
			if( ++newstr2det[id] >= 3 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0027) detected on player %s, SteamID: %s, IP: %s", name, steamid, ipaddr );
				
				//bBanned[id] = true;
				
				isbeinglogged[id] = true;
				timetolog[id] = 1999;
				
				//server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0027) detected^"", get_user_userid( id ) );
			}
		}
		
		if( ~oldbuttons[id] & IN_FORWARD && ~oldbuttons[id] & IN_BACK && ~oldbuttons[id] & IN_MOVERIGHT && oldbuttons[id] & IN_MOVELEFT
		&& ~buttons & IN_FORWARD && ~buttons & IN_MOVELEFT && ~buttons & IN_BACK && buttons & IN_MOVERIGHT && flSideMove[id] > 200.0 ) {
			if( ++newstr2det[id] >= 3 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0028) detected on player %s, SteamID: %s, IP: %s", name, steamid, ipaddr );
				
				//bBanned[id] = true;
				
				isbeinglogged[id] = true;
				timetolog[id] = 1999;
				
				//server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0028) detected^"", get_user_userid( id ) );
			}
		}
		
		if( ~oldbuttons[id] & IN_MOVERIGHT && ~oldbuttons[id] & IN_BACK && ~oldbuttons[id] & IN_MOVELEFT && oldbuttons[id] & IN_FORWARD
		&& ~buttons & IN_FORWARD && ~buttons & IN_MOVERIGHT && ~buttons & IN_FORWARD && buttons & IN_BACK && flForwardMove[id] < -200.0 ) {
			if( ++newstr2det[id] >= 3 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0029) detected on player %s, SteamID: %s, IP: %s", name, steamid, ipaddr );
				
				//bBanned[id] = true;
				
				isbeinglogged[id] = true;
				timetolog[id] = 1999;
				
				//server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0029) detected^"", get_user_userid( id ) );
			}
		}
		
		if( ~oldbuttons[id] & IN_MOVERIGHT && ~oldbuttons[id] & IN_MOVELEFT && ~oldbuttons[id] & IN_FORWARD && oldbuttons[id] & IN_BACK
		&& ~buttons & IN_BACK && ~buttons & IN_MOVERIGHT && ~buttons & IN_MOVELEFT && buttons & IN_FORWARD && flForwardMove[id] > 200.0 ) {
			if( ++newstr2det[id] >= 3 ) {
				new name[32], steamid[32], ipaddr[32];
				get_user_name( id, name, charsmax( name ) );
				get_user_ip( id, ipaddr, charsmax( ipaddr ), 1 );
				get_user_authid( id, steamid, charsmax( steamid ) );
				
				log_to_file( "rAntiCheat.log", "Strafe helper (#0030) detected on player %s, SteamID: %s, IP: %s", name, steamid, ipaddr );
				
				//bBanned[id] = true;
				
				isbeinglogged[id] = true;
				timetolog[id] = 1999;
				
				//server_cmd( "amx_mban #%d 0 ^"[^x03rAnti-Cheat^x01] Strafe helper (#0030) detected^"", get_user_userid( id ) );
			}
		}
	} else if( pev( id, pev_flags ) & FL_ONGROUND )
		newstr2det[id] = 0;
	/*
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	*/
	
	flOldSideMove[id] = flSideMove[id];
	flOldForwardmove[id] = flForwardMove[id];
	m_oldmx[id] = m_mx[id];
	m_oldyaw[id] = m_yaw[id];
	oldbuttons[id] = buttons;
	return;
}

public Cvars( id, const szVar[], const szValue[] ) {
    if( !is_user_connected( id ) || is_user_bot( id ) )
		return;
	
	static name[32];
	get_user_name( id, name, charsmax( name ) );
	
	if( contain( name, "#" ) == 0 ) {
		replace( name, charsmax( name ), "#", "" );
	}
	
	if( bShouldExclude ) {
		new SteamID[32], excludeSteamID[32];
		get_user_authid( id, SteamID, charsmax( SteamID ) );
		for(new i = 0; i < ArraySize( authIDs ); i++ ) {
		ArrayGetString( authIDs, i, excludeSteamID, charsmax( excludeSteamID ) );
			if( strcmp( SteamID, excludeSteamID ) == 0 ) {
				return;
			}
		}
	}
	
	new Float:m_szValue = str_to_float( szValue );
	
    if( equal( szVar, "cl_forwardspeed" ) && m_szValue != 400 ) {
		server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal value: 400)^"", get_user_userid( id ), szVar, m_szValue );
	}
	
    if( equal( szVar, "cl_sidespeed" ) && m_szValue != 400 ) {
		server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal value: 400)^"", get_user_userid( id ), szVar, m_szValue );
	}
	
    if( equal( szVar, "cl_backspeed" ) && m_szValue != 400 ) {
		server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal value: 400)^"", get_user_userid( id ), szVar, m_szValue );
	}
	
    if( equal( szVar, "cl_yawspeed" ) && m_szValue != 210 ){
		server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal value: 210)^"", get_user_userid( id ), szVar, m_szValue );
	}
	
    if( equal( szVar, "cl_pitchspeed" ) && m_szValue != 225 ){
		server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal value: 225)^"", get_user_userid( id ), szVar, m_szValue );
	}
	
    if( equal( szVar, "developer" ) && m_szValue != 0 ){
		server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal value: 0)^"", get_user_userid( id ), szVar, m_szValue );
	}
	
	if( equal( szVar, "cl_filterstuffcmd" ) && m_szValue != 0 ){
		server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal value: 0)^"", get_user_userid( id ), szVar, m_szValue );
	}
	
    if( equal( szVar, "fps_override" ) && m_szValue != 0 ){
		server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal value: 0)^"", get_user_userid( id ), szVar, m_szValue );
	}
	
    if( equal( szVar, "fps_modem" ) && m_szValue != 0 ){
		server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal value: 0)^"", get_user_userid( id ), szVar, m_szValue );
	}
	
    if( equal( szVar, "sv_cheats" ) && m_szValue != 0 ){
		server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal value: 0)^"", get_user_userid( id ), szVar, m_szValue );
	}
	
	if( equal( szVar, "fps_max" ) && m_szValue > 101 ) {
        server_cmd( "kick #%d ^"Bad cvar detected %s, value %.f, (Legal max value: 101)^"", get_user_userid( id ), szVar, m_szValue );
    }
	
	client_cmd( id, "+mlook" );
		
	return;
}

public client_command(id) {
	if( !is_user_connected( id ) )
		return;
	
	static sArgv[64], sArgv1[64];
	
	read_argv( 0, sArgv, 63 );
	read_args( sArgv1, charsmax( sArgv1 ) );
	remove_quotes( sArgv );
	trim( sArgv );
	
	if( strlen( sArgv ) == 0 )
		return;
	
	new szName[32];
	get_user_name( id, szName, charsmax( szName ) );
	
	//ColorChat( 0, NORMAL, "Command %s was executed", sArgv );
	
	/*if( TrieKeyExists( BadCommands, sArgv ) ) {
		server_cmd( "kick #%d ^"Bad command detected %s^"", get_user_userid( id ), sArgv );
		ColorChat( 0, NORMAL, "^3rAnti-Cheat^1 | Bad commands detected! [%s has been kicked]", szName );
	}*/
}

public client_connect( id ) {
	for( new i = 0; i < sizeof( g_DefaultCvar ); i++ ) {
		console_cmd( id, "%s", g_DefaultCvar[i] );
	}
	
	static name[32];
	get_user_name( id, name, charsmax( name ) );
	
	if( contain( name, "#" ) == 0 ) {
		replace( name, charsmax( name ), "#", "" );
	}
	
	return;
}

public client_putinserver( id ) {
    helperdet[id] = 0;
	strafedetforward[id] = 0;
	strafedetside[id] = 0;
	advhelperdet[id] = 0;
	scriptdet[id] = 0;
	helperdetbuttons[id] = 0;
	filterstrdet[id] = 0;
	AVGFPS[id][0] = 0.0;
	AVGFPS[id][1] = 0.0;
	bBanned[id] = false;
	
	return;
}

public client_disconnect( id ) {
    helperdet[id] = 0;
	strafedetforward[id] = 0;
	strafedetside[id] = 0;
	advhelperdet[id] = 0;
	scriptdet[id] = 0;
	helperdetbuttons[id] = 0;
	filterstrdet[id] = 0;
	AVGFPS[id][0] = 0.0;
	AVGFPS[id][1] = 0.0;
	bBanned[id] = false;
	
    if( task_exists( id ) )
		remove_task( id );
	
	return;
}

public player_spawn( id ) {
    helperdet[id] = 0;
	strafedetforward[id] = 0;
	strafedetside[id] = 0;
	advhelperdet[id] = 0;
	scriptdet[id] = 0;
	helperdetbuttons[id] = 0;
	filterstrdet[id] = 0;
	
	if( is_user_alive( id ) )
		ColorChat( id, NORMAL, "^x03rAntiCheat^x01 v%s by ^x04Ranarrr^x01 | ^x04rAntiCheat active", VERSION );
	
    return HAM_IGNORED;
}

public check_cvars() {
    static players[32], num, id;
    get_players( players, num, "h" );
    for( new i = 0; i < num; i++ ) {
        id = players[i];
        for( new j = 0; j < sizeof( g_CheckCvar ); j++ )
            query_client_cvar( id, g_CheckCvar[j], "Cvars" );
    }
	return;
}

public Player_CmdStart( id, uc_handle ) {
	
	if( !is_user_alive( id ) || pev( id, pev_flags ) & FL_FROZEN || pev( id, pev_maxspeed ) < 210.0 || pev( id, pev_maxspeed ) > 260 || get_user_team( id ) == 3 || get_user_team( id ) == 0 || get_user_team( id ) == -1
	|| is_user_bot( id ) )
		return FMRES_IGNORED;
	
	UserFPS[id] = ( 1 / ( get_uc( uc_handle, UC_Msec ) * 0.001 ) );
	
	get_uc( uc_handle, UC_SideMove, flSideMove[id] );
	get_uc( uc_handle, UC_ForwardMove, flForwardMove[id] );
	
	return FMRES_IGNORED;
}

public bugfix() {
	bPluginPause = true;
	return;
}

public stoprecord( id ) {
	if( read_argc() != 2 ) {
		client_cmd( id, "echo rStopRecordPlayer usage: rStopRecordPlayer #userid/^"name^"" );
		client_cmd( id, "echo Players being recorded:" );
		for( new i = 0; i <= 32; ++i ) {
			if( isbeinglogged[i] ) {
				new name[32];
				get_user_name( i, name, charsmax( name ) );
				
				client_cmd( id, "echo ^t%s, userid: %i", name, get_user_userid( i ) );
			}
		}	
		return;
	}
	
	static name[33], playerid;
	
	read_argv( 1, name, charsmax( name ) );
	
	if( contain( name, "#" ) == 0 ) {
		// Userid
		playerid = find_player( "hk", str_to_num( name[1] ) );
		if( !playerid ) {
			client_cmd( id, "echo Could not find player with userid %s", name[1] );
			return;
		}
	} else {
		// Name
		playerid = find_player( "ah", name );
		if( !playerid )
			playerid = find_player( "bhl", name );
		
		if( !playerid ) {
			client_cmd( id, "echo Could not find player with substring or full name %s", name );
			return;
		}
	}
	
	if( !playerid ) {
		client_cmd( id, "echo Could not find player" );
		return;
	}
	
	isbeinglogged[playerid] = false;
	
	get_user_name( playerid, name, charsmax( name ) );
	client_cmd( id, "echo Stopped recording player %s", name );
	
	return;
}

public startrecord( id ) {
	if( read_argc() > 3 || read_argc() < 2 ) {
		client_cmd( id, "echo rRecordPlayer usage: rRecordPlayer #userid/^"name^" <time in ticks, default: 1999>" );
		return;
	}
	
	static name[33], playerid, time[32];
	
	read_argv( 1, name, charsmax( name ) );
	
	if( contain( name, "#" ) == 0 ) {
		// Userid
		playerid = find_player( "hk", str_to_num( name[1] ) );
		if( !playerid ) {
			client_cmd( id, "echo Could not find player with userid %s", name[1] );
			return;
		}
	} else {
		// Name
		playerid = find_player( "ah", name );
		if( !playerid )
			playerid = find_player( "bhl", name );
		
		if( !playerid ) {
			client_cmd( id, "echo Could not find player with substring or full name %s", name );
			return;
		}
	}
	
	if( !playerid ) {
		client_cmd( id, "echo Could not find player" );
		return;
	}
	
	get_user_name( playerid, name, charsmax( name ) );
	
	if( read_argc() == 2 ) {
		timetolog[playerid] = 1999;
	} else {
		read_argv( 2, time, sizeof( time ) );
		if( str_to_num( time ) > 20000 )
			timetolog[playerid] = 20000;
		else if( str_to_num( time ) < 10 )
			timetolog[playerid] = 10;
		
		timetolog[playerid] = str_to_num( time );
	}
	
	isbeinglogged[playerid] = true;
	client_cmd( id, "echo Recording player %s", name );
	return;
}

// Credits to ConnorMcLeod
Float:distance_to_ground( id ) {
    new Float:start[3], Float:end[3];
    entity_get_vector( id, EV_VEC_origin, start );
    if( entity_get_int( id, EV_INT_flags ) & FL_DUCKING ) { 
        start[2] += 18.0;
    }

    end[0] = start[0];
    end[1] = start[1];
    end[2] = start[2] - 9999.0;

    new ptr = create_tr2();
    engfunc( EngFunc_TraceHull, start, end, IGNORE_MONSTERS, HULL_HUMAN, id, ptr );
    new Float:fraction;
    get_tr2( ptr, TR_flFraction, fraction );
    free_tr2( ptr );

    return ( fraction * 9999.0 );
}