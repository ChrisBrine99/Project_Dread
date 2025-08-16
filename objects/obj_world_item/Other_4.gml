// First, check if the item has been properly initialized. To meet this criteria, the item needs to have a valid
// world item ID (This allows reference to the data struccture managing the item's properties between rooms), a
// valid item ID, as well as a valid quantity (Greater than zero) and durability (Greater than or equals zero).
if (worldItemID == ID_INVALID || itemID == ID_INVALID || itemQuantity <= 0 || itemDurability < 0){
	instance_destroy(self);
	return;
}
	
// Grab this item's data from within the world item data. This struct reference is used below to set the item's
// values to match what was stored upon leaving the room this item resides in.
var _data = world_item_get(worldItemID);
if (_data == ID_INVALID){ // No value exists, check if the value exists in the "collected items" list and destroy if so.
	if (ds_list_find_index(global.collectedItems, worldItemID) != -1){
		instance_destroy(self);
		return; // Exit early since the object was destoryed.
	}
	
	// Create the item's world data if it hasn't been collected yet. Then, exit since all the values match
	// between the object and its "world" data.
	world_item_initialize(worldItemID, room, itemID, itemQuantity, itemDurability);
	return;
}

// Only two values need to be updated: the item's remaining quantity, and its durability. Once grabbed, the item
// will have its base values replaced with these stored values.
var _quantity	= 0;
var _durability	= 0;
with(_data){
	_quantity	= quantity;
	_durability	= durability;
}
itemQuantity	= _quantity;
itemDurability	= _durability;