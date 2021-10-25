public Action OnPlayerRunCmd(int iClient, int & iButtons, int & impulse, float vel[3], float fAngles[3], int & weapon, int & subtype, int & iCmdnum, int & iTickcount, int & iSeed, int iMouse[2])
{
	g_iTickCountCMD[iClient] = iTickcount;
	g_iCmdGameTime[iClient] = GetGameTime();
	
	//PrintToConsole(iClient, "Fake: %i Dead: %i InGame: %i Obs: %i", IsFakeClient(iClient), IsPlayerAlive(iClient), IsClientInGame(iClient), Client_GetObserverMode(iClient));
	
	if (IsPlayerAlive(iClient))
	{
		g_vEyeAngles[iClient] = fAngles;
		
		if (!IsFakeClient(iClient))
		{
			if (iCmdnum <= 0)
			{
				return Plugin_Handled;
			}

			if (g_iCvar[8])
			{
				float fForwardMove = vel[0], fSideMove = vel[1];
				
				if ((fForwardMove == g_fMaxMove && (iButtons & IN_FORWARD) == 0) || (fSideMove == -g_fMaxMove && (iButtons & IN_MOVELEFT) == 0) || (fForwardMove == -g_fMaxMove && (iButtons & IN_BACK) == 0) || (fSideMove == g_fMaxMove && (iButtons & IN_MOVERIGHT) == 0))
				{
					HG_CHATLOG(iClient, "Incorrect movements and buttons");
					HG_LOG(iClient, "Incorrect movements and buttons F: %f S: %f", fForwardMove, fSideMove);
					HG_Ban(iClient);
					
					g_bBan[iClient] = true;
				}
				
				if (!(IsValidMove(fForwardMove) || IsValidMove(fSideMove)))
				{
					
					if (IfStrafeMove(fAngles, iMouse))
						g_iInvalidMoveCount[iClient] = 0;
					
					if (++g_iInvalidMoveCount[iClient] > SAMPLE)
					{
						HG_CHATLOG(iClient, "Incorrect movements");
						HG_LOG(iClient, "Incorrect movements F: %f S: %f", fForwardMove, fSideMove);
						HG_Ban(iClient);
						
						g_bBan[iClient] = true;
						g_iInvalidMoveCount[iClient] = 0;
					}
				}
				
				if (iButtons & IN_BULLRUSH)
				{
					iButtons &= ~IN_BULLRUSH;
					
					HG_CHATLOG(iClient, "FastDuck");
					HG_LOG(iClient, "FastDuck");
					HG_Ban(iClient);
					
					g_bBan[iClient] = true;
				}
			}
			
			if (g_iCvar[13])
			{
				
				float fAngleDiff;
				static float flAngles[3];
				float fDAngles[3];
				fDAngles[1] = fAngles[1];
				fAngleDiff = GetVectorDistance(flAngles, fDAngles);
				
				if (fAngleDiff > 180.0)
				{
					fAngleDiff -= 360.0;
				} else if (fAngleDiff < -180.0)
				{
					fAngleDiff += 360.0;
				}
				
				if (fAngleDiff != 0.0)
				{
					static float flAngleDiff;
					
					g_iGameTick[iClient] = GetGameTickCount();
					
					if (fAngleDiff == flAngleDiff && !(iButtons & (IN_LEFT | IN_RIGHT)) && IsLegalMoveType(iClient))
					{
						if ((g_ilGameTick[iClient] - g_iGameTick[iClient]) < 3 && (g_ilGameTick[iClient] - g_iGameTick[iClient]) >= 0)
						{
							fAngles[1] += flAngleDiff;
						}
						
						if (g_ilGameTick[iClient] - g_iGameTick[iClient] == 0)
						{
							g_iDetectDesyncAngles[iClient]++
							
							if (g_iDetectDesyncAngles[iClient]++ > 64)
							{
								HG_CHATLOG(iClient, "Difference Angles");
								HG_LOG(iClient, "Difference Angles [D: %f] C: %i", flAngleDiff, g_iDetectDesyncAngles[iClient]);
								HG_Ban(iClient);
								g_bBan[iClient] = true;
								//HG_Ban(iClient);
								
								//g_bBan[iClient] = true;
							}
						}
						
						g_ilGameTick[iClient] = GetGameTickCount();
						
					} else {
						g_iDetectDesyncAngles[iClient] = 0;
					}
					flAngleDiff = fAngleDiff;
				}
				
				flAngles[1] = fDAngles[1];
				
				
			}
			
			if (g_iCvar[10])
			{
				
				if (GetEntityMoveType(iClient) != MOVETYPE_LADDER && hConvarBhop.IntValue == 0)
				{
					static int ilButtons[MS];
					
					int iGround = GetEntityFlags(iClient) & FL_ONGROUND;
					int iJump = iButtons & IN_JUMP;
					
					if (iJump && !(ilButtons[iClient] & IN_JUMP))
					{
						if (iGround) {
							g_iButtonPressedTick[iClient][1]++;
						}
						if (!(g_iCvar[10] == 1))
						{
							
							if (g_iButtonPressedTick[iClient][1] > 7)
							{
								HG_CHATLOG(iClient, "Bhop");
								HG_LOG(iClient, "Bhop");
								HG_Ban(iClient);
								
								g_bBan[iClient] = true;
							}
						} else {
							if (iGround && g_iButtonPressedTick[iClient][1] > 2)
							{
								iButtons &= ~IN_JUMP;
								iButtons &= ~IN_DUCK;
							}
						}
					} else if (iGround) {
						
						g_iButtonPressedTick[iClient][1] = 0;
					}
					
					ilButtons[iClient] = iButtons;
				}
				
			}
			
			if (g_iCvar[9])
			{
				if (GetEntityFlags(iClient) & FL_ONGROUND && HG_GetPlayerSpeed(iClient) < 0.01)
				{
					static float DeltaY;
					if ((iCmdnum % 2) == 1 || (iCmdnum % 3) == 1)
					{
						float DesyncAngles = fAngles[1] - DeltaY;
						if ((DesyncAngles) == -90.0 || (DesyncAngles) == 90.0)
							fAngles[1] += DesyncAngles;
					}
					DeltaY = fAngles[1];
				}
			}
			
			if (g_iCvar[12])
			{
				
				if (fAngles[2] != 0.0)
				{
					fAngles[2] = 0.0;
				}
				
				if (fAngles[0] > 89.0)
				{
					fAngles[0] = 89.0;
				}
				
				if (fAngles[0] < -89.0)
				{
					fAngles[0] = -89.0;
				}
				
				while (fAngles[1] > 180.0)
				{
					fAngles[1] -= 360.0;
				}
				
				while (fAngles[1] < -180.0)
				{
					fAngles[1] += 360.0;
				}
				
				if (fAngles[2] != 0.0)
				{
					fAngles[2] = 0.0;
				}
			}
			
			if (g_iCvar[15])
			{
				static float flAngless[MS][3];
				float Delta = GetAngleDelta(fAngles, flAngless[iClient]);
				
				if (iMouse[0] == 0 && iMouse[1] == 0 && Delta > 0.05 && !(iButtons & (IN_LEFT | IN_RIGHT)) && IsLegalMoveType(iClient) && !g_bJoyStick[iClient])
				{
					g_iDeltaChanged[iClient]++;
					
					
					if (g_iDeltaChanged[iClient] >= 64)
					{
						HG_CHATLOG(iClient, "Mouse Aim");
						HG_LOG(iClient, "Mouse Aim (Delta %f) %i", Delta, g_iDeltaChanged[iClient]);
						HG_Ban(iClient);
						g_bBan[iClient] = true;
					}
					
				} else {
					g_iDeltaChanged[iClient] = 0;
				}
				
				
				for (int i = 0; i < 3; i++)
				{
					flAngless[iClient][i] = fAngles[i];
				}
			}

			/* if (g_iCvar[14]) (FIX FAKE DETECT bind mwheeldown "+attack")
			{
				if (iButtons & IN_ATTACK)
				{
					g_iAutoShootTemp[iClient]++;
				}
				
				if (g_iAutoShootTemp[iClient] == 1)
				{
					g_iAutoShootTemp[iClient] = 0;
					
					if (++g_iAutoShoot[iClient] == 1)
					{
						if (g_iAutoShootCount[iClient]++ > 2)
						{
							iButtons &= ~IN_ATTACK;
							HG_CHATLOG(iClient, "AutoShoot");
							HG_LOG(iClient, "Maybe AutoShoot (%i)", g_iAutoShootCount[iClient]);
							//HG_Ban(iClient);
							g_iAutoShootCount[iClient] = 0;
							g_bBan[iClient] = true;
						}
					} else {
						g_iAutoShootCount[iClient] = 0;
					}
				} else {
					g_iAutoShoot[iClient] = 0;
				}
			} */
			
			
			//TEST AIMLOCK
		}
	}
	
	return Plugin_Continue;
}



