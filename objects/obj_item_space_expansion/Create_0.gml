#region Variable Initializations

// Inherit all functions and variables from the parent object and its parent objects. Then, toggle the item
// to be visible and active so it will be rendered, and adjust the interaction position.
event_inherited();
flags			= ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE;
interactX	   += 8;	// The origin of the sprites is (0, 0), so offset the interaction origin to the middle of it.
interactY	   += 8;

// Adjust the default message to match what the world item object's interaction prompt says since this is
// technically an item as well; it just immediately has its effect applied to the player's item inventory
// capacity. THe textbox message is replaced to be a blurb about now being able to hold more items.
interactMessage = "Pick Up Item";
textboxMessage	= "Hmm... If I use this I should be able to hold more on me at the same time.\n@0xF87C58{(Two slots have been added to your item inventory)}";

// The only value that is needed here is a value that ties it to a bit within the event flag buffer. When set,
// this flag will prevent the expansion in question from spawning in again for the player to pick up.
flagID = ID_INVALID;

#endregion Variable Initializations

#region Interaction Function Override

/// @description 
///	Interaction logic that is unique to the item inventory expansion item. It will automatically increase the
/// capcity of the player's item inventory by two slots (If possible given the maximum capacity for the combat
/// difficulty chosen) upon interaction.
///
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
on_player_interact = function(_delta){
	var _itemInvSize = array_length(global.curItems);
	if (_itemInvSize < global.maxItemInvCapacity){ // Increase by two slots if still possible.
		array_resize(global.curItems,	_itemInvSize + 2);
		
		// Sets both new slots to the item inventory's default value of -1; signifying an empty slot.
		array_set(global.curItems,		_itemInvSize,		INV_EMPTY_SLOT); 
		array_set(global.curItems,		_itemInvSize + 1,	INV_EMPTY_SLOT);
	}
	
	var _textboxMessage = textboxMessage;
	with(TEXTBOX){ // Display a message about the item inventory expansion.
		queue_new_text(_textboxMessage);
		activate_textbox();
	}
	
	// Set the flag tied to this item capacity expasion to true so it will no longer be available. Then,
	// destroy the instance of this object that was interacted with.
	event_set_flag(flagID, true);
	instance_destroy(self);
}

#endregion Interaction Function Override