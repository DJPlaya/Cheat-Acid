#include <ucpd>
#include <smac>
#include <smac_wallhack>

public Plugin:myinfo =
{
	name = "SMAC: Anti-Wallhack exclude UCP",
	author = SMAC_AUTHOR,
	description = "Exclude UCP-players for wallhack checking.",
	version = SMAC_VERSION,
	url = SMAC_URL
};


public Action:UCP_OnClientAuthenticated(client)
{
	SMAC_WH_SetClientIgnore(client, (UCP_IsClientUCP(client)) ? true:false);
}
