#region Macro Initializations

// 
#macro	DOOR_FLAG_LOCKED				0x00000001
#macro	DOOR_FLAG_NORTHBOUND			0x00000002
#macro	DOOR_FLAG_SOUTHBOUND			0x00000004
#macro	DOOR_FLAG_EASTBOUND				0x00000008
#macro	DOOR_FLAG_WESTBOUND				0x00000010

// 
#macro	DOOR_IS_LOCKED					((flags & DOOR_FLAG_LOCKED)		!= 0)
#macro	DOOR_FACING_NORTH				((flags & DOOR_FLAG_NORTHBOUND) != 0)
#macro	DOOR_FACING_SOUTH				((flags & DOOR_FLAG_SOUTHBOUND) != 0)
#macro	DOOR_FACING_EAST				((flags & DOOR_FLAG_EASTBOUND)	!= 0)
#macro	DOOR_FACING_WEST				((flags & DOOR_FLAG_WESTBOUND)	!= 0)

#endregion Macro Initializations

#region Variable Initializations

// Inherit the default interactable's variables and functions, and then adjust the default radius from 8 pixels
// to 12 so the doorways can be better covered by the valid interaction area. For doors, the "textboxMessage"
// variable is used to display the text for when the door is locked.
event_inherited();
interactRadius	= 12;
textboxMessage	= "The door is locked. I can't get it open without its key.";

// Also edit the dfault interaction input prompt to reference that this is a door.
interactMessage	= "Open Door";

// Variables relating to the door's lock/key system. There will be a list containing all the items (AKA keys)
// required within the player's inventory upon interaction to unlock the door, and the last two variables hold
// text that is shown to the player when they've unlocked some of the locks or all of them, respectively.
lockData		= ds_list_create();
semiLockMessage	= "There are still some unopened locks preventing me from opening the door...";
unlockMessage	= "The door has been unlocked.";

// The parameters for the position to snap the player object to and the room to move them to when they
// interact with this object (When it's also flagged to be unlocked) in a given area.
targetX			= 0;
targetY			= 0;
targetRoom		= undefined;

#endregion Variable Initializations

#region Interaction Funciton Override

/// @description 
/// The function that is called whenever the player interacts with the interactable object in question. It 
/// will handle displaying one of the three messages based on if the door is completely unlocked (All locks
/// have been opened by the player), particallyunlocked  (Only some of the locks have been opened), or still
/// completely locked (All locks are still locked). When the door is unlocked, an interaction will cause the
/// player to be warped to the target room and position set for the door. 
///	
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
on_player_interact = function(_delta){
	if (!DOOR_IS_LOCKED || ds_list_size(lockData) == 0){
		if (GAME_IS_ROOM_WARP_OCCURRING || is_undefined(targetRoom) || !room_exists(targetRoom))
			return; // No warp will occur if the target room index isn't defined or a room warp is already occurring.
		global.flags |= GAME_FLAG_ROOM_WARP;
		
		// Set the game manager up to handle the room warping logic. It will add the player to the warp queue
		// with their position after the warp being the target x and y values set by the door.
		var _targetX	= targetX;
		var _targetY	= targetY;
		var _targetRoom = targetRoom;
		with(GAME_MANAGER){
			targetRoom = _targetRoom;
			add_instance_to_warp(PLAYER, _targetX, _targetY);
		}
		
		// Finally, initialize the screen fading effect that is used in tandem with the room warp logic. It is
		// toggled to manually activating its fade out so it doesn't begin fading out until AFTER the target
		// room has completely loaded in.
		with(SCREEN_FADE) { activate_screen_fade(0.05, 0.05, COLOR_BLACK, true); }
		return;
	}
	
	// Loop through the door's list of locks to see how many of them have been unlocked by the player. This
	// sum of opened locks is stored and referenced after the loop to determine which of three different 
	// types of message to show to the player: an unlock message, a partial-unlock message, and a completely 
	// locked message.
	var _locksOpened	= 0;
	var _length			= ds_list_size(lockData);
	for (var i = 0; i < _length; i++){
		with(lockData[| i]){
			// The required key has already been used to unlock the door. Add it to the sum of opened locks
			// and continue on to the next key for the door (If another key exists).
			if (event_get_flag(flagID) == flagState){
				_locksOpened++;
				continue;
			}
			
			// Check to see if the player has the required key within their inventory. If they do, unlock the
			// lock by setting its desired event flag to the state it requires.
			if (item_inventory_count(keyID) >= 1){
				item_inventory_remove(keyID, 1);
				event_set_flag(flagID, flagState);
			}
		}
	}
	
	// Display the unlocked message to signify to the player that the door has been successfully opened. Note
	// that this message can be made unique to each door instance if required.
	if (_locksOpened == _length){
		flags &= ~DOOR_FLAG_LOCKED;
		
		var _unlockMessage = unlockMessage;
		with(TEXTBOX){ // Queue up the door's unlocking message for being displayed to the user.
			queue_new_text(_unlockMessage);
			activate_textbox();
		}
		return;
	}
	
	// Display a "semi-locked" message to signify to the player that the door still has locks that must be 
	// opened before they can enter through it. The message can be adjusted on a per-door basis if required.
	if (_locksOpened > 0){
		var _semiLockMessage = semiLockMessage;
		with(TEXTBOX){
			queue_new_text(_semiLockMessage);
			activate_textbox();
		}
		return;
	}
	
	// The final message, which is simply the message that will show up to the player if they haven't unlocked
	// any of the locks for the door. The message can be adjusted on a per-door basis if required.
	var _lockedMessage = textboxMessage;
	with(TEXTBOX){
		queue_new_text(_lockedMessage);
		activate_textbox();
	}
}

#endregion Interaction Function Override

#region Unique Function Initializations

/// @description 
///	Adds a lock to the door in the form of an event flag bit and item that will be required to unlock the door
/// and set the event flag bit tied to the lock. Note that any number of locks can be added to a door.
///	
/// @param {Real}	keyID		The ID for the item that represents the lock's key in the player's items.
///	@param {Real}	flagID		The event ID flag that is tied to this key.
/// @param {Real}	flagState	The state that the flag needs to be for the lock to be considered open.
add_lock = function(_keyID, _flagID, _flagState){
	flags |= DOOR_FLAG_LOCKED; // A call to this function will always flip the door's "locked" bit.
	var _index = ds_list_find_index(lockData, _flagID);
	if (_index != -1) // If the flag is already occupying the list of keys, don't add it again.
		return;
	
	ds_list_add(lockData, {
		keyID		: _keyID,
		flagID		: _flagID,
		flagState	: _flagState,
	});
}

/// @description 
/// Attempts to set the parameters for the door's room warping. If the index provided for the room doesn't
/// actually exist, the value for "targetRoom" is set to "undefined" so an attempt to warp will not occur.
/// 
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

#endregion Unique Function Initializations