#region Macros for Base Struct (All standard structs also use these as required)

#macro	STR_FLAG_PERSISTENT				0x80000000	// Prevents struct from being destroyed until end of runtime.
#macro	STR_IS_PERSISTENT				((flags & STR_FLAG_PERSISTENT) != 0)

#endregion Base Struct's Macros

#region Macros for Base Struct (All standard structs also use these as required)

/// @param {Function}	index	Similar to an object's index; it will store the value tied to it by GameMaker during runtime.
function str_base(_index) constructor {
	structID		= global.structID++;
	structIndex		= _index;
	flags			= 0;
	
	/// @description 
	///	Called upon creation of a struct instance (WARNING!! Creating a struct without using 
	/// instance_create_struct will skip the automatic calling of this function).
	///	
	create_event	= function() {}
	
	/// @description 
	///	Called upon destruction of a struct instance (WARNING!! Destroying a struct through manually invoking
	/// the delete keyword will cause this function to be ignored, so using instance_destroy_struct is required).
	///	
	destroy_event = function() {}
}

#endregion Base Struct Definition