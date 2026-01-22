if (GAME_IS_PAUSED)
	return; // Prevent anything from updating while the game is considered paused.

// Ensures that objects will be automatically destroyed if their destroyed flag is toggled and they aren't set to
// be invincible. Otherwise, they will remain active despite the flag to signal their destruction being set.
with(par_dynamic_entity){
	if (ENTT_IS_DESTROYED) 
		instance_destroy_object(id);
}

with(par_static_entity){
	if (ENTT_IS_DESTROYED) 
		instance_destroy_object(id);
}

// Check to see if a room warp is currently occurring. If not, the code below this check will be ignored. If so,
// the game will process warping to the next room as required.
if (!GAME_IS_ROOM_WARP_OCCURRING)
	return;

// Get and store the screen fade's current alpha value which is used to determine when to activate the room 
// transition and when to end the room warping event.
var _fadeAlpha = 0.0;
with(SCREEN_FADE) { _fadeAlpha = alpha; }
global.blurSigma = WARP_BLUR_SIGMA * _fadeAlpha;

// Check when to end the room transition process. This can only happen if the current room matches the target.
// Otherwise, the game will ignore this branch even if the screen fade's alpha level is zero.
if (_fadeAlpha == 0.0 && room == targetRoom){
	global.flags		= global.flags & ~GAME_FLAG_ROOM_WARP;
	targetRoom			= undefined;
	return;
}

// Check for when the screen fade is completely opaque. At this point, the room can be switched without the
// player noticing the change occurring. After this, the screen fade will be signaled to begin fadeing out
// so the transition can complete.
if (_fadeAlpha == 1.0 && room != targetRoom){
	// First, load in the target room.
	room_goto(targetRoom);
	
	// Begin looping through all instances that need to warp to the target room. They will have their positions
	// updates to match the required coordinates and their persistence flag will be reset to what it was prior
	// to the warp event occurring. Then, this map is cleared of all elements.
	var _key	= ds_map_find_first(instancesToWarp);
	var _data	= undefined;
	while(!is_undefined(_key)){
		_data = instancesToWarp[? _key];
		with(_key){ // The key within the map is always the instance id that will use the data.
			x			= _data.targetX;
			y			= _data.targetY;
			persistent	= _data.wasPersistent;
		}
		delete instancesToWarp[? _key]; // Signal to the garbage collector that the struct is no longer required.
		_data	= undefined;
		_key	= ds_map_find_next(instancesToWarp, _key);
	}
	ds_map_clear(instancesToWarp);
	
	// Finally, signal to the screen fade effect that it can begin fading back out which will then end the warp
	// event and bring the game back into the control of the player's actions.
	with(SCREEN_FADE) { flags = flags | FADE_FLAG_ALLOW_FADE_OUT; }
}