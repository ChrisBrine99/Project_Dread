#region General Struct Macros

// 
#macro 	STR_STRUCTID					"structID" 
#macro 	CREATE_EVENT					"create_event" 
#macro 	DESTROY_EVENT					"destroy_event"

// Macros that determine what group type a given struct instance belongs to in order to prevent certain structs from being created with
// functions like "struct_create_menu_instance" and "light_create", for example.
#macro	STRUCT_TYPE_MENU			   -10000
#macro	STRUCT_TYPE_LIGHT_SOURCE	   -10001

#endregion General Struct Macros

// A list that manages the current struct instances that exist at any given point during runtime, and the unique value to provide to a newly
// created struct instance which will always increment by one from a successful execution of the instance_create_struct function.
global.structs		= ds_list_create();
global.structID		= 1000000000; 
// ^	Start at one billion since GML starts counting instance IDs at 100000; preventing clashing instance IDs between objects and structs.

// A ds_map containing key/value pairs for every struct that can be grouped into specific types to allow only certain groups from being
// created using specific functions like "light_create" and "instance_create_menu_struct", for example.
global.structType	= ds_map_create();
// Each sruct that required a specific typing assigned to it will be added to the ds_map directly below this comment.
ds_map_add(global.structType, str_light_basic,			STRUCT_TYPE_LIGHT_SOURCE);
ds_map_add(global.structType, str_light_flicker,		STRUCT_TYPE_LIGHT_SOURCE);
ds_map_add(global.structType, str_light_blink,			STRUCT_TYPE_LIGHT_SOURCE);
ds_map_add(global.structType, str_sub_menu,				STRUCT_TYPE_MENU);
ds_map_add(global.structType, str_pause_menu,			STRUCT_TYPE_MENU);
ds_map_add(global.structType, str_inventory_menu,		STRUCT_TYPE_MENU);
ds_map_add(global.structType, str_item_menu,			STRUCT_TYPE_MENU);
ds_map_add(global.structType, str_note_menu,			STRUCT_TYPE_MENU);
ds_map_add(global.structType, str_map_menu,				STRUCT_TYPE_MENU);
ds_map_add(global.structType, str_textbox_options_menu,	STRUCT_TYPE_MENU);

#endregion General Struct Global Variable Declarations

#region General Purpose Struct Instance Functions

/// @description 
///	Creates a new struct instance (These structs must use the *constructor* keyword and be a child of *str_base* to call this function 
/// without bugs or crashes). After creation, it will automatically call the instance's *create_event*, store its reference in the ds_list 
/// of currently existing structs, and return that reference should the caller of the function require it. Attempting to create a singleton
/// struct instance with this function will simply return *undefined*.
/// @returns 	{Struct._structFunc}
/// @param 		{Function}			 structFunc		The struct to attempt to create an instance of.
function instance_create_struct(_structFunc){
	if (!is_undefined(global.singletons.structSingletons[? _structFunc]))
		return undefined;
	
	var _structRef = new _structFunc(_structFunc);
	ds_list_add(global.structs, _structRef);
	method_call(struct_get(_structRef, CREATE_EVENT));

	show_debug_message("Created struct {1} (StructRef: {0})", _structRef, _structRef.structID);
	return _structRef; // Returns the reference to the struct for ease of access in the future if required.
}

/// @description 
///	Attempts to destroy a struct via the reference value provided. If that value is found in the list of currently existing structs, the
/// reference is deleted from the list and *delete* is called on said reference so the garbage collecter knows it can safely clean the data.
/// @returns 	{Bool}
/// @param 		{Struct._structFunc}	structRef		Reference to the struct that will be deleted.
function instance_destroy_struct(_structRef){
	var _index = ds_list_find_index(global.structs, _structRef);
	if (_index == -1) // Struct is either a singleton or doesn't exist; no deletion necessary and false is returned.
		return false;
	
	ds_list_delete(global.structs, _index);
	method_call(struct_get(_structRef, DESTROY_EVENT));
	
	show_debug_message("Deleted struct {1} (StructRef: {0})", _structRef, _structRef.structID);
	delete _structRef;
	return true; // Return true to signify a successful deletion.
}

