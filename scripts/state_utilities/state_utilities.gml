#region Shared Macros Between State Machine Implementations

// Macros for a default state value which signifies no state is currently set for execution on the object/struct, and condensed code that
// is required to reference the variables "curState", "nextState", and "lastState" outside of the object said variables are contained within.
#macro	STATE_NONE						0
#macro 	CURRENT_STATE					variable_instance_get(self, "curState")
#macro 	NEXT_STATE						variable_instance_get(self, "nextState")
#macro 	LAST_STATE						variable_instance_get(self, "lastState")

// Macros that exist only because "object_set_state" and "object_update_state" used to be the names for those two functions and these macros
// will prevent the project from crashing since not all times they are used have been renamed as of yet.
#macro 	object_set_state				set_state
#macro 	object_update_state				update_state  

#endregion Shared Macros Between State Machine Implementations

#region Setting/Updating State Function Declarations

/// @description
/// Determines the state function that the object calling this function will execute from the next frame onwards. Note that without the 
/// *curState*, *nextState*, and *lastState* variables defined in its *Create Event* (Or the struct equivalent), a call to this function will 
/// cause the game to crash.
/// @param {Function}	state	The variable assigned to the state function.
function set_state(_state){
	if (_state == LAST_STATE){ // Returning to the previous state.
		variable_instance_set(self, "nextState", LAST_STATE);
		return;
	}

	if (is_undefined(_state) || _state == CURRENT_STATE){
		variable_instance_set(self, "nextState", CURRENT_STATE);
		return; // Don't update to an invalid state or if the state is identical to the current one.
	}
	variable_instance_set(self, "curState", STATE_NONE);
	variable_instance_set(self, "nextState", method_get_index(_state));
}

/// @description 
///	Usually called in the *End Step Event* of the object (Or the struct equivalent to that event). Updates the object's current state to match 
/// the value currently stored within its *nextState* variable. Note that without the *curState*, *nextState*, and *lastState* variables 
/// defined in its *Create Event* (Or the struct equivalent), a call to this function will cause the game to crash.
function update_state(){
	if (CURRENT_STATE != NEXT_STATE){
		variable_instance_set(self, "lastState", 	CURRENT_STATE);
		variable_instance_set(self, "curState", 	NEXT_STATE);
	}
}

#endregion Setting/Updating State Function Declarations