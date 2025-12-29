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
#macro	PLYR_FLAG_RELOADING				0x00000100
#macro	PLYR_FLAG_SPRINT_TOGGLE			0x00400000
#macro	PLYR_FLAG_AIM_TOGGLE			0x00800000
// Bits 0x01000000 and above are used by inherited flags.

// Checks for the state of all flag bits that are exclusive to the player.
#macro	PLYR_IS_MOVING					((flags & PLYR_FLAG_MOVING)				!= 0)
#macro	PLYR_IS_SPRINTING				((flags & PLYR_FLAG_SPRINTING)			!= 0 && (flags & PLYR_FLAG_MOVING) != 0)
#macro	PLYR_IS_BLEEDING				((flags & PLYR_FLAG_BLEEDING)			!= 0)
#macro	PLYR_IS_CRIPPLED				((flags & PLYR_FLAG_CRIPPLED)			!= 0)
#macro	PLYR_IS_POISONED				((flags & PLYR_FLAG_POISONED)			!= 0)
#macro	PLYR_IS_FLASHLIGHT_ON			((flags & PLYR_FLAG_FLASHLIGHT)			!= 0)
#macro	PLYR_CAN_UP_POISON_DAMAGE		((flags & PLYR_FLAG_UP_POISON_DAMAGE)	!= 0)
#macro	PLYR_CAN_PLAY_STEP_SOUND		((flags & PLYR_FLAG_PLAY_STEP_SOUND)	!= 0)
#macro	PLYR_IS_RELOADING				((flags & PLYR_FLAG_RELOADING)			!= 0)
#macro	PLYR_IS_SPRINT_TOGGLE			((flags & PLYR_FLAG_SPRINT_TOGGLE)		!= 0)
#macro	PLYR_IS_AIM_TOGGLE				((flags & PLYR_FLAG_AIM_TOGGLE)			!= 0)

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
#macro	PINPUT_FLAG_RELOAD_WEAPON		0x00000200
#macro	PINPUT_FLAG_CHANGE_AMMO			0x00000400
#macro	PINPUT_FLAG_GP_LEFT_STICK		0x04000000
#macro	PINPUT_FLAG_GP_RIGHT_STICK		0x08000000
#macro	PINPUT_FLAG_ITEM_MENU			0x10000000
#macro	PINPUT_FLAG_NOTES_MENU			0x20000000
#macro	PINPUT_FLAG_MAP_MENU			0x40000000
#macro	PINPUT_FLAG_PAUSE_MENU			0x80000000

