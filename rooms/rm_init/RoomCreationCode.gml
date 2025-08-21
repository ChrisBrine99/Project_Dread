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

// Since the create event of "obj_game_manager" is where the variable global.sInstances is initialized, the
// game manager must be created BEFORE it is added to that data structure. The same is done with the player and
// any other objects to ensure weird issues with YYC don't occur like what happened before I split the creation
// of the game manager away from where it is added to the global.sInstances map.
var _gManagerInstance	= instance_create_depth(0, 0, 30, obj_game_manager);
var _playerInstance		= instance_create_depth(200, 200, 30, obj_player);

// Adding the game manager, player, and any other objects to the global.sInstances map so they can all be
// referenced and also cannot be created again through the custom instance_create_object function. The same
// is done for all struct instances that are also singletons that exist from game start to game end.
ds_map_add(global.sInstances, obj_game_manager,			_gManagerInstance);
ds_map_add(global.sInstances, obj_player,				_playerInstance);
ds_map_add(global.sInstances, str_control_ui_manager,	new str_control_ui_manager(str_control_ui_manager));
ds_map_add(global.sInstances, str_camera,				new str_camera(str_camera));
ds_map_add(global.sInstances, str_textbox,				new str_textbox(str_textbox));
ds_map_add(global.sInstances, str_screen_fade,			new str_screen_fade(str_screen_fade));
// NOTE -- This is the only time the default ways of struct and object creation should be used!!!

// Initialize what needs initialization above by manually calling its create event (If it wasn't a "compile-
// time" singleton like it is within this game, the event would've been invoked automatically when it was 
// created).
with(CONTROL_UI_MANAGER) { create_event(); }
with(CAMERA)			 { create_event(); }
with(TEXTBOX)			 { create_event(); }
with(PLAYER)			 { object_set_state(state_default); } // For testing //

// Once everything has been initialized, the first official room for the game is loaded, and the game is 
// unpaused to allow various game elements to start updating.
room_goto(rm_test_01);
global.flags &= ~GAME_FLAG_PAUSED;