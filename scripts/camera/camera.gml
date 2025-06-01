#region Macros for Camera Struct

// Values for the flags that are unique to the camera. They allow various states to be enabled or disabled as
// required during runtime.
#macro	CAM_FLAG_BOUNDS_LOCKED			0x00000001	// Prevents the viewport from going outside of the room bounds.
#macro	CAM_FLAG_FOLLOWING_OBJECT		0x00000002

// Macros for the checks required to see if each flag unique to the camera is currently set 0 or 1.
#macro	CAM_ARE_BOUNDS_LOCKED			((flags & CAM_FLAG_BOUNDS_LOCKED)		!= 0)
#macro	CAM_IS_FOLLOWING_OBJECT			((flags & CAM_FLAG_FOLLOWING_OBJECT)	!= 0)

// The default viewport width and height. The application window size should ALWAYS be set to a whole number 
// multiple of these values. Otherwise pixels on the screen won't be equally sized; ruining the image quality.
#macro	VIEWPORT_WIDTH					320
#macro	VIEWPORT_HEIGHT					180

// Determines a square region with a width and height of the value below multiplied by two where the camera
// will no longer move alongside the object it is currently set to follow.
#macro	DEADZONE_SIZE					8

#endregion Macros for Camera Struct

#region Camera Struct Definition

