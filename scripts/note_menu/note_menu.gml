#region Note Menu Struct Definition

/// @param {Function}	index	The value of "str_note_menu" as determined by GameMaker during runtime.
function str_note_menu(_index) : str_base_menu(_index) constructor {
	/// @description 
	///	
	///	
	create_event = function(){
		alpha = 1.0;
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
}

#endregion Note Menu Struct Definition