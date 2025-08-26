#region Macro Initializations

// Values for the bits within this object's flags variable that are used by it and any children that may
// inherit from it.
#macro	WRLDITM_FLAG_DYNAMIC			0x00000001

// Checks against bits used by this object within its flags variable to determine if they are currently 
// cleared (0) or set (1).
#macro	WRLDITM_IS_DYNAMIC				((flags & WRLDITM_FLAG_DYNAMIC) != 0)

// The two message types that can be displayed when interacting with this object. One simply displayed the
// name of the item and the other includes the amount of said item that was picked up.
#macro	ITMPCKUP_MESSAGE_STANDARD		"Picked up @0x00F8F8{" + _itemID + "}."
#macro	ITMPCKUP_MESSAGE_SHOW_AMOUNT	"Picked up @0x00F8F8{" + _itemID + "} (@0x3050F8{" + string(_quantity) + "})."

#endregion Macro Initializations

#region Variable Initializations

// Inherit all functions and variables from the parent object and its parent objects. Then, toggle the item
// to be visible and active so it will be rendered, and adjust the interaction position.
event_inherited();
flags			= ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE;
interactX	   += 8;	// The origin of the sprites is (0, 0), so offset the interaction origin to the middle of it.
interactY	   += 8;

// Adjust the two default message variables to be more specific to an item that the player can pick up.
interactMessage = "Pick Up Item";
textboxMessage	= "I don't have room for this. I can't pick it up.";

// Variables for determining what item this object represents within the world. The "worldItemID" is used to
// reference a persistent struct of the item's state between rooms. Meanwhile, the other three variables are
// for the item's ID value, the total number of the item (Or its ammunition in the case of ranged weapons),
// and the starting durability of the item.
worldItemID		= ID_INVALID;
itemID			= ID_INVALID;
itemQuantity	= 0;
itemDurability	= 0;

#endregion Variable Initializations

#region Interaction Function Override

/// @description 
///	The interaction process for this object, which attempts to add the item it represents into the item 
/// inventory in the amount required by the quantity set. If the quantity to be picked up fits within the
/// item inventory's current free space, the item is destroyed and its 
///	
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
on_player_interact = function(_delta){
	var _amount = item_inventory_add(itemID, itemQuantity, itemDurability);
	
	// The player's item inventory is completely full, so the textbox that is created will display flavor text
	// of the character saying to themselves (In their head) that they have no room remaining.
	if (_amount == itemQuantity){
		var _message = textboxMessage;
		with(TEXTBOX){
			queue_new_text(_message);
			activate_textbox();
		}
		return;
	}
	
	// Only a portion of the available amount could be added to the player's item inventory. The text shown in
	// the textbox will say how much was picked up; along with flavor text letting the player know that they
	// have no room left in their item inventory.
	var _itemID		= itemID;
	var _quantity	= itemQuantity - _amount;
	if (_amount > 0){
		with(TEXTBOX){
			queue_new_text(ITMPCKUP_MESSAGE_SHOW_AMOUNT + " There's no room for the rest, though...");
			activate_textbox();
		}
		
		// Update the quantity stored in the item's world data to match how much was left behind. Also update
		// the object's stored quantity to match the amount leftover as well.
		with(world_item_get(worldItemID))
			quantity = _amount;
		itemQuantity = _amount;
		return;
	}
	
	// Determine how the text should be formatted based on the item's type and not its stack limit since that
	// value refers to the magazine size of weapons that require ammunition or fuel to use. Equipable items
	// will also ignore their stack limit should they need it for a different purpose.
	var _itemData		= global.itemData[? itemID];
	var _itemStackLimit	= _itemData.stackLimit;
	var _itemType		= _itemData.typeID;
	if (_itemType == ITEM_TYPE_EQUIPABLE || _itemType == ITEM_TYPE_WEAPON)
		_itemStackLimit = 1; // Treat these types of items as one per slot regardless of stack size.
	
	// Create the message that will be displayed in the textbox. If the value in _itemStackLimit is one it
	// means that the quantity added to the inventory isn't displayed in the textbox. Otherwise, it will be
	// shown next to the item's name in brackets.
	with(TEXTBOX){
		if (_itemStackLimit == 1)	{ queue_new_text(ITMPCKUP_MESSAGE_STANDARD); }
		else						{ queue_new_text(ITMPCKUP_MESSAGE_SHOW_AMOUNT); }
		activate_textbox();
	}
	
	// Finally, remove the item's world data information and destroy this object. When the room is loaded
	// again, the item will be destroyed to reflect that the item is now considered collected.
	world_item_remove(worldItemID, WRLDITM_IS_DYNAMIC);
	instance_destroy(id);
}

#endregion Interaction Function Override

#region Unique Function Initialization

/// @description 
///	Sets all the parameters required for an item object to function properly. Should be called within the 
/// creation code of each instance of this object. Failure to do so will mean the object is deleted as soon
/// as its room start event is called.
///	
///	@param {Any}	worldItemID		Unique from an item's ID, this value allows reference to its world item data.
/// @param {String}	itemID			Value that allows reference to the item's data within the global map containing that information.
/// @param {Real}	quantity		Amount of the item in question that will be added to the player's inventory when picked up.
/// @param {Real}	durability		Condition of the item when first picked up (Only used on higher difficulties).
set_item_params = function(_worldItemID, _itemID, _quantity, _durability){
	worldItemID		= _worldItemID;
	itemID			= _itemID;
	itemQuantity	= _quantity;
	itemDurability	= _durability;
}

#endregion Unique Function Initialization