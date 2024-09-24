extern objStruct;

static DefineMemory(void)
{
	SegDelete(0xFF0F00, 0);
	SegCreate(0xFF0F00, 0xFF5000, 0, 1, 1, 0);
	SegRename(0xFF0000, "RAM_LO");
	SegDelete(0xFFFFA000, 0);
	SegCreate(0xFFFFA000 & addrMask, 0xFFFFFD00 & addrMask, 0, 1, 1, 0);
	SegRename(0xFFFFA000 & addrMask, "RAM_HI");
	
	SegDelete(0xC00000, 0);
	SegCreate(0xC00000, 0xC0000A, 0, 1, 1, 0);
	SegRename(0xC00000, "VDP");
	DefineVariable(0xC00000, "VDP_DATA", 4);
	DefineVariable(0xC00004, "VDP_CTRL", 4);
	DefineVariable(0xC00008, "VDP_HV", 2);
	
	SegDelete(0xA00000, 0);
	SegCreate(0xA00000, 0xA02000, 0, 1, 1, 0);
	SegRename(0xA00000, "Z80_RAM");
	DefineVariable(0xA00000, "Z80_RAM", 0x2000);
	
	SegDelete(0xA10000, 0);
	SegCreate(0xA10000, 0xA1000E, 0, 1, 1, 0);
	SegRename(0xA10000, "IO");
	DefineVariable(0xA10001, "VERSION", 1);
	DefineVariable(0xA10003, "IO_DATA_1", 1);
	DefineVariable(0xA10005, "IO_DATA_2", 1);
	DefineVariable(0xA10007, "IO_DATA_3", 1);
	DefineVariable(0xA10009, "IO_CTRL_1", 1);
	DefineVariable(0xA1000B, "IO_CTRL_2", 1);
	DefineVariable(0xA1000D, "IO_CTRL_3", 1);
	
	SegDelete(0xA11100, 0);
	SegCreate(0xA11100, 0xA11202, 0, 1, 1, 0);
	SegRename(0xA11100, "Z80_IO");
	DefineVariable(0xA11100, "Z80_BUS", 2);
	DefineVariable(0xA11200, "Z80_RESET", 2);
	
	SegDelete(0xA12000, 0);
	SegCreate(0xA12000, 0xA12030, 0, 1, 1, 0);
	SegRename(0xA12000, "MCD");
	DefineVariable(0xA12000, "MCD_IRQ2", 1);
	DefineVariable(0xA12001, "MCD_RESET", 1);
	DefineVariable(0xA12002, "MCD_PROTECT", 1);
	DefineVariable(0xA12003, "MCD_MEM_MODE", 1);
	DefineVariable(0xA12004, "MCD_CDC_MODE", 2);
	DefineVariable(0xA12006, "MCD_USER_HBLANK", 2);
	DefineVariable(0xA12008, "MCD_CDC_HOST", 2);
	DefineVariable(0xA1200C, "MCD_STOPWATCH", 2);
	DefineVariable(0xA1200E, "MCD_MAIN_FLAG", 1);
	DefineVariable(0xA1200F, "MCD_SUB_FLAG", 1);
	DefineVariable(0xA12010, "MCD_MAIN_COMM_0", 1);
	DefineVariable(0xA12011, "MCD_MAIN_COMM_1", 1);
	DefineVariable(0xA12012, "MCD_MAIN_COMM_2", 1);
	DefineVariable(0xA12013, "MCD_MAIN_COMM_3", 1);
	DefineVariable(0xA12014, "MCD_MAIN_COMM_4", 1);
	DefineVariable(0xA12015, "MCD_MAIN_COMM_5", 1);
	DefineVariable(0xA12016, "MCD_MAIN_COMM_6", 1);
	DefineVariable(0xA12017, "MCD_MAIN_COMM_7", 1);
	DefineVariable(0xA12018, "MCD_MAIN_COMM_8", 1);
	DefineVariable(0xA12019, "MCD_MAIN_COMM_9", 1);
	DefineVariable(0xA1201A, "MCD_MAIN_COMM_10", 1);
	DefineVariable(0xA1201B, "MCD_MAIN_COMM_11", 1);
	DefineVariable(0xA1201C, "MCD_MAIN_COMM_12", 1);
	DefineVariable(0xA1201D, "MCD_MAIN_COMM_13", 1);
	DefineVariable(0xA1201E, "MCD_MAIN_COMM_14", 1);
	DefineVariable(0xA1201F, "MCD_MAIN_COMM_15", 1);
	DefineVariable(0xA12020, "MCD_SUB_COMM_0", 1);
	DefineVariable(0xA12021, "MCD_SUB_COMM_1", 1);
	DefineVariable(0xA12022, "MCD_SUB_COMM_2", 1);
	DefineVariable(0xA12023, "MCD_SUB_COMM_3", 1);
	DefineVariable(0xA12024, "MCD_SUB_COMM_4", 1);
	DefineVariable(0xA12025, "MCD_SUB_COMM_5", 1);
	DefineVariable(0xA12026, "MCD_SUB_COMM_6", 1);
	DefineVariable(0xA12027, "MCD_SUB_COMM_7", 1);
	DefineVariable(0xA12028, "MCD_SUB_COMM_8", 1);
	DefineVariable(0xA12029, "MCD_SUB_COMM_9", 1);
	DefineVariable(0xA1202A, "MCD_SUB_COMM_10", 1);
	DefineVariable(0xA1202B, "MCD_SUB_COMM_11", 1);
	DefineVariable(0xA1202C, "MCD_SUB_COMM_12", 1);
	DefineVariable(0xA1202D, "MCD_SUB_COMM_13", 1);
	DefineVariable(0xA1202E, "MCD_SUB_COMM_14", 1);
	DefineVariable(0xA1202F, "MCD_SUB_COMM_15", 1);
	
	DefineVariable(0xFF0F00, "ipx_vsync", 1);
	DefineVariable(0xFF0F01, "time_attack_mode", 1);
	DefineVariable(0xFF0F02, "saved_stage", 2);
	DefineVariable(0xFF0F10, "time_attack_time", 4);
	DefineVariable(0xFF0F14, "time_attack_stage", 2);
	DefineVariable(0xFF0F16, "ipx_vdp_reg_81", 2);
	DefineVariable(0xFF0F18, "time_attack_unlock", 1);
	DefineVariable(0xFF0F19, "unknown_buram_var", 1);
	DefineVariable(0xFF0F1A, "good_future_zones", 1);
	DefineVariable(0xFF0F1C, "demo_id", 1);
	DefineVariable(0xFF0F1D, "title_flags", 1);
	DefineVariable(0xFF0F1F, "save_disabled", 1);
	DefineVariable(0xFF0F20, "time_stones", 1);
	DefineVariable(0xFF0F21, "current_special_stage", 1);
	DefineVariable(0xFF0F22, "palette_clear_flags", 1);
	DefineVariable(0xFF0F24, "ending_id", 1);
	DefineVariable(0xFF0F25, "special_stage_lost", 1);
	DefineVariable(0xFF1000, "unknown_buffer", 0x200);
	DefineVariable(0xFF1200, "map_object_states", 0x300);
	DefineVariable(0xFF1502, "stage_restart", 2);
	DefineVariable(0xFF1504, "stage_frames", 2);
	DefineVariable(0xFF1506, "zone", 1);
	DefineVariable(0xFF1507, "act", 1);
	DefineVariable(0xFF1508, "lives", 1);
	DefineVariable(0xFF1509, "use_player_2", 1);
	DefineVariable(0xFF150A, "drown_timer", 2);
	DefineVariable(0xFF150C, "time_over", 1);
	DefineVariable(0xFF150D, "lives_flags", 1);
	DefineVariable(0xFF150E, "update_hud_lives", 1);
	DefineVariable(0xFF150F, "update_hud_rings", 1);
	DefineVariable(0xFF1510, "update_hud_time", 1);
	DefineVariable(0xFF1511, "update_hud_score", 1);
	DefineVariable(0xFF1512, "rings", 2);
	DefineVariable(0xFF1514, "time", 1);
	DefineVariable(0xFF1515, "time_minutes", 1);
	DefineVariable(0xFF1516, "time_seconds", 1);
	DefineVariable(0xFF1517, "time_frames", 1);
	DefineVariable(0xFF1518, "score", 4);
	DefineVariable(0xFF151C, "nem_art_queue_flags", 1);
	DefineVariable(0xFF151D, "palette_fade_flags", 1);
	DefineVariable(0xFF151E, "shield", 1);
	DefineVariable(0xFF151F, "invincible", 1);
	DefineVariable(0xFF1520, "speed_shoes", 1);
	DefineVariable(0xFF1521, "time_warp", 1);
	DefineVariable(0xFF1522, "spawn_mode", 1);
	DefineVariable(0xFF1523, "saved_spawn_mode", 1);
	DefineVariable(0xFF1524, "saved_x", 2);
	DefineVariable(0xFF1526, "saved_y", 2);
	DefineVariable(0xFF1528, "warp_rings", 2);
	DefineVariable(0xFF152A, "saved_time", 4);
	DefineVariable(0xFF152E, "time_zone", 1);
	DefineVariable(0xFF1530, "saved_bottom_bound", 2);
	DefineVariable(0xFF1532, "saved_camera_fg_x", 2);
	DefineVariable(0xFF1534, "saved_camera_fg_y", 2);
	DefineVariable(0xFF1536, "saved_camera_bg_x", 2);
	DefineVariable(0xFF1538, "saved_camera_bg_y", 2);
	DefineVariable(0xFF153A, "saved_camera_bg2_x", 2);
	DefineVariable(0xFF153C, "saved_camera_bg2_y", 2);
	DefineVariable(0xFF153E, "saved_camera_bg3_x", 2);
	DefineVariable(0xFF1540, "saved_camera_bg3_y", 2);
	DefineVariable(0xFF1542, "saved_water_height", 1);
	DefineVariable(0xFF1543, "saved_water_routine", 1);
	DefineVariable(0xFF1544, "saved_water_fullscreen", 1);
	DefineVariable(0xFF1545, "warp_lives_flags", 1);
	DefineVariable(0xFF1546, "warp_spawn_mode", 1);
	DefineVariable(0xFF1548, "warp_x", 2);
	DefineVariable(0xFF154A, "warp_y", 2);
	DefineVariable(0xFF154C, "warp_player_flags", 1);
	DefineVariable(0xFF154E, "warp_bottom_bound", 2);
	DefineVariable(0xFF1550, "warp_camera_fg_x", 2);
	DefineVariable(0xFF1552, "warp_camera_fg_y", 2);
	DefineVariable(0xFF1554, "warp_camera_bg_x", 2);
	DefineVariable(0xFF1556, "warp_camera_bg_y", 2);
	DefineVariable(0xFF1558, "warp_camera_bg2_x", 2);
	DefineVariable(0xFF155A, "warp_camera_bg2_y", 2);
	DefineVariable(0xFF155C, "warp_camera_bg3_x", 2);
	DefineVariable(0xFF155E, "warp_camera_bg3_y", 2);
	DefineVariable(0xFF1560, "warp_water_height", 2);
	DefineVariable(0xFF1562, "warp_water_routine", 1);
	DefineVariable(0xFF1563, "warp_water_fullscreen", 1);
	DefineVariable(0xFF1564, "warp_ground_speed", 2);
	DefineVariable(0xFF1566, "warp_x_speed", 2);
	DefineVariable(0xFF1568, "warp_y_speed", 2);
	DefineVariable(0xFF156A, "good_future", 1);
	DefineVariable(0xFF156B, "powerup", 1);
	DefineVariable(0xFF156C, "unknown_stage_flag", 1);
	DefineVariable(0xFF156D, "projector_destroyed", 1);
	DefineVariable(0xFF156E, "special_stage", 1);
	DefineVariable(0xFF156F, "combine_ring", 1);
	DefineVariable(0xFF1570, "warp_time", 4);
	DefineVariable(0xFF1574, "section_id", 2);
	DefineVariable(0xFF1577, "amy_captured", 1);
	DefineVariable(0xFF1578, "next_1up_score", 4);
	DefineVariable(0xFF157C, "debug_angle", 1);
	DefineVariable(0xFF157D, "debug_angle_shift", 1);
	DefineVariable(0xFF157E, "debug_quadrant", 1);
	DefineVariable(0xFF157F, "debug_floor_dist", 1);
	DefineVariable(0xFF1580, "demo_mode", 2);
	DefineVariable(0xFF1584, "s1_credits_index", 2);
	DefineVariable(0xFF1586, "hardware_version", 1);
	DefineVariable(0xFF1588, "debug_cheat", 2);
	DefineVariable(0xFF158A, "init_flag", 4);
	DefineVariable(0xFF158E, "checkpoint", 1);
	DefineVariable(0xFF1590, "good_future_acts", 1);
	DefineVariable(0xFF1591, "saved_mini_player", 1);
	DefineVariable(0xFF1593, "warp_mini_player", 1);
	DefineVariable(0xFF1600, "flower_positions", 0x300);
	DefineVariable(0xFF1900, "flower_count", 3);
	DefineVariable(0xFF1903, "fade_enable_display", 1);
	DefineVariable(0xFF1904, "debug_object", 1);
	DefineVariable(0xFF1906, "debug_mode", 2);
	DefineVariable(0xFF190A, "stage_vblank_frames", 4);
	DefineVariable(0xFF190E, "time_stop", 2);
	DefineVariable(0xFF1910, "log_spike_anim_timer", 1);
	DefineVariable(0xFF1911, "log_spike_anim_frame", 1);
	DefineVariable(0xFF1912, "ring_anim_timer", 1);
	DefineVariable(0xFF1913, "ring_anim_frame", 1);
	DefineVariable(0xFF1914, "unknown_anim_timer", 1);
	DefineVariable(0xFF1915, "unknown_anim_frame", 1);
	DefineVariable(0xFF1916, "ring_loss_anim_timer", 1);
	DefineVariable(0xFF1917, "ring_loss_anim_frame", 1);
	DefineVariable(0xFF1918, "ring_loss_anim_accum", 1);
	DefineVariable(0xFF1926, "camera_fg_x_copy", 4);
	DefineVariable(0xFF192A, "camera_fg_y_copy", 4);
	DefineVariable(0xFF192E, "camera_bg_x_copy", 4);
	DefineVariable(0xFF1932, "camera_bg_y_copy", 4);
	DefineVariable(0xFF1936, "camera_bg2_x_copy", 4);
	DefineVariable(0xFF193A, "camera_bg2_y_copy", 4);
	DefineVariable(0xFF193E, "camera_bg3_x_copy", 4);
	DefineVariable(0xFF1942, "camera_bg3_y_copy", 4);
	DefineVariable(0xFF1946, "scroll_flags_fg_copy", 2);
	DefineVariable(0xFF1948, "scroll_flags_bg_copy", 2);
	DefineVariable(0xFF194A, "scroll_flags_bg2_copy", 2);
	DefineVariable(0xFF194C, "scroll_flags_bg3_copy", 2);
	DefineVariable(0xFF194E, "debug_map_block", 2);
	DefineVariable(0xFF1950, "ccz_no_bumper", 1);
	DefineVariable(0xFF1954, "debug_subtype_2", 1);
	DefineVariable(0xFF1955, "water_sway_angle", 1);
	DefineVariable(0xFF1956, "layer", 1);
	DefineVariable(0xFF1957, "stage_started", 1);
	DefineVariable(0xFF1958, "boss_music", 1);
	DefineVariable(0xFF195A, "wwz_beam_mode", 1);
	DefineVariable(0xFF195B, "mini_player", 1);
	DefineVariable(0xFF1980, "anim_art_buffer", 0x480);
	DefineVariable(0xFF1E00, "scroll_section_speeds", 0x200);
	DefineVariable(0xFF2000, "map_blocks", 0x2000);
	DefineVariable(0xFF4000, "unknown_buffer_2", 0x1000);
}

