#region Player-Specific Flag Macros

// Values for the bits that are used within the player object only. These values shouldn't overwrite occupied
// flags found in obj_dynamic_entity and any general entity flags; as doing so will cause unintended results.
#macro	PLYR_FLAG_MOVING				0x00000001
#macro	PLYR_FLAG_SPRINTING				0x00000002
#macro	PLYR_FLAG_BLEEDING				0x00000004
#macro	PLYR_FLAG_CRIPPLED				0x00000008
#macro	PLYR_FLAG_POISONED				0x00000010
#macro	PLYR_FLAG_FLASHLIGHT			0x00000020
#macro	PLYR_FLAG_UP_POISON_DAMAGE		0x00000040
#macro	PLYR_FLAG_PLAY_STEP_SOUND		0x00000080

// Checks for the state of all flag bits that are exclusive to the player.
#macro	PLYR_IS_MOVING					((flags & PLYR_FLAG_MOVING)				!= 0)
#macro	PLYR_IS_SPRINTING				((flags & PLYR_FLAG_SPRINTING)			!= 0 && (flags & PLYR_FLAG_MOVING) != 0)
#macro	PLYR_IS_BLEEDING				((flags & PLYR_FLAG_BLEEDING)			!= 0)
#macro	PLYR_IS_CRIPPLED				((flags & PLYR_FLAG_CRIPPLED)			!= 0)
#macro	PLYR_IS_POISONED				((flags & PLYR_FLAG_POISONED)			!= 0)
#macro	PLYR_IS_FLASHLIGHT_ON			((flags & PLYR_FLAG_FLASHLIGHT)			!= 0)
#macro	PLYR_CAN_UP_POISON_DAMAGE		((flags & PLYR_FLAG_UP_POISON_DAMAGE)	!= 0)
#macro	PLYR_CAN_PLAY_STEP_SOUND		((flags & PLYR_FLAG_PLAY_STEP_SOUND)	!= 0)

#endregion Player-Specific Flag Macros

#region Input Macros

// Values for the bits found within "inputFlags" and "prevInputFlags". Each denotes a seperate input binding
// that allows the player to perform a certain action within the game depending on their current state.
#macro	PINPUT_FLAG_MOVE_RIGHT			0x00000001
#macro	PINPUT_FLAG_MOVE_LEFT			0x00000002
#macro	PINPUT_FLAG_MOVE_UP				0x00000004
#macro	PINPUT_FLAG_MOVE_DOWN			0x00000008
#macro	PINPUT_FLAG_INTERACT			0x00000010
#macro	PINPUT_FLAG_SPRINT				0x00000020
#macro	PINPUT_FLAG_READY_WEAPON		0x00000040
#macro	PINPUT_FLAG_FLASHLIGHT			0x00000080
#macro	PINPUT_FLAG_USE_WEAPON			0x00000100
#macro	PINPUT_FLAG_GP_LEFT_STICK		0x04000000
#macro	PINPUT_FLAG_GP_RIGHT_STICK		0x08000000
#macro	PINPUT_FLAG_ITEM_MENU			0x10000000
#macro	PINPUT_FLAG_NOTES_MENU			0x20000000
#macro	PINPUT_FLAG_MAP_MENU			0x40000000
#macro	PINPUT_FLAG_PAUSE_MENU			0x80000000

// Checks to see if the above input flags have been set in such a way that they have been pressed, held, or
// released as required by each individual input.
#macro	PINPUT_MOVE_RIGHT_HELD			((inputFlags & PINPUT_FLAG_MOVE_RIGHT)		!= 0 && (inputFlags & PINPUT_FLAG_MOVE_LEFT)		== 0)
#macro	PINPUT_MOVE_LEFT_HELD			((inputFlags & PINPUT_FLAG_MOVE_LEFT)		!= 0 && (inputFlags & PINPUT_FLAG_MOVE_RIGHT)		== 0)
#macro	PINPUT_MOVE_UP_HELD				((inputFlags & PINPUT_FLAG_MOVE_UP)			!= 0 && (inputFlags & PINPUT_FLAG_MOVE_DOWN)		== 0)
#macro	PINPUT_MOVE_DOWN_HELD			((inputFlags & PINPUT_FLAG_MOVE_DOWN)		!= 0 && (inputFlags & PINPUT_FLAG_MOVE_UP)			== 0)
#macro	PINPUT_INTERACT_PRESSED			((inputFlags & PINPUT_FLAG_INTERACT)		!= 0 && (prevInputFlags & PINPUT_FLAG_INTERACT)		== 0)
#macro	PINPUT_SPRINT_PRESSED			((inputFlags & PINPUT_FLAG_SPRINT)			!= 0 && (prevInputFlags & PINPUT_FLAG_SPRINT)		== 0)
#macro	PINPUT_READY_WEAPON_PRESSED		((inputFlags & PINPUT_FLAG_READY_WEAPON)	!= 0 && (prevInputFlags & PINPUT_FLAG_READY_WEAPON)	== 0)
#macro	PINPUT_FLASHLIGHT_PRESSED		((inputFlags & PINPUT_FLAG_FLASHLIGHT)		!= 0 && (prevInputFlags & PINPUT_FLAG_FLASHLIGHT)	== 0)
#macro	PINPUT_SPRINT_RELEASED			((inputFlags & PINPUT_FLAG_SPRINT)			== 0 && (prevInputFlags & PINPUT_FLAG_SPRINT)		!= 0)
#macro	PINPUT_READY_WEAPON_RELEASED	((inputFlags & PINPUT_FLAG_READY_WEAPON)	== 0 && (prevInputFlags & PINPUT_FLAG_READY_WEAPON)	!= 0)
#macro	PINPUT_FLASHLIGHT_RELEASED		((inputFlags & PINPUT_FLAG_FLASHLIGHT)		== 0 && (prevInputFlags & PINPUT_FLAG_FLASHLIGHT)	!= 0)
#macro	PINPUT_USE_WEAPON_HELD			((inputFlags & PINPUT_FLAG_USE_WEAPON)		!= 0)
#macro	PINPUT_OPEN_ITEMS_RELEASED		((inputFlags & PINPUT_FLAG_ITEM_MENU)		== 0 && (prevInputFlags & PINPUT_FLAG_ITEM_MENU)	!= 0)
#macro	PINPUT_OPEN_NOTES_RELEASED		((inputFlags & PINPUT_FLAG_NOTES_MENU)		== 0 && (prevInputFlags & PINPUT_FLAG_NOTES_MENU)	!= 0)
#macro	PINPUT_OPEN_MAPS_RELEASED		((inputFlags & PINPUT_FLAG_MAP_MENU)		== 0 && (prevInputFlags & PINPUT_FLAG_MAP_MENU)		!= 0)
#macro	PINPUT_OPEN_PAUSE_RELEASED		((inputFlags & PINPUT_FLAG_PAUSE_MENU)		== 0 && (prevInputFlags & PINPUT_FLAG_PAUSE_MENU)	!= 0)

