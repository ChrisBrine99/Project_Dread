// A macro that defines what setting an object's state to 0 will do. When set to zero, most logic processing
// of objects should be bypassed since it isn't actively doing anything in the game (Excluding rendering if
// that is still required by the object).
#macro	STATE_NONE						0

/// @description 
/// A slightly modified version of the standard instance creation functions that come standard with Game 
/// Maker. It will simply check to see if an object is special before creating an instance of them.
/// 
/// @param {Real}			x		Horizontal position to create the object at within the current room.
/// @param {Real}			y		Vertical position to create the object at within the current room.
/// @param {Asset.GMObject}	object	Index of the GameMaker object asset to create an instance of.
/// @param {Real}			depth	(Optional) Layer/depth to place the instance at. Default value is 30.
function instance_create_object(_x, _y, _object, _depth = 30){
	if (object_is_special(_object))
		return noone;
	return instance_create_depth(_x, _y, _depth, _object);
}

/// @description 
///	A slightly modified version of the standard instance destruction functions that come standard with Game
///	Maker. It will simply check to see if its a special object being destroyed or not, and if so it won't allow
///	that instance to be destroyed.
///	
/// @param {Id.Instance}	id				The desired object instance to remove from the game.
/// @param {Bool}			executeEvent	(Optional) Flag that allows the object's destroy event to be called or not.
function instance_destroy_object(_id, _executeEvent = true){
	if (object_is_special(_id.object_index))
		return;
	instance_destroy(_id, _executeEvent);
}

/// @description 
/// Simply checks to see if the supplied object is special or not. If so, only one instance of it should exist 
/// during runtime; only being deleted once the game itself closes. Otherwise, the object can have as many 
/// instances of it created as required.
/// 
/// @param {Asset.GMObject}	object	Index of the GameMaker object asset to check for.
function object_is_special(_object){
	switch(_object){
		default:					return false;
		case obj_game_manager:		return true;
		case obj_player:			return true;
	}
}

/// @description
/// Determines the state function that the object calling this function will execute from the next frame 
/// onwards. Note that without the "curState", "nextState", and "lastState" variables defined in its Create
/// Event (Or the struct equivalent), a call to this function will cause the game to crash.
/// 
/// @param {Function}	state	The variable assigned to the state function.
function object_set_state(_state){
	if (_state == lastState){ // Returning to the previous state.
		nextState = _state;
		return;
	}
	
	var _index = method_get_index(_state);
	if (is_undefined(_index) || _index == curState)
		return; // Don't update to an invalid state or if the state is identical to the current one.
	nextState = _index;
}