static DefineVariables(void)
{
	DefineVariable(0xFFFFA000 & addrMask, "map_layout", 0x800);
	DefineVariable(0xFFFFA800 & addrMask, "deform_buffer", 0x200);
	DefineVariable(0xFFFFAA00 & addrMask, "nem_code_table", 0x200);
	DefineVariable(0xFFFFAC00 & addrMask, "object_draw_queue", 0x400);
	DefineVariable(0xFFFFC800 & addrMask, "player_art_buffer", 0x300);
	DefineVariable(0xFFFFCB00 & addrMask, "player_positions", 0x100);
	DefineVariable(0xFFFFCC00 & addrMask, "hscroll", 0x400);
	DefineVariable(0xFFFFF00A & addrMask, "fm_sound_queue_1", 1);
	DefineVariable(0xFFFFF00B & addrMask, "fm_sound_queue_2", 1);
	DefineVariable(0xFFFFF00C & addrMask, "fm_sound_queue_3", 1);
	DefineVariable(0xFFFFF600 & addrMask, "game_mode", 1);
	DefineVariable(0xFFFFF602 & addrMask, "player_ctrl_hold", 1);
	DefineVariable(0xFFFFF603 & addrMask, "player_ctrl_tap", 1);
	DefineVariable(0xFFFFF604 & addrMask, "p1_ctrl_hold", 1);
	DefineVariable(0xFFFFF605 & addrMask, "p1_ctrl_tap", 1);
	DefineVariable(0xFFFFF606 & addrMask, "p2_ctrl_hold", 1);
	DefineVariable(0xFFFFF607 & addrMask, "p2_ctrl_tap", 1);
	DefineVariable(0xFFFFF60C & addrMask, "vdp_reg_81", 2);
	DefineVariable(0xFFFFF614 & addrMask, "global_timer", 2);
	DefineVariable(0xFFFFF616 & addrMask, "vscroll_screen", 4);
	DefineVariable(0xFFFFF61A & addrMask, "hscroll_screen", 4);
	DefineVariable(0xFFFFF624 & addrMask, "vdp_reg_8a", 2);
	DefineVariable(0xFFFFF626 & addrMask, "palette_fade_start", 1);
	DefineVariable(0xFFFFF627 & addrMask, "palette_fade_length", 1);
	DefineVariable(0xFFFFF628 & addrMask, "vblank_e_count", 1);
	DefineVariable(0xFFFFF62A & addrMask, "vblank_routine", 1);
	DefineVariable(0xFFFFF62C & addrMask, "sprite_count", 1);
	DefineVariable(0xFFFFF636 & addrMask, "rng_seed", 4);
	DefineVariable(0xFFFFF63A & addrMask, "paused", 2);
	DefineVariable(0xFFFFF640 & addrMask, "dma_command_low", 2);
	DefineVariable(0xFFFFF646 & addrMask, "water_height", 2);
	DefineVariable(0xFFFFF648 & addrMask, "water_height_logical", 2);
	DefineVariable(0xFFFFF64A & addrMask, "target_water_height", 2);
	DefineVariable(0xFFFFF64C & addrMask, "water_move_speed", 1);
	DefineVariable(0xFFFFF64D & addrMask, "water_routine", 1);
	DefineVariable(0xFFFFF64E & addrMask, "water_fullscreen", 1);
	DefineVariable(0xFFFFF64F & addrMask, "hblank_updates", 1);
	DefineVariable(0xFFFFF666 & addrMask, "anim_art_frames", 6);
	DefineVariable(0xFFFFF66C & addrMask, "anim_art_timers", 6);
	DefineVariable(0xFFFFF680 & addrMask, "nem_art_queue", 0x60);
	DefineVariable(0xFFFFF6E0 & addrMask, "nem_art_write", 4);
	DefineVariable(0xFFFFF6E4 & addrMask, "nem_art_repeat", 4);
	DefineVariable(0xFFFFF6E8 & addrMask, "nem_art_pixel", 4);
	DefineVariable(0xFFFFF6EC & addrMask, "nem_art_row", 4);
	DefineVariable(0xFFFFF6F0 & addrMask, "nem_art_read", 4);
	DefineVariable(0xFFFFF6F4 & addrMask, "nem_art_shift", 4);
	DefineVariable(0xFFFFF6F8 & addrMask, "nem_art_tile_count", 2);
	DefineVariable(0xFFFFF6FA & addrMask, "nem_art_proc_tile_count", 2);
	DefineVariable(0xFFFFF6FC & addrMask, "hblank_flag", 2);
	DefineVariable(0xFFFFF700 & addrMask, "camera_fg_x", 4);
	DefineVariable(0xFFFFF704 & addrMask, "camera_fg_y", 4);
	DefineVariable(0xFFFFF708 & addrMask, "camera_bg_x", 4);
	DefineVariable(0xFFFFF70C & addrMask, "camera_bg_y", 4);
	DefineVariable(0xFFFFF710 & addrMask, "camera_bg2_x", 4);
	DefineVariable(0xFFFFF714 & addrMask, "camera_bg2_y", 4);
	DefineVariable(0xFFFFF718 & addrMask, "camera_bg3_x", 4);
	DefineVariable(0xFFFFF71C & addrMask, "camera_bg3_y", 4);
	DefineVariable(0xFFFFF720 & addrMask, "target_left_bound", 2);
	DefineVariable(0xFFFFF722 & addrMask, "target_right_bound", 2);
	DefineVariable(0xFFFFF724 & addrMask, "target_top_bound", 2);
	DefineVariable(0xFFFFF726 & addrMask, "target_bottom_bound", 2);
	DefineVariable(0xFFFFF728 & addrMask, "left_bound", 2);
	DefineVariable(0xFFFFF72A & addrMask, "right_bound", 2);
	DefineVariable(0xFFFFF72C & addrMask, "top_bound", 2);
	DefineVariable(0xFFFFF72E & addrMask, "bottom_bound", 2);
	DefineVariable(0xFFFFF730 & addrMask, "unused_f730", 2);
	DefineVariable(0xFFFFF732 & addrMask, "left_bound_unknown", 2);
	DefineVariable(0xFFFFF73A & addrMask, "scroll_x_diff", 2);
	DefineVariable(0xFFFFF73C & addrMask, "scroll_y_diff", 2);
	DefineVariable(0xFFFFF73E & addrMask, "camera_y_center", 2);
	DefineVariable(0xFFFFF740 & addrMask, "unused_f740", 1);
	DefineVariable(0xFFFFF741 & addrMask, "unused_f741", 1);
	DefineVariable(0xFFFFF742 & addrMask, "event_routine", 2);
	DefineVariable(0xFFFFF744 & addrMask, "scroll_lock", 2);
	DefineVariable(0xFFFFF746 & addrMask, "unused_f746", 2);
	DefineVariable(0xFFFFF748 & addrMask, "unused_f748", 2);
	DefineVariable(0xFFFFF74A & addrMask, "map_block_cross_fg_x", 1);
	DefineVariable(0xFFFFF74B & addrMask, "map_block_cross_fg_y", 1);
	DefineVariable(0xFFFFF74C & addrMask, "map_block_cross_bg_x", 1);
	DefineVariable(0xFFFFF74D & addrMask, "map_block_cross_bg_y", 1);
	DefineVariable(0xFFFFF74E & addrMask, "map_block_cross_bg2_x", 1);
	DefineVariable(0xFFFFF74F & addrMask, "map_block_cross_bg2_y", 1);
	DefineVariable(0xFFFFF750 & addrMask, "map_block_cross_bg3_x", 1);
	DefineVariable(0xFFFFF751 & addrMask, "map_block_cross_bg3_y", 1);
	DefineVariable(0xFFFFF754 & addrMask, "scroll_flags_fg", 2);
	DefineVariable(0xFFFFF756 & addrMask, "scroll_flags_bg", 2);
	DefineVariable(0xFFFFF758 & addrMask, "scroll_flags_bg2", 2);
	DefineVariable(0xFFFFF75A & addrMask, "scroll_flags_bg3", 2);
	DefineVariable(0xFFFFF75C & addrMask, "bottom_bound_shift", 2);
	DefineVariable(0xFFFFF75F & addrMask, "sneeze_flag", 1);
	DefineVariable(0xFFFFF760 & addrMask, "player_top_speed", 2);
	DefineVariable(0xFFFFF762 & addrMask, "player_acceleration", 2);
	DefineVariable(0xFFFFF764 & addrMask, "player_deceleration", 2);
	DefineVariable(0xFFFFF766 & addrMask, "player_prev_frame", 1);
	DefineVariable(0xFFFFF767 & addrMask, "update_player_art", 1);
	DefineVariable(0xFFFFF768 & addrMask, "angle_buffer_1", 1);
	DefineVariable(0xFFFFF76A & addrMask, "angle_buffer_2", 1);
	DefineVariable(0xFFFFF76C & addrMask, "map_object_routine", 1);
	DefineVariable(0xFFFFF76E & addrMask, "prev_map_object_chunk", 2);
	DefineVariable(0xFFFFF770 & addrMask, "map_object_chunk_right", 4);
	DefineVariable(0xFFFFF774 & addrMask, "map_object_chunk_left", 4);
	DefineVariable(0xFFFFF778 & addrMask, "map_object_chunk_null_1", 4);
	DefineVariable(0xFFFFF77C & addrMask, "map_object_chunk_null_2", 4);
	DefineVariable(0xFFFFF780 & addrMask, "bored_timer", 2);
	DefineVariable(0xFFFFF782 & addrMask, "bored_timer_p2", 2);
	DefineVariable(0xFFFFF784 & addrMask, "time_warp_direction", 1);
	DefineVariable(0xFFFFF786 & addrMask, "time_warp_timer", 2);
	DefineVariable(0xFFFFF788 & addrMask, "look_mode", 1);
	DefineVariable(0xFFFFF78A & addrMask, "demo_data", 4);
	DefineVariable(0xFFFFF78E & addrMask, "demo_data_cursor", 2);
	DefineVariable(0xFFFFF790 & addrMask, "s1_demo_cursor", 2);
	DefineVariable(0xFFFFF796 & addrMask, "map_collision", 4);
	DefineVariable(0xFFFFF7A0 & addrMask, "camera_x_center", 2);
	DefineVariable(0xFFFFF7A7 & addrMask, "boss_flags", 1);
	DefineVariable(0xFFFFF7A8 & addrMask, "player_positions_index", 2);
	DefineVariable(0xFFFFF7AA & addrMask, "boss_fight", 1);
	DefineVariable(0xFFFFF7AC & addrMask, "special_map_chunks", 4);
	DefineVariable(0xFFFFF7B0 & addrMask, "palette_cycle_steps", 7);
	DefineVariable(0xFFFFF7B7 & addrMask, "palette_cycle_timers", 7);
	DefineVariable(0xFFFFF7C7 & addrMask, "wind_tunnel_flag", 1);
	DefineVariable(0xFFFFF7CA & addrMask, "water_slide_flag", 1);
	DefineVariable(0xFFFFF7CC & addrMask, "ctrl_locked", 1);
	DefineVariable(0xFFFFF7D0 & addrMask, "score_chain", 2);
	DefineVariable(0xFFFFF7D2 & addrMask, "time_bonus", 2);
	DefineVariable(0xFFFFF7D4 & addrMask, "ring_bonus", 2);
	DefineVariable(0xFFFFF7D6 & addrMask, "update_hud_bonus", 1);
	DefineVariable(0xFFFFF7DA & addrMask, "saved_sr", 2);
	DefineVariable(0xFFFFF7E0 & addrMask, "button_flags", 0x20);
	DefineVariable(0xFFFFF800 & addrMask, "sprites", 0x200);
	DefineVariable(0xFFFFFA00 & addrMask, "water_fade_palette", 0x80);
	DefineVariable(0xFFFFFA80 & addrMask, "water_palette", 0x80);
	DefineVariable(0xFFFFFB00 & addrMask, "palette", 0x80);
	DefineVariable(0xFFFFFB80 & addrMask, "fade_palette", 0x80);
	
	objStruct = FindStruct("obj");
	if (objStruct == -1) {
		objStruct = AddStrucEx(-1, "obj", 0);
		
		AddStrucMember(objStruct, "id", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "sprite_flags", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "sprite_tile", -1, FF_WORD, -1, 2);
		AddStrucMember(objStruct, "sprites", -1, FF_DWRD, -1, 4);
		AddStrucMember(objStruct, "x", -1, FF_DWRD, -1, 2);
		AddStrucMember(objStruct, "y", -1, FF_DWRD, -1, 2);
		AddStrucMember(objStruct, "x_speed", -1, FF_WORD, -1, 2);
		AddStrucMember(objStruct, "y_speed", -1, FF_WORD, -1, 2);
		AddStrucMember(objStruct, "ground_speed", -1, FF_WORD, -1, 2);
		AddStrucMember(objStruct, "collide_height", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "collide_width", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "sprite_layer", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "width", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "sprite_frame", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "anim_frame", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "anim_id", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "prev_anim_id", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "anim_time", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_1f", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "collide_type", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "collide_status", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "flags", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "state_id", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "routine", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "routine_2", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "angle", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_27", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "subtype", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "subtype_2", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_2A", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_2B", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_2C", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_2D", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_2E", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_2F", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_30", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_31", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_32", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_33", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_34", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_35", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_36", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_37", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_38", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_39", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_3A", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_3B", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_3C", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_3D", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_3E", -1, FF_BYTE, -1, 1);
		AddStrucMember(objStruct, "var_3F", -1, FF_BYTE, -1, 1);
	}
	
	if (FindStruct("DEBUG_ITEM") == -1) {
		auto dbg;
		dbg = AddStrucEx(-1, "DEBUG_ITEM", 0);
		
		AddStrucMember(dbg, "id", -1, FF_BYTE, -1, 1);
		AddStrucMember(dbg, "priority", -1, FF_BYTE, -1, 1);
		AddStrucMember(dbg, "sprites", -1, FF_DWRD | FF_0OFF, 0, 4);
		AddStrucMember(dbg, "tile", -1, FF_WORD, -1, 2);
		AddStrucMember(dbg, "subtype", -1, FF_BYTE, -1, 1);
		AddStrucMember(dbg, "flip", -1, FF_BYTE, -1, 1);
		AddStrucMember(dbg, "subtype2", -1, FF_BYTE, -1, 1);
		AddStrucMember(dbg, "frame", -1, FF_BYTE, -1, 1);
	}
	
	auto i;
	for (i = (0xFFFFD000 & addrMask); i < (0xFFFFF000 & addrMask); i = i + 0x40) {
		MakeStructEx(i, -1, "obj");
	}
	
	MakeName(0xFFFFD000 & addrMask, "player_object");
	MakeName(0xFFFFD040 & addrMask, "player_2_object");
	MakeName(0xFFFFD080 & addrMask, "hud_score_object");
	MakeName(0xFFFFD0C0 & addrMask, "hud_lives_object");
	MakeName(0xFFFFD100 & addrMask, "title_card_object");
	MakeName(0xFFFFD140 & addrMask, "hud_rings_object");
	MakeName(0xFFFFD180 & addrMask, "shield_object");
	MakeName(0xFFFFD1C0 & addrMask, "bubbles_object");
	MakeName(0xFFFFD200 & addrMask, "inv_stars_1_object");
	MakeName(0xFFFFD240 & addrMask, "inv_stars_2_object");
	MakeName(0xFFFFD280 & addrMask, "inv_stars_3_object");
	MakeName(0xFFFFD2C0 & addrMask, "inv_stars_4_object");
	MakeName(0xFFFFD300 & addrMask, "time_star_1_object");
	MakeName(0xFFFFD340 & addrMask, "time_star_2_object");
	MakeName(0xFFFFD380 & addrMask, "time_star_3_object");
	MakeName(0xFFFFD3C0 & addrMask, "time_star_4_object");
	MakeName(0xFFFFD7C0 & addrMask, "hud_icon_object");
	MakeName(0xFFFFD800 & addrMask, "object_spawn_pool");
}