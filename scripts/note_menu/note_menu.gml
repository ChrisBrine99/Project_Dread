#region Note Menu Struct Definition

/// @param {Function}	index	The value of "str_note_menu" as determined by GameMaker during runtime.
function str_note_menu(_index) : str_base_menu(_index) constructor {
	// Set up the "auxilliary" return inputs to the input that opens up this menu during gameplay, so it can
	// also close the menu should the player choose to use it instead of the standard menu return input.
	var _inputs		= global.settings.inputs;
	keyAuxReturn	= _inputs[STNG_INPUT_NOTE_MENU];
	padAuxReturn	= _inputs[STNG_INPUT_NOTE_MENU + 1];
	
	/// @description 
	///	
	///	
	create_event = function(){
		alpha = 1.0;
		object_set_state(state_default);
		show_debug_message("Note Menu has been initialized!");
	}
	
	/// @description
	///	Called during every frame that the menu exists for. It will be responsible for rendering its contents
	/// to the game's GUI layer. Note that its position refers to the top-left of the menu itself, and its
	/// contents will be offset from that point based on each of their unique position values.
	///	
	///	@param {Real}	xPos	The menu's current x position, rounded down.
	/// @param {Real}	yPos	The menu's current y position, rounded down.
	draw_gui_event = function(_xPos, _yPos){
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_shadow(VIEWPORT_WIDTH >> 1, VIEWPORT_HEIGHT >> 1, "NOTES", COLOR_WHITE, alpha);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
	
	/// @description 
	///	
	///	
	/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
	state_default = function(_delta){
		process_player_input();
		if (MINPUT_IS_AUX_RETURN_RELEASED){
			with(prevMenu) { instance_destroy_struct(selfRef); }
			return;
		}
	}
}

#endregion Note Menu Struct Definition