/// @description 
/// Finds the struct with the matching ID from within the global list of structs. If the id wasn't found, the function will return *noone*. 
/// Otherwise, it will return the struct's reference.
/// @returns 	{Struct._structFunc}
/// @param 		{Real}					id		The unique value given upon creation for the desired struct.
function instance_find_struct(_id){
	var _structRef	= undefined;
	var _start		= 0;
	var _end		= ds_list_size(global.structs) - 1;
	var _middle		= 0;
	
	// Loop until the value found in _end either hits or exceeds the value found in _start.
	while (_end >= _start){
        _middle    	= _start + floor((_end - _start) / 2);
		_structRef	= global.structs[| _middle];
		if (struct_get(_structRef, STR_STRUCTID) < _id){
			_start	= _middle + 1;
			continue; // Cut off bottom half and search again.
		}
		
		if (struct_get(_structRef, STR_STRUCTID) > _id){
			_end 	= _middle - 1;
			continue; // Cut off top half and search again.
		}
		
		// Desired struct found; return its reference.
		return _structRef;
	}
	
	// The struct in question wasn't found; return undefined to signify as such.
	return undefined;
}

/// @description 
///	Wrapper function for getting the instance of an existing struct, but treated as if it was the base struct (*str_base*).
/// @returns 	{Struct.str_base}
/// @param		{Real}				index	The position the struct instance occupies within *global.structs*.
function instance_struct_get(_index){
	return ds_list_find_value(global.structs, _index);
}

#endregion General Purpose Struct Instance Functions

#region Singleton Struct Instance Functions

/// @description 
///	Creates a struct that is considered a singleton instance. This will ensure that only a single version of the desired struct(s) exist
/// at a single time. Attempting to create a non-singleton struct here (Or an object) will result in no struct instance being created.
/// @param {Function} structFunc	The struct to attempt to create a singleton instance of.
function instance_create_struct_singleton(_structFunc){
	var _structName = global.singletons.structSingletons[? _structFunc];
	if (is_undefined(_structName) || struct_get(global.singletons, _structName) != _structFunc){
		show_debug_message("{0} cannot be created as a singleton! It either isn't a struct, singleton or already exists!", _structFunc);
		return; // Parameter value isn't a valid singleton struct; don't create anything.
	}
	
	// Create the new instance for the singleton struct, and store its reference in its respective variable within the global.singletons
	// struct. Then, call its create event automatically as all structs should contain it if they're children of str_base.
	var _structRef = new _structFunc(_structFunc);
	struct_set(global.singletons, _structName, _structRef);
	method_call(struct_get(_structRef, CREATE_EVENT));
	
	show_debug_message("Created singleton struct {1} (StructRef: {0})", _structRef, _structRef.structID);
}

/// @description 
///	Destroys a struct that is considered to be a singleton instance. Does nothing if said struct isn't a singleton, doesn't currently exist,
/// or if the provided argument value isn't a struct to begin with.
/// @returns 	{Bool}
/// @param 		{Struct._structFunc}	structRef		Reference to the singleton struct that will be deleted.
function instance_destroy_struct_singleton(_structRef){
	var _structIndex = struct_get(_structRef, "structIndex");
	var _structName = global.singletons.structSingletons[? _structIndex];
	if (is_undefined(_structName)){
		show_debug_message("{0} is not a singleton!", _structRef);
		return false; // Parameter value isn't a valid singleton struct; don't destroy anything and return false.
	}
	
	var _instance = struct_get(global.singletons, _structName);
	if (_instance != _structRef){
		show_debug_message("{0} does not currently exist!", _structRef);
		return false; // Struct that is being deleted doesn't actually exist; don't execute the deletion process and return false.
	}
	
	// Call the singleton's destroy event and reset its value within global.singletons back to its default of the struct's script index.
	// Then, call delete on the reference so the garbage collector knows it can safely clean up the data. Returns true for a successful
	// deletion occurring.
	method_call(struct_get(_instance, DESTROY_EVENT));
	struct_set(global.singletons, _structName, _structIndex);
	show_debug_message("Deleted singleton struct {1} (StructRef: {0})", _instance, _instance.structID);
	delete _instance;
	return true;
}

#endregion Singleton Struct Instance Functions