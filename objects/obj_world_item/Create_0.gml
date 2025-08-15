#region Variable Initializations

// 
event_inherited();
interactX	   += 8;	// The origin of the sprites is (0, 0), so offset the interaction origin to the middle of it.
interactY	   += 8;
interactMessage = "Pick Up Item";

// 
textboxMessage	= "I don't have room for this. I can't pick it up.";

// 
flags			= ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE;

// 
itemID			= ID_INVALID;
itemQuantity	= 0;

#endregion Variable Initializations

#region Interaction Function Override

/// @description 
///	
///	
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
on_player_interact = function(_delta){
	var _amount = item_inventory_add(itemID, itemQuantity);
	
	// 
	if (_amount == itemQuantity){
		var _message = textboxMessage;
		with(TEXTBOX){
			queue_new_text(_message);
			activate_textbox();
		}
		return;
	}
	
	// 
	var _itemID = itemID;
	if (_amount > 0){
		var _remainder = itemQuantity - _amount;
		with(TEXTBOX){
			queue_new_text(string("Picked up {0} (x{1}). There's no room for the rest, though...", _itemID, _remainder));
			activate_textbox();
		}
		return;
	}
	
	// 
	var _itemData		= global.itemData[? itemID];
	var _itemStackLimit	= _itemData.stackLimit;
	var _itemType		= _itemData.typeID;
	if (_itemType == ITEM_TYPE_EQUIPABLE || _itemType == ITEM_TYPE_WEAPON)
		_itemStackLimit = 1; // Treat these types of items as one per slot regardless of stack size.
	
	// 
	var _quantity		= itemQuantity;
	with(TEXTBOX){
		if (_itemStackLimit == 1)	{ queue_new_text(string("Picked up a {0}.", _itemID)); }
		else						{ queue_new_text(string("Picked up some {0} (x{1}).", _itemID, _quantity)); }
		activate_textbox();
	}
	
	// 
	instance_destroy(id);
}

#endregion Interaction Function Override