#include <Cheat-Acid>

//Handle aExploitCvars

public Plugin myinfo =
{
	name = "Cheat-Acid: Client Protect",
	author = "Playa",
	description = "Anti Cheat System. This Module prevents the Client from using Exploits",
	version = PLUGIN_VERSION,
	url = "FunForBattle"
}

public void OnPluginStart()
{
	//aExploitCvars = CreateArray();// 256);
}

new aExploitCvars [41][4]/*[1]*/ = // Cvars - Value Range Start - Value Range End - Action
{	//			[0]			[1]			[2]			[3]
	/*[0]*/{"cl_clock_correction", float 1.0, float 1.0, 2},
	/*[1]*/{"cl_leveloverview", float 0.0, float 0.0, 2},
	/*[2]*/{"cl_overdraw_test", float 0.0, float 0.0, 2},
	/*[3]*/{"cl_particles_show_bbox", float 0.0, float 0.0, 2},
	/*[4]*/{"cl_phys_timescale", float 1.0, float 1.0, 2},
	/*[5]*/{"cl_showevents", float 0.0, float 0.0, 2},
	/*[6]*/{"fog_enable", float 1.0, float 1.0, 2},
	/*[7]*/{"host_timescale", float 1.0, float 1.0, 2}, // GetConVarInt("");	host_timescale #OnConvarChange nicht vergessen
	/*[8]*/{"mat_fillrate", float 0.0, float 0.0, 2},
	/*[9]*/{"mat_proxy", float 0.0, float 0.0, 2},
	/*[10]*/{"mat_wireframe", float 0.0, float 0.0, 2},
	/*[11]*/{"mem_force_flush", float 0.0, float 0.0, 2},
	/*[12]*/{"snd_show", float 0.0, float 0.0, 2},
	/*[13]*/{"snd_visualize", float 0.0, float 0.0, 2},
	/*[14]*/{"sv_cheats", float 0.0, float 0.0, 2}, // Add a serversided check, cheats should be ALLWAYS disabled, else we need to fix ALL security problems comming with it
	/*[15]*/{"sv_consistency", float 1.0, float 1.0, 2},
	/*[16]*/{"sv_gravity", float 800.0, float 800.0, 2}, // GetConVarInt("");	sv_gravity #OnConvarChange nicht vergessen
	/*[17]*/{"r_aspectratio", float 0.0, float 0.0, 2},
	/*[18]*/{"r_colorstaticprops", float 0.0, float 0.0, 2},
	/*[19]*/{"r_DispWalkable", float 0.0, float 0.0, 2},
	/*[20]*/{"r_DrawBeams", float 1.0, float 1.0, 2},
	/*[21]*/{"r_drawbrushmodels", float 1.0, float 1.0, 2},
	/*[22]*/{"r_drawclipbrushes", float 0.0, float 0.0, 2},
	/*[23]*/{"r_drawdecals", float 1.0, float 1.0, 2},
	/*[24]*/{"r_drawentities", float 1.0, float 1.0, 2},
	/*[25]*/{"r_drawopaqueworld", float 1.0, float 1.0, 2},
	/*[26]*/{"r_drawothermodels", float 1.0, float 1.0, 2},
	/*[27]*/{"r_drawparticles", float 1.0, float 1.0, 2},
	/*[28]*/{"r_drawrenderboxes", float 0.0, float 0.0, 2},
	/*[29]*/{"r_drawtranslucentworld", float 1.0, float 1.0, 2},
	/*[30]*/{"r_shadowwireframe", float 0.0, float 0.0, 2},
	/*[31]*/{"r_skybox", float 1.0, float 1.0, 2},
	/*[32]*/{"r_visocclusion", float 0.0, float 0.0, 2}, // ---
	/*[33]*/{"vcollide_wireframe", float 0.0, float 0.0, 2}, // ---
	/*[34]*/{"sourcemod_version", float -0.0, float -0.0, 1},
	/*[35]*/{"metamod_version", float -0.0, float -0.0, 1},
	/*[36]*/{"bat_version", float -0.0, float -0.0, 1},
	/*[37]*/{"est_version", float -0.0, float -0.0, 1},
	/*[38]*/{"eventscripts_ver", float -0.0, float -0.0, 1},
	/*[39]*/{"mani_admin_plugin_version", float -0.0, float -0.0, 1},
	/*[40]*/{"zb_version", float -0.0, float -0.0, 1},
	/*[41]*/{"mat_dxlevel", float 70.0, float ###, 1} // Find Max Value
}


///
/*
new g_HackCVarsComp[] = {
	COMP_EQUAL,	// cl_clock_correction	15	0
	COMP_EQUAL,	// cl_leveloverview	9	1
	COMP_EQUAL,	// cl_overdraw_test		2
	COMP_EQUAL,	// cl_particles_show_bbox 11	3
	COMP_EQUAL,	// cl_phys_timescale		4
	COMP_EQUAL,	// cl_showevents		5
	COMP_EQUAL,	// fog_enable		7	6
	COMP_EQUAL,	// host_timescale	2	7
	COMP_EQUAL,	// mat_fillrate		8	8
	COMP_EQUAL,	// mat_proxy		5	9
	COMP_EQUAL,	// mat_wireframe		10
	COMP_EQUAL,	// mem_force_flush	10	11
	COMP_EQUAL,	// snd_show		17	12
	COMP_EQUAL,	// snd_visualize	18	13
	COMP_EQUAL,	// sv_cheats		0	14
	COMP_EQUAL,	// sv_consistency	3	15
	//COMP_EQUAL,	// sv_gravity		1	16
	COMP_EQUAL,	// r_aspectratio	14	17
	COMP_EQUAL,	// r_colorstaticprops	19	18
	COMP_EQUAL,	// r_DispWalkable	20	19
	COMP_EQUAL,	// r_DrawBeams		21	20
	COMP_EQUAL,	// r_drawbrushmodels	22	21
	COMP_EQUAL,	// r_drawclipbrushes	23	22
	COMP_EQUAL,	// r_drawdecals		24	23
	COMP_EQUAL,	// r_drawentities		24
	COMP_EQUAL,	// r_drawopaqueworld		25
	COMP_EQUAL,	// r_drawothermodels	16	26
	COMP_EQUAL,	// r_drawparticles	4	27
	COMP_EQUAL,	// r_drawrenderboxes	12	28
	COMP_EQUAL,	// r_drawtranslucentworld	29
	COMP_EQUAL,	// r_shadowwireframe	6	30
	COMP_EQUAL,	// r_skybox			31
	COMP_EQUAL,	// r_visocclusion		32
	COMP_EQUAL,	// vcollide_wireframe	13	33
	COMP_NONEXIST,	// sourcemod_version		34
	COMP_NONEXIST,	// metamod_version		35
	COMP_NONEXIST,	// bat_version			36
	COMP_NONEXIST,	// est_version			37
	COMP_NONEXIST,	// eventscripts_ver		38
	COMP_NONEXIST,	// mani_admin_plugin_version	39
	COMP_NONEXIST,	// zb_version			40
	COMP_GREATER	// mat_dxlevel			41
};
*/