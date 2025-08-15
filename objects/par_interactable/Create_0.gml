#region Macro Initializations

#macro	INTR_FLAG_INTERACT				0x01000000
#macro	INTR_CAN_PLAYER_INTERACT		((flags & INTR_FLAG_INTERACT) != 0)

#endregion Macro Initializations

#region Variable Initializations

event_inherited();

// Determines where the "area of interaction" is located on a given interactable object. The pair of X/Y values
// allow this area to be placed anywhere relative to the origin of the object itself, which is the default. The
// radius will determine how large the interaction area for the object will be.
interactX		= x;
interactY		= y;
interactRadius	= 8.0;

// This value can be set in the instance's creation code to create a unique message for the textbox to utilize 
// should an interactble allow a per-instance message like the default interaction does (Ex. A generic object
// for text describing the nearby environment should be unique compared to another in a different part of the
// room).
textboxMessage	= "Nothing special.";

// 
interactMessage	= "Interact";

#endregion Variable Initializations

#region Function Initializations

/// @description 
///	The function that is called through the player object whenever they successfully interact with a child of
/// this generic interactable parent object. By default, it will open the textbox and display a generic message,
/// but it can be overridden by children object to do whatever is required upon an interaction.
/// 
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
on_player_interact = function(_delta){
	var _message = textboxMessage;
	with(TEXTBOX){
		queue_new_text(_message);
		activate_textbox();
	}
}

/// @description
/// The default GUI overlay for an interactable that the player is able to interact with currently. It simply
///	shows the appropriate icon for the current input method's interact command; along with the text "interact".
///	
draw_gui_event = function(){
	// 
	var _guiWidth		= display_get_gui_width();
	var _guiHeight		= display_get_gui_height();
	var _messageWidth	= string_width(interactMessage);
	var _iconData		= CONTROL_UI_MANAGER.get_control_icon(ICONUI_INTERACT);
	if (_iconData != ICONUI_NO_ICON){
		// 
		var _iconWidth	= sprite_get_width(_iconData[ICONUI_ICON_SPRITE]);
		var _xOffset	= (_guiWidth - _messageWidth - _iconWidth - 2) >> 1;
		draw_sprite_ext(_iconData[ICONUI_ICON_SPRITE], _iconData[ICONUI_ICON_SUBIMAGE], 
			_xOffset, _guiHeight - 32, 1.0, 1.0, 0.0, COLOR_TRUE_WHITE, 1.0);
		
		// 
		_xOffset	   += _iconWidth + 2;
		draw_text_shadow(_xOffset, _guiHeight - 30, interactMessage, COLOR_WHITE);
		return;
	}
	
	// 
	draw_text_shadow((_guiWidth - _messageWidth) >> 2, _guiHeight - 30, interactMessage, COLOR_WHITE);
}

#endregion Function Initializations