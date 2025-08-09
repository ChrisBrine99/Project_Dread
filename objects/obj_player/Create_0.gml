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

// Checks for the state of all flag bits that are exclusive to the player.
#macro	PLYR_IS_MOVING					((flags & PLYR_FLAG_MOVING)				!= 0)
#macro	PLYR_IS_SPRINTING				((flags & PLYR_FLAG_SPRINTING)			!= 0 && (flags & PLYR_FLAG_MOVING) != 0)
#macro	PLYR_IS_BLEEDING				((flags & PLYR_FLAG_BLEEDING)			!= 0)
#macro	PLYR_IS_CRIPPLED				((flags & PLYR_FLAG_CRIPPLED)			!= 0)
#macro	PLYR_IS_POISONED				((flags & PLYR_FLAG_POISONED)			!= 0)
#macro	PLYR_IS_FLASHLIGHT_ON			((flags & PLYR_FLAG_FLASHLIGHT)			!= 0)
#macro	PLYR_CAN_UP_POISON_DAMAGE		((flags & PLYR_FLAG_UP_POISON_DAMAGE)	!= 0)

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

// Variants of the above pressed/released inputs for readying a weapon and sprinting that can be toggled to 
// be hold inputs or not in the game's accessibility settings.
#macro	PINPUT_READY_WEAPON_HELD		((inputFlags & PINPUT_FLAG_READY_WEAPON)	!= 0)
#macro	PINPUT_SPRINT_HELD				((inputFlags & PINPUT_FLAG_SPRINT)			!= 0)

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

#endregion Misc. Macros

#region Variable Inheritance and Initialization

// Inherit all functions and variables initialized by par_dynamic_entity's create event.
event_inherited();

// Set the flags that are initially toggled upon the player object's creation.
flags				= DENTT_FLAG_WORLD_COLLISION | ENTT_FLAG_OVERRIDE_DRAW | 
						ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE;

// Set the player's acceleration and maximum movement speeds (Running allows the player to temporarily exceed
// this maximum until their stamina runs out).
accel				= PLYR_ACCEL_NORMAL;
maxMoveSpeed		= PLYR_SPEED_NORMAL;

// Create a very dim ambient light that will illuminate the player's face when in complete darkness.
entity_add_basic_light(PLYR_AMBLIGHT_XOFFSET, PLYR_AMBLIGHT_YOFFSET, 
	PLYR_AMBLIGHT_RADIUS, PLYR_AMBLIGHT_COLOR, PLYR_AMBLIGHT_STRENGTH, 0.0, STR_FLAG_PERSISTENT);

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
	weapon			: ID_INVALID,
	weaponAmmo		: ID_INVALID,
	armor			: ID_INVALID,
	flashlight		: ID_INVALID,
	firstAmulet		: ID_INVALID,
	secondAmulet	: ID_INVALID,
};

// 
interactableID		= noone;

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
		
		// Getting input from the secondary analog stick if the controller has one.
		if (gamepad_axis_count(global.gamepadID) > 1){
			padStickInputRH	= gamepad_axis_value(_gamepad, gp_axisrh);
			padStickInputRV = gamepad_axis_value(_gamepad, gp_axisrv);
		}
		
		inputFlags |= (GAME_PAD_RIGHT				 ); // Offset based on position of the bit within the variable.
		inputFlags |= (GAME_PAD_LEFT			<<  1);
		inputFlags |= (GAME_PAD_UP				<<  2);
		inputFlags |= (GAME_PAD_DOWN			<<  3);
		inputFlags |= (GAME_PAD_INTERACT		<<  4);
		inputFlags |= (GAME_PAD_SPRINT			<<  5);
		inputFlags |= (GAME_PAD_READYWEAPON		<<  6);
		inputFlags |= (GAME_PAD_FLASHLIGHT		<<  7);
		inputFlags |= (GAME_PAD_USEWEAPON		<<  8);
		return;
	}
	
	inputFlags |= (GAME_KEY_RIGHT				 ); // Offset based on position of the bit within the variable.
	inputFlags |= (GAME_KEY_LEFT			<<  1);
	inputFlags |= (GAME_KEY_UP				<<  2);
	inputFlags |= (GAME_KEY_DOWN			<<  3);
	inputFlags |= (GAME_KEY_INTERACT		<<  4);
	inputFlags |= (GAME_KEY_SPRINT			<<  5);
	inputFlags |= (GAME_KEY_READYWEAPON		<<  6);
	inputFlags |= (GAME_KEY_FLASHLIGHT		<<  7);
	inputFlags |= (GAME_KEY_USEWEAPON		<<  8);
}

/// @description
/// Calcualtes the values for "moveDirectionX" and "moveDirectionY" based on if a keyboard is being used for
/// input currently or a connected gamepad is being used. Using the joystick on the gamepad will alter the value
/// so it can be any value between -1.0 and 1.0 for each axis, and the standard digital way returns either a
/// -1, 0, or +1 based on current input flags.
/// 
determine_movement_vector = function(){
	if (GAME_IS_GAMEPAD_ACTIVE && (padStickInputLH != 0.0 || padStickInputLV != 0.0)){ 
		moveDirectionX = padStickInputLH;
		moveDirectionY = padStickInputLV;
	} else{ // Uses the d-pad values to return a value of -1, 0, or +1.
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

#endregion Utility Function Definitions

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
			flags |= PLYR_FLAG_UP_POISON_DAMAGE;
			poisonDamagePercent *= 2.0;
		} else{
			flags &= ~PLYR_FLAG_UP_POISON_DAMAGE;
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
			
	var _interactX = x + lengthdir_x(10, direction);
	var _interactY = y + lengthdir_y(8, direction) - 8;
	draw_set_color(COLOR_TRUE_WHITE);
	draw_set_alpha(1.0);
	draw_sprite(spr_rectangle, 0, _interactX, _interactY);
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
		flags		   |= PLYR_FLAG_MOVING;
		moveSpeed	   += accel * _delta;
		if (moveSpeed > maxMoveSpeed)
			moveSpeed	= maxMoveSpeed;
		direction		= point_direction(0.0, 0.0, moveDirectionX, moveDirectionY);
	} else if (moveSpeed > 0.0){ // Handling deceleration
		moveSpeed		   -= accel * _delta;
		if (moveSpeed <= 0.0){
			flags		   &= ~PLYR_FLAG_MOVING;
			image_index		= animLoopStart;
			animCurFrame	= 0.0;
			moveSpeed		= 0.0;
		}
	}
	
	// Handling the input for toggling the flashlight on and off (If one happens to be equipped).
	if (PINPUT_FLASHLIGHT_PRESSED && equipment.flashlight != ID_INVALID){
		// Turning off the flashlight; returning the player's ambient light to its default parameters.
		if (PLYR_IS_FLASHLIGHT_ON){
			flags &= ~PLYR_FLAG_FLASHLIGHT;
			lightX = PLYR_AMBLIGHT_XOFFSET;
			lightY = PLYR_AMBLIGHT_YOFFSET;
			lightSource.light_set_properties(PLYR_AMBLIGHT_RADIUS, PLYR_AMBLIGHT_COLOR, PLYR_AMBLIGHT_STRENGTH);
		} else{ // Turning on the flashlight; using the properties of the equipped flashlight.
			flags |= PLYR_FLAG_FLASHLIGHT;
			//lightSource.light_set_properties(64.0, COLOR_VERY_LIGHT_YELLOW, 0.8);
		}
	}
	
	// 
	var _isMoving = PLYR_IS_MOVING;
	if (_isMoving || interactableID == noone){
		var _interactX			= x + lengthdir_x(10, direction);
		var _interactY			= y + lengthdir_y(8, direction) - 8;
		interactableID			= instance_nearest(_interactX, _interactY, par_interactable);
		with(interactableID){
			if (point_distance(_interactX, _interactY, interactX, interactY) <= interactRadius){
				flags |= INTR_FLAG_INTERACT;
				break;
			}
			flags &= ~INTR_FLAG_INTERACT;
		}
	}
	
	// 
	if (PINPUT_INTERACT_PRESSED){
		with(interactableID){
			if (INTR_CAN_PLAYER_INTERACT){
				on_player_interact(_delta);
				flags &= ~INTR_FLAG_INTERACT;
			}
		}
		interactableID = noone;
	}
	
	// Don't bother with collision, sprinting or animation if the player isn't current considered moving.
	if (!_isMoving)
		return;
		
	// Activating the player's sprinting, which will cause their stamina to deplete to zero and remain there
	// until they stop running. They can still run without stamina, but the speed is heavily reduced.
	if (PINPUT_SPRINT_PRESSED && !PLYR_IS_SPRINTING){
		timers[PLYR_STAMINA_LOSS_TIMER] = PLYR_STAMINA_LOSS_RATE;
		flags |= PLYR_FLAG_SPRINTING;
		
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

		flags		   &= ~PLYR_FLAG_SPRINTING;
		accel			= PLYR_ACCEL_NORMAL;
		maxMoveSpeed	= PLYR_SPEED_NORMAL;
	}

	// Process the movement animation as normal if no collision occurred for the frame.
	process_movement_animation(_delta);
}
object_set_state(state_default);
curState = nextState; // Instantly applies the state specified above.

/// @description 
///	A very VERY simple function that simply checks to see if the textbox is no longer open. If that is the
/// case, the player will be returned to whatever their previous state was prior to the textbox opening.
/// 
///	@param {Real}	delta	The difference in time between the execution of this frame and the last.
state_textbox_open = function(_delta){
	if (!GAME_IS_TEXTBOX_OPEN){
		object_set_state(lastState);
	}
}

#endregion State Function Definitions