/// @param {Function}	index	The value of "str_camera" as determined by GameMaker during runtime.
function str_camera(_index) : str_base(_index) constructor {
	flags			= STR_FLAG_PERSISTENT;
	
	// Stores the true position of the camera, which is usually set to the coordinates of the object it has
	// been set to follow throughout the current room.
	x				= 0;
	y				= 0;
	
	// Create the camera instance, set its position such that the camera's position is as close to the center
	// of the screen as possible, and set its view size to match that of the viewport dimensions above.
	cameraID		= camera_create();
	
	// Variables that keep track of various characteristics of the camera's viewport. It stores the positional
	// data and current size of the viewport, as well as the instance ID for the object the camera is following.
	viewportX		= 0;
	viewportY		= 0;
	viewportWidth	= 0;
	viewportHeight	= 0;
	followedObject	= noone;
	
	/// @description 
	///	The camera struct's destroy event. It will clean up anything that isn't automatically cleaned up by
	/// GameMaker when a struct is destroyed/out of scope.
	///
	destroy_event = function(){
		camera_destroy(cameraID);
		cameraID = -1;
	}
	
	/// @description 
	///	Called every frame that the camera struct exists (Which should be the entirety of the game). It handles
	/// moving the viewport to follow an object if the camera has an instance to follow.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	step_event = function(_delta){
		// The camera is manually controlled during cutscenes, so the functions within the cutscene manager
		// for moving the camera around will have to be used to move the camera as required. Not having an
		// object to follow will also mean the camera will not run its step event.
		if (GAME_IS_CUTSCENE_ACTIVE || followedObject == noone)
			return;
		
		// Move towards the target object if one is assigned by the camera isn't "following" it yet. In this
		// context, "following" means that the camera is centered upon the followed object.
		if (!CAM_IS_FOLLOWING_OBJECT){
			move_towards_object(followedObject, 0.25, _delta);
			return;
		}
		
		// Grabs the followed object's position and stores it into two local variables for the x and y position
		// of that object, respectively. Then, it uses those values to ensure the camera keeps the object in
		// the deadzone at the center of the viewport.
		var _objectX = x;
		var _objectY = y;
		with(followedObject){
			_objectX = x;
			_objectY = y;
		}
		
		// Keeping the object within the deadzone area along the x axis.
		if (_objectX < x - DEADZONE_SIZE)		{ x = _objectX + DEADZONE_SIZE; }
		else if (_objectX > x + DEADZONE_SIZE)	{ x = _objectX - DEADZONE_SIZE; }
		
		// Keeping the object within the deadzone area along the y axis.
		if (_objectY < y - DEADZONE_SIZE)		{ y = _objectY + DEADZONE_SIZE; }
		else if (_objectY > y + DEADZONE_SIZE)	{ y = _objectY - DEADZONE_SIZE; }
	}
	
	/// @description 
	///	Called at the end of the step events for all instances. It is responsible for setting the viewport to
	/// the coordinate calculated during the camera's step event (If an object is being followed). The camera's
	/// position is actual the center of the viewport instead of the top-left to make camera movement easier.
	///	
	end_step_event = function(){
		// Offset the viewport coordinates such that the viewport is centered on the camera's position.
		var _viewX = x - floor(viewportWidth / 2);
		var _viewY = y - floor(viewportHeight / 2);
		
		if (CAM_ARE_BOUNDS_LOCKED){ // Camera is bound; clamp the view coords to not go outside the room.
			camera_set_view_pos(cameraID, 
				clamp(_viewX, 0, room_width - viewportWidth), 
				clamp(_viewY, 0, room_height - viewportHeight)
			);
		} else{ // Camera isn't bound to the room's dimensions; simply update the position with no clamping.
			camera_set_view_pos(cameraID, _viewX, _viewY);
		}
		
		// Finally, update the viewport position variables to match the updated values.
		viewportX = camera_get_view_x(cameraID);
		viewportY = camera_get_view_y(cameraID);
	}
	
	/// @description 
	///	Called when a new room is loaded in by GameMaker. It enables the viewport for said room, sets it to
	/// visible, and performs a check to see if the followed object still exists so it doesn't try to follow
	///	a now non-existent instance.
	///
	room_start_event = function(){
		// Sets up the viewport for the room to utilize the camera that was set up during the game's initialization.
		view_set_visible(0, true);
		view_set_camera(0, cameraID);
		view_enabled = true;
		
		// Check if the followed object still exists. If not, clear the value so the camera won't crash the
		// game by attempting to follow something that isn't there anymore.
		if (followedObject != noone && !instance_exists(followedObject)){
			flags		   &= ~CAM_FLAG_FOLLOWING_OBJECT;
			followedObject	= noone;
		}
	}
	
	/// @description 
	///	Moves the camera towards a given object's coordinates within the room. The speed at which the camera
	/// moves towards said coordinates is relative to the difference between them and the camera's current
	/// position. So, it will smoothly decelerate as the camera gets closer to its target.
	///	
	/// @param {Id.Instance}	object	The id for the object that the camera is moving towards.
	///	@param {Real}			speed	Determines how fast the camera will move towards the object in question.
	///	@param {Real}			delta	The difference in time between the execution of this frame and the last.
	move_towards_object = function(_object, _speed, _delta){
		var _objectX = x;
		var _objectY = y;
		with(_object){ // Get the object's current coordinates if they exist.
			_objectX = x;
			_objectY = y;
		}
		
		// Don't bother with any calculations below if the camera is already at its target coordinates.
		if (x == _objectX && y == _objectY)
			return;
		
		_speed *= _delta; // Apply delta time to the speed value.
		x	   += (_objectX - x) * _speed;
		y	   += (_objectY - y) * _speed;
		if (point_distance(x, y, _objectX, _objectY) <= ceil(_speed)){
			x = _objectX;
			y = _objectY;
			
			// Toggle the flag that allows the standard camera movement to start executing if the object being
			// moved towards was in fact the object the camera has been assigned to follow.
			if (_object == followedObject)
				flags |= CAM_FLAG_FOLLOWING_OBJECT;
		}
	}
	
	/// @description 
	/// Updates the camera's current viewport to the values supplied in the argument paramters of this function.
	/// Also handles updating the size of the window relative to its current scaling factor, as well as updating
	/// the application surface and GUi layer to match the new viewport size.
	///
	/// @param {Real}	width	Size of the camera's viewport along the x axis in whole pixels.
	/// @param (Real}	height	Size of the camera's viewport along the y axis in whole pixels.
	camera_set_viewport = function(_width, _height){
		// If the camera hasn't been initialized for whatever reason OR the argument parameters match the current
		// dimensions of the viewport--do not execute this function.
		if (cameraID == -1 || (viewportWidth == _width && viewportHeight == _height))
			return;
		viewportWidth	= _width;
		viewportHeight	= _height;
		
		// Update the camera viewport, and the application surface/gui surface to match it.
		camera_set_view_size(cameraID, _width, _height);
		surface_resize(application_surface, _width, _height);
		display_set_gui_size(_width, _height);
		
		// Finally, update the window size and positioning if the game isn't set to be full-screen.
		var _scale		= global.settings.windowScale;
		_width			= _width * _scale;	// Update "_width" and "_height" variables to apply scaling to them.
		_height			= _height * _scale;
		window_set_size(_width, _height);
		window_set_position(floor((display_get_width() - _width) / 2), floor((display_get_height() - _height) / 2));
	}
	
	/// @description 
	///	Assigns the id value for the object the camera will be set to follow into the "followedObject" variable.
	///	It won't assign id values that don't point to existing objects.
	///	
	///	@param {Id.Instance}	id				The unique id value for the object the camera will begin following.
	/// @param {Bool}			snapToPosition	When true, the camera will immediately center itself onto the followed object's position.
	camera_set_followed_object = function(_id, _snapToPosition){
		if (!instance_exists(_id))
			return;
		followedObject = _id;
		
		if (_snapToPosition){ // Snap to the object's position if required.
			x = followedObject.x;
			y = followedObject.y;
		}
	}
}

#endregion Camera Struct Definition