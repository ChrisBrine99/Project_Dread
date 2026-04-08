#region Macro Initializations

// Macros for the bits the door warp will utilize for various characteristics about itself at a given moment of time.
#macro	DOOR_FLAG_LOCKED_KEY			0x00000001
#macro 	DOOR_FLAG_LOCKED_OTHER_SIDE 	0x00000002
#macro 	DOOR_FLAG_INTERACT_UNLOCK		0x00000004
#macro	DOOR_FLAG_NORTHBOUND			0x00000008
#macro	DOOR_FLAG_SOUTHBOUND			0x00000010
#macro	DOOR_FLAG_EASTBOUND				0x00000020
#macro	DOOR_FLAG_WESTBOUND				0x00000040

// Macros for referencing the state of the door warp's flags; if they are set or cleared.
#macro	DOOR_IS_LOCKED_BY_KEY			((flags & DOOR_FLAG_LOCKED_KEY)			!= 0)
#macro 	DOOR_IS_LOCKED_FROM_OTHER_SIDE	((flags & DOOR_FLAG_LOCKED_OTHER_SIDE)	!= 0) 
#macro 	DOOR_CAN_INTERACT_UNLOCK		((flags & DOOR_FLAG_INTERACT_UNLOCK) 	!= 0) 
#macro	DOOR_FACING_NORTH				((flags & DOOR_FLAG_NORTHBOUND) 		!= 0)
#macro	DOOR_FACING_SOUTH				((flags & DOOR_FLAG_SOUTHBOUND) 		!= 0)
#macro	DOOR_FACING_EAST				((flags & DOOR_FLAG_EASTBOUND)			!= 0)
#macro	DOOR_FACING_WEST				((flags & DOOR_FLAG_WESTBOUND)			!= 0)

// Special marco for checking if both the "locked" flags are set to zero so it can begin the warping process.
#macro 	DOOR_IS_UNLOCKED		 		((flags & (DOOR_FLAG_LOCKED_KEY | DOOR_FLAG_LOCKED_OTHER_SIDE)) == 0)

// Determines how fast the door's direction arrow indicator will bob up/down or left/right to signify the player is able to interact with it 
// (Locked doors won't display this indicator).
#macro	DOOR_ARROW_MOVE_SPEED			0.03

// Determines how fast the screen will fade into the warp's screen fade and out of it during the warp process.
#macro	DOOR_WARP_FADE_IN_SPEED			0.02
#macro	DOOR_WARP_FADE_OUT_SPEED		0.02

#endregion Macro Initializations

#region Variable Initializations

// Inherit the default interactable's variables and functions, and then adjust the default radius from 8 pixels to 12 so the doorways can be
// better covered by the interaction area. For doors, the "textboxMessage" variable is used to display the text for when the door is locked.
event_inherited();
interactRadius	= 12;
textboxMessage	= "The door is locked. I can't get it open without its key.";

// Ensure the entity sorting/rendering systems know that the door warp will use a custom draw function and that it is an active entity 
// (Without being set to active, rendering always gets skipped).
flags = ENTT_FLAG_OVERRIDE_DRAW | ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE;

// Also edit the default interaction input prompt to reference that this is a door.
interactMessage	= "Open Door";

// Variables relating to the door's lock/key system. There will be a list containing all the items (AKA keys) required within the player's 
// inventory upon interaction to unlock the door, and the last two variables hold text that is shown to the player when they've unlocked 
// some of the locks or all of them, respectively.
lockData		= ds_list_create();
semiLockMessage	= "There are still some unopened locks preventing me from opening the door...";
unlockMessage	= "The door has been unlocked.";

// The parameters for the position to snap the player object to and the room to move them to when they interact with this object (When it's 
// also flagged to be unlocked) in a given area.
targetX			= 0;
targetY			= 0;
targetRoom		= undefined;

// Acts as both the offset and the timer for the arrow indicator's bobbing effect. It will increase until 2.0 before rolling back to zero to 
// repeat the process indefinitely.
arrowOffset		= 0.0;

// Stores an event flag ID that is set to true if the door has been manually unlocked by the player. This is used with doorways that are
// locked from one side and not for doors that are locked by keys.
manualUnlockID	= EVENT_ID_INVALID;

#endregion Variable Initializations

#region Interaction Funciton Override

/// @description 
/// The function that is called whenever the player interacts with the interactable object in question. It will handle displaying one of the
/// three messages based on if the door is completely unlocked (All locks have been opened by the player), partically unlocked  (Only some of 
/// the locks have been opened), or still completely locked (All locks are still locked). When the door is unlocked, an interaction will 
/// cause the player to be warped to the target room and position set for the door. 
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
on_player_interact = function(_delta){
	if (DOOR_IS_UNLOCKED){
		if (GAME_IS_ROOM_WARP_OCCURRING || is_undefined(targetRoom) || !room_exists(targetRoom))
			return; // No warp will occur if the target room index isn't defined or a room warp is already occurring.
		global.flags = global.flags | GAME_FLAG_ROOM_WARP;
		
		// Set the game manager up to handle the room warping logic. It will add the player to the warp queue with their position after the 
		// warp being the target x and y values set by the door.
		var _targetX	= targetX;
		var _targetY	= targetY;
		var _targetRoom = targetRoom;
		with(GAME_MANAGER){
			targetRoom = _targetRoom;
			add_instance_to_warp(PLAYER, _targetX, _targetY);
		}
		
		// Finally, initialize the screen fading effect that is used in tandem with the room warp logic. It is toggled to manually activating
		// its fade out so it doesn't begin fading out until AFTER the target room has completely loaded in.
		with(SCREEN_FADE)
			activate_screen_fade(DOOR_WARP_FADE_IN_SPEED, DOOR_WARP_FADE_OUT_SPEED, COLOR_BLACK, true);
		return;
	}
	
	// If this door represents the "other side" of a locked door that cannot be opened via key, this branch is taken and the relevant flag
	// for both sides of the door is set to true. The custom unlocked message is shown to the player, and both flags for the door being
	// locked are clear in case the other was set accidentally, as this logic doesn't care if it is, but actually opening the door does.
	if (DOOR_CAN_INTERACT_UNLOCK){
		event_set_flag(manualUnlockID, true);
		textbox_show_message(unlockMessage);
		flags = flags & ~(DOOR_FLAG_LOCKED_KEY | DOOR_FLAG_LOCKED_OTHER_SIDE);
		return;
	}
	
	// The door is currently locked from the opposite side to where the player is. So, a message is displayed to let them know that the door
	// can be unlocked without any kind of key, but they must reach the other side in order to unlock it.
	if (DOOR_IS_LOCKED_FROM_OTHER_SIDE){
		textbox_show_message(textboxMessage);
		return;
	}
	
	// Loop through the door's list of locks to see how many of them have been unlocked by the player. This sum of opened locks is stored and
	// referenced after the loop to determine which of three different types of message to show to the player: an unlock message, a partial
	// unlock message, and a completely locked message.
	var _locksOpened	= 0;
	var _length			= ds_list_size(lockData);
	for (var i = 0; i < _length; i++){
		with(lockData[| i]){
			// The required key has already been used to unlock the door. Add it to the sum of opened locks and continue on to the next key 
			// for the door (If another key exists).
			if (event_get_flag(flagID) == flagState){
				_locksOpened++;
				continue;
			}
			
			// Check to see if the player has the required key within their inventory. If they do, unlock the lock by setting its desired 
			// event flag to the state it requires. Increment _locksOpened since a lock has been opened.
			if (item_inventory_count(keyName) >= 1){
				item_inventory_remove(keyName, 1);
				event_set_flag(flagID, flagState);
				textbox_queue_used_item(keyName);
				_locksOpened++;
			}
		}
	}
	
	// Display the unlocked message to signify to the player that the door has been successfully opened.
	if (_locksOpened == _length){
		textbox_show_message(unlockMessage);
		flags = flags & ~DOOR_FLAG_LOCKED_KEY;
		return;
	}
	
	// Display a message letting the player know they haven't unlocked any of the door's locks yet (Stored in "textboxMessage"), or if they
	// have partially unlocked the door but not completely (Stored in "semiLockMessage"). 
	if (_locksOpened > 0) 	{ textbox_show_message(semiLockMessage); }
	else 					{ textbox_show_message(textboxMessage); }
}

#endregion Interaction Function Override

#region Custom Draw Function Definition

/// @description 
///	A custom drawing function for the door. It will display an arrow pointing in the direction that the door is flagged as facing towards; 
/// bobbing up and down or left and right for a small animation while it is visible to the player.
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
custom_draw_default = function(_delta){
	if (!INTR_CAN_PLAYER_INTERACT || !DOOR_IS_UNLOCKED)
		return;
	
	arrowOffset += DOOR_ARROW_MOVE_SPEED * _delta;
	if (arrowOffset >= 2.0) // Reset back to 0 so door indication switches between two positions.
		arrowOffset -= 2.0;
		
	// Calculate the arrow's offset by rounding the value downward; allowing it to bob up and down pixel-by-pixel instead of slowly shifting 
	// through subpixels relative to the value plus its fraction part. Then, store the door's position into local variables so the calculated
	// offset can be added as required.
	var _arrowOffset	= floor(arrowOffset);
	var _xPosition		= x;
	var _yPosition		= y;
	
	// Check which direction the doorway is facing. If it is up or down, the arrow's offset will be placed on the indicator's y position. 
	// Otherwise, the offset is applied to the x position.
	if (DOOR_FACING_NORTH)		{ _yPosition = y - _arrowOffset; } 
	else if (DOOR_FACING_SOUTH)	{ _yPosition = y + _arrowOffset; }
	else if (DOOR_FACING_EAST)	{ _xPosition = x + _arrowOffset; }
	else if (DOOR_FACING_WEST)	{ _xPosition = x - _arrowOffset; }
		
	// Finally, take the positional values and draw the arrow indicator. Note that since it is drawn in what could be considered "world 
	// space" , the indicator is affected by the current area's lighting.
	draw_sprite_ext(sprite_index, image_index, _xPosition, _yPosition, 1.0, 1.0, 0.0, COLOR_TRUE_WHITE, 1.0);
}
drawFunction = method_get_index(custom_draw_default);

#endregion Custom Draw Function Definition

#region Unique Function Initializations

/// @description 
///	Adds a lock to the door in the form of an event flag bit and item that will be required to unlock the door and set the event flag bit 
/// tied to the lock. Note that any number of locks can be added to a door.
/// @param {String}	keyName		The name for the item that represents the lock's key in the player's items.
///	@param {Real}	flagID		The event ID flag that is tied to this key.
/// @param {Real}	flagState	The state that the flag needs to be for the lock to be considered open.
add_lock = function(_keyName, _flagID, _flagState){
	flags = flags | DOOR_FLAG_LOCKED_KEY; // A call to this function will always flip the door's "locked" bit.
	var _index = ds_list_find_index(lockData, _flagID);
	if (_index != -1) // If the flag is already occupying the list of keys, don't add it again.
		return;
	
	ds_list_add(lockData, {
		keyName		: _keyName,
		flagID		: _flagID,
		flagState	: _flagState,
	});
}

/// @description 
/// Attempts to set the parameters for the door's room warping. If the index provided for the room doesn't actually exist, the value for 
/// *targetRoom* is set to *undefined* so an attempt to warp will not occur.
/// @param {Real}			targetX		Player's destination along the x-axis within the target room.
/// @param {Real}			targetY		Player's destination along the y-axis within the target room.
/// @param {Asset.GMRoom}	targetRoom	The room to warp the player to.
set_warp_params = function(_targetX, _targetY, _targetRoom){
	if (!room_exists(_targetRoom)){
		targetRoom = undefined;
		return;
	}
	targetX		= _targetX;
	targetY		= _targetY;
	targetRoom	= _targetRoom;
}

/// @description 
///	Sets up the door to internally face a given *direction* which can be one of four different possibilities: north, south, east, or west. 
/// This will determine where to place the door indicator arrow and which one to use relative to the desired direction.
/// @param {Real}	flag 
set_facing_direction = function(_flag){
	// Don't set a facing direction if the flag specified isn't a valid direction flag. Instead, set the door to not be active so it doesn't 
	// get rendered pointing in the wrong direction.
	if ((_flag & (DOOR_FLAG_NORTHBOUND | DOOR_FLAG_SOUTHBOUND | DOOR_FLAG_EASTBOUND | DOOR_FLAG_WESTBOUND)) == 0){
		flags = flags & ~ENTT_FLAG_ACTIVE;
		return; 
	}
	flags = flags | _flag;
	
	// Offset along the x or y position, and assign the proper subimage based on the _flag value. Note that if for some reason this value is 
	// a combination of multiple direction flags, the offset and proper subimage will not be set.
	if (_flag == DOOR_FLAG_NORTHBOUND){
		image_index	= 0;
		y		   -= 8;
		// No adjusts to the interaction origin required.
	} else if (_flag == DOOR_FLAG_SOUTHBOUND){
		image_index	= 2;
		y		   += 6;
		interactY  += 8; // Interaction origin is also offset downward.
	} else if (_flag == DOOR_FLAG_EASTBOUND){
		image_index = 3;
		x		   += 8;
		interactX  += 8; // Shift interaction origin to the right.
	} else if (_flag == DOOR_FLAG_WESTBOUND){
		image_index	= 1;
		x		   -= 8;
		interactX  -= 8; // Shift interaction origin to the left.
	}
}

/// @description 
/// Sets the door as locked, but not by a key. Instead, it is locked from the "other side" meaning the player will have to go to where this
/// door leads to in order to unlock it. Until then, it remains locked.
/// @param {Real}	flagID				Flag bit that represents if the door is currently locked (Bit is set to 0) or unlocked (Set to 1).
/// @param {String}	textboxMessage		(Optional) The message that is displayed to the player when they attempt to interact with the door.
set_locked_other_side = function(_flagID, _textboxMessage = "The door is locked from the other side."){
	if (manualUnlockID != EVENT_ID_INVALID)
		return;
	manualUnlockID 	= _flagID;
	flags 			= flags | DOOR_FLAG_LOCKED_OTHER_SIDE;
	textboxMessage = _textboxMessage;
}

/// @description 
///	Sets the door as locked, but not by a key. Instead, it is a door locked from the "other side" and this door object represents that "other
/// side". Upon interacting with it, the player will unlock the doorway.
/// @param {Real}	flagID			Flag bit that represents if the door is currently locked (Bit is set to 0) or unlocked (Set to 1).
/// @param {String}	unlockMessage	(Optional) Custom message that can be created instead of using the default message for unlocking a door.
set_locked_this_side = function(_flagID, _unlockMessage = ""){
	if (manualUnlockID != EVENT_ID_INVALID)
		return;
	manualUnlockID 	= _flagID;
	flags 			= flags | DOOR_FLAG_LOCKED_OTHER_SIDE | DOOR_FLAG_INTERACT_UNLOCK;
	if (_unlockMessage != "") // Only overwrite the base unlock message if one is provided.
		unlockMessage = _unlockMessage;
}

#endregion Unique Function Initializations