// Checks to see if the above input flags have been set in such a way that they have been pressed, held, or
// released as required by each individual input.
#macro	PINPUT_MOVE_RIGHT_HELD			((inputFlags & PINPUT_FLAG_MOVE_RIGHT)		!= 0 && (inputFlags & PINPUT_FLAG_MOVE_LEFT)			== 0)
#macro	PINPUT_MOVE_LEFT_HELD			((inputFlags & PINPUT_FLAG_MOVE_LEFT)		!= 0 && (inputFlags & PINPUT_FLAG_MOVE_RIGHT)			== 0)
#macro	PINPUT_MOVE_UP_HELD				((inputFlags & PINPUT_FLAG_MOVE_UP)			!= 0 && (inputFlags & PINPUT_FLAG_MOVE_DOWN)			== 0)
#macro	PINPUT_MOVE_DOWN_HELD			((inputFlags & PINPUT_FLAG_MOVE_DOWN)		!= 0 && (inputFlags & PINPUT_FLAG_MOVE_UP)				== 0)
#macro	PINPUT_INTERACT_PRESSED			((inputFlags & PINPUT_FLAG_INTERACT)		!= 0 && (prevInputFlags & PINPUT_FLAG_INTERACT)			== 0)
#macro	PINPUT_SPRINT_PRESSED			((inputFlags & PINPUT_FLAG_SPRINT)			!= 0 && (prevInputFlags & PINPUT_FLAG_SPRINT)			== 0)
#macro	PINPUT_READY_WEAPON_PRESSED		((inputFlags & PINPUT_FLAG_READY_WEAPON)	!= 0 && (prevInputFlags & PINPUT_FLAG_READY_WEAPON)		== 0)
#macro	PINPUT_FLASHLIGHT_PRESSED		((inputFlags & PINPUT_FLAG_FLASHLIGHT)		!= 0 && (prevInputFlags & PINPUT_FLAG_FLASHLIGHT)		== 0)
#macro	PINPUT_CHANGE_AMMO_PRESSED		((inputFlags & PINPUT_FLAG_CHANGE_AMMO)		!= 0 && (prevInputFlags & PINPUT_FLAG_CHANGE_AMMO)		== 0)
#macro	PINPUT_RELOAD_WEAPON_PRESSED	((inputFlags & PINPUT_FLAG_RELOAD_WEAPON)	!= 0 && (prevInputFlags & PINPUT_FLAG_RELOAD_WEAPON)	== 0)
#macro	PINPUT_READY_WEAPON_HELD		((inputFlags & PINPUT_FLAG_READY_WEAPON)	!= 0)
#macro	PINPUT_USE_WEAPON_HELD			((inputFlags & PINPUT_FLAG_USE_WEAPON)		!= 0)
#macro	PINPUT_SPRINT_RELEASED			((inputFlags & PINPUT_FLAG_SPRINT)			== 0 && (prevInputFlags & PINPUT_FLAG_SPRINT)			!= 0)
#macro	PINPUT_READY_WEAPON_RELEASED	((inputFlags & PINPUT_FLAG_READY_WEAPON)	== 0 && (prevInputFlags & PINPUT_FLAG_READY_WEAPON)		!= 0)
#macro	PINPUT_FLASHLIGHT_RELEASED		((inputFlags & PINPUT_FLAG_FLASHLIGHT)		== 0 && (prevInputFlags & PINPUT_FLAG_FLASHLIGHT)		!= 0)
#macro	PINPUT_USE_WEAPON_RELEASED		((inputFlags & PINPUT_FLAG_USE_WEAPON)		== 0 && (prevInputFlags & PINPUT_FLAG_USE_WEAPON)		!= 0)
#macro	PINPUT_OPEN_ITEMS_RELEASED		((inputFlags & PINPUT_FLAG_ITEM_MENU)		== 0 && (prevInputFlags & PINPUT_FLAG_ITEM_MENU)		!= 0)
#macro	PINPUT_OPEN_NOTES_RELEASED		((inputFlags & PINPUT_FLAG_NOTES_MENU)		== 0 && (prevInputFlags & PINPUT_FLAG_NOTES_MENU)		!= 0)
#macro	PINPUT_OPEN_MAPS_RELEASED		((inputFlags & PINPUT_FLAG_MAP_MENU)		== 0 && (prevInputFlags & PINPUT_FLAG_MAP_MENU)			!= 0)
#macro	PINPUT_OPEN_PAUSE_RELEASED		((inputFlags & PINPUT_FLAG_PAUSE_MENU)		== 0 && (prevInputFlags & PINPUT_FLAG_PAUSE_MENU)		!= 0)

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
#macro	PLYR_RELOAD_TIMER				4
#macro	PLYR_WEAPON_ATTACK_TIMER		5
#macro	PLYR_TOTAL_TIMERS				6

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

// Determines various characteristics of the accuracy penalty system; how they'll incur over sustained weapon
// usage, how large the penalty can be, and how quick it will decay to zero once no longer using the weapon,
// respectively.
#macro	PLYR_ACCPEN_DECAY_INCREMENT		0.15
#macro	PLYR_ACCPEN_MAX_VALUE			1.75
#macro	PLYR_ACCPEN_DECAY_AMOUNT		0.01

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

// Create a struct that stores and manages the currently equipped items on the player and the variables/data
// each of them require to function efficiently. 
equipment = {
	// --- Variables Related to Equipped Weapon --- //
	weapon				: INV_EMPTY_SLOT,
	weaponStatRef		: undefined,
	
	// --- Variables Related to Equipped Weapon's Ammunition --- //
	curAmmoIndex		: 0,
	curAmmoStatRef		: undefined,
	ammoCount			: array_create(1, ID_INVALID),

	// --- Variables Related to Equipped Subweapon --- //
	subWeapon			: INV_EMPTY_SLOT,
	subWeaponStatRef	: undefined,
	
	// --- Variables Related to Equipped Armor --- //
	armor				: INV_EMPTY_SLOT,
	
	// --- Variables Related to Equipped Light Source --- //
	light				: INV_EMPTY_SLOT,
	lightParamRef		: undefined,
	
	// --- Variables for the Two Amulet Slots --- //
	firstAmulet			: INV_EMPTY_SLOT,
	secondAmulet		: INV_EMPTY_SLOT,
};

// Stores the total number of bullets that can be fired by holding down the "use weapon" input. When this
// value matches the total number, the player will need to release the input before being able to fire the
// weapon again. If the total is -1 they will never have to release the input.
weaponBulletCount	= 0;
bulletCounter		= 0;

// Determines how much ammo is remaining with the equipped weapon's current clip/magazine to avoid having
// to constantly jump into the struct stored within the item inventory array to grab said value.
weaponRemainingAmmo	= 0;

