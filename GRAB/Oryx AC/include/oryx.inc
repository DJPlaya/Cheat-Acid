/*  Oryx AC: collects and analyzes statistics to find some cheaters in CS:S, CS:GO, and TF2 bunnyhop.
 *  Copyright (C) 2018  Nolan O.
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

#if defined _oryx_included
	#endinput
#endif
#define _oryx_included

#define ORYX_VERSION "1.3"

/**
* List of current detection descriptions:
* 
* "Acute TR formatter"
* "+left/right bypasser"
* "Prestrafe tool"
* "Average strafe too close to 0"
* "Too many perfect strafes"
* "Movement config"
* "Unsynchronised movement"
* "Invalid wish velocity"
* "Script on scroll"
* "Hyperscroll"
*/

enum
{
	TRIGGER_LOW,			// Reachable by skilled players occasionally. Not always necessary before a med detect.
	TRIGGER_MEDIUM,			// Reachable by skilled players by unlikely chance.
	TRIGGER_HIGH,			// Only theoretically reachable by the aligning of stars by the gods.
	TRIGGER_HIGH_NOKICK,	// This should really only be used for a follow up definitive detection.
	TRIGGER_DEFINITIVE,		// Non-skill-based detection type. 100% sure detection.
	TRIGGER_TEST			// Allows you to develop new detections on live servers with minimal side effects.
};

/**
 * Called when Oryx gets triggered on a client.
 *
 * @param client				Client entity index.
 * @param level					Level of detection as defined in the above enum.
 * @param cheat					Short description or name of the cheat being detected. 32 cells char array.
 * @return						Plugin_Continue to do nothing. Plugin_Changed to modify values. Plugin_Handled to abort kicks. Plugin_Stop to completely ignore the trigger.
 */
forward Action Oryx_OnTrigger(int client, int &level, char[] cheat);

/**
 * Call to activate Oryx's trigger procedure (logging, kicking, admin notifications, etc..).
 *
 * @param client				Client entity index.
 * @param level					Level of detection as defined in the above enum.
 * @param cheat					Short description or name of the cheat being detected.
 * @return						Return value of the Oryx_OnTrigger forward.
 */
native Action Oryx_Trigger(int client, int level, const char[] cheat);

/**
 * Prints a message to admins' chat.
 *
 * @param format					Formatting rules.
 * @param any						Variable number of format parameters.
 * @noreturn
 */
native void Oryx_PrintToAdmins(const char[] format, any ...);

/**
 * Prints a message to admins' console.
 *
 * @param format					Formatting rules.
 * @param any						Variable number of format parameters.
 * @noreturn
 */
native void Oryx_PrintToAdminsConsole(const char[] format, any ...);

/**
 * Logs an entry to Oryx's log file.
 *
 * @param format					Formatting rules.
 * @param any						Variable number of format parameters.
 * @noreturn
 */
native void Oryx_LogMessage(const char[] format, any ...);

/**
 * Checks if f1 is inbetween a specified threshold of f12.
 *
 * @param f1					First value.
 * @param f2					Second value.
 * @param frac					Used as a threshold of f2 for f1 to be within.
 * @return 						True if the test passed.
 */
native bool Oryx_WithinThreshold(float f1, float f2, float threshold);

/**
 * Checks if the player has permissions to bypass Oryx.
 * Will return false if `oryx_allow_bypass` is set to 0.
 * With bhoptimer or bTimes v1.8.3, will return true for styles with the `oryx_bypass` special flag.
 * For bTimes2, will return true if the player is in edit mode (rewind/fastforward etc).
 *
 * @param client				Client index.
 * @return 						True if the player can bypass the anticheat.
 */
native bool Oryx_CanBypass(int client);

/**
 * A tiny function to veify if the player fits gameplay.
 *
 * @param client				Client entity index.
 * @param watrer				Check for water level?
 * @return 						True if the test passed.
 */
stock bool IsLegalMoveType(int client, bool water = true)
{
	MoveType iMoveType = GetEntityMoveType(client);

	return (!water || GetEntProp(client, Prop_Data, "m_nWaterLevel") < 2) &&
		(GetEntityFlags(client) & FL_ATCONTROLS) == 0 &&
		(iMoveType == MOVETYPE_WALK || iMoveType == MOVETYPE_ISOMETRIC || iMoveType == MOVETYPE_LADDER);
}

public SharedPlugin __pl_oryx =
{
	name = "oryx",
	file = "oryx.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_oryx_SetNTVOptional()
{
	MarkNativeAsOptional("Oryx_CanBypass");
	MarkNativeAsOptional("Oryx_LogMessage");
	MarkNativeAsOptional("Oryx_PrintToAdmins");
	MarkNativeAsOptional("Oryx_PrintToAdminsConsole");
	MarkNativeAsOptional("Oryx_Trigger");
	MarkNativeAsOptional("Oryx_WithinThreshold");
}
#endif
