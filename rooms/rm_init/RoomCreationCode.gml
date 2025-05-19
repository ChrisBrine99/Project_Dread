application_surface_draw_enable(false);
gpu_set_alphatestref(10);

// All singleton instances will be created here, and they will exist throughout the ENTIRE runtime of the game. If
// any of them are to be deleted for whatever reason before the game is closed, a lot of undefined things and 
// potential crashes will occur.
ds_map_add(global.sInstances, KEY_GAME_MANAGER, instance_create_depth(0, 0, 30, obj_game_manager));
ds_map_add(global.sInstances, KEY_CAMERA,		new str_camera(str_camera));
ds_map_add(global.sInstances, KEY_TEXTBOX,		new str_textbox(str_textbox));
ds_map_add(global.sInstances, KEY_PLAYER,		instance_create_depth(100, 100, 30, obj_player));
// NOTE -- This is the only time the default ways of struct and object creation should be used!!!

// Initialize the camera viewport and the window's dimensions; settings the starting coordinates as well.
with(CAMERA){
	camera_set_viewport(VIEWPORT_WIDTH, VIEWPORT_HEIGHT);
	camera_set_followed_object(PLAYER, true);
}

with(TEXTBOX){
	queue_new_text("Test test\ntest test test test this is a test to see if the textbox can format the gogungo\ntext\nproperly!!!", TBOX_ACTOR_PLAYER);
	activate_textbox(0);
}

// Once everything has been initialized, the first official room for the game is loaded, and the game is unpaused.
room_goto(rm_test_01);
global.flags &= ~GAME_FLAG_PAUSED;