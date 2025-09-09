#region Macro Initializations

// Values for the bits within this object's flags variable that are used by it and any children that may
// inherit from it.
#macro	WRLDITM_FLAG_DYNAMIC			0x00000001

// Checks against bits used by this object within its flags variable to determine if they are currently 
// cleared (0) or set (1).
#macro	WRLDITM_IS_DYNAMIC				((flags & WRLDITM_FLAG_DYNAMIC)		!= 0)

// The two message types that can be displayed when interacting with this object. One simply displayed the
// name of the item and the other includes the amount of said item that was picked up.
#macro	ITMPCKUP_MESSAGE_STANDARD		"Picked up @0x00F8F8{" + _itemName + "}."
#macro	ITMPCKUP_MESSAGE_SHOW_AMOUNT	"Picked up @0x00F8F8{" + _itemName + "} (@0x3050F8{" + string(_quantity) + "})."

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
itemName		= "";
itemQuantity	= 0;
itemDurability	= 0;
itemAmmoIndex	= 0;

#endregion Variable Initializations

#region Interaction Function Override

/// @description 
///	The interaction process for this object, which attempts to add the item it represents into the item 
/// inventory in the amount required by the quantity set. If the quantity to be picked up fits within the
/// item inventory's current free space, the item is destroyed and its 
///	
/// @param {Real}	delta	The difference in time between the execution of this frame and the last.
on_player_interact = function(_delta){
	// The player's item inventory is completely full, so the textbox that is created will display flavor text
	// of the character saying to themselves (In their head) that they have no room remaining.
	var _amount = item_inventory_add(itemName, itemQuantity, itemDurability, itemAmmoIndex);
	if (_amount == itemQuantity){
		var _message = textboxMessage;
		with(TEXTBOX){
			queue_new_text(_message);
			activate_textbox();
		}
		return;
	}
	
	// Get the reference to the item's struct containing all its data, and then grab the type of the item from
	// that data since it is utilized throughout this interaction function.
	var _itemData = global.itemData[? itemName];
	var _itemType = _itemData.typeID;
	
	// Only a portion of the available amount could be added to the player's item inventory. The text shown in
	// the textbox will say how much was picked up; along with flavor text letting the player know that they
	// have no room left in their item inventory.
	var _itemName	= itemName;
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
		
		// If the item was ammunition, make sure to check if the current ammunition counts for the equipped
		// weapon (If there is one to begin with) need to be updated based on the ammo that was just picked up.
		if (_itemType == ITEM_TYPE_AMMO){
			with(PLAYER) { update_current_ammo_counts(_itemData.itemID, _quantity); }
		}
		return;
	}
	
	// Grab the item's stack limit from within the item struct's data, and set it to one if the item happens
	// to be either an equipable item or a weapon so the textbox doesn't display its quantity on pick up.
	var _itemStackLimit	= _itemData.stackLimit;
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
	
	// If the item was ammunition, make sure to check if the current ammunition counts for the equipped weapon 
	// (If there is one to begin with) need to be updated based on the ammo that was just picked up.
	if (_itemType == ITEM_TYPE_AMMO){
		with(PLAYER) { update_current_ammo_counts(_itemData.itemID, _quantity); }
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
/// @param {String}	itemName		Value that allows reference to the item's data within the global map containing that information.
/// @param {Real}	quantity		Amount of the item in question that will be added to the player's inventory when picked up.
/// @param {Real}	durability		(Optional; Higher Difficulties Only) The item's current condition.
///	@param {Real}	ammoIndex		(Optional; Weapon-Type Items Only) The ammunition found within the item relative to its list of valid ammo types.
set_item_params = function(_worldItemID, _itemName, _quantity, _durability = 0, _ammoIndex = ID_INVALID){
	worldItemID		= _worldItemID;
	itemName		= _itemName;
	itemQuantity	= _quantity;
	itemDurability	= _durability;
	itemAmmoIndex	= _ammoIndex;
}

#endregion Unique Function Initialization