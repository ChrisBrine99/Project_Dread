#region Cutscene Manager Macro Definitions

// Values for the bits that are utilized within the cutscne manager's "flags" variable. Outside of these, 
// the value 0x80000000 is used by the parent struct (str_base) to determine if the struct is persistent
// between rooms or not.
#macro	SCENE_INFLAG_LOG				0x00000001
#macro	SCENE_PREV_INFLAG_LOG			0x00000002
#macro	SCENE_FLAG_ACTIVE				0x00000004
#macro	SCENE_FLAG_TEXTBOX_OPEN			0x00000008
#macro	SCENE_FLAG_ACTION_FIRST_CALL	0x00000010

// Defines to check if each respective flag is currently set (1) or cleared (0).
#macro	SCENE_WAS_LOG_RELEASED			((flags & (SCENE_INFLAG_LOG | SCENE_PREV_INFLAG_LOG))	== SCENE_PREV_INFLAG_LOG)
#macro	SCENE_IS_ACTIVE					((flags & SCENE_FLAG_ACTIVE)							!= 0)
#macro	SCENE_IS_TEXTBOX_OPEN			((flags & SCENE_FLAG_TEXTBOX_OPEN)						!= 0)
#macro	SCENE_IS_ACTION_FIRST_CALL		((flags & SCENE_FLAG_ACTION_FIRST_CALL)					!= 0)

// References to the functions that will perform a given action within a currently executing scene.
#macro	SCENE_CONCURRENT_ACTIONS		CUTSCENE_MANAGER.cutscene_queue_concurrent_actions
#macro	SCENE_WAIT						CUTSCENE_MANAGER.cutscene_wait
#macro	SCENE_WAIT_TEXTBOX				CUTSCENE_MANAGER.cutscene_wait_for_textbox
#macro	SCENE_WAIT_CONCURRENT			CUTSCENE_MANAGER.cutscene_wait_for_concurrent_actions
#macro	SCENE_SET_EVENT_FLAG			CUTSCENE_MANAGER.cutscene_set_event_flag
#macro	SCENE_SNAP_CAMERA				CUTSCENE_MANAGER.cutscene_snap_camera_to_position
#macro	SCENE_MOVE_CAMERA				CUTSCENE_MANAGER.cutscene_move_camera_to_position
#macro	SCENE_MOVE_CAMERA_PATH			CUTSCENE_MANAGER.cutscene_move_camera_along_path
#macro	SCENE_CAMERA_FOLLOW_OBJECT		CUTSCENE_MANAGER.cutscene_camera_set_followed_object
#macro	SCENE_QUEUE_TEXTBOX				CUTSCENE_MANAGER.cutscene_queue_new_text
#macro	SCENE_QUEUE_TEXTBOX_EXT			CUTSCENE_MANAGER.cutscene_queue_new_text_ext
#macro	SCENE_ACTIVATE_TEXTBOX			CUTSCENE_MANAGER.cutscene_activate_textbox
#macro	SCENE_SNAP_OBJECT				CUTSCENE_MANAGER.cutscene_snap_object_to_position
#macro	SCENE_DESTROY_OBJECT			CUTSCENE_MANAGER.cutscene_destroy_object
#macro	SCENE_MOVE_ENTITY				CUTSCENE_MANAGER.cutscene_move_entity_to_position
#macro	SCENE_MOVE_ENTITY_PATH			CUTSCENE_MANAGER.cutscene_move_entity_along_path
#macro	SCENE_INVOKE_SCREEN_FADE		CUTSCENE_MANAGER.cutscene_invoke_screen_fade
#macro	SCENE_END_SCREEN_FADE			CUTSCENE_MANAGER.cutscene_end_screen_fade

// Positions within the "timers" array that the respective macro's timer will be located. The final value is
// the sum of how many timers currently exist that the cutscene manager utilizes.
#macro	SCENE_WAIT_TIMER_INDEX			0
#macro	SCENE_CONWAIT_TIMER_INDEX		1
#macro	SCENE_TBOX_TIMER_INDEX			2
#macro	SCENE_FADE_TIMER_INDEX			3
#macro	SCENE_TOTAL_TIMERS				4