// Variants of the above pressed/released inputs for readying a weapon and sprinting that can be toggled to 
// be hold inputs or not in the game's accessibility settings.
#macro	PINPUT_READY_WEAPON_HELD		((inputFlags & PINPUT_FLAG_READY_WEAPON)	!= 0)
#macro	PINPUT_SPRINT_HELD				((inputFlags & PINPUT_FLAG_SPRINT)			!= 0)

// Two unique flags contained within the player's "inputFlags" variable. They will let the rest of the code
// run by the player which of the two sticks are being used for movement during the current frame.
#macro	PINPUT_USING_LEFT_STICK			((inputFlags & PINPUT_FLAG_GP_LEFT_STICK)	!= 0)
#macro	PINPUT_USING_RIGHT_STICK		((inputFlags & PINPUT_FLAG_GP_RIGHT_STICK)	!= 0)

#endregion Input Macros

#region Misc. Macros

// Macros for the player's default acceleration and maximum speeds. When crippled, these act as the "slow"
// sprinting speed when their stamina is completely depleted.
#macro	PLYR_ACCEL_NORMAL				0.15
#macro	PLYR_SPEED_NORMAL				1.05

// Macros for the player's acceleration and maximum speed when sprinting. These values are only utilized when
// the player has available stamina and isn't crippled.
#macro	PLYR_ACCEL_SPRINT_FAST			0.35
#macro	PLYR_SPEED_SPRINT_FAST			1.75

// Macros for the player's acceleration and maximum speed when sprinting without stamina. When crippled, these
// act as the "fast" sprinting speed should the player still have stamina remaining.
#macro	PLYR_ACCEL_SPRINT_SLOW			0.20
#macro	PLYR_SPEED_SPRINT_SLOW			1.40

// Determines the minimum percentage of movement can occur when using a gamepad's analog stick relative to the
// player's current maximum movement speed.
#macro	PLYR_MIN_ANALOG_PERCENTAGE		0.25

// Macros that will determine how the player's movement animation sprite is split up relative to the number of
// directions representing within that sprite resource.
#macro	PLYR_ANIM_DIRECTION_DELTA		90.0	// Number MUST divide 360 with no remainder.
#macro	PLYR_MOVE_ANIM_LENGTH			3.0

// Macros for the indices into the "timers" array that correspond to each one utilized by the player for various
// interval-based actions and code. The final value is the total number of those timers required by the object.
#macro	PLYR_STAMINA_LOSS_TIMER			0
#macro	PLYR_STAMINA_REGEN_TIMER		1
#macro	PLYR_BLEEDING_TIMER				2
#macro	PLYR_POISON_TIMER				3
#macro	PLYR_TOTAL_TIMERS				4

// Macros that determine the speed at which various interval-based actions will occur for the player.
#macro	PLYR_STAMINA_LOSS_RATE			2.0
#macro	PLYR_STAMINA_REGEN_RATE			5.0
#macro	PLYR_BLEEDING_DAMAGE_RATE		300.0
#macro	PLYR_POISON_DAMAGE_RATE			600.0

// Determines the additional time added to the player's stamina regeneration timer for the interval of time
// between the player releasing the run button and their stamina beginning its regeneration.
#macro	PLYR_STAMINA_PAUSE_FACTOR		10.0

// Determines how much of a penalty is applied to the player's initial break before their stamina regenerates
// if their stamina is completely depleted while running.
#macro	PLYR_STAMINA_EXHAUST_FACTOR		3.0

// Determines the percentage amount relative to their current maximum hitpoints of damage dealt to the player 
// whenever they're bleeding and the damage interval timer rolls over. Unlike poison, it is a constant amount.
#macro	PLYR_BLEEDING_DAMAGE_AMOUNT		0.02

// Determines the starting damage of the poison status condition. From here, it doubles until the player either
// curs the status or dies from the damage. The damage is reset once the player's poison status is removed.
#macro	PLYR_POISON_BASE_DAMAGE			0.01