// Store copies of the reload and fire rate/attack speed for the currently equipped weapon outside of the 
// equipment struct since having to jump into there to get the reference to the equipped weapon's item struct
// reference so those two values can be grabbed each time they're needed.
weaponReloadSpeed	= 0.0;
weaponAttackSpeed	= 0.0;

// Determines the penalty applied to the weapon's accuracy as it is used coninuously. Value goes down when
// the player is no longer actively firing their weapon.
curAccuracyPenalty	= 0.0;

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
		inputFlags = inputFlags | (GAME_PAD_RELOADWEAPON	<<  9);
		inputFlags = inputFlags | (GAME_PAD_CHANGE_AMMO		<< 10);
		inputFlags = inputFlags | (GAME_PAD_ITEM_MENU		<< 28);
		inputFlags = inputFlags | (GAME_PAD_NOTE_MENU		<< 29);
		inputFlags = inputFlags | (GAME_PAD_MAP_MENU		<< 30);
		inputFlags = inputFlags | (GAME_PAD_PAUSE_MENU		<< 31);
		return;
	}
	
	// This looks like a lot but its a way of avoiding confusing the YYC since it doesn't like the player's
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
	inputFlags = inputFlags | (GAME_KEY_RELOADWEAPON	<<  9);
	inputFlags = inputFlags | (GAME_KEY_CHANGE_AMMO		<< 10);
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
	prevStepSoundID = sound_effect_play_ext(_snd, STNG_AUDIO_GAME_SOUNDS, _volume, 1.0, 0, false, false, 0.1, 0.08);
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
		
		// Perform the same checks as above, but for the equipped sub weapon (If there is one equipped).
		if (subWeapon == _firstSlot)			{ subWeapon = _secondSlot; }
		else if (subWeapon == _secondSlot)		{ subWeapon = _secondSlot; }
		
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
/// Equips a main weapon onto the player, which is any of the firearms/melee weapons found within the game.
///	
/// @param {Struct._structRef}	itemStructRef	Reference to the struct in the global item data that represents the weapon.
///	@param {Real}				itemSlot		Slot in the item inventory where the main weapon being equipped is located.
equip_main_weapon = function(_itemStructRef, _itemSlot){
	var _quantity = 0;
	with(equipment){
		// Make sure the previously equipped weapon's ammo index is carried over into the item inventory data
		// if another weapon happened to be previously equipped before this function executed to equip another
		// weapon. Then, normal equipping logic can commence.
		if (weapon != INV_EMPTY_SLOT){
			var _curAmmoIndex = curAmmoIndex;
			with(global.curItems[weapon])
				ammoIndex = _curAmmoIndex;
		}
		
		// First, copy the slot index where the weapon is found in the item inventory. Then, store the
		// reference to that weapon's data so it can be accessed later as required.
		weapon			= _itemSlot;
		weaponStatRef	= _itemStructRef;
		
		// Grab some data from the item inventory slot that holds the weapon that is to be equipped. Then,
		// set the current ammunition index within this struct to match so the proper ammo is utilized.
		var _ammoIndex	= 0;
		with(global.curItems[_itemSlot]){
			_quantity	= quantity;
			_ammoIndex	= ammoIndex;
		}
		curAmmoIndex	= global.curItems[_itemSlot].ammoIndex;
		
		// Using the current ammunition found within the gun, get the ID for the item it is tied to and check
		// if that value isn't (-1). If it is, the weapon doesn't use ammo and the function exits early.
		var _ammoTypes	= _itemStructRef.ammoTypes;
		var _ammoID		= _ammoTypes[curAmmoIndex];
		if (_ammoID == ID_INVALID)
			return;
			
		// Grab a reference to the current ammunition's data so it can be referenced later as required.
		curAmmoStatRef	= array_get(global.itemIDs, _ammoID);
		
		// Loop through all possible ammo type of the equipped weapon, storing the current sum of each into
		// an array that is updated as the equipped weapon's possible ammo types are added/removed from the
		// item inventory.
		var _ammoNum = array_length(_ammoTypes);
		array_resize(ammoCount, _ammoNum);
		for (var i = 0; i < _ammoNum; i++)
			ammoCount[i] = item_inventory_count(_ammoTypes[i]);
	}
	weaponRemainingAmmo	= _quantity;
	
	// Grab some values from the item data struct of the weapon that will be frequently used by the player
	// for various states and operations to avoid having to constantly jump around to grab said values.
	var _bulletCount = -1;
	var _reloadSpeed = 0;
	var _attackSpeed = 0;
	with(_itemStructRef){
		// When set to be a burstfire weapon, the bullet count will match what is specified in the item
		// data. Otherwise, the count is set to one and that value will be used to determine how many
		// projectiles to spawn for a single bullet (Ex. shotguns).
		if (WEAPON_IS_BURSTFIRE)		{ _bulletCount = bulletCount; }
		else if (!WEAPON_IS_AUTOMATIC)	{ _bulletCount = 1; }
		else							{ _bulletCount = -1; }
		_reloadSpeed = reloadSpeed * GAME_TARGET_FPS;
		_attackSpeed = attackSpeed * GAME_TARGET_FPS;
	}
	weaponBulletCount	= _bulletCount;
	weaponReloadSpeed	= _reloadSpeed;
	weaponAttackSpeed	= _attackSpeed;
}