#endregion Cutscene Manager Macro Definitions

#region Cutscene Manager Struct Definition

/// @param {Function}	index	The value of "str_cutscene_manager" as determined by GameMaker during runtime.
function str_cutscene_manager(_index) : str_base(_index) constructor {
	flags				= STR_FLAG_PERSISTENT;
	
	// Variables for storing the cutscene manager's current, next, and last states, respectively.
	curState			= STATE_NONE;
	nextState			= STATE_NONE;
	lastState			= STATE_NONE;
	
	// The main values for the cutscene manager's functionality. The first value keeps track of what action
	// is being executed by the current scene. The second stores the complete list of actions to perform.
	// Finally, the last value simply stores the current size of the queue.
	actionIndex			= 0;
	actionQueue			= ds_list_create();
	queueSize			= 0;
	
	// Stores a list of concurrently executing actions within the cutscene. They will execute alongside the
	// current action being processed within the queue, and will remove themselves from this list when
	// completed.
	ccActions			= ds_list_create();
	
	// Stores the delta for the frame that was passed into the cutscene manager's step event. This is needed
	// since the action functions themselves don't all need this value in order to execute, and having to
	// constantly pass it in would be a waste.
	curDelta			= 0.0;
	
	// Various variables that can used by actions to perform certain actions (Ex. incrementing a value until
	// it hits or exceeds the requirement, etc.).
	timers				= array_create(SCENE_TOTAL_TIMERS, 0.0);
	prevFollowedObject	= noone;
	
	/// @description 
	///	The cutscene manager struct's destroy event. It will clean up anything that isn't automatically 
	/// cleaned up by GameMaker when this struct is destroyed/out of scope.
	///	
	destroy_event = function(){
		ds_list_destroy(actionQueue);
		ds_list_destroy(ccActions);
	}
	
	/// @description 
	///	The cutscene manager's default state. It executes the current action for the scene, checks to see if
	/// the log needs to be opened, and so on. 
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		// Handle updating the cutscene's input flag, and then check if that input was pressed and released
		// at this current point in time. If so, the cutscene will pause so the log can open for viewing.
		process_input();
		if (SCENE_WAS_LOG_RELEASED){
			object_set_state(state_open_log_animation);
			flags = flags & ~(SCENE_INFLAG_LOG | SCENE_PREV_INFLAG_LOG);
			
			with(TEXTBOX_LOG){ // Start the textbox log's opening animation and activate it.
				object_set_state(state_open_animation);
				flags = flags | TBOXLOG_FLAG_ACTIVE;
			}
			
			// Don't bother with the code below if the textbox isn't currently open.
			if (!GAME_IS_TEXTBOX_OPEN)
				return;
			
			// Make sure the textbox also moves onto its state for waiting on the log's opening animation if
			// it is currently open and active within the current scene.
			with(TEXTBOX){
				object_set_state(state_open_log_animation);
				flags			= flags & ~(TBOX_INFLAG_TEXT_LOG | TBOX_INFLAG_ADVANCE) | TBOX_FLAG_LOG_ACTIVE;
				prevInputFlags	= 0;
			}
			return;
		}
		
		var _curAction	= actionQueue[| actionIndex];
		curDelta		= _delta; // Copy delta into a cutscene struct variable so it can be referenced as needed.
		if (script_execute_ext(_curAction[0], _curAction, 1))
			end_action();
			
		// After executing the main action for the scene, execute all the currently active concurrent actions.
		// Once completed, the action will be deleted from the list.
		var _length = ds_list_size(ccActions);
		for (var i = 0; i < _length; i++){
			_curAction = ccActions[| i];
			if (script_execute_ext(_curAction[0], _curAction, 1)){
				ds_list_delete(ccActions, i);
				_length--;	// Subtract both by one to account for deleted list element.
				i--;
			}
		}
	}

	/// @description 
	/// State that is executed whenever the player is currently viewing the conversation/textbox log. The state
	/// is exited once the player triggers the closure of the log.
	/// 
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_view_log = function(_delta){
		var _isClosing = false;
		with(TEXTBOX_LOG)
			_isClosing = TBOXLOG_IS_CLOSING;
		
		if (_isClosing)
			object_set_state(state_close_log_animation);
	}
	
	/// @description 
	/// State that executes when the cutscene is waiting for the textbox's log to complete its opening 
	/// animation. Once that animation has completed, the cutscene manager will remain paused until the player
	///	chooses to close the log and continue the current scene's execution.
	/// 
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_open_log_animation = function(_delta){
		var _animFinished = false;
		with(TEXTBOX_LOG)
			_animFinished = (alpha == 1.0);
		
		if (_animFinished)
			object_set_state(state_view_log);
	}
	
	/// @description 
	/// State that executes when the cutscene is waiting for the textbox's log to complete its closing
	/// animation. Once that animation has completed, the cutscene manager returns to executing the remainder
	/// of its action queue.
	/// 
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_close_log_animation = function(_delta){
		var _animFinished = false;
		with(TEXTBOX_LOG)
			_animFinished = (alpha == 0.0);
		
		if (_animFinished)
			object_set_state(state_default);
	}
	
	/// @description 
	///	Handles getting the current state of the input used by the cutscene manager. It stores the current
	/// and previous state of this bit in the "flags" variable (THe 1st and 2nd bits, respectively) since it 
	/// would be a waste to store them into two separate variables like the input management in the player
	/// object, for example
	///	
	process_input = function(){
		var _inputFlag	= (flags & SCENE_INFLAG_LOG) != 0;
		flags			=  flags & ~SCENE_INFLAG_LOG;
		flags			=  flags | (_inputFlag << 1);
		
		if (GAME_IS_GAMEPAD_ACTIVE){
			flags = flags | MENU_PAD_TBOX_LOG;
			return;
		}
		
		flags = flags | MENU_KEY_TBOX_LOG;
	}
	
	/// @description
	///	Allows a cutscene that has been queued up to begin execution. Does nothing if another cutscene is
	/// already executing. Otherwise, it copies that queued list into its "actionQueue" list so it can begin
	/// execution.
	///	
	/// @param {Id.DsList}	actionQueue		The list of actions that will be performed for the cutscene.
	start_action_queue = function(_actionQueue){
		// Don't attempt to start a queue of actions if a cutscene is already being executed.
		var _size = ds_list_size(_actionQueue);
		if (SCENE_IS_ACTIVE || _size == 0)
			return;
		
		// Set flags and reset necessary values before the execution of the cutscene begins. The list
		// containing all actions for the scene is copied over as well.
		object_set_state(state_default);
		global.flags	= global.flags | GAME_FLAG_CUTSCENE_ACTIVE;
		flags			= flags | SCENE_FLAG_ACTIVE;
		queueSize		= _size;
		actionIndex		= 0;
		ds_list_copy(actionQueue, _actionQueue);
		
		// Store the id for the object that the camera was previously following since the camera can be set
		// to follow other objects or move around as required throughout a scene Then remove that object from
		// being the one the camera follows.
		var _followedObject = noone;
		with(CAMERA){ 
			_followedObject = followedObject; 
			followedObject	= noone;
		}
		prevFollowedObject = _followedObject;
		
		// Finally, pause all entities that are flagged to be paused by cutscene. If not, they will continue
		// executing whatever they were before the scene as normal.
		with(par_dynamic_entity){
			if (!ENTT_PAUSES_FOR_CUTSCENE)
				continue;
			entity_pause(id, curState, nextState, lastState);
		}
		with(par_static_entity){
			if (!ENTT_PAUSES_FOR_CUTSCENE)
				continue;
			entity_pause(id, curState, nextState, lastState);
		}
	}
	
	/// @description
	///	A function that is called after every action is successfully completed. It increments to begin the
	/// next instruction in the action queue and resets variables so they can be used by the next action if
	/// required. Should the action queue index hit the size of the queue, the cutscene will end.
	///	
	end_action = function(){
		actionIndex++;
		if (actionIndex == queueSize){
			object_set_state(STATE_NONE);
			global.flags	= global.flags & ~GAME_FLAG_CUTSCENE_ACTIVE;
			flags			= flags & ~SCENE_FLAG_ACTIVE;
			ds_list_clear(actionQueue);
			entity_unpause_all();
			
			// Make sure the camera has its followed object reassigned after the scene is completed.
			var _prevFollowedObject = prevFollowedObject;
			with(CAMERA) { camera_set_followed_object(_prevFollowedObject, false); }
		}
		
		flags	= flags & ~SCENE_FLAG_ACTION_FIRST_CALL;
		timers	= array_create(SCENE_TOTAL_TIMERS, 0.0);
	}
	
	/// @description 
	///	A function that allows a cutscene to queue up a given number of actions that will all be executed
	/// at the same time; removing themselves one by one as they complete their respective actions. Keep in
	/// mind these will execute at the same time as any non-concurrent action that the scene is also executing.
	///	
	/// @param {Array<Array<Any>>}	actionQueue		The list of actions that will all be executed concurrently.
	cutscene_queue_concurrent_actions = function(_actionQueue){
		var _length = array_length(_actionQueue);
		for (var i = 0; i < _length; i++)
			ds_list_add(ccActions, _actionQueue[i]);
		return true;
	}
	
	/// @description
	///	A simple function that allows the cutscene to pause for a given amount of time before it can continue
	/// executing instructions.
	///	
	///	@param {Real}	duration	How long the period of waiting will last in units (1 second = 60 units).
	cutscene_wait = function(_duration){
		timers[SCENE_WAIT_TIMER_INDEX] += curDelta;
		return (timers[SCENE_WAIT_TIMER_INDEX] >= _duration);
	}
	
	/// @description 
	///	A version of the basic "cutscene_wait" function with added functionality that makes the action wait 
	/// until the textbox is closed before actually beginning the "wait" duration.
	///	
	///	@param {Real}	duration	How long the period of waiting will last in units (1 second = 60 units).
	cutscene_wait_for_textbox = function(_duration){
		with(TEXTBOX)
			return !TBOX_IS_ACTIVE;
		
		timers[SCENE_TBOX_TIMER_INDEX] += curDelta;
		return (timers[SCENE_TBOX_TIMER_INDEX] >= _duration);
	}
	
	/// @description 
	///	A version of the "cutscene_wait" function with added functionality that makes the action wait until
	/// all currently active concurrent actions have completed. After that, the "wait" duration begins.
	///	
	///	@param {Real}	duration	How long the period of waiting will last in units (1 second = 60 units).
	cutscene_wait_for_concurrent_actions = function(_duration){
		if (ds_list_size(ccActions) > 0)
			return false;
			
		timers[SCENE_CONWAIT_TIMER_INDEX] += curDelta;
		return (timers[SCENE_CONWAIT_TIMER_INDEX] >= _duration);
	}
	
	/// @description 
	///	Function that sets a given event flag to the desired state within a cutscene.
	///	
	///	@param {Real}	flagID		The position of the bit (Starting from 0 as the first) to get the value of.
	/// @param {Bool}	flagState	The desired value to set the event's bit to (True = 1, False = 0).
	cutscene_set_event_flag = function(_flagID, _flagState){
		event_set_flag(_flagID, _flagState);
		return true;
	}
	
	/// @description 
	///	A simple function that snaps the camera to the position provided by the argument parameters. These
	/// values are still under the effect of if the camera has its viewport bound to the inside of the room.
	///	
	/// @param {Real}	x	Position along the current room's x axis to place the camera at.
	/// @param {Real}	y	Position along the current room's y axis to place the camera at.
	cutscene_snap_camera_to_position = function(_x, _y){
		with(CAMERA){
			x = _x;
			y = _y;
		}
		return true;
	}
	
	/// @description 
	///	Moves the camera towards a given position in the room at a specified speed. It smoothly decelerates
	/// as it approaches the position in question to previde a smooth look to the movement.
	///	
	///	@param {Real}	x			Target position along the current room's x axis.
	/// @param {Real}	y			Target position along the current room's y axis.
	///	@param {Real}	speed		(Optional) How fast the camera will move towards the target coordinates.
	cutscene_move_camera_to_position = function(_x, _y, _speed = 0.25){
		var _curDelta = curDelta;
		with(CAMERA) { return move_towards_position(_x, _y, _speed, _curDelta); }
		return true; // If this line is somehow reached there are BIG problems.
	}
	
	/// @description 
	///	Moves the camera linearly along a path of points at a specified speed.
	///	
	///	@param {Array<Real>}	path	The list of x/y coordinates that the camera will move between.
	/// @param {Real}			speed	How fast the camera will move along the points in the path.
	cutscene_move_camera_along_path = function(_path, _speed = 1.0){
		var _curDelta = curDelta;
		with(CAMERA){
			// The path index has hit or exceeded the number of points along the path; return true so the
			// action completes itself and the scene can move along.
			var _pathIndex = pathIndex * 2;
			if (_pathIndex >= array_length(_path)){
				pathIndex = 0;
				return true;
			}
			
			// Call the camera's linear movement function as it moves toward each point in the path. Once the
			// fuction returns true, the point has been met and the next one can be targeted.
			if (move_towards_position_linear(_path[_pathIndex], _path[_pathIndex + 1], _speed, _curDelta))
				pathIndex++;
			return false;
		}
		return true;
	}
	
	/// @description 
	///	Allows the camera to have an object set for it to follow during the currently executing scene.
	///	
	///	@param {Id.Instance}	id				The unique id value for the object the camera will begin following.
	/// @param {Bool}			snapToPosition	When true, the camera will immediately center itself onto the followed object's position.
	cutscene_camera_set_followed_object = function(_id, _snapToPosition){
		with(CAMERA) { camera_set_followed_object(_id, _snapToPosition); }
		return true;
	}
	
	/// @description 
	///	A function that allows a cutscene to add text to a textbox's queue that is being constructed to be
	/// shown to the player during said cutscene.
	///	
	///	@param {String}	text		The text to format and enqueue for the textbox to display when ready.
	/// @param {Real}	actorIndex	(Optional) If set to a value greater than 0, the actor's name relative to the index will be shown.
	///	@param {Real}	nextIndex	(Optional) Determines which textbox out of the current data is after this one.
	cutscene_queue_new_text = function(_text, _actorIndex = TBOX_ACTOR_INVALID, _nextIndex = -1){
		with(TEXTBOX) { queue_new_text(_text, _actorIndex, _nextIndex); }
		return true;
	}
	
	/// @description 
	/// An entension of the standard "cutscene_queue_new_text" function that enables the ability to add an
	/// array of choices and their selection instructions to be added to the textbox's data on top of the
	/// standard information.
	/// 
	///	@param {String}				text			The text to format and enqueue for the textbox to display when ready.
	/// @param {Array<String>}		options			Array of strings that represent the available options to the player.
	///	@param {Array<Array<Any>>}	selectParams	An array of arrays that contain functions alongside their parameters that should be executed when an option is selected.
	/// @param {Real}				actorIndex		(Optional) If set to a value greater than 0, the actor's name relative to the index will be shown.
	///	@param {Real}				nextIndex		(Optional) Determines which textbox out of the current data is after this one.
	cutscene_queue_new_text_ext = function(_text, _options, _selectParams, _actorIndex = TBOX_ACTOR_INVALID, _nextIndex = -1){
		with(TEXTBOX) { add_options(queue_new_text(_text, _actorIndex, _nextIndex), _options, _selectParams); }
		return true;
	}
	
	/// @description 
	///	A function that simply allows a cutscene to activate the textbox if required during the scene.
	///	
	cutscene_activate_textbox = function(){
		with(TEXTBOX) { activate_textbox(); }
		return true;
	}
	
	/// @description 
	///	A function that allows the cutscene to teleport an object from one position to another in a single
	/// frame. Useful for properly positioning things off-screen that will be used in the scene later.
	///	
	///	@param {Id.Instance}	id		The id for the object that will be moved.
	/// @param {Real}			x		Position to place within the current room on the x axis.
	/// @param {Real}			y		Position to place within the current room on the y axis.
	cutscene_snap_object_to_position = function(_id, _x, _y){
		with(_id){ // Apply the position values to the instance in question.
			x = _x;
			y = _y;
		}
		return true;
	}
	
	/// @description 
	///	A function that allows the scene to destroy an instance within the room if required. Useful for 
	/// removing objects off-screen that are no longer needed in the cutscene.
	///	
	/// @param {Id.Instance}	id				The id for the object that will be destroyed.
	/// @param {Bool}			executeEvent	(Optional) Allows the object to skip its destroy event if required.
	cutscene_destroy_object = function(_id, _executeEvent){
		instance_destroy_object(_id, _executeEvent);
		return true;
	}
	
	/// @description 
	///	A function that causes an entity to move from one position to another over the course of however long
	/// it takes the entity to reach the target position in question.
	///	
	///	@param {Id.Instance}	id			The ID for the entity that will be moved.
	/// @param {Real}			xTarget		Target position along the current room's x axis.
	/// @param {Real}			yTarget		Target position along the current room's y axis.
	/// @param {Real}			speed		(Optional) How fast the entity will move relative to its current max speed.
	cutscene_move_entity_to_position = function(_id, _xTarget, _yTarget, _speed = 1.0){
		var _curDelta = curDelta;
		with(_id) { return move_to_position(_curDelta, _xTarget, _yTarget, _speed); }
		return true;
	}
	
	/// @description 
	///	An extension of the standard cutscene_move_entity_to_position function that allows a list of points
	/// to be used as a path that the entity will follow. The action is ended when the entity has hit the
	/// final target position in that list.
	///	
	///	@param {Id.Instance}	id		The ID for the entity that will be moved.
	/// @param {Array<Real>}	path	A list of x/y coordinates that the Entity will move to in order.
	/// @param {Real}			speed	(Optional) How fast the entity will move relative to its current max speed.
	cutscene_move_entity_along_path = function(_id, _path, _speed = 1.0){
		var _curDelta = curDelta;
		with(_id){
			// The path index has hit or exceeded the number of points along the path; return true so the
			// action completes itself and the scene can move along.
			var _pathIndex = pathIndex * 2;
			if (_pathIndex >= array_length(_path)){
				pathIndex = 0;
				return true;
			}
			
			// Use the standard move_to_position function alongside the current target position within the
			// path the Entity is currently on. If that target is hit, the Entity moves onto the next path
			// point and repeats the process.
			if (move_to_position(_curDelta, _path[_pathIndex], _path[_pathIndex + 1], _speed))
				pathIndex++;
			return false;
		}
		return true;
	}
	
	/// @description 
	///	An action function that allows a cutscene to cause a screen fade to occur. The speed of the fading in
	/// and out can be set as needed, as well as the color for the screen to fade into. Note that this fade is
	/// always manually ended by the "cutscene_end_screen_fade" action.
	///	
	///	@param {Real}	inSpeed			How fast the screen will fade completely into the desired color.
	/// @param {Real}	outSpeed		How fast the screen will fade from the desired color back to the current viewport contents.
	/// @param {Real}	color			Determines the color that will completely fill the screen once the fade is fully opaque.
	cutscene_invoke_screen_fade = function(_inSpeed, _outSpeed, _color){
		with(SCREEN_FADE)
			activate_screen_fade(_inSpeed, _outSpeed, _color, true);
		return true;
	}
	
	/// @description 
	///	A function that causes the screen to begin fading back out from whatever color was chosen back into
	/// the game's current viewport.
	///	
	/// @param {Real}	delay	How long to delay the screen fade out in units (60 = one real-world second).
	cutscene_end_screen_fade = function(_delay){
		timers[SCENE_FADE_TIMER_INDEX] += curDelta;
		if (timers[SCENE_FADE_TIMER_INDEX] < _delay)
			return false;
		
		with(SCREEN_FADE)
			flags = flags | FADE_FLAG_ALLOW_FADE_OUT;
		return true;
	}
}

#endregion Cutscene Manager Struct Definition