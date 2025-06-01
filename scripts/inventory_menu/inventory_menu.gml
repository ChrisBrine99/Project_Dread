#region Macros for Inventory Menu Struct
#endregion Macros for Inventory Menu Struct

#region Inventory Menu Struct Definition

/// @param {Function}	index	The value of "str_inventory_menu" as determined by GameMaker during runtime.
function str_inventory_menu(_index) : str_base_menu(_index) constructor {
	
	/// @description 
	///	
	///	
	create_event = function(){
		initialize_params(true, true, 6, 4, 4, 1, 1);
		initialize_option_params(100, 5, 50, 10);
		
		for (var i = 0; i < 37; i++)
			add_option(string("Test {0}", i + 1));
			
		object_set_state(state_default);
	}
	
	/// @description 
	///	
	///	
	draw_gui_event = function(){
		draw_text(5, 50, string("cursorShiftTimer: {0}", cursorShiftTimer));
		
		draw_visible_options();
	}
	
	/// @description 
	///	
	///	
	///	@param {Real} delta		The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		update_cursor_position(_delta);
	}
}

#endregion Inventory Menu Struct Definition