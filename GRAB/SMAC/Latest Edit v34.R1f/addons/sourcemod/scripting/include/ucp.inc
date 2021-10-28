/* Ultra Core Protector Anti-Cheat System Functions
*
* Copyright © 2008-2010, UCP Team
*
* This file is provided as is (no warranties).
*
*/

/**
 * Retrieves a client's ucpid.
 *
 * @param client		Player index.
 * @param ucpid			Buffer to store the client's ucpid string.
 * @return				True on success, false otherwise.
 * @error				If the client is not connected or the index is invalid.
 */
native ucp_id(client, String:ucpid[]);

/**
 * Retrieves a client's authentication string (SteamID generated from ucpid).
 *
 * @param client		Player index.
 * @param auth			Buffer to store the client's auth string.
 * @param maxlen		Maximum length of string buffer (includes NULL terminator).
 * @return				True on success, false otherwise.
 * @error				If the client is not connected or the index is invalid.
 */
native bool:GetClientAuthString2(client, String:auth[], maxlen);

/**
 * Retrieves a client's build number.
 *
 * @param client		Player index.
 * @param build			Buffer to store the client's build string.
 * @noreturn
 */
native GetClientBuild(client, String:build[]);

/**
 * Retrieves a client's OS.
 *
 * @param client		Player index.
 * @param useros		Buffer to store the client's OS string.
 * @noreturn
 */
native GetClientOs(client, String:useros[]);
