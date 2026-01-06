// Macros that determine the size of the buffer (which must be set in bytes) and that represents the total
// number of bits found within that event flag buffer relative to the size in bytes, respectively.
#macro	EVENT_BUFFER_SIZE_BYTES			64
#macro	EVENT_BUFFER_SIZE_BITS			8 * EVENT_BUFFER_SIZE_BYTES

// A global variable that will store a buffer of bits for various aspects of the game; from locks on doors to
// cutscenes, and so on. These values can either be set or cleared to cause these unique events to happen or
// be removed from the game.
global.eventFlags = buffer_create(EVENT_BUFFER_SIZE_BYTES, buffer_fast, 1);
buffer_fill(global.eventFlags, 0, buffer_u8, 0, EVENT_BUFFER_SIZE_BYTES);

/// @description 
/// Sets a given bit within the "global.eventFlags" buffer to either true (1) or false (0) depending on what
/// the second argument of the function is set to.
///	
///	@param {Real}	flagID		The position of the bit (Starting from 0 as the first) to get the value of.
/// @param {Bool}	flagState	The desired value to set the event's bit to (True = 1, False = 0).
function event_set_flag(_flagID, _flagState){
	if (_flagID < 0 || _flagID >= EVENT_BUFFER_SIZE_BITS)
		return; // The desired flag is out of the bounds of the buffer.
	
	// Grab the byte offset that will be used to read the desired group of bits from the buffer, and then 
	// calculate the offset into that byte that the desired bit resides.
	var _byteOffset = _flagID >> 3;
	var _bitField	= buffer_peek(global.eventFlags, _byteOffset, buffer_u8);
	var _bitOffset	= _flagID % 8; // Determine offset within the byte for the bit we need.
	
	var _bitFieldString = "";
	for (var i = 0; i < 8; i++) { _bitFieldString += string(real(bool(_bitField & (1 << i)))); }
	show_debug_message("Setting bit {0} from bit field {1} to {2}.", _flagID, _bitFieldString, _flagState);
	
	// Finally, clear the bit if "_flagState" is false, or set it if "_flagState" is true by performing bitwise 
	// math on the byte that was retrieved from the event flag buffer relative to the id bit's offset.
	if (_flagState) { buffer_poke(global.eventFlags, _byteOffset, buffer_u8, _bitField |  (1 << _bitOffset)); }
	else			{ buffer_poke(global.eventFlags, _byteOffset, buffer_u8, _bitField & ~(1 << _bitOffset)); }
}

/// @descrription 
///	Grabs a given flag from the "global.eventFlags" buffer and returns either true (1) or false (0) depending
/// on if the bit in question has been set or cleared. If the flagID is out of the bounds of the buffer, the
/// function will return false (0) by default.
///	
///	@param {Real}	flagID		The position of the bit (Starting from 0 as the first) to get the value of.
function event_get_flag(_flagID){
	if (_flagID < 0 || _flagID >= EVENT_BUFFER_SIZE_BITS)
		return false; // False will always be the default flag value.
	
	// Grab the byte offset that will be used to read the desired group of bits from the buffer, and then 
	// calculate the offset into that byte that the desired bit resides.
	var _byteOffset = _flagID >> 3;
	var _bitField	= buffer_peek(global.eventFlags, _byteOffset, buffer_u8);
	var _bitOffset	= _flagID % 8; // Determine offset within the byte for the bit we need.
	
	//var _bitFieldString = "";
	//for (var i = 0; i < 8; i++) { _bitFieldString += string(real(bool(_bitField & (1 << i)))); }
	//show_debug_message("Getting bit {0} from bit field {1}.", _flagID, _bitFieldString);
	
	// Finally, return a bool that is either true (1) or false (0) depending on what is calculated from bitwise
	// ANDing the grabbed bitfield against a value where only the desired bit is set.
	if (_bitOffset == 0) // No bit shifting required; AND the value against one.
		return bool(_bitField & 0b00000001);
	return bool(_bitField & (1 << _bitOffset));
}