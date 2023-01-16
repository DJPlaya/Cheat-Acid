#ifndef HIGHOMEGA_SAURAY_H
#define HIGHOMEGA_SAURAY_H

#ifdef __cplusplus
#include "world.h"

extern "C" {
#endif
	extern int sauray_debug_mode;
	extern unsigned int sauray_debug_w;
	extern unsigned int sauray_debug_h;
	void sauray_setdebug(unsigned int debug_w, unsigned int debug_h);
	int sauray_start(unsigned int max_players, unsigned int player_trace_res, unsigned int sauray_temporal_history_amount);
	int sauray_feedmap_quake2(char *mapName);
	void sauray_player_quake2(unsigned int player_id,
		float absmin_x, float absmin_y, float absmin_z,
		float absmax_x, float absmax_y, float absmax_z,
		float e1x, float e1y, float e1z,
		float e2x, float e2y, float e2z,
		int qa1_yaw, int qa1_pitch, int qa1_roll,
		int qa2_yaw, int qa2_pitch, int qa2_roll,
		float yfov, float whr);
	int sauray_can_see_quake2(unsigned int viewer, unsigned int subject);
	void sauray_randomize_audio_source(unsigned int listenerId,
		float listenerX, float listenerY, float listenerZ,
		float originX, float originY, float originZ,
		float* retOriginX, float* retOriginY, float* retOriginZ,
		float randDistance, float updateDistanceThreshold);
	void sauray_remove_player(unsigned int player);
	int sauray_loop();         // Non-threaded mode..
	int sauray_thread_start(); // Threaded mode...
	int sauray_thread_join();

#ifdef __cplusplus
}
#endif

#endif