// Macros for the values/properties applied to the player's ambient light source whenever they're in the world
// without a flashlight or with their equipped flashlight turned off.
#macro	PLYR_AMBLIGHT_XOFFSET			0
#macro	PLYR_AMBLIGHT_YOFFSET		   -14
#macro	PLYR_AMBLIGHT_RADIUS			12.0
#macro	PLYR_AMBLIGHT_COLOR				COLOR_DARK_GRAY
#macro	PLYR_AMBLIGHT_STRENGTH			0.25

// The vertical offset for the point that will be checked to determine the current floor material beneath
// the player which will set what footstep sound should be played when one is required.
#macro	PLYR_FLOOR_CHECK_OFFSET_Y		2

// Macros that determine which frames in the player's walking/running animation will trigger a step sound.
#macro	PLYR_FIRST_STEP_INDEX			1
#macro	PLYR_SECOND_STEP_INDEX			3

#endregion Misc. Macros

#region Variable Inheritance and Initialization

// Inherit all functions and variables initialized by par_dynamic_entity's create event.
event_inherited();

// Set the flags that are initially toggled upon the player object's creation.
flags			    = DENTT_FLAG_WORLD_COLLISION | ENTT_FLAG_OVERRIDE_DRAW | 
						ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE;

// Set the player's acceleration and maximum movement speeds (Running allows the player to temporarily exceed
// this maximum until their stamina runs out).
accel				= PLYR_ACCEL_NORMAL;
maxMoveSpeed		= PLYR_SPEED_NORMAL;

// Create a very dim ambient light that will illuminate the player's face when in complete darkness.
entity_add_basic_light(PLYR_AMBLIGHT_XOFFSET, PLYR_AMBLIGHT_YOFFSET, 
	PLYR_AMBLIGHT_RADIUS, PLYR_AMBLIGHT_COLOR, PLYR_AMBLIGHT_STRENGTH, 0.0, 
		STR_FLAG_PERSISTENT | LGHT_FLAG_ACTIVE);

// Set the starting sprite for the player.
entity_set_sprite(spr_player_unarmed);
animSpeed			= 0.0; // Pauses the inherited animation system so the one below can be utilized instead.

// To prevent repeating the same frame twice for each direction (An extra 4 redundant sprites), the player 
// will use a slightly adjusted version of the standard Entity animation system. It will set "image_index" to 
// the value found at each index within "animFrames" and "animCurFrame" will store what "image_index" was 
// originally required to.
animFrames			= [0, 1, 0, 2];
animLength			= array_length(animFrames);
animCurFrame		= 0.0;

// Assign the player's starting and maximum hitpoints to be 100 units so whole percentage values are always
// at or above a value of one.
maxHitpoints		= 100;
curHitpoints		= maxHitpoints;

// Stores the inputs that were held versus not held for the current and last frame of gameplay. From this, 
// checks to see if they've been pressed, held, or released can be performed quickly through bitwise math.
inputFlags			= 0;
prevInputFlags		= 0;

// Variables for input that are exclusive to a controller with at least one analog stick. They simply store
// the values retrieved from said sticks when inputs is handled by the player.
padStickInputLH		= 0.0;
padStickInputLV		= 0.0;
padStickInputRH		= 0.0;
padStickInputRV		= 0.0;

// Determines the movement direction of the player character relative to the inputs that have been held or if
// the left stick has been moved to a position outside its deadzone.
moveDirectionX		= 0.0;
moveDirectionY		= 0.0;

// Stores the player's current and maximum stamina values, respectively.
maxStamina			= 100;
curStamina			= maxStamina;

// Stores the player's current and maximum sanity values, respectively.
maxSanity			= 100;
curSanity			= maxSanity;

// Stores a collection of floating point values that act as timers for various interval-based things that can
// occur to the player. For example, the damage intervals for bleeding and poison, as well as the stamina loss
// and regen timers are all found within this array.
timers				= array_create(PLYR_TOTAL_TIMERS, 0.0);

// Stores the current damage that the poison status will inflict on its next damage interval. After which the
// value will double itself again.
poisonDamagePercent	= PLYR_POISON_BASE_DAMAGE;

// A local struct that stores all the item IDs for the various pieces of equipment that the player can have on
// throughout the game. The first four are used in all playthroughs, and the remaining two "amulet" slots are 
// exclusive to new game+ modes.
equipment = {
	weapon				: INV_EMPTY_SLOT,
	ammoArrayRef		: ID_INVALID,
	curAmmoIndex		: INV_EMPTY_SLOT,
	armor				: INV_EMPTY_SLOT,
	light				: INV_EMPTY_SLOT,
	lightParamRef		: ID_INVALID,
	firstAmulet			: INV_EMPTY_SLOT,
	secondAmulet		: INV_EMPTY_SLOT,
};

// Stores the instance ID for the nearest interactable object to the player's current position.
interactableID		= noone;

// Variables used for the player's footstep sound effect system. The first value stores the ID for the layer
// in the room that stores the floor material tiles, and the second stores the ID of the footstep sound that
// was most recently played back.
floorMaterials		= -1;
prevStepSoundID		= -1;

#endregion Variable Inheritance and Initialization

#region Utility Function Definitions

