#if defined _INCLUDE_included
 #endinput
#endif
#define _INCLUDE_included


#include <smlib> // Still some oldish Syntax :/
#pragma newdecls required // New Syntax forced


// ********** Include Everything **********

#define PLUGIN_VERSION "1.0"

// 1 - Kick
// 2 - Ban
// 4 - Delayed Ban
// 8 - Block

CreateConVar("sm_cheat-acid_version", PLUGIN_VERSION, "Plugin Version", FCVAR_UNLOGGED|FCVAR_DONTRECORD);


// ********** Functions **********

/**
 * Sends an Chat Message too all online Admins
 *
 * @param iErrorType			Errortype 0 - Info, 1 - Warning, 2 - Error, 3 - Critical
 * @param cChatMessage			The Text to Display
 */
void SendToAdminChat(const int iErrorType, const char[] cChatMessage)
{
	//const char[] cMessage;
	//Format(cMessage, sizeof(cMessage), "[%s][Cheat-Acid] %s", iErrorType == 0 : "Info" : iErrorType == 1 : "Warning" : iErrorType == 2 : "Error" : "Critical", cChatMessage)
	
	for(int iClient = 1; iClient <= MaxClients; iClient++)
		if(Client_IsIngameAuthorized(iClient, true))
			if(GetUserAdmin(iClient) != INVALID_ADMIN_ID)
				PrintToChat(iClient, cMessage);
}