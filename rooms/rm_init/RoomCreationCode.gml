// Since the game manager is a singleton instance that is created within this initialization room, if it happens to exist BEFORE the line of 
// code that creates the instance something has gone terrible wong and the game will close itself.
if (instance_exists(obj_game_manager)){
	game_end(1);
	return;
}

// Disable drawing the application surface automatically so post-processing effects can be done properly and set the rendering alpha test 
// threshold so nearly invisible elements will be completely ignored in the rendering pipeline.
application_surface_draw_enable(false);
gpu_set_alphatestref(2); // ~0.0078

// All singleton instances that are created within the block of code below this comment. The object singletons are created in a slightly
// different manner from their struct counterparts; they're created with the default GML instance creation function, and then have their
// references stored locally so they can be passed in and stored by the global.sInstances struct for easy reference.
var _gameManager 	= instance_create_depth(0, 0, 30, obj_game_manager);
var _player			= instance_create_depth(100, 100, 30, obj_player);
with(global.singletons){
	// These key/value pairs will prevent additional instances of the game manager and player objects from being created using the wrapper
	// function instance_create_object. They also prevent destruction of both objects through use of the function instance_destroy_object.
	ds_map_add(objSingletons, obj_game_manager, 			0);
	ds_map_add(objSingletons, obj_player, 					1);
	
	// Store the reference player object as it is created here.
	player = _player;
	
	// Add key/value pairs for all structs that should only ever have a single instance of them active at once for the entire runtime of the
	// game. These elements will prevent instance_create_struct from ever creating an instance of them and instance_create_struct_singleton 
	// from ever created a second instance of them. 
	ds_map_add(structSingletons, str_camera, 				"camera");
	ds_map_add(structSingletons, str_control_ui_manager, 	"controlUiManager");
	ds_map_add(structSingletons, str_cutscene_manager,		"cutsceneManager");
	ds_map_add(structSingletons, str_textbox,				"textbox");
	ds_map_add(structSingletons, str_textbox_log,			"textboxLog");
	ds_map_add(structSingletons, str_screen_fade,			"screenFade");
	
	// Add key/value pairs for all structs that should only ever have a single instance of them active at once, but don't need to exist for
	// the entire duration of the game's runtime. As such, they can be created/deleted as required, but only one of each can ever exist at
	// any given time.
	ds_map_add(structSingletons, str_pause_menu,			"pauseMenu");
	ds_map_add(structSingletons, str_inventory_menu,		"inventoryMenu");
	ds_map_add(structSingletons, str_item_menu,				"itemMenu");
	ds_map_add(structSingletons, str_note_menu,				"noteMenu");
	ds_map_add(structSingletons, str_map_menu,				"mapMenu");
	ds_map_add(structSingletons, str_textbox_options_menu,	"textboxOptionsMenu");
	ds_map_add(structSingletons, str_fog,					"fog");
	
	// After all required values have been added to the structSingletons map to prevent duplicates of singletons being created, call the
	// function for creating structs on all of those singletons that should exist throughout the game's entire runtime.
	instance_create_struct_singleton(str_camera);
	instance_create_struct_singleton(str_control_ui_manager);
	instance_create_struct_singleton(str_screen_fade);
	instance_create_struct_singleton(str_cutscene_manager);
	instance_create_struct_singleton(str_textbox);
	instance_create_struct_singleton(str_textbox_log);
	
	with(_player) { set_state(state_initialize); } // FOR TESTING
}

// After creating the required singleton instances, initialize the camera so the window can be properly sized, the viewport into the game can 
// be created and sized as well, and the game can start rendering to that window via the current viewport position/size.
camera_initialize(320, 180, _player, true);

// Once everything has been initialized, the first official room for the game is loaded, and the game is unpaused to allow various game 
// elements to start updating.
room_goto(rm_test_01);
global.flags = global.flags & ~GAME_FLAG_PAUSED;