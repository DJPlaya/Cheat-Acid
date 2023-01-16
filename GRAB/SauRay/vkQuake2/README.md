# vkQuake2 with SauRay(TM) integration
This is a fork of [vkQuake2](https://github.com/kondrak/vkQuake2) with [SauRay(TM)](http://www.sauray.tech) integration. Much thanks to [Krzysztof Kondrak](https://twitter.com/k_kondrak) for the original modernized Vulkan port.

We are releasing this to be GPL-compatible (in case we release binaries) and to show the modifications required to make Quake II wall-hack free using SauRay(TM). If you would like to compile this, please reach out to us [directly](http://www.sauray.tech) to get a copy of ``HighOmega.lib`` to compile against. It should be placed in ``ext/lib``.

# Describing our Usage
In this section we will highlight all the changes we made to the code for our integration. Please note that for this demo we didn't handle dynamic entities such as doors. This is to demonstrate API usage in its most basic sense.

## Header include
The header file we needed in order integrate with Quake II was less than 40 lines with ultimately only 8 API calls necessary:

[sauray.h](https://github.com/toomuchvoltage/SauRay/tree/master/vkQuake2/ext/include/sauray.h)

We include ``sauray.h`` at the top of ``server.h``. Being that our solution is server-side only this is the only place we will need to include.

## Geometry caching
In ``R_BeginRegistration ()`` in ``vk_model.c`` we have the following to cache geometry for our own usage. Though, there are alternative routes, we found this to be the quickest. Note how we avoid invisible or transparent geometry:

```
	...
	Com_sprintf(fullname, sizeof(fullname), "./assets/maps/%s.txt", model);

	FILE *fp = fopen(fullname, "wb");
	int i = 0, j = 0;

	for (i = 0; i != r_worldmodel->numsurfaces; i++)
	{
		if (r_worldmodel->surfaces[i].texinfo->flags & (SURF_SKY | SURF_TRANS33 | SURF_TRANS66 | SURF_WARP | SURF_NODRAW))
			continue;

		vkpoly_t* curPoly = r_worldmodel->surfaces[i].polys;
		do
		{
			for (j = 0; j != curPoly->numverts - 2; j++)
			{
				fwrite(&curPoly->verts[0][0], sizeof(float), 1, fp);
				fwrite(&curPoly->verts[0][1], sizeof(float), 1, fp);
				fwrite(&curPoly->verts[0][2], sizeof(float), 1, fp);

				fwrite(&curPoly->verts[j + 1][0], sizeof(float), 1, fp);
				fwrite(&curPoly->verts[j + 1][1], sizeof(float), 1, fp);
				fwrite(&curPoly->verts[j + 1][2], sizeof(float), 1, fp);

				fwrite(&curPoly->verts[j + 2][0], sizeof(float), 1, fp);
				fwrite(&curPoly->verts[j + 2][1], sizeof(float), 1, fp);
				fwrite(&curPoly->verts[j + 2][2], sizeof(float), 1, fp);
			}

			curPoly = curPoly->chain;
			if (!curPoly) break;
		} while (true);
	}
	fclose(fp);
    ...
```

## Start-up
At the end of ``SV_SpawnServer ()`` in ``sv_init.c`` we have the following lines. This starts SauRay(TM) with a maximum of 4 players, each with a primary trace resolution of 640x640 and with a temporal history of 2 frames. Following that, it loads up the map geometry cached earlier.

```
	...
	// set serverinfo variable
	Cvar_FullSet ("mapname", sv.name, CVAR_SERVERINFO | CVAR_NOSET);

	sauray_start(4, 640, 2);
	sauray_feedmap_quake2(sv.name);

	Com_Printf ("-------------------------------------\n");
    ...
```

## Player feeding
We need to feed player geom and vantage points based on both current and historical data in ``SV_Frame ()`` in ``sv_main.c``. The heavy lifting of actual projection work happens inside SauRay(TM). Following that we need to kick off the visibility tests.

If you'd like high ping players to be allowed with SauRay's laggy player support, type ``cvar_highping_allowed 1`` on the server's console. The threshold is currently set at pings >128ms.
Please note that this is not preferred for competitive matches and is to only allow lagging players in a non-critical context due to its additional leakage to suppress popping. Best to be combined with fake high-latency detection mechanisms such as comparing successive client hop latencies retrived from a ``tracert``.
```
	...
	}
    
	int i = 0;
	client_t* cl;
	int highping_allowed = 0;
	if (Cvar_Get("cvar_highping_allowed", "0", 0)->value != 0.0f) highping_allowed = 1;
	for (i = 0, cl = svs.clients; i < maxclients->value; i++, cl++)
	{
		if (cl->state != cs_spawned)
			continue;

		int isPlayerLagging = 0;
		if (cl->ping > 128) isPlayerLagging = 1;

		if (!highping_allowed && isPlayerLagging)
		{
			SV_DropClient(cl);
			continue;
		}

		float lastOrig[3], curOrig[3], futOrig[3], curVelocity[3], lastVelocity[3];
		lastOrig[0] = (cl->frames[cl->lastframe & UPDATE_MASK].ps.pmove.origin[0] * 0.125f) + cl->frames[cl->lastframe & UPDATE_MASK].ps.viewoffset[0];
		lastOrig[1] = (cl->frames[cl->lastframe & UPDATE_MASK].ps.pmove.origin[1] * 0.125f) + cl->frames[cl->lastframe & UPDATE_MASK].ps.viewoffset[1];
		lastOrig[2] = (cl->frames[cl->lastframe & UPDATE_MASK].ps.pmove.origin[2] * 0.125f) + cl->frames[cl->lastframe & UPDATE_MASK].ps.viewoffset[2];
		curOrig[0] = ((float)cl->edict->client->ps.pmove.origin[0] * 0.125f) + cl->edict->client->ps.viewoffset[0];
		curOrig[1] = ((float)cl->edict->client->ps.pmove.origin[1] * 0.125f) + cl->edict->client->ps.viewoffset[1];
		curOrig[2] = ((float)cl->edict->client->ps.pmove.origin[2] * 0.125f) + cl->edict->client->ps.viewoffset[2];
		curVelocity[0] = cl->edict->client->ps.pmove.velocity[0] * 0.0125f; // 0.1f == FRAMETIME, 0.1 * 0.125 == 0.0125f
		curVelocity[1] = cl->edict->client->ps.pmove.velocity[1] * 0.0125f;
		curVelocity[2] = cl->edict->client->ps.pmove.velocity[2] * 0.0125f;
		lastVelocity[0] = curOrig[0] - lastOrig[0];
		lastVelocity[1] = curOrig[1] - lastOrig[1];
		lastVelocity[2] = curOrig[2] - lastOrig[2];
		float curSpeedSq = (curVelocity[0] * curVelocity[0]) + (curVelocity[1] * curVelocity[1]) + (curVelocity[2] * curVelocity[2]);
		float lastSpeedSq = (lastVelocity[0] * lastVelocity[0]) + (lastVelocity[1] * lastVelocity[1]) + (lastVelocity[2] * lastVelocity[2]);
		float scaleSpeed = 1.0f;
		if (curSpeedSq > 0.0 && lastSpeedSq > curSpeedSq) scaleSpeed = sqrtf(lastSpeedSq / curSpeedSq);
		futOrig[0] = curOrig[0] + scaleSpeed * curVelocity[0];
		futOrig[1] = curOrig[1] + scaleSpeed * curVelocity[1];
		futOrig[2] = curOrig[2] + scaleSpeed * curVelocity[2];

		float lastAngle[3], curAngle[3], futAngle[3];
		lastAngle[0] = cl->frames[cl->lastframe & UPDATE_MASK].ps.viewangles[0] + cl->frames[cl->lastframe & UPDATE_MASK].ps.kick_angles[0];
		lastAngle[1] = cl->frames[cl->lastframe & UPDATE_MASK].ps.viewangles[1] + cl->frames[cl->lastframe & UPDATE_MASK].ps.kick_angles[1];
		lastAngle[2] = cl->frames[cl->lastframe & UPDATE_MASK].ps.viewangles[2] + cl->frames[cl->lastframe & UPDATE_MASK].ps.kick_angles[2];
		curAngle[0] = cl->edict->client->ps.viewangles[0] + cl->edict->client->ps.kick_angles[0];
		curAngle[1] = cl->edict->client->ps.viewangles[1] + cl->edict->client->ps.kick_angles[1];
		curAngle[2] = cl->edict->client->ps.viewangles[2] + cl->edict->client->ps.kick_angles[2];
		futAngle[0] = curAngle[0] + (curAngle[0] - lastAngle[0]);
		futAngle[1] = curAngle[1] + (curAngle[1] - lastAngle[1]);
		futAngle[2] = curAngle[2] + (curAngle[2] - lastAngle[2]);

		float boxMins[3], boxMaxs[3];
		boxMins[0] = boxMins[1] = boxMins[2] = -1.0f;
		boxMaxs[0] = boxMaxs[1] = boxMaxs[2] = 1.0f;
		trace_t traceResult = SV_Trace(curOrig, boxMins, boxMaxs, futOrig, cl->edict, MASK_OPAQUE); // Make sure people don't leak by slamming into walls...
		futOrig[0] = traceResult.endpos[0];
		futOrig[1] = traceResult.endpos[1];
		futOrig[2] = traceResult.endpos[2];

		sauray_player_quake2((unsigned int)i,
			cl->edict->absmin[0], cl->edict->absmin[1], cl->edict->absmin[2],
			cl->edict->absmax[0], cl->edict->absmax[1], cl->edict->absmax[2],
			curOrig[0], curOrig[1], curOrig[2],
			futOrig[0], futOrig[1], futOrig[2],
			curAngle[0], curAngle[1], curAngle[2],
			futAngle[0], futAngle[1], futAngle[2],
			cl->edict->client->ps.fov, isPlayerLagging ? 1.8f : 1.77777778f);
	}
	sauray_thread_start();
    
	// update ping based on the last known frame from all clients
    ...
```

And finally you join to fetch results.
```
	...
	SV_RunGameFrame ();

	sauray_thread_join();

	// send messages back to the clients that had packets read this frame
    ...
```
Obviously, thread start and join don't have to actually start and join threads as you can use synchronization primitives. Also, you might spot an off-by-one-frame error, and you'd be right. In practice, it didn't really affect the experience.

## Player disconnects
Don't forget to handle players that leave in ``SV_DropClient()`` in ``sv_main.c`` again.
```
	...
	}

	int i = 0;
	client_t * clientCheck;
	for (i = 0, clientCheck = svs.clients; i < maxclients->value; i++, clientCheck++)
	{
		if (drop == clientCheck)
		{
			sauray_remove_player(i);
			break;
		}
	}

	drop->state = cs_zombie;		// become free in a few seconds
    ...
```

## Packet filtering
``SV_BuildClientFrame()`` in ``sv_ents.c`` builds client updates to send out over the network. A lot of Quake's own PVS work happens in here. We need to do our own more accurate PVS work here using SauRay(TM):

```
	...
	c_fullsend = 0;

	our_client = 0;
	for (ii = 0, clientCheck = svs.clients; ii < maxclients->value; ii++, clientCheck++)
	{
		if (client == clientCheck)
		{
			our_client = ii;
			break;
		}
	}

	for (e=1 ; e<ge->num_edicts ; e++)
	{
		ent = EDICT_NUM(e);

		subject_client = -1;
		for (ii = 0, clientCheck = svs.clients; ii < maxclients->value; ii++, clientCheck++)
		{
			if (clientCheck->edict == ent)
			{
				subject_client = ii;
				break;
			}
		}
		if (subject_client != -1 && sauray_can_see_quake2(our_client, subject_client) == 0) continue;

		// ignore ents without visible models
	...
```

## Handling audio cues
Since we handle PVS separately from PHS -- and more accurately -- we need to adapt to this situation. Especially if we don't want to modify the client (which in our case we didn't). As a result, we always send the audio position in ```SV_StartSound()``` in ```sv_send.c```.

```
	...
		flags |= SND_ATTENUATION;

	// the client doesn't know that bmodels have weird origins
	// the origin can also be explicitly set
	/*
	   SauRay modification: make sure we always send the position and never the entity... 
	   entity positions are not reliable any more...
	*/
	/*if ( (entity->svflags & SVF_NOCLIENT)
		|| (entity->solid == SOLID_BSP) 
		|| origin )*/
	flags |= SND_POS;

	// always send the entity number for channel overrides
	/*
	   SauRay modification: make sure we always send the position and never the entity...
	   entity positions are not reliable any more...
	*/
	//flags |= SND_ENT;

	if (timeofs)
    ...
```
However, we must ensure that the audio position cannot be used to reconstruct the player position. Thus we obfuscate it:
```
	...
		MSG_WriteShort (&sv.multicast, sendchan);

	if (flags & SND_POS)
	{
		MSG_WritePos(&sv.multicast, origin);
		// If we do have a source obfuscate it...
		Obfuscate_Audio_Source = 1;
		MultiCast_flags = flags;
	}

	// if the sound doesn't attenuate,send it to everyone
	// (global radio chatter, voiceovers, etc)
	if (attenuation == ATTN_NONE)
		use_phs = false;

	if (channel & CHAN_RELIABLE)
	{
		if (use_phs)
			SV_Multicast(origin, MULTICAST_PHS_R);
		else
			SV_Multicast(origin, MULTICAST_ALL_R);
	}
	else
	{
		if (use_phs)
			SV_Multicast(origin, MULTICAST_PHS);
		else
			SV_Multicast(origin, MULTICAST_ALL);
	}

	// Reset this flag irrespective of whether we obfuscated anything...
	Obfuscate_Audio_Source = 0;
}
...
```

```Obfuscate_Audio_Source``` and ```MultiCast_flags``` are new variables we made to specialize our usage of ```SV_Multicast()```.
```
...
*/

// Some specialize params for audio source obfuscation
int Obfuscate_Audio_Source = 0;
int MultiCast_flags;

void SV_Multicast (vec3_t origin, multicast_t to)
...
```
Finally we craft individual obfuscated audio sources for each recipient:
```
		...
		}

		if (origin && (MultiCast_flags & SND_POS) && Obfuscate_Audio_Source)
		{
			sauray_randomize_audio_source(j,
				client->edict->s.origin[0], client->edict->s.origin[1], client->edict->s.origin[2],
				origin[0], origin[1], origin[2],
				origin, &origin[1], &origin[2],
				40.0f, 60.0f);

			sv.multicast.cursize -= 6; // We know we have position already...
			MSG_WritePos(&sv.multicast, origin); // Re-write new position...
		}

		if (reliable)
		...
```

# And that's it!
Thanks for reading. Again, if you have any questions, don't hesitate to [reach out](http://www.sauray.tech).

If you'd like to keep your eyes peeled for updates, follow us on [Twitter](https://twitter.com/antiwallhack/).

# Additional thanks
Help from [Paril](https://github.com/Paril) from [QuakeLegacy](https://quakelegacy.com/) was instrumental in getting this demo out in record time.
