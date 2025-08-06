// Adjust some default variables so the Game Maker animation system can be overridden by a custom implementation.
image_speed		= 0.0;
image_index		= 0;
visible			= false;

#region Dynamic Entity Specific Flags

// Bits for flags that are exclusive to dynamic entities, but are shared between all of them. Bits not shown
// here are occupied if their value is higher than the highest value bit defined here.
#macro	DENTT_FLAG_WORLD_COLLISION		0x01000000

// Checks against the bits that are exclusive to a dynamic entity and its children that determine what aspects
// of the Entity are enabled or disabled for said children of this object.
#macro	DENTT_COLLIDES_WITH_WORLD		((flags & DENTT_FLAG_WORLD_COLLISION) != 0)

#endregion Dynamic Entity Specific Flags

#region Adding Entity To Depth Sorting Grid

var _height = ds_grid_height(global.sortOrder);
ds_grid_resize(global.sortOrder, 2, _height + 1);
ds_grid_set(global.sortOrder, 0, _height, id);

#endregion Adding Entity To Depth Sorting Grid

#region Variable Initializations

// A value storing bits that enable/disable various aspects of the Entity's general functionality.
flags			= 0;

// Stores the currently executing state, as well as the last state to be executed AND the state to shift to at the
// end of the current frame if applicable (Its value matches that of "curState" otherwise).
curState		= 0;
nextState		= 0;
lastState		= 0;

// If required, the entity may utilize its own drawing function to replace the standard one. Having this set
// to 0 will cause the entity to fallback to said standard drawing function.
drawFunction	= 0;

// Stores a reference to a light source struct that will be placed at a given offset relative to the Entity's
// current position. The offset on the x and y axes are stored in the two other values below.
lightSource		= 0;
lightX			= 0;
lightY			= 0;

// Variables for the entity's custom animation implementation, which will utilize the sprite's speed set within
// the editor as well as a target animation frame rate of 60 fps to provide a frame-independent animation system.
animSpeed		= 0.0;
animFps			= 0.0;
animLength		= 0;
animLoopStart	= 0;

// Stores the fractional portion of the Entity's current position within the room to avoid potential issues with
// collision checks and rendering with floating-point position values at lower resolutions (This game is 320 by 180).
xFraction		= 0.0;
yFraction		= 0.0;

// Since this game is top-down, only one movement variable is required since it's assumed the Entity has the
// same velocity across both axes. This means they share the same maximum movement speed, acceleration, and
// speed; their direction determining how they'll move in the game world.
accel			= 0.0;
moveSpeed		= 0.0;
maxMoveSpeed	= 0.0;

// Keeps track of the Entity's current and maximum hitpoints, respectively. When updating the hitpoints for the
// Entity, it will automatically flag them for destruction when it reaches of goes below 0. Note that even with
// the flag toggled, an invincible Entity will not be destroyed.
curHitpoints	= 0;
maxHitpoints	= 0;

#endregion Variable Initializations

#region Utility Function Definitions

/// @description
///	Handles updating the position of the entity while also processing collision against the world if the Entity
/// has been set to collide with that type of collider. The parameter values should be calculated at a rate of
///	60 times per second since that's the target FPS for the game overwll ("deltaTime" is 1.0 at 60fps).
///
///	@param {Real}	xMove	The current horizontal movement rate.
/// @param {Real}	yMove	The current vertical movement rate.
/// @param {Real}	delta	Time between the current and previous frame.
update_position = function(_xMove, _yMove, _delta){
	// Removing fractional values from the Entity's horizontal movement.
	if (_xMove != 0.0){
		_xMove	   *= _delta;
		_xMove	   += xFraction;
		xFraction	= _xMove - (floor(abs(_xMove)) * sign(_xMove));
		_xMove	   -= xFraction;
	}
	
	// Removing fractional values from the Entity's vertical movement.
	if (_yMove != 0.0){
		_yMove	   *= _delta;
		_yMove	   += yFraction;
		yFraction	= _yMove - (floor(abs(_yMove)) * sign(_yMove));
		_yMove	   -= yFraction;
	}
	
	// Once fractional movement values has been removed and stored, updating the position of the Entity or
	// perform collision detection if the Entity is set to collide with general world colliders.
	if (!DENTT_COLLIDES_WITH_WORLD){
		x += _xMove;
		y += _yMove;
		return false;
	}
	return process_world_collision(_xMove, _yMove);
}

/// @description 
///	Handles collision between an Entity and the world collision objects. It handles movement in whole pixels,
/// and as such is pixel-perfect when it comes to collision resolution. Returns true if a collision occurred.
///	
/// @param {Real}	xMove	The number of whole pixels to move along the horizontal axis.
/// @param {Real}	yMove	The number of whole pixels to move along the vertical axis.
process_world_collision = function(_xMove, _yMove){
	var _collision = false;
	
	// Processing horizontal collision
	if (place_meeting(x + _xMove, y, obj_solid_collider)){
		var _xSign	= sign(_xMove);
		while (!place_meeting(x + _xSign, y, obj_solid_collider))
			x	   += _xSign;
		_collision	= true;
	} else{ // No collision; move as normal
		x += _xMove;
	}
	
	// Processing vertical collision
	if (place_meeting(x, y + _yMove, obj_solid_collider)){
		var _ySign	= sign(_yMove);
		while (!place_meeting(x, y + _yMove, obj_solid_collider))
			y	   += _ySign;
		_collision	= true;
	} else{ // No collision; move as normal
		y += _yMove;
	}
	
	return _collision;
}

/// @description 
///	A function that will remove or add some amount of hitpoints from the Entity. It automatically clamps the
///	new value to be between 0 and whatever the Entity's maximum hitpoints are.
///	
///	@param {Real}	amount	The value to remove from the Entity's current hitpoints (Negative numbers will increase their hitpoints).
update_hitpoints = function(_amount){
	curHitpoints = clamp(curHitpoints + _amount, 0, maxHitpoints);
	if (curHitpoints == 0){ // Deactivate and destroy the Entity.
		object_set_state(0);
		flags &= ~ENTT_FLAG_ACTIVE;
		flags |=  ENTT_FLAG_DESTROYED;
	}
}

#endregion Utility Function Definitions

#region Event-Like Function Definitions

/// @description
///	Called within "obj_game_manager" for all dynamic entities. Can be overridden by children to extend its
/// capabilities from simply updating the current state to more as required by the object.
///
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
end_step_event = function(_delta){
	if (curState != nextState){
		lastState = curState;
		curState = nextState;
	}
	
	if (lightSource != noone) // Update the posiiton of the light source in case the entity moved.
		lightSource.light_set_position(x + lightX, y + lightY);
}

#endregion Event Function Definitions