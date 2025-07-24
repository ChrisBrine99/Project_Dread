// Two macros that determine which kind of singleton the struct is based on its index instead of an instance ID.
#macro	STRUCT_TYPE_CT_SINGLETON	   -10000	// Can only be created/destroy within rm_init and when the game closes, respectively.
#macro	STRUCT_TYPE_RT_SINGLETON	   -20000	// Allows only one instance to be created at any given time, but can be destroyed to free that slot.

// A list that manages the current struct instances that exist at any given point during runtime, and the unique
// value to provide to a newly created struct instance which will always increment by one from a successful
// execution of the "instance_create_struct" function.
global.structs		= ds_list_create();
global.structID		= 1000000000; // Start at one billion since GML starts counting instance IDs at 100000; preventing clashing instance IDs between objects and structs.

// A list that should only be written to BEFORE the game actually begins running (AKA before rm_init is even
// created and executed) so the game will know at runtime whether a struct can be created multiple times or
// not or has conditions pertaining to its potential creation. 
global.structType	= ds_map_create();
// ALL STRUCTS THAT ARE EITHER A COMPILE-TIME OR RUNTIME SINGLETON HERE SHOULD HAVE THAT VALUE SET HERE!!!
ds_map_add(global.structType, str_base,				STRUCT_TYPE_CT_SINGLETON);
ds_map_add(global.structType, str_camera,			STRUCT_TYPE_CT_SINGLETON);
ds_map_add(global.structType, str_textbox,			STRUCT_TYPE_CT_SINGLETON);
ds_map_add(global.structType, str_base_menu,		STRUCT_TYPE_CT_SINGLETON);
ds_map_add(global.structType, str_inventory_menu,	STRUCT_TYPE_RT_SINGLETON);

/// @description 
///	Attempts to create an instance of the provided struct. If that struct happens to be a "special" struct and 
/// an instance for said struct already exists, this function will not create another instance and "noone" will
/// be returned to signify no creation occured.
///
/// @param {Function}	structFunc		The struct to attempt to create an instance of.
function instance_create_struct(_structFunc){
	if (struct_is_singleton(_structFunc))
		return noone;
	
	var _structRef = new _structFunc(_structFunc);
	ds_list_add(global.structs, _structRef);
	_structRef.create_event();
	
	// Check if the created instance is a runtime singleton. If so, store its reference into the global map
	// for managing singletons; both runtime and compile-time.
	if (!is_undefined(ds_map_find_value(global.structType, _structFunc)))
		ds_map_set(global.sInstances, _structFunc, _structRef);
	
	return _structRef; // Returns the reference to the struct for ease of access in the future if required.
}

/// @description 
///	Destroys the provided struct reference (Special structs don't exist within the management list, so a check 
/// against the struct being special is not required here). This removes it from the global management list and 
/// also singals to the internal garbage collector to free it from memory.
///	
/// @param {Struct._structRef}	structRef		Reference to the struct that will be deleted.
function instance_destroy_struct(_structRef){
	var _index = ds_list_find_index(global.structs, _structRef);
	if (_index == -1 || struct_is_singleton(_structRef.structIndex, true))
		return;
	
	ds_list_delete(global.structs, _index);
	_structRef.destroy_event();
	delete _structRef;
}

/// @description 
/// Finds the struct with the matching ID from within the global list of structs. If the id wasn't found, the 
///	function will return "undefined". Otherwise, it will return the struct's reference.
///	
/// @param {Real}	id		The unique value given upon creation for the desired struct.
function instance_find_struct(_id){
	var _structRef	= undefined;
	var _start		= 0;
	var _end		= ds_list_size(global.structs) - 1;
	var _middle		= floor(_end / 2);
	
	// UNIQUE CASE: only one struct exists; check it to see if the id matches and return its reference if so.
	// Otheriwse, it will return the default value of "undefined".
	if (_end == 0){
		_structRef = global.structs[| 0];
		if (_structRef.structID == _id) 
			return _structRef;
		return undefined;
	} else if (_end == -1){ // UNIQUE CASE: no struct instances exist; always return undefined.
		return undefined;
	}
	
	while (_start != _end){
		_structRef = global.structs[| _middle];
		if (_structRef.structID < _id){
			_start	= _middle; // Cut off bottom half; search remainder of instances.
			_middle = floor((_end + _start) / 2);
			continue;
		}
		
		if (_structRef.structID > _id){
			_end = _middle; // Cut off top half; search remainder of instances.
			_middle = floor((_end + _start) / 2);
			continue;
		}
		
		return _structRef;
	}
	
	return undefined;
}

/// @description 
/// Checks to see if the struct is a compile time singleton or not. It doesn't actually mean that the struct
/// CAN'T be created during runtime, but simply that it can't so long as creation/destruction are done through
/// "instance_create_struct" and "instance_destroy_struct", respectively.
///	
/// @param {Function}	structFunc		The struct function to check.
/// @param {Bool}		isDestroying	(Optional) When true, the function will check if a runtime singleton exists to be deleted.
function struct_is_singleton(_structFunc, _isDestroying = false){
	var _structType = ds_map_find_value(global.structType, _structFunc);
	if (_structType == STRUCT_TYPE_CT_SINGLETON) // No creation of compile time singletons can ever occur.
		return true;
	
	// The struct is a singleton, but it can be created/destroyed during runtime. However, only a single 
	// instance can exist at any given time. This will check if that instance currnetly exists or not.
	if (_structType == STRUCT_TYPE_RT_SINGLETON){
		if (!_isDestroying){ // Only bother checking for a valid instance id if destroying the struct in question.
			var _structID = ds_map_find_value(global.sInstances, _structFunc);
			if (!is_undefined(_structID) && _structID != noone)
				return true;
		}
			
		// Creates a spot in the sInstances map for this runtime singleton's single allowed instance; sets the
		// value to "noone" as a default (This is overwritten in the "instance_create_struct" function).
		ds_map_set(global.sInstances, _structFunc, noone);
	}
	
	return false; // By default, "undefined" is also classified as a standard struct would.
}