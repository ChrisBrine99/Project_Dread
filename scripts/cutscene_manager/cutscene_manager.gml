#region Cutscene Manager Macro Definitions

// 
#macro	SCENE_FLAG_ACTIVE				0x00000001

// 
#macro	SCENE_IS_ACTIVE					((flags & SCENE_FLAG_ACTIVE) != 0)

#endregion Cutscene Manager Macro Definitions

#region Cutscene Manager Struct Definition

/// @param {Function}	index	The value of "str_cutscene_manager" as determined by GameMaker during runtime.
function str_cutscene_manager(_index) : str_base(_index) constructor {
	flags		= STR_FLAG_PERSISTENT;
	
	// 
	actionIndex	= 0;
	actionQueue = ds_list_create();
	queueSize	= 0;
	
	// 
	waitTimer	= 0.0;
	
	/// @description 
	///	
	///	
	destroy_event = function(){
		ds_list_clear(actionQueue);
		ds_list_destroy(actionQueue);
	}
	
	/// @description
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	step_event = function(_delta){
		var _curAction = actionQueue[| actionIndex];
		script_execute_ext(_curAction[0], _curAction, 1);
	}
	
	/// @description
	///	
	///	
	/// @param {Id.DsList}	actionQueue		The list of actions that will be performed for the cutscene.
	start_action_queue = function(_actionQueue){
		// Don't attempt to start a queue of actions if a cutscene is already being executed.
		var _size = ds_list_size(_actionQueue);
		if (SCENE_IS_ACTIVE || _size == 0)
			return;
			
		flags		= flags | SCENE_FLAG_ACTIVE;
		queueSize	= _size;
		
		ds_list_copy(actionQueue, _actionQueue);
	}
	
	/// @description
	///	
	///	
	end_action = function(){
		actionIndex++;
		if (actionIndex == queueSize){
			flags = flags & ~SCENE_FLAG_ACTIVE;
			ds_list_clear(actionQueue);
		}
	}
}

#endregion Cutscene Manager Struct Definition