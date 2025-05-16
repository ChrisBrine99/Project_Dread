// A list that manages the current struct instances that exist at any given point during runtime, and the unique
// value to provide to a newly created struct instance which will always increment by one from a successful
// execution of the "instance_create_struct" function.
global.structs = ds_list_create();
global.structID = 200000;

/// @description 
///	Attempts to create an instance of the provided struct. If that struct happens to be a "special" struct and 
/// an instance for said struct already exists, this function will not create another instance.
///	
/// @param {Function}	structFunc		The struct to create an instance for (Cannot create duplicates of singleton structs).
function instance_create_struct(_structFunc){
	if (struct_is_special(_structFunc))
		return undefined;
	
	var _structRef = new _structFunc(_structFunc);
	ds_list_add(global.structs, _structRef);
	_structRef.create_event();
	
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
	if (_index == -1)
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
/// A struct that is considered "special" is one that acts like a singleton; only one instance can exist during 
/// runtime and it cannot be destroyed during the game's runtime. If the supplied struct is special, this 
/// function will return true. Otherwise, it will return false.
///	
/// @param {Function}	structFunc		The struct function to check.
function struct_is_special(_structFunc){
	switch(_structFunc){
		default:			return false;
		case str_textbox:	return true;
		case str_camera:	return true;
		case str_base:		return true;
	}
}