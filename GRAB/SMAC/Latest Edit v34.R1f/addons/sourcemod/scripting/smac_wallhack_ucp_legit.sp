#include <sourcemod>
#include <smac>
#include <smac_wallhack>
#include <ucp>

public Plugin:myinfo =
{
	name = "SMAC: Anti-Wallhack exclude UCP",
	author = SMAC_AUTHOR,
	description = "Exclude UCP-players for wallhack checking.",
	version = SMAC_VERSION,
	url = SMAC_URL
};

public OnClientPostAdminCheck(client)
{
	if(client && !IsFakeClient(client))
	{
		new String:ucpid[9];
		ucp_id(client, ucpid);
		SMAC_WH_SetClientIgnore(client, (ucpid[0]) ? true:false);
	}
}