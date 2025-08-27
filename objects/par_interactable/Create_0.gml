#region Macro Initializations

// A unique flag for interactable objects that determines whether or not the player can interact with them
// whenever they're currently set as the player's tracked interactable and they press the interact input.
#macro	INTR_FLAG_INTERACT				0x01000000
#macro	INTR_CAN_PLAYER_INTERACT		((flags & INTR_FLAG_INTERACT) != 0)

// Determines how many pixels there are between the rightmost column of pixels on the icon sprite and the
// leftmost portion of the interaction string.
#macro	INTR_ICON_TEXT_PADDING			3

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

// The text that will appear alongside a input binding icon to let the player know what will happen when they
// activate the input shown for the interactable in question. I can be changed on a per-object basis.
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
	draw_set_font(fnt_small); // Assign the proper font.
	
	// Get the current dimensions of the GUI layer in order to properly center the input binding icon (If one
	// currently exists for the input) and the descriptive text that goes alongside it. If no icon exists,
	// only the text will be shown to tell the player they can interact with an object.
	var _guiWidth		= display_get_gui_width();
	var _guiHeight		= display_get_gui_height();
	var _messageWidth	= string_width(interactMessage);
	var _iconData		= CONTROL_UI_MANAGER.get_control_icon(ICONUI_INTERACT);
	if (_iconData != ICONUI_NO_ICON){
		// Get the width of the input binding's icon. Then, offset the position by the width of the icon, 
		// the width of the message, and a three-pixel spacing between the two to place it in its cenetered 
		// position.
		var _iconWidth	= sprite_get_width(_iconData[ICONUI_ICON_SPRITE]);
		var _xOffset	= (_guiWidth - _messageWidth - _iconWidth - INTR_ICON_TEXT_PADDING) >> 1;
		draw_sprite_ext(_iconData[ICONUI_ICON_SPRITE], _iconData[ICONUI_ICON_SUBIMAGE], 
			_xOffset, _guiHeight - 32, 1.0, 1.0, 0.0, COLOR_TRUE_WHITE, 1.0);
		
		// After the icon has been drawn, the offset is updated to apply the icon's width plus the three-
		// pixel spacing so the message is placed where is should be while being centered alongside the icon.
		_xOffset	   += _iconWidth + INTR_ICON_TEXT_PADDING;
		draw_text_shadow(_xOffset, _guiHeight - 30, interactMessage, COLOR_WHITE);
		return;
	}
	
	// If no icon exists for the input that is currently set, the message is simply drawn on the GUI at the
	// center of the screen.
	draw_text_shadow((_guiWidth - _messageWidth) >> 1, _guiHeight - 30, interactMessage, COLOR_WHITE);
}

#endregion Function Initializations