float GetAngleDelta(float a1[3], float a2[3])
{
	int iNormal = 5;
	float p1[3], p2[3], delta;
	p1 = a1;
	p2 = a2;

	p1[2] = 0.0;
	p2[2] = 0.0;
	
	delta = GetVectorDistance(p1, p2);

	while (delta > 180.0 && iNormal > 0) {
		iNormal--;
		delta = FloatAbs(delta - 360.0);
	}
	
	return delta;
}

stock bool IfStrafeMove(float fAngles[3], int iMouse[2])
{
	static float fLastfAngles[3]; bool bStrafe;
	
	if ((fLastfAngles[0] == fAngles[0] && fLastfAngles[1] == fAngles[1] && fLastfAngles[1] == fAngles[1]) && (iMouse[0] > 0 || iMouse[1] > 0))
	{ bStrafe = true; }
	else if ((fLastfAngles[0] != fAngles[0] || fLastfAngles[1] != fAngles[1] || fLastfAngles[1] != fAngles[1]) && (iMouse[0] == 0 || iMouse[1] == 0))
	{ bStrafe = false; }
	fLastfAngles[0] = fAngles[0]; fLastfAngles[1] = fAngles[1]; fLastfAngles[2] = fAngles[2];
	
	return bStrafe;
}


bool IsValidMove(float num)
{
	#if (DEBUG != 1)
	if (hSvCheats.IntValue != 0)return true;
	#endif
	
	num = FloatAbs(num);
	
	return (num == 0.0 || num == g_fMaxMove || num == (g_fMaxMove * 0.75) || num == (g_fMaxMove * 0.50) || num == (g_fMaxMove * 0.25));
}

stock bool IsLegalMoveType(int client, bool water = true)
{
	MoveType iMoveType = GetEntityMoveType(client);
	int iFlags = GetEntityFlags(client);
	return (!water || GetEntProp(client, Prop_Data, "m_nWaterLevel") < 2) && (iFlags & FL_ATCONTROLS) == 0 && (iFlags & FL_FROZEN) == 0 && (iMoveType == MOVETYPE_WALK || iMoveType == MOVETYPE_ISOMETRIC || iMoveType == MOVETYPE_LADDER);
} 
