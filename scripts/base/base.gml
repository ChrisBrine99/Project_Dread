#region Macros for Base Struct (All standard structs also use these as required)

#macro	STR_FLAG_PERSISTENT				0x80000000	// Prevents struct from being destroyed until end of runtime.
#macro	STR_IS_PERSISTENT				(flags & STR_FLAG_PERSISTENT)

#endregion Base Struct's Macros

#region Macros for Base Struct (All standard structs also use these as required)

/// @param {Function}	index	Similar to an object's index; it will store the value tied to it by GameMaker during runtime.
function str_base(_index) constructor {
	structID		= global.structID++;
	structIndex		= _index;
	flags			= 0;
	
	create_event	= function() {}
	destroy_event	= function() {}
}

#endregion Base Struct Definition