/// @description 
///	Unequips the weapon that was previously assigned to the player's main weapon equipment slot while also
/// removing the references to the weapon's data struct as well as the current utilized ammo's data struct.
///	
unequip_main_weapon = function(){
	with(equipment){
		// Before clearing all relevant values from the equipment struct's equipped weapon values, make
		// sure the index for the ammo currently in the weapon is copied into the item's struct itself.
		var _curAmmoIndex = curAmmoIndex;
		with(global.curItems[weapon])
			ammoIndex = _curAmmoIndex;
			
		// Clear the necessary values to signify a weapon is no longer equipped.
		weapon			= INV_EMPTY_SLOT;
		weaponStatRef	= undefined;
		curAmmoIndex	= 0;
		curAmmoStatRef	= undefined;
	}
	
	// Finally, clear the external values found in the player's sope since they're no longer needed.
	weaponRemainingAmmo = 0;
	weaponBulletCount	= 0;
	weaponReloadSpeed	= 0.0;
	weaponAttackSpeed	= 0.0;
}

/// @description 
///	Equips the item in the provided slot into the player's light source equipment slot. If the item isn't of
/// equip type "light" the function will not have it occupy said slot, and the function will do nothing.
///	
///	@param {Struct._structRef}	itemStructRef	Reference to the struct that represents the weapon.
///	@param {Real}				itemSlot		Slot in the item inventory where the light being equipped is located.
equip_flashlight = function(_itemStructRef, _itemSlot){
	// Create a local variable for easily referencing the properties of the equipped light while updating
	// the player's ambient light to said properties. Copy the slot index and a reference to those light
	// properties within the equipment struct so they can be referenced when toggling the light on/off.
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
}

/// @description 
///	Unequips the light source that was previously assigned to the player's light source equipment slot.
///	
unequip_flashlight = function(){
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

#region Equipped Weapon Function Definitions

/// @description
///	Reloads the equipped weapon by converting the currently utilized ammo into "quantity" for the equipped
/// weapon in question.
///	
reload_current_weapon = function(){
	var _quantity = weaponRemainingAmmo;
	with(equipment){
		// Jump into the struct referenced within the equipped weapon for its stats/variables; copying over
		// the ID for the ammo being used and the stack limit for the equipped weapon which is the same as
		// its magazine/clip size.
		var _curAmmoIndex	= curAmmoIndex;
		var _ammoItemID		= 0;
		var _stackLimit		= 0;
		with(weaponStatRef){
			_ammoItemID		= ammoTypes[_curAmmoIndex];
			_stackLimit		= stackLimit;
		}
		
		// If that item ID is ID_INVALID (-1), the weapon doesn't actually use any ammunition and is assumed
		// to be an infinite ammo weapon, so the quantity is set to the stack limit without any ammo used.
		if (_ammoItemID == ID_INVALID){
			global.curItems[weapon].quantity = _stackLimit;
			break;
		}
		
		// Jump into the scope of the item inventory's item struct so that the available space can be found
		// which is then used to remove that amount of ammo from the item inventory. Any remainder returned
		// by that function is subtracted from the max amount the equipped weapon can hold instead of the
		// full amount being added to that quantity value.
		with(global.curItems[weapon]){
			var _availableSpace = _stackLimit - quantity;
			var _remainder		= item_inventory_remove(_ammoItemID, _availableSpace);
			_quantity			= _stackLimit - _remainder;
			quantity			= _quantity;
		}
	}
	weaponRemainingAmmo = _quantity;
}

/// @description 
///	Attempts to switch the ammunition being currently used by the equipped weapon with another. If the
/// player doesn't have any amount of the other valid ammo types in the inventory no switch will occur.
/// Otherwise, the previous ammo is placed back in the item inventory if possible, and the new ammo type
/// is put into the equipped weapon by reloading it.
///	
swap_current_ammo_index = function(){
	var _x = x;
	var _y = y;
	with(equipment){
		// If there is only one type of ammunition for the currently equipped weapon OR the type of ammo is
		// an invalid ID (-1) it means an ammo swap should never occur, so the function will exit early.
		var _length	= array_length(ammoCount);
		if (_length == 1 || weaponStatRef.ammoTypes[0] == ID_INVALID)
			return false;
		
		// Keep looping until the same value is hit again for the current ammo index or the new value's
		// count is a value other than zero; meaning a swap can occur.
		var _prevAmmoIndex	= curAmmoIndex;
		var _curAmmoIndex	= curAmmoIndex;
		do{
			curAmmoIndex++;
			if (curAmmoIndex == _length)
				curAmmoIndex = 0;
		} until(ammoCount[curAmmoIndex] != 0 || _prevAmmoIndex == curAmmoIndex);
		_curAmmoIndex = curAmmoIndex;
		
		// The previous and current index values match. This means no ammunition switch could occur and the
		// function will exit early instead of swapping ammo types.
		if (_prevAmmoIndex == _curAmmoIndex)
			return false;
		
		// Get the name for the previous ammo in use so it can be added to the inventory while removing
		// it from the quantity of the current weapon's magazine/clip.
		var _prevAmmoName = ""; 
		with(weaponStatRef){
			var _prevAmmoItemID = ammoTypes[_prevAmmoIndex];
			if (_prevAmmoItemID != ID_INVALID)
				_prevAmmoName = global.itemIDs[_prevAmmoItemID].itemName;
		}

		// Jump into scope of the item inventory's struct representation of the equipped weapon to add the
		// previous ammunition into the item inventory before reloading said weapon with the new ammo.
		var _quantity	= 0;
		var _remainder	= 0;
		with(global.curItems[weapon]){
			// Attempt to add the previous ammunition to the item inventory. Whatever doesn't get added is
			// stored in the local _remainder value so it can be used to place what couldn't be put into
			// the item storage into the world itself.
			_quantity	= quantity;
			_remainder	= item_inventory_add(_prevAmmoName, _quantity);
			if (_remainder == 0){
				quantity = 0;
				break; // Break out of the loop after removing the ammo's full quantity from the weapon.
			}
			
			// The item inventory couldn't hold all of the previous ammo's amount; create a dynamic item 
			// with the remainder of what couldn't fit into the item inventory.
			var _worldItem = instance_create_object(_x, _y, obj_world_item);
			with(_worldItem){ // Applies the parameters of the ammunition instead of the weapon itself.
				set_item_params(global.nextDynamicKey, _prevAmmoName, _quantity, 0, 0);
				flags = flags | WRLDITM_FLAG_DYNAMIC;
			}
			dynamic_item_initialize(_x, _y, _prevAmmoName, _remainder, 0, 0);
		}
		
		// Finally, update the count of the previous ammunition to match what was successfully added to
		// the player's item inventory. If _remainder is zero, the full quantity is added.
		ammoCount[_prevAmmoIndex] += _quantity - _remainder;
		
		// Return true to signify the ammo swqp was successful so the correct actions can be taken outside
		// of this funciton.
		return true;
	}
	
	// Return false if the equipment struct's scope was never entered into. This should never happen, but
	// in case it does somehow this will cause ammo swapping to cease its function.
	return false;
}

/// @description 
///	Checks to see is an update needs to be done to one of the equipped weapon's current ammo counts. If the
/// ammo isn't a part of the equipped weapon's valid ammo types (Or the weapon doesn't use any ammo) the
/// function will exit prematurely.
///	
///	@param {Real}	itemID		The unique numerical identifier for the ammo to check for.
/// @param (Real)	quantity	How much of said ammo was added to the item inventory.
update_current_ammo_counts = function(_itemID, _quantity){
	with(equipment){
		// If no weapon is equipped there is no need to check for ammunition counts; exit the function.
		if (weapon == INV_EMPTY_SLOT)
			return;
		
		// A weapon is equipped, but we don't know if it uses ammunition. A check is performed against the
		// 0th index of the wepaon's ammunition types array (This should always have at least one element).
		// If the value of this element is invalid (-1), the weapon doesn't use ammo and the count check
		// is completely skipped.
		var _ammoTypes = weaponStatRef.ammoTypes;
		if (_ammoTypes[0] == ID_INVALID)
			return;
		
		// Loop through all possible ammunition types for the equipped weapon and check if their item ID
		// matches the ID of the ammo being added to/removed from the item inventory. If a match is found,
		// add the _quantity parameter to the current count and exit the function.
		var _length	= array_length(_ammoTypes);
		for (var i = 0; i < _length; i++){
			if (_ammoTypes[i] == _itemID){
				ammoCount[i] += _quantity;
				// show_debug_message("Ammo ID: {0}, Amount: {1}", _ammoTypes[i], ammoCount[i]);
				return;
			}
		}
	}
}

#endregion Equipped Weapon Function Definitions

#region End Step Event Function Override Definition

// Stores a reference to the original function so it can be called within the overridden function.
__end_step_event = end_step_event;
/// @description
///	An inherited version of the "end_step_event" function found witin "par_dynamic_entity" that updates the
/// player's various timers and other non-state dependent logic.
///
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
end_step_event = function(_delta){
	__end_step_event(_delta);
	
	// Always tranfer the current frame's input states into the variable that stores the state from the
	// previous frame, and then set the main input state storing variable to zero regardless of if there
	// is input polling occurring within the player's current state.
	prevInputFlags	= inputFlags;
	inputFlags		= 0;
	
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
			flags = flags | PLYR_FLAG_UP_POISON_DAMAGE;
			poisonDamagePercent *= 2.0;
		} else{
			flags = flags & ~PLYR_FLAG_UP_POISON_DAMAGE;
		}
	}
	
	// Lowering the current accuracy penalty (How many additional degrees are added to the equipped firearm's
	// base accuracy) once the weapon's recoil timer has completed; reducing at a constant speed until it
	// hits zero once again.
	if (curAccuracyPenalty > 0.0 && timers[PLYR_WEAPON_ATTACK_TIMER] == 0.0){
		curAccuracyPenalty -= PLYR_ACCPEN_DECAY_AMOUNT * _delta;
		if (curAccuracyPenalty < 0.0)
			curAccuracyPenalty = 0.0;
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
///	An initialization state that will act as the "Create Event" for the player object since they're actually
/// created at the very beginning of the game alongside other singleton objects/structs. It automatically
/// shifts to the player's default state at the end of its first execution.
///	
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
state_initialize = function(_delta){
	if (STNG_IS_SPRINT_INPUT_TOGGLE) { flags = flags | PLYR_FLAG_SPRINT_TOGGLE; }
	if (STNG_IS_AIM_INPUT_TOGGLE)	 { flags = flags | PLYR_FLAG_AIM_TOGGLE; }
	
	item_inventory_add("Flashlight", 1, 0);
	item_inventory_add(ITEM_SUBMACHINE_GUN, 20, 20);
	
	object_set_state(state_default);
}

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
	
	// The player has pressed the input for readying their equipped main weapon/sub weapon. If there isn't
	// a equip currently equipped, the branch is not taken. Otherwise, the player is set to their aiming/
	// weapon readied state and this state exits early as well.
	if (PINPUT_READY_WEAPON_PRESSED && equipment.weapon != INV_EMPTY_SLOT){
		object_set_state(state_player_weapon_ready);
		flags		    = flags & ~(PLYR_FLAG_MOVING | PLYR_FLAG_SPRINTING);
		image_index		= animLoopStart;
		accel			= PLYR_ACCEL_NORMAL;
		maxMoveSpeed	= PLYR_SPEED_NORMAL;
		moveSpeed		= 0.0;
		return;
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
		
		// Fixes an issue where sprinting would be immediately cancelled if the input is set to a toggle
		// instead of a hold by turning the player's press input into a hold for the current frame.
		if (PLYR_IS_SPRINT_TOGGLE)
			prevInputFlags = inputFlags;
		
		
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
	var _xMove			= lengthdir_x(moveSpeed, direction);
	var _yMove			= lengthdir_y(moveSpeed, direction);
	var _sprintEndInput	= PLYR_IS_SPRINT_TOGGLE ? PINPUT_SPRINT_PRESSED : PINPUT_SPRINT_RELEASED;
	if ((update_position(_xMove, _yMove, _delta) || _sprintEndInput) && PLYR_IS_SPRINTING){
		timers[PLYR_STAMINA_REGEN_TIMER] = PLYR_STAMINA_REGEN_RATE * PLYR_STAMINA_PAUSE_FACTOR;
		// Triple the time it takes before stamina begins to regen if the player is completely exhausted.
		if (curStamina == 0) { timers[PLYR_STAMINA_REGEN_TIMER] *= PLYR_STAMINA_EXHAUST_FACTOR; }
		
		flags		    = flags & ~PLYR_FLAG_SPRINTING;
		accel			= PLYR_ACCEL_NORMAL;
		maxMoveSpeed	= PLYR_SPEED_NORMAL;
	}

	// Finally, process the player's movement animation and handle their footstep sound logic which requires
	// the movement animation being processed in order to do anything.
	process_movement_animation(_delta);
	process_footstep_sound();
}

/// @description
///	The function that is running whenever the player is in their readied weapon state. It handles switching
/// directions to choose where to aim, swapping ammunition and reloading (If applicable to the currently
/// equipped weapon), and using the weapon by switch the player to their using weapon state to handle that
/// process.
///	
///	@param {Real}	delta	The difference in time between the execution of this frame and the last.
state_player_weapon_ready = function(_delta){
	process_player_input();
	determine_movement_vector();
	
	// If the movement vector in either direction is not zero, the currently facing direction will be updated;
	// allowing the player to aim in their desired direction but not move during this state.
	if (moveDirectionX != 0.0 || moveDirectionY != 0.0){
		direction	= point_direction(0.0, 0.0, moveDirectionX, moveDirectionY);
		image_index	= PLYR_MOVE_ANIM_LENGTH * round(direction / PLYR_ANIM_DIRECTION_DELTA);
	}
	
	// Returning from this state will have the highest input priority (Aside from updating the current aiming 
	// direction) and its input check is altered based on if it is set as a toggle or the default method of
	// checking for a hold ending. If the relevant check returns true, the player returns to their default
	// state once again.
	if (PLYR_IS_AIM_TOGGLE ? PINPUT_READY_WEAPON_PRESSED : !PINPUT_READY_WEAPON_HELD){
		object_set_state(state_default);
		return;
	}
	
	// Firing or using the equipped weapon. For fully automatic weapons, the input doesn't need to be 
	// released. For melee and non-automatic weapons, the input will need to be released and pressed again
	// to use the weapon again.
	if (timers[PLYR_WEAPON_ATTACK_TIMER] == 0.0 && PINPUT_USE_WEAPON_HELD && 
			(bulletCounter < weaponBulletCount || weaponBulletCount == -1)){
		// The weapon's clip/magazine is currently empty, so check if a reload is possible and do so instead
		// of firing the weapon when it shouldn't be able to.
		if (weaponRemainingAmmo == 0){
			// Check to make sure there is ammunition within the player's item inventory they can even use
			// to reload their equipped weapon. If not, the state immediately exits and the weapon will not
			// be fired OR reloaded.
			with(equipment){
				if (ammoCount[curAmmoIndex] == 0)
					return;
			}
			
			// Since remaining ammo was found, the player's state is switched to their reloading state so
			// they can reloading when trying to fire a weapon that is currently empty.
			object_set_state(state_player_reloading);
			timers[PLYR_RELOAD_TIMER] = weaponReloadSpeed;
			return;
		}
		
		// Check if the weapon is set to fire a single time/automatically or it is set to fire a burst of
		// bullets before the input needs to be released. If it is the latter, the attack speed for that
		// burst is significantly faster than the regular fire rate.
		if (weaponBulletCount > 1)  { timers[PLYR_WEAPON_ATTACK_TIMER] = weaponAttackSpeed * 0.1; }
		else						{ timers[PLYR_WEAPON_ATTACK_TIMER] = weaponAttackSpeed; }
		
		// Increase the bullet counter and lower the remaining ammo value, but only do the latter if the
		// remaining ammo is any value greater than zero.
		bulletCounter++;
		if (weaponRemainingAmmo != -1)
			weaponRemainingAmmo--;
		
		// Store the player's directional value truncated donw to one of four possible values, and store the
		// current accuracy penalty value that will be applied to the accuracy of the fired bullet.
		var _direction		 = floor(direction / 90) * 90;
		var _accuracyPenalty = curAccuracyPenalty;
		
		// Add to the current accuracy penalty's value whenever a firearm is used. This value isn't reflected
		// in the accuracy of the current fired bullet, but all the ones fired after it.
		curAccuracyPenalty += PLYR_ACCPEN_DECAY_INCREMENT;
		if (curAccuracyPenalty > PLYR_ACCPEN_MAX_VALUE)
			curAccuracyPenalty = PLYR_ACCPEN_MAX_VALUE;
		
		// Jump into scope of the equipment struct so its values can be utilized for determining how the
		// weapon will be used.
		with(equipment){
			// Copy over some of the equipped weapon's characteristics as they will be used to determine how
			// much damage the weapon will do, how many projectiles it needs to spawn, the flags it has toggled,
			// and so on.
			var _damage			= 0;
			var _range			= 0;
			var _accuracy		= 0;
			var _bulletCount	= 0;
			var _flags			= 0;
			with(weaponStatRef){
				_damage			= damage;
				_range			= range;
				_accuracy		= accuracy;
				_bulletCount	= bulletCount;
				_flags			= flags;
			}
			
			// Jump into scope fo the weapon's item inventory struct to see if its quantity and/or durabilty
			// needs to be reduced to reflect the use of the weapon.
			var _isMelee = ((_flags & WEAP_FLAG_IS_MELEE) != 0);
			with(global.curItems[weapon]){
				if (!_isMelee) { quantity--; }
				
				// On higher difficulties, durability will be reduced by one every time the wepaon is used.
				if (global.flags & (GAME_FLAG_CMBTDIFF_PUNISHING | GAME_FLAG_CMBTDIFF_NIGHTMARE | GAME_FLAG_CMBTDIFF_ONELIFE) != 0)
					durability--;
			}
			
			// 
			if (_isMelee){
				// TODO -- Create melee hitbox object here.
				return;
			}
			
			// When a non-melee weapon is being used, the ammunition it utilizes needs to have an effect on
			// the damage, range, accuracy, and bullet count of the projectile. So, this values are all added
			// to what values are currently there.
			with(curAmmoStatRef){
				_damage		   += damage;
				_range		   += range;
				_accuracy	   += accuracy;
				_bulletCount   += bulletCount;
			}
				
			// Multiply the accuracy against the current penalty value. At the worst, an additional 75%
			// is added to the accuracy value to make constant shooting incredihbly inaccurate.
			_accuracy += (_accuracy * _accuracyPenalty);
				
			// Use the accuracy value calculated above to create a range that is -accuracy and +accuracy from
			// the cardinal direction the player is currently facing. A random direction within that area is
			// chosen and added to the base direction to offset it.
			_direction += random_range(-_accuracy, _accuracy);
			
			// Hitscan projectiles will cast a ray between the barrel of the equipped weapon, and the endpoint
			// of the bullet's path based on weapon's range stat. It then iterates through the objects until
			// it hits an object that it can interact with. When that occurs, the bullet ignores the rest of
			// the list as it will be assumed they cannot go through objects.
			if ((_flags & WEAP_FLAG_IS_HITSCAN) != 0){
				for (var i = 0; i < _bulletCount; i++){
					with(GAME_MANAGER){
						var _pX = PLAYER.x;
						var _pY = PLAYER.y - 12;
						add_debug_line(_pX, _pY, 
							_pX + lengthdir_x(_range, _direction), _pY + lengthdir_y(_range, _direction), 
								120);
					}
				}
				
				// There is no need to continue with the state, so it will exit early.
				return;
			}
			
			// TODO -- Create a projectile object here for the weapon.
		}
		
		// Don't allow execution of the remaining portion of this state.
		return;
	}
	
	// Releasing the input while using a non-automatic weapon will have its remaining bullet before needing
	// to release the input reset to what the total count of bullets for that burst fire is.
	if (PINPUT_USE_WEAPON_RELEASED && weaponBulletCount != -1)
		bulletCounter = 0;
	
	// The player has pressed the input that changes the equipped weapon's current ammunition to another
	// type (So long as another type exists), so the function for swapping ammo is called which handles the
	// logic for switch ammo types if possible.
	if (PINPUT_CHANGE_AMMO_PRESSED && swap_current_ammo_index()){
		object_set_state(state_player_reloading);
		timers[PLYR_RELOAD_TIMER] = weaponReloadSpeed;
		return;
	}
	
	// Exit the function early so long as the player hasn't pressed the reload input, as this is the lowest
	// priority processed input while in the readied weapon state.
	if (!PINPUT_RELOAD_WEAPON_PRESSED)
		return;
	
	// Make sure there is ammo in the player's inventory to use in the reload process and that the weapon
	// isn't full on ammo already. If either happens to be true, the reload process isn't started.
	with(equipment){
		if (ammoCount[curAmmoIndex] == 0 || global.curItems[weapon].quantity == weaponStatRef.stackLimit)
			return;
	}
	object_set_state(state_player_reloading);
	timers[PLYR_RELOAD_TIMER] = weaponReloadSpeed;
}

/// @description 
///	A state the player finds themself in when they're reloading their equipped weapon (If that weapon needs
/// to be reloaded). Once the timer for reloading has decremented to zero, the state ends and the reload
/// function is called to handle what is required for that process.
///	
///	@param {Real}	delta	The difference in time between the execution of this frame and the last.
state_player_reloading = function(_delta){
	if (timers[PLYR_RELOAD_TIMER] == 0.0){
		object_set_state(state_player_weapon_ready);
		reload_current_weapon();
		return;
	}
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