#region Cutscene Manager Macro Definitions

// Values for the bits that are utilized within the cutscne manager's "flags" variable. Outside of these, 
// the value 0x80000000 is used by the parent struct (str_base) to determine if the struct is persistent
// between rooms or not.
#macro	SCENE_FLAG_ACTIVE				0x00000001
#macro	SCENE_FLAG_TEXTBOX_OPEN			0x00000002

// Defines to check if each respective flag is currently set (1) or cleared (0).
#macro	SCENE_IS_ACTIVE					((flags & SCENE_FLAG_ACTIVE)		!= 0)
#macro	SCENE_IS_TEXTBOX_OPEN			((flags & SCENE_FLAG_TEXTBOX_OPEN)	!= 0)

// References to the functions that will perform a given action within a currently executing scene.
#macro	SCENE_CONCURRENT_ACTIONS		CUTSCENE_MANAGER.cutscene_queue_concurrent_actions
#macro	SCENE_WAIT						CUTSCENE_MANAGER.cutscene_wait
#macro	SCENE_WAIT_TEXTBOX				CUTSCENE_MANAGER.cutscene_wait_for_textbox
#macro	SCENE_WAIT_CONCURRENT			CUTSCENE_MANAGER.cutscene_wait_for_concurrent_actions
#macro	SCENE_SNAP_CAMERA				CUTSCENE_MANAGER.cutscene_snap_camera_to_position
#macro	SCENE_MOVE_CAMERA				CUTSCENE_MANAGER.cutscene_move_camera_to_position
#macro	SCENE_QUEUE_TEXTBOX				CUTSCENE_MANAGER.cutscene_queue_new_text
#macro	SCENE_QUEUE_TEXTBOX_EXT			CUTSCENE_MANAGER.cutscene_queue_new_text_ext
#macro	SCENE_ACTIVATE_TEXTBOX			CUTSCENE_MANAGER.cutscene_activate_textbox
#macro	SCENE_SNAP_OBJECT				CUTSCENE_MANAGER.cutscene_snap_object_to_position
#macro	SCENE_DESTROY_OBJECT			CUTSCENE_MANAGER.cutscene_destroy_object
#macro	SCENE_MOVE_ENTITY				CUTSCENE_MANAGER.cutscene_move_entity_to_position

#endregion Cutscene Manager Macro Definitions

#region Cutscene Manager Struct Definition

/// @param {Function}	index	The value of "str_cutscene_manager" as determined by GameMaker during runtime.
function str_cutscene_manager(_index) : str_base(_index) constructor {
	flags		= STR_FLAG_PERSISTENT;
	
	// The main values for the cutscene manager's functionality. The first value keeps track of what action
	// is being executed by the current scene. The second stores the complete list of actions to perform.
	// Finally, the last value simply stores the current size of the queue.
	actionIndex	= 0;
	actionQueue = ds_list_create();
	queueSize	= 0;
	
	// Stores a list of concurrently executing actions within the cutscene. They will execute alongside the
	// current action being processed within the queue, and will remove themselves from this list when
	// completed.
	ccActions	= ds_list_create();
	
	// Stores the delta for the frame that was passed into the cutscene manager's step event. This is needed
	// since the action functions themselves don't all need this value in order to execute, and having to
	// constantly pass it in would be a waste.
	curDelta	= 0.0;
	
	// Various variables that can used by actions to perform certain actions (Ex. incrementing a value until
	// it hits or exceeds the requirement, etc.).
	waitTimer	= 0.0;
	
	/// @description 
	///	The cutscene manager struct's destroy event. It will clean up anything that isn't automatically 
	/// cleaned up by GameMaker when this struct is destroyed/out of scope.
	///	
	destroy_event = function(){
		ds_list_destroy(actionQueue);
		ds_list_destroy(ccActions);
	}
	
	/// @description
	///	Called every frame that the cutscene manager struct exists (Which should be the entirety of the game)
	/// AND is currently executing a scene. It will execute the current action as well as any concurrent
	/// actions that are currently active.
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	step_event = function(_delta){
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
		global.flags	= global.flags | GAME_FLAG_CUTSCENE_ACTIVE;
		flags			= flags | SCENE_FLAG_ACTIVE;
		queueSize		= _size;
		actionIndex		= 0;
		ds_list_copy(actionQueue, _actionQueue);
		
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
			global.flags	= global.flags & ~GAME_FLAG_CUTSCENE_ACTIVE;
			flags			= flags & ~SCENE_FLAG_ACTIVE;
			ds_list_clear(actionQueue);
			entity_unpause_all();
		}
		
		waitTimer = 0.0;
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
		waitTimer += curDelta;
		return (waitTimer >= _duration);
	}
	
	/// @description 
	///	A version of the basic "cutscene_wait" function with added functionality that makes the action wait 
	/// until the textbox is closed before actually beginning the "wait" duration.
	///	
	///	@param {Real}	duration	How long the period of waiting will last in units (1 second = 60 units).
	cutscene_wait_for_textbox = function(_duration){
		with(TEXTBOX) {
			if (TBOX_IS_ACTIVE)
				return;
		}
		
		waitTimer += curDelta;
		return (waitTimer >= _duration);
	}
	
	/// @description 
	///	A version of the "cutscene_wait" function with added functionality that makes the action wait until
	/// all currently active concurrent actions have completed. After that, the "wait" duration begins.
	///	
	///	@param {Real}	duration	How long the period of waiting will last in units (1 second = 60 units).
	cutscene_wait_for_concurrent_actions = function(_duration){
		if (ds_list_size(ccActions) > 0)
			return false;
			
		waitTimer += curDelta;
		return (waitTimer >= _duration);
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
	///	@param {Real}	speed		How fast the camera will move towards the target coordinates.
	cutscene_move_camera_to_position = function(_x, _y, _speed){
		var _curDelta = curDelta;
		with(CAMERA) { return move_towards_position(_x, _y, _speed, _curDelta); }
		return true; // If this line is somehow reached there are BIG problems.
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
		
		// Always return true so the cutscene doesn't get softlocked on this action if an invalid id was
		// passed into this action's id parameter.
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
	///	
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
}

#endregion Cutscene Manager Struct Definition