// Since the game manager is a singleton instance that is created within this initialization room, if it 
// happens to exist BEFORE the line of code that creates the instance something has gone terrible wong and the 
// game will close itself.
if (instance_exists(obj_game_manager)){
	game_end(1);
	return;
}

// Disable drawing the application surface automatically so post-processing effects can be done properly and
// set the rendering alpha test threshold so nearly invisible elements will be completely ignored in the
// rendering pipeline.
application_surface_draw_enable(false);
gpu_set_alphatestref(10); // ~0.039

// All singleton instances will be created here, and they will exist throughout the ENTIRE runtime of the game. If
// any of them are to be deleted for whatever reason before the game is closed, a lot of undefined things and 
// potential crashes will occur.
ds_map_add(global.sInstances, obj_game_manager, instance_create_depth(0, 0, 30, obj_game_manager));
ds_map_add(global.sInstances, obj_player,		instance_create_depth(100, 100, 30, obj_player));
ds_map_add(global.sInstances, str_camera,		new str_camera(str_camera));
ds_map_add(global.sInstances, str_textbox,		new str_textbox(str_textbox));
ds_map_add(global.sInstances, str_screen_fade,	new str_screen_fade(str_screen_fade));
// NOTE -- This is the only time the default ways of struct and object creation should be used!!!

// Initialize the camera viewport and the window's dimensions; settings the starting coordinates as well.
with(CAMERA){
	camera_set_viewport(VIEWPORT_WIDTH, VIEWPORT_HEIGHT);
	camera_set_followed_object(PLAYER, true);
}

with(TEXTBOX){
	queue_new_text("THIS IS A TEST TO SEE IF THE TEXTBOX IS WORKING PROPERLY!!!", TBOX_ACTOR_PLAYER);
	queue_new_text("IF THIS CAUSES THE TEXTBOX TO REOPEN IT IS NOT WORKING!!!", TBOX_ACTOR_PLAYER);
	queue_new_text("IF THIS DOES IT MEANS IT IS WORKING PROPERLY!!!");
	queue_new_text("I have aids.", TBOX_ACTOR_PLAYER);
	activate_textbox();
}

// Once everything has been initialized, the first official room for the game is loaded, and the game is 
// unpaused to allow various game elements to start updating.
room_goto(rm_test_01);
global.flags &= ~GAME_FLAG_PAUSED;