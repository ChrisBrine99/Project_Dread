event_inherited(); // Ensures the message's width is stored for displaying it on the screen properly.

// Checking and unlocking the door if it was previously locked from its other side (Or it is the door representing that other side) but has 
// since been unlocked by the player. If so, clear the flags that signify the door is locked so they can open it without having to interact
// twice: once for unlocking again and another for actually opening the door.
if (DOOR_IS_LOCKED_FROM_OTHER_SIDE){
	if (event_get_flag(manualUnlockID))
		flags = flags & ~(DOOR_FLAG_LOCKED_KEY | DOOR_FLAG_LOCKED_OTHER_SIDE);
	return;
}

// Perform a simplified verstion of the door's interaction function by seeing if the key's have been used on each of the door's locks. If
// they've all been opened, the "locked" flag will immediately be cleared.
var _locksOpened	= 0;
var _length			= ds_list_size(lockData);
for (var i = 0; i < _length; i++){
	with(lockData[| i]){
		if (event_get_flag(flagID) == flagState)
			_locksOpened++;
	}
}

if (_locksOpened == _length)
	flags = flags & ~(DOOR_FLAG_LOCKED_KEY | DOOR_FLAG_LOCKED_OTHER_SIDE);