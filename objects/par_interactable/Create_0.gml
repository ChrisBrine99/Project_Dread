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

#endregion Variable Initializations

#region Interaction Function Initialization

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

#endregion Interaction Function Initialization