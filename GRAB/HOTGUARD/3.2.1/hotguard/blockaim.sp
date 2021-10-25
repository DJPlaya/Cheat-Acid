
bool DisableModuleBlockAim()
{
	UnhookEvent("round_start", ePlayerAimBlock, EventHookMode_Post);
	UnhookEvent("player_death", ePlayerAimBlock, EventHookMode_Post);
	
	return false;
}


bool EnableModuleBlockAim()
{
	HookEvent("round_start", ePlayerAimBlock, EventHookMode_Post);
	HookEvent("player_death", ePlayerAimBlock, EventHookMode_Post);
	
	return false;
}

stock void ModuleBlockAimCreateObject(int iClient)
{
	if (g_iAimBlockActive[iClient] != 0)return;
	
	
	g_iAimBlockEntity[iClient] = CreateEntityByName("prop_physics_override");
	
	if (IsValidEntity(g_iAimBlockEntity[iClient]))
	{
		DispatchKeyValue(g_iAimBlockEntity[iClient], "model", "models/props_vehicles/cara_69sedan.mdl");
		
		if (DispatchSpawn(g_iAimBlockEntity[iClient]))
		{
			SetVariantString("!activator");
			AcceptEntityInput(g_iAimBlockEntity[iClient], "SetParent", iClient, g_iAimBlockEntity[iClient], 0);
			
			SetVariantInt(1);
			AcceptEntityInput(g_iAimBlockEntity[iClient], "DisableShadow");
			
			SetVariantInt(1);
			AcceptEntityInput(g_iAimBlockEntity[iClient], "DisableReceivingFlashlight");
			
			SetEntPropEnt(g_iAimBlockEntity[iClient], Prop_Send, "m_hOwnerEntity", iClient);
			SetEntPropFloat(g_iAimBlockEntity[iClient], Prop_Send, "m_flModelScale", 1.85);
			
			SetEntityRenderMode(g_iAimBlockEntity[iClient], RENDER_NONE);
			SetEntityMoveType(g_iAimBlockEntity[iClient], MOVETYPE_NONE);
			
			SetEntProp(g_iAimBlockEntity[iClient], Prop_Send, "m_fEffects", 0x010 | 0x040 | 0x001 | 0x080 | 0x008);
			SetEntProp(g_iAimBlockEntity[iClient], Prop_Send, "m_nSolidType", 1, 1);
			SetEntProp(g_iAimBlockEntity[iClient], Prop_Data, "m_usSolidFlags", 0, 2);
			SetEntProp(g_iAimBlockEntity[iClient], Prop_Data, "m_CollisionGroup", 10);
			
			g_iAimBlockActive[iClient] = g_iAimBlockEntity[iClient];
		}
	}
}

stock void ModuleBlockAimRemoveObject(int iClient)
{
	if (g_iAimBlockActive[iClient] == 0)return;
	
	if (g_iAimBlockEntity[iClient] != INVALID_ENT_REFERENCE && IsValidEntity(g_iAimBlockEntity[iClient]) && g_iAimBlockActive[iClient] == g_iAimBlockEntity[iClient])
	{
		RemoveEntity(g_iAimBlockEntity[iClient]);
		g_iAimBlockActive[iClient] = 0;
	}
}

void ePlayerAimBlock(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	
	if (iClient)
	{
		if (sName[0] == 'r')
		{
			Hook_SpawnPost(iClient);
		} else {
			Hook_SpawnPost(iClient);
		}
	}
	
}

public void Hook_ModuleBlockAim(int iClient)
{
	if (HG_IsValidClient(iClient))
	{
		SDKHook(iClient, SDKHook_SpawnPost, Hook_SpawnPost);
		Hook_SpawnPost(iClient);
	}
}


public void Unhook_ModuleBlockAim(int iClient)
{
	if (HG_IsValidClient(iClient))
	{
		SDKUnhook(iClient, SDKHook_SpawnPost, Hook_SpawnPost);
		ModuleBlockAimRemoveObject(iClient);
	}
}

public void Hook_SpawnPost(int iClient)
{
	if (GetClientTeam(iClient) > 1 && IsPlayerAlive(iClient))
	{
		ModuleBlockAimCreateObject(iClient);
	}
} 