/// @description 
/// Updates the flags within "inputFlags" to whatever the player has pressed/released for the current
/// frame. Also automatically swaps between gamepad and keyboard input polling as required.
/// 
process_player_input = function(){
	prevInputFlags	= inputFlags;
	inputFlags		= 0;
	
	if (GAME_IS_GAMEPAD_ACTIVE){
		// Getting input from the main analog stick by reading its current horizontal and vertical position
		// relative to its centerpoint and the deadzone applied by the game's input settings.
		var _gamepad	= global.gamepadID;
		padStickInputLH = gamepad_axis_value(_gamepad, gp_axislh);
		padStickInputLV = gamepad_axis_value(_gamepad, gp_axislv);
		if (padStickInputLH != 0.0 || padStickInputLV != 0.0)
			inputFlags = inputFlags | PINPUT_FLAG_GP_LEFT_STICK;
		
		// Getting input from the secondary analog stick if the controller has one and the primary stick isn't
		// being currently utilized by the player.
		if (gamepad_axis_count(global.gamepadID) > 1){
			padStickInputRH	= gamepad_axis_value(_gamepad, gp_axisrh);
			padStickInputRV = gamepad_axis_value(_gamepad, gp_axisrv);
			if (!PINPUT_USING_LEFT_STICK && (padStickInputRH != 0.0 || padStickInputRV != 0.0))
				inputFlags = inputFlags | PINPUT_FLAG_GP_RIGHT_STICK;
		}
		
		// This looks like a lot but its a way of avoiding confusing YYC since it doesn't like the player's
		// bitwise AND operations and I'd rather not risk something breaking because of other bitwise 
		// operators.
		inputFlags = inputFlags | (GAME_PAD_RIGHT				 ); // Offset based on position of the bit within the variable.
		inputFlags = inputFlags | (GAME_PAD_LEFT			<<  1);
		inputFlags = inputFlags | (GAME_PAD_UP				<<  2);
		inputFlags = inputFlags | (GAME_PAD_DOWN			<<  3);
		inputFlags = inputFlags | (GAME_PAD_INTERACT		<<  4);
		inputFlags = inputFlags | (GAME_PAD_SPRINT			<<  5);
		inputFlags = inputFlags | (GAME_PAD_READYWEAPON		<<  6);
		inputFlags = inputFlags | (GAME_PAD_FLASHLIGHT		<<  7);
		inputFlags = inputFlags | (GAME_PAD_USEWEAPON		<<  8);
		inputFlags = inputFlags | (GAME_PAD_ITEM_MENU		<< 28);
		inputFlags = inputFlags | (GAME_PAD_NOTE_MENU		<< 29);
		inputFlags = inputFlags | (GAME_PAD_MAP_MENU		<< 30);
		inputFlags = inputFlags | (GAME_PAD_PAUSE_MENU		<< 31);
		return;
	}
	
	// This looks like a lot but its a way of avoiding confusing YYC since it doesn't like the player's
	// bitwise AND operations and I'd rather not risk something breaking because of other bitwise operators.
	inputFlags = inputFlags | (GAME_KEY_RIGHT				 ); // Offset based on position of the bit within the variable.
	inputFlags = inputFlags | (GAME_KEY_LEFT			<<  1);
	inputFlags = inputFlags | (GAME_KEY_UP				<<  2);
	inputFlags = inputFlags | (GAME_KEY_DOWN			<<  3);
	inputFlags = inputFlags | (GAME_KEY_INTERACT		<<  4);
	inputFlags = inputFlags | (GAME_KEY_SPRINT			<<  5);
	inputFlags = inputFlags | (GAME_KEY_READYWEAPON		<<  6);
	inputFlags = inputFlags | (GAME_KEY_FLASHLIGHT		<<  7);
	inputFlags = inputFlags | (GAME_KEY_USEWEAPON		<<  8);
	inputFlags = inputFlags | (GAME_KEY_ITEM_MENU		<< 28);
	inputFlags = inputFlags | (GAME_KEY_NOTE_MENU		<< 29);
	inputFlags = inputFlags | (GAME_KEY_MAP_MENU		<< 30);
	inputFlags = inputFlags | (GAME_KEY_PAUSE_MENU		<< 31);
}

/// @description
/// Calcualtes the values for "moveDirectionX" and "moveDirectionY" based on if a keyboard is being used for
/// input currently or a connected gamepad is being used. Using the joystick on the gamepad will alter the value
/// so it can be any value between -1.0 and 1.0 for each axis, and the standard digital way returns either a
/// -1, 0, or +1 based on current input flags.
/// 
determine_movement_vector = function(){
	var _isGamepadActive = GAME_IS_GAMEPAD_ACTIVE;
	if (_isGamepadActive && PINPUT_USING_LEFT_STICK){ // Using the left stick for movement.
		moveDirectionX = padStickInputLH;
		moveDirectionY = padStickInputLV;
	} else if (_isGamepadActive && PINPUT_USING_RIGHT_STICK){ // Using the right stick for movement.
		moveDirectionX = padStickInputRH;
		moveDirectionY = padStickInputRV;
	} else{ // Uses the gamepad's d-pad or the relevant keyboard keys to return a value of -1, 0, or +1.
		moveDirectionX = ((inputFlags & PINPUT_FLAG_MOVE_RIGHT) != 0) - ((inputFlags & PINPUT_FLAG_MOVE_LEFT)	!= 0);
		moveDirectionY = ((inputFlags & PINPUT_FLAG_MOVE_DOWN)	!= 0) - ((inputFlags & PINPUT_FLAG_MOVE_UP)		!= 0);
	}
}

/// @description
/// Handles updating the player's movement animation(s) which works in a similar way to the standard Entity
///	animation processing, but taking into account that the player can face 4 directions and all those directions
/// are stored in a single sprite together when determining the starting index within that data. 
/// 
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
process_movement_animation = function(_delta){
	animLoopStart = PLYR_MOVE_ANIM_LENGTH * round(direction / PLYR_ANIM_DIRECTION_DELTA);
	animCurFrame += _delta * (moveSpeed / PLYR_SPEED_NORMAL) * (animFps / GAME_TARGET_FPS);
	if (animCurFrame >= animLength) // Loop back to the start of the animation.
		animCurFrame -= animLength;
	image_index = floor(animFrames[animCurFrame] + animLoopStart);
}

/// @description 
/// Handles playback of the footstep sounds that play depending on the current floor material they are walking
/// on. No sound playback will occur if there isn't a layer in the room named "Tiles_Floor_Materials".
///	
process_footstep_sound = function(){
	if (floorMaterials == -1)
		return; // Don't try to play footstep sounds if the area doesn't have a valid layer for floor types.
	
	// Make sure the correct animation frame is being shown before any sound is played. If the frame isn't one
	// of the two valid values, the function exits early and no step sound playback occurs for the game frame.
	var _animCurFrame = floor(animCurFrame);
	if (_animCurFrame != PLYR_FIRST_STEP_INDEX && _animCurFrame != PLYR_SECOND_STEP_INDEX){
		flags = flags | PLYR_FLAG_PLAY_STEP_SOUND; // Flag is only ever set when beginning movement or during off frames.
		return;
	}
	
	// If the current frame of animation is one of the two valid values (Both can occur for any number of game
	// frames relative to what else is happening in the room), make sure the flag allowing a step sound to play
	// is set. Otherwise, exit the function early. If not, proceed and immediately clear said flag.
	if (!PLYR_CAN_PLAY_STEP_SOUND)
		return;
	flags = flags & ~PLYR_FLAG_PLAY_STEP_SOUND;
	
	// Calculate which tile the player is currently walking on, and set the sound to playback relative to the
	// tile index value that is returned by the tilemap_get function.
	var _snd	= -1;
	var _cellX	= floor(x / TILE_WIDTH);
	var _cellY	= floor((y - PLYR_FLOOR_CHECK_OFFSET_Y) / TILE_HEIGHT);
	switch(tilemap_get(floorMaterials, _cellX, _cellY)){
		default:
		case TILE_INDEX_FLOOR_TILE:		_snd = snd_player_step_tile;		break;
		case TILE_INDEX_FLOOR_WATER:	_snd = snd_player_step_water;		break;
		case TILE_INDEX_FLOOR_WOOD:		_snd = snd_player_step_wood;		break;
		case TILE_INDEX_FLOOR_GRASS:	_snd = snd_player_step_grass;		break;
	}
	
	// Set the sound's unaltered volume, and very slightly increase it if the player is currently running.
	// Then, play the sound effect using the special function that automatically adjusts volume and pitch
	// within a random range on a per-playback basis.
	var _volume = 0.4;
	if (PLYR_IS_SPRINTING)
		_volume += 0.05;
	prevStepSoundID = sound_effect_play_ext(_snd, _volume, 1.0, 0, false, false, 0.1, 0.08);
}

/// @description 
/// A function that can be called whenever the player needs to be paused while other entities and objects are 
/// still allowed to remain active (Ex. Interacting with objects or opening a menu that isn't the pause menu).
/// 
pause_player = function(){
	if (curState == method_get_index(state_player_paused) || GAME_IS_CUTSCENE_ACTIVE)
		return; // Don't pause the player again if they've been paused previously or a cutscene is active.
	object_set_state(state_player_paused);
	image_index		= animLoopStart;
	flags		    = flags & ~(PLYR_FLAG_MOVING | PLYR_FLAG_SPRINTING);
	animCurFrame	= 0.0;
	moveSpeed		= 0.0;
}

/// @description 
///	A function that can be called whenever a given state the player can find themselves in can allow them to
/// toggle their equipped flashlight on or off. If they don't activate the input, this function does nothing.
///	
handle_light_toggle_input = function(){
	if (!PINPUT_FLASHLIGHT_PRESSED || equipment.light == INV_EMPTY_SLOT)
		return; // No input detected or a light isn't euqipped; don't process anything else in the function.
	
	// Turning off the flashlight; returning the player's ambient light to its default parameters.
	if (PLYR_IS_FLASHLIGHT_ON){
		flags  = flags & ~PLYR_FLAG_FLASHLIGHT;
		lightX = PLYR_AMBLIGHT_XOFFSET;
		lightY = PLYR_AMBLIGHT_YOFFSET;
		lightSource.light_set_properties(PLYR_AMBLIGHT_RADIUS, PLYR_AMBLIGHT_COLOR, PLYR_AMBLIGHT_STRENGTH);
	} else{ // Turning on the flashlight; using the properties of the equipped flashlight.
		flags  = flags |  PLYR_FLAG_FLASHLIGHT;
		var _light = lightSource;
		with(equipment){ // Jump into the equipment struct so the light's parameters can be applied.
			_light.light_set_properties(
				lightParamRef[EQUP_PARAM_LIGHT_RADIUS], 
				lightParamRef[EQUP_PARAM_LIGHT_COLOR],
				lightParamRef[EQUP_PARAM_LIGHT_STRENGTH]
			);
		}
	}
}

/// @description 
///	A function that can be called in a given player state to allow them to open their inventory or the pause
/// menu depending on the menu input they released on the current frame. These inputs work on a priority;
/// pausing is first; then the inventory's item section; notes; and maps.
///	
handle_menu_open_inputs = function(){
	if (PINPUT_OPEN_ITEMS_RELEASED){ // Opens the inventory to the collected item section.
		menu_inventory_open(MENUINV_INDEX_ITEM_MENU);
	} else if (PINPUT_OPEN_NOTES_RELEASED){ // Open the inventory to its collected notes section.
		menu_inventory_open(MENUINV_INDEX_NOTE_MENU); 
	} else if (PINPUT_OPEN_MAPS_RELEASED){ // Open the inventory to its map section.
		menu_inventory_open(MENUINV_INDEX_MAP_MENU); 
	}
}

#endregion Utility Function Definitions

#region Equipment Function Definitions

/// @description
///	Checks all five equipment slots to see if any contain the first parameter or second parameter's value. If
/// they do, the slot where the first value is found will now store the second, and vice versa if the second
/// value is contained in the given equipment slot.
///	
/// @param {Real}	firstSlot	The first slot value to check for; swapping for the second value instead.
/// @param {Real}	secondSlot	The second slot value to check for; swapping for the first value instead.
update_equip_slot = function(_firstSlot, _secondSlot){
	with(equipment){
		// Check if the equipped weapon was in either slot. If so, swap the first with the second or the 
		// second with the first as required.
		if (weapon == _firstSlot)				{ weapon = _secondSlot; }
		else if (weapon == _secondSlot)			{ weapon = _firstSlot; }
		
		// Do the same as above, but for the equipped armor's slot (If any armor is even equipped).
		if (armor == _firstSlot)				{ armor = _secondSlot; }
		else if (armor == _secondSlot)			{ armor = _firstSlot; }
		
		// The same logic for the weapon and armor values is then done for the light's equipped slot.
		if (light == _firstSlot)				{ light = _secondSlot; }
		else if (light == _secondSlot)			{ light = _firstSlot; }
		
		// Apply that logic again for the first amulet slot.
		if (firstAmulet == _firstSlot)			{ firstAmulet = _secondSlot; }
		else if (firstAmulet == _secondSlot)	{ firstAmulet = _firstSlot; }
		
		// Finally, do the same for the 5th and finally equipment slot on the player.
		if (secondAmulet == _firstSlot)			{ secondAmulet = _secondSlot; }
		else if (secondAmulet == _secondSlot)	{ secondAmulet = _firstSlot; }
	}
}

/// @description 
///	Equips the item in the provided slot into the player's light source equipment slot. If the item isn't of
/// equip type "light" the function will not have it occupy said slot, and the function will do nothing.
///	
///	@param {Real}	itemSlot		Slot in the item inventory where the flashlight being equipped is located.
equip_flashlight = function(_itemSlot){
	if (_itemSlot < 0 || _itemSlot >= array_length(global.curItems) || global.curItems[_itemSlot] == INV_EMPTY_SLOT)
		return false; // Exit early if the slot value is out of bounds or the slot provided is actually empty.
	
	var _itemID			= global.curItems[_itemSlot].itemID;
	var _itemStructRef	= array_get(global.itemIDs, _itemID);
	if (is_undefined(_itemStructRef) || _itemStructRef.equipType != ITEM_EQUIP_TYPE_FLASHLIGHT)
		return false; // The item with the given ID doesn't exist or the equipment isn't a flashlight; exit early.
	
	// Attach the slot index to the light source equipment slot so the player knows the slot in the item
	// inventory to reference when powering the light on and off while it is equipped. The array of values
	// that determine the characteristics of the light in the game world is also copied into a local value
	// so it can be referenced to set the light's size, color, and strength.
	var _paramRef = 0;
	with(equipment){
		light			= _itemSlot;
		lightParamRef	= _itemStructRef.equipParams;
		_paramRef		= lightParamRef;
	}
	
	// Enable the light source as soon as it is equipped by setting the flag within the player's data that
	// signifies the light's state, and apply the parameters of the player's ambient light to be that of
	// the equipped light's parameters.
	flags = flags | PLYR_FLAG_FLASHLIGHT;
	lightSource.light_set_properties(
		_paramRef[EQUP_PARAM_LIGHT_RADIUS],
		_paramRef[EQUP_PARAM_LIGHT_COLOR], 
		_paramRef[EQUP_PARAM_LIGHT_STRENGTH]
	);
	
	// Return true to signify a successful equipping of a flashlight.
	return true;
}

/// @description 
///	Unequips the light source that was previously assigned to the player's light source equipment slot. If
/// this function is called while no light is equipped, it will exit early and perform no logic.
///	
unequip_flashlight = function(){
	if (equipment.light == INV_EMPTY_SLOT)
		return; // No need to uneuqip since no flashlight is equipped; exit the function.
	
	// Clear the flag that signifies the flashlight is currently on, and restore the player's default
	// ambient light source characteristics.
	flags = flags & ~PLYR_FLAG_FLASHLIGHT;
	lightSource.light_set_properties(PLYR_AMBLIGHT_RADIUS, PLYR_AMBLIGHT_COLOR, PLYR_AMBLIGHT_STRENGTH);
	
	// Reset the light value so it is no longer a valid slot in the inventory and reset the reference value
	// that points towards its parameters for whenever the light is active.
	with(equipment){
		light			= INV_EMPTY_SLOT;
		lightParamRef	= ID_INVALID;
	}
}

#endregion Equipment Function Definitions

#region End Step Event Function Override Definition

// Stores a reference to the original function so it can be called within the overridden function.
___end_step_event = end_step_event;
/// @description
///	An inherited version of the "end_step_event" function found witin "par_dynamic_entity" that updates the
/// player's various timers and other non-state dependent logic.
///
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
end_step_event = function(_delta){
	___end_step_event(_delta);
	
	// Decrement all timers by the current delta time; preventing them from going below a value of zero.
	for (var i = 0; i < PLYR_TOTAL_TIMERS; i++){
		timers[i] -= _delta;
		if (timers[i] < 0.0)
			timers[i] = 0.0;
	}
	
	// Regenerating the player's stamina when they're no longer sprinting but don't have all their stamina or
	// depleting their stamina if the player is currently running.
	if (!PLYR_IS_SPRINTING && curStamina < maxStamina && timers[PLYR_STAMINA_REGEN_TIMER] == 0.0){
		timers[PLYR_STAMINA_REGEN_TIMER] = PLYR_STAMINA_REGEN_RATE;
		curStamina++;
	} else if (PLYR_IS_SPRINTING && curStamina > 0 && timers[PLYR_STAMINA_LOSS_TIMER] == 0.0){
		timers[PLYR_STAMINA_LOSS_TIMER] = PLYR_STAMINA_LOSS_RATE;
		curStamina--;
		
		// The player's stamina has been completely depleted, slow them down until they stop sprinting.
		if (curStamina == 0){
			if (PLYR_IS_CRIPPLED){ // Move the player back to the standard walking speed and acceleration.
				accel			= PLYR_ACCEL_NORMAL;
				maxMoveSpeed	= PLYR_SPEED_NORMAL;
			} else{ // Move them to the slower sprinting values.
				accel			= PLYR_ACCEL_SPRINT_SLOW;
				maxMoveSpeed	= PLYR_SPEED_SPRINT_SLOW;
			}
		}
	}
	
	// Damaging the player at each bleeding status timer interval if they are current bleeding.
	if (PLYR_IS_BLEEDING && timers[PLYR_BLEEDING_TIMER] == 0.0){
		timers[PLYR_BLEEDING_TIMER] = PLYR_BLEEDING_DAMAGE_RATE;
		update_hitpoints(floor(maxHitpoints * PLYR_BLEEDING_DAMAGE_AMOUNT)); // Reduce hitpoints by 2% rounded down.
	}
	
	// Damaging the player at each poison damage interval if they are currently poisoned and also doubling
	// the damage it will deal after every other time damage has been dealt.
	if (PLYR_IS_POISONED && timers[PLYR_POISON_TIMER] == 0.0){
		timers[PLYR_POISON_TIMER] = PLYR_POISON_DAMAGE_RATE;
		update_hitpoints(floor(maxHitpoints * poisonDamagePercent));
		
		// There's no limit to how high this percentage can go; meaning it will become a fatal amount of damage
		// (128% of the player's maximum hitpoints) inflicted even when at max hitpoints after 80 seconds.
		if (PLYR_CAN_UP_POISON_DAMAGE){
			flags = flags |  PLYR_FLAG_UP_POISON_DAMAGE;
			poisonDamagePercent *= 2.0;
		} else{
			flags = flags & ~PLYR_FLAG_UP_POISON_DAMAGE;
		}
	}
}

#endregion End Step Event Function Override Definition

#region Custom Draw Function Definition

/// @description 
/// 
/// 
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
custom_draw_default = function(_delta){
	draw_sprite_ext(sprite_index, image_index, x, y, 
			image_xscale, image_yscale, image_angle, image_blend, image_alpha);
	/*var _interactX = x + lengthdir_x(8, direction);
	var _interactY = y + lengthdir_y(8, direction) - 8;
	draw_set_color(COLOR_TRUE_WHITE);
	draw_set_alpha(1.0);
	draw_sprite(spr_rectangle, 0, _interactX, _interactY);*/
}
drawFunction = method_get_index(custom_draw_default);

#endregion Custom Draw Function Definition

#region State Function Definitions

/// @description 
/// The player's standard state. When in this state, they can move around the environment at either walking
/// or running speed, shift facing direction relative to movement, interact with objects in the environment,
/// and ready their weapon for use if one is equipped.
/// 
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
state_default = function(_delta){
	process_player_input();
	determine_movement_vector();
	
	// Updating the current direction of the player and also accelerating/decelerating them depending on the
	// movement vector.
	if (moveDirectionX != 0.0 || moveDirectionY != 0.0){ // Handling acceleration
		if (!PLYR_IS_MOVING){
			flags		 = flags | PLYR_FLAG_MOVING | PLYR_FLAG_PLAY_STEP_SOUND;
			animCurFrame = 1.0; // Ensures the player's animation starts on their first step frame immediately.
		}
		moveSpeed	   += accel * _delta;
		direction		= point_direction(0.0, 0.0, moveDirectionX, moveDirectionY);
		
		// Dynamically calculate the limit for the player's movement speed based on if they're currently using
		// the primary or secondary analog sticks on a gamepad. If they aren't using either stick (Or are using
		// the keyboard for input) the maximum movement speed isn't altered by this logic.
		var _maxMoveSpeed = maxMoveSpeed;
		if (PINPUT_USING_LEFT_STICK){ // This is considered the primary stick, so it has priority.
			var _movePercent	= point_distance(0.0, 0.0, padStickInputLH, padStickInputLV);
			_maxMoveSpeed	   *= max(_movePercent, PLYR_MIN_ANALOG_PERCENTAGE);
		} else if (PINPUT_USING_RIGHT_STICK){ // Primary stick wasn't being used, check for the secondary.
			var _movePercent	= point_distance(0.0, 0.0, padStickInputRH, padStickInputRV);
			_maxMoveSpeed	   *= max(_movePercent, PLYR_MIN_ANALOG_PERCENTAGE);
		}
		
		// Prevent the current movement speed from exceeding the current limit.
		if (moveSpeed > _maxMoveSpeed)
			moveSpeed = _maxMoveSpeed;
	} else if (moveSpeed > 0.0){ // Handling deceleration
		moveSpeed		   -= accel * _delta;
		if (moveSpeed <= 0.0){
			flags		    = flags & ~(PLYR_FLAG_MOVING | PLYR_FLAG_SPRINTING);
			image_index		= animLoopStart;
			accel			= PLYR_ACCEL_NORMAL;
			maxMoveSpeed	= PLYR_SPEED_NORMAL;
			animCurFrame	= 0.0;
			moveSpeed		= 0.0;
		}
	}
	
	// Updating what the player is currently able to interact with, which only occurs if the player is moving
	// around or they haven't checked the current room to see what the nearest interactable is. Then, the
	// interactable checks to see if the player's point of interaction is within the item's valid interaction
	// radius. If so, the player will be able to press the interact input to perform the interaction with the
	// item.
	var _isMoving = PLYR_IS_MOVING;
	if (_isMoving || interactableID == noone){
		var _interactX	= x + lengthdir_x(8, direction); // Calculate the interaction point based on facing direction.
		var _interactY	= y + lengthdir_y(8, direction) - 8;
		interactableID	= instance_nearest(_interactX, _interactY, par_interactable);
		with(interactableID){ // Check to see if the distance of the point if within the interaction radius.
			if (point_distance(_interactX, _interactY, interactX, interactY) <= interactRadius){
				flags = flags | INTR_FLAG_INTERACT;
				continue;
			}
			flags = flags & ~INTR_FLAG_INTERACT; // Always clear flag when an interaction can't occur.
		}
	}
	
	// Checking for player input for an interaction. It will check to see if the current nearest interactable
	// can be interacted with (This is decided by the state of its interaction flag). If it can, its function
	// for the interaction is executed.
	if (PINPUT_INTERACT_PRESSED){
		with(interactableID){
			if (INTR_CAN_PLAYER_INTERACT){
				on_player_interact(_delta);
				flags	    = flags & ~INTR_FLAG_INTERACT;
				_isMoving	= false;
			}
		}
		
		// Remove the reference to the interactable since it isn't required during the interaction process.
		// Then, exit the state early so collision with the world and opening the inventory/pause menu are
		// prevented if those inputs were hit at the same time as the interaction input was.
		if (!_isMoving){ 
			interactableID = noone;
			return;
		}
	}
	
	// In this state, the player should be able to toggle the light source they currently have equipped on
	// or off as they see fit, and also open their inventory or the pause menu should they choose to do so.
	handle_light_toggle_input();
	handle_menu_open_inputs();

	// Don't bother with collision, sprinting or animation if the player isn't current considered moving.
	if (!_isMoving)
		return;
		
	// Activating the player's sprinting, which will cause their stamina to deplete to zero and remain there
	// until they stop running. They can still run without stamina, but the speed is heavily reduced.
	if (PINPUT_SPRINT_PRESSED && !PLYR_IS_SPRINTING){
		timers[PLYR_STAMINA_LOSS_TIMER] = PLYR_STAMINA_LOSS_RATE;
		flags = flags | PLYR_FLAG_SPRINTING;
		
		// Determine if the player should use their fast speed values (stamina > 0 and not crippled) or their 
		// slow speed values (stamina == 0 or stamina > 0 and crippled).
		if (curStamina > 0 && !PLYR_IS_CRIPPLED){
			accel			= PLYR_ACCEL_SPRINT_FAST;
			maxMoveSpeed	= PLYR_SPEED_SPRINT_FAST;
		} else if ((curStamina == 0 && !PLYR_IS_CRIPPLED) || (curStamina > 0 && PLYR_IS_CRIPPLED)){
			accel			= PLYR_ACCEL_SPRINT_SLOW;
			maxMoveSpeed	= PLYR_SPEED_SPRINT_SLOW;
		}
	}
	
	// Update the position of the player and handle collision against the world. Then, depending on the value
	// returned, reset the animation back to the player's idle stance or animate them as they move.
	var _xMove = lengthdir_x(moveSpeed, direction);
	var _yMove = lengthdir_y(moveSpeed, direction);
	if ((update_position(_xMove, _yMove, _delta) || PINPUT_SPRINT_RELEASED) && PLYR_IS_SPRINTING){
		timers[PLYR_STAMINA_REGEN_TIMER] = PLYR_STAMINA_REGEN_RATE * PLYR_STAMINA_PAUSE_FACTOR;
		// Triple the time it takes before stamina begins to regen if the player is completely exhausted.
		if (curStamina == 0) { timers[PLYR_STAMINA_REGEN_TIMER] *= PLYR_STAMINA_EXHAUST_FACTOR; }

		flags		    = flags & ~PLYR_FLAG_SPRINTING;
		accel			= PLYR_ACCEL_NORMAL;
		maxMoveSpeed	= PLYR_SPEED_NORMAL;
	}

	// 
	process_movement_animation(_delta);
	process_footstep_sound();
}

/// @description
///	A very simple state that the player is placed in whenever they need to have their funcitonality paused
/// without having other existing entities paused as well (Ex. Opening a menu that isn't the pause menu, an
/// interaction textbox opening, etc.).
///	
///	@param {Real}	delta	The difference in time between the execution of this frame and the last.
state_player_paused = function(_delta){
	if (!GAME_IS_MENU_OPEN && !GAME_IS_TEXTBOX_OPEN){
		if (lastState != 0) { object_set_state(lastState); }
		else				{ object_set_state(state_default); }
	}
}

#endregion State Function Definitions

item_inventory_add("Flashlight", 1, 0);
item_inventory_add("Flashlight", 1, 0);