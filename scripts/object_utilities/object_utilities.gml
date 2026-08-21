/// @description 
/// A wrapper function for GameMaker's standard *instance_create* function that prevents it from creating new singleton instances if they
/// are objects and found within the *objSingletons* map. In order to create them, the standard *instance_create_depth* or 
/// *instance_create_layer* functions will have to be invoked manually, which should only happen in the creation code of *obj_game_manager*.
/// @returns 	{Id.Instance}
/// @param 		{Real}				x		Horizontal position to create the object at within the current room.
/// @param 		{Real}				y		Vertical position to create the object at within the current room.
/// @param 		{Asset.GMObject}	object	Index of the GameMaker object asset to create an instance of.
/// @param 		{Real}				depth	(Optional) Layer/depth to place the instance at. Default value is 30.
function instance_create_object(_x, _y, _object, _depth = 10){
	if (!is_undefined(global.singletons.objSingletons[? _object]))
		return noone;
	return instance_create_depth(_x, _y, _depth, _object);
}

/// @description 
///	A wrapper function for GameMaker's standard *instance_destroy* function that prevents the destruction of singleton objects through
/// standard means. In order to destroy them, the standard *instance_destroy* function will have to be used (Which should never happen).
/// @param {Id.Instance}	id				The desired object instance to remove from the game.
/// @param {Bool}			executeEvent	(Optional) Flag that allows the object's destroy event to be called or not.
function instance_destroy_object(_id, _executeEvent = true){
	if (!is_undefined(global.singletons.objSingletons[? variable_instance_get(_id, "object_index")]))
		return; // Singleton instance objects cannot be destroyed; prevent that from occurring if the provided ID is a singleton.
	instance_destroy(_id, _executeEvent);
}