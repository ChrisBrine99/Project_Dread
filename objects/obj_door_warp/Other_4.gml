// Perform a simplified verstion of the door's interaction function by seeing if the key's have been used on each
// of the door's locks. If they've all been opened, the "locked" flag will immediately be cleared.
var _locksOpened	= 0;
var _length			= ds_list_size(lockData);
for (var i = 0; i < _length; i++){
	with(lockData[| i]){
		if (event_get_flag(flagID) == flagState)
			_locksOpened++;
	}
}

if (_locksOpened == _length)
	flags &= ~DOOR_FLAG_LOCKED;