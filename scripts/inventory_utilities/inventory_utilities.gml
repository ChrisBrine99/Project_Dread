// Macros for the numerical representations of an item's type, which will help determine how it functions within
// the game and what options are available to the player when it is selected in the inventory (Excluding any
// flags that may also affect this).
#macro	ITEM_TYPE_INVALID			   -1
#macro	ITEM_TYPE_WEAPON				0
#macro	ITEM_TYPE_AMMO					1
#macro	ITEM_TYPE_CONSUMABLE			2
#macro	ITEM_TYPE_COMBINABLE			3
#macro	ITEM_TYPE_EQUIPABLE				4
#macro	ITEM_TYPE_KEY_ITEM				5

// Macros for the bit values of the flags that exist within every weapon-type item.
#macro	WEAP_FLAG_IS_MELEE				0x00000001
#macro	WEAP_FLAG_IS_AUTOMATIC			0x00000002
#macro	WEAP_FLAG_IS_BURSTFIRE			0x00000004
#macro	WEAP_FLAG_IS_THROWN				0x00000008

// Macros that represent the checks for specific bit states within the flags variable of a weapon-type item.
#macro	WEAPON_IS_MELEE					(flags & WEAP_FLAG_IS_MELEE)
#macro	WEAPON_IS_AUTOMATIC				(flags & WEAP_FLAG_IS_AUTOMATIC)
#macro	WEAPON_IS_BURSTFIRE				(flags & WEAP_FLAG_IS_BURSTFIRE)
#macro	WEAPON_IS_THROWN				(flags & WEAP_FLAG_IS_THROWN)

// Macros for the bit values of the flags that exist within every consumable-type item.
#macro	CNSM_FLAG_CURE_POISON			0x00000001
#macro	CNSM_FLAG_CURE_BLEED			0x00000002
#macro	CNSM_FLAG_CURE_CRIPPLE			0x00000004
#macro	CNSM_FLAG_TMPIMU_POISON			0x00000008
#macro	CNSM_FLAG_TMPIMU_BLEED			0x00000010
#macro	CNSM_FLAG_TMPIMU_CRIPPLE		0x00000020

// Macros that represent the checks for specific bit states within the flags variable of a consumable-type item.
#macro	CNSM_CURES_POISON				(flags & CNSM_FLAG_CURE_POISON)
#macro	CNSM_CURES_BLEED				(flags & CNSM_FLAG_CURE_BLEED)
#macro	CNSM_CURES_CRIPPLE				(flags & CNSM_FLAG_CURE_CRIPPLE)
#macro	CNSM_GIVES_TMPIMU_POISON		(flags & CNSM_FLAG_TMPIMU_POISON)
#macro	CNSM_GIVES_TMPIMU_BLEED			(flags & CNSM_FLAG_TMPIMU_BLEED)
#macro	CNSM_GIVES_TMPIMU_CRIPPLE		(flags & CNSM_FLAG_TMPIMU_CRIPPLE)

// Macro that represents an inventory slot that current has no item contained within it.
#macro	INV_EMPTY_SLOT				   -1

/// @description
///	Initializes the inventory data structure. It's starting size will be determined by what difficulty the
/// player selected for their playthrough. The maximum size will also be affected by the selected difficulty,
/// but not as a hard limit. Instead, it will limit how many capacity upgrades can be found in the world.
///	
///	@param {Real}	cmbDiffFlagBit		Determines how inventory will be initialized.
function inventory_initialize(_cmbDiffFlagBit){
	if (is_array(global.inventory)){ // Clear out old inventory contents to prevent memory leaks.
		var _length = array_length(global.inventory);
		for (var i = 0; i < _length; i++){
			if (is_struct(global.inventory[i]))
				delete global.inventory[i];
		}
	} else{ // Initialize the inventory array with a default size of 0.
		global.inventory = array_create(0, INV_EMPTY_SLOT);
	}
	
	switch(_cmbDiffFlagBit){
		default: /* Invalid difficulty param */	array_resize(global.inventory,  0);		break;
		case GAME_FLAG_CMBTDIFF_FORGIVING:		array_resize(global.inventory, 10);		break;
		case GAME_FLAG_CMBTDIFF_STANDARD:		// Also starts with 8 slots available.
		case GAME_FLAG_CMBTDIFF_PUNISHING:		array_resize(global.inventory,  8);		break;
		case GAME_FLAG_CMBTDIFF_NIGHTMARE:		// Also starts with 6 slots available.
		case GAME_FLAG_CMBTDIFF_ONELIFE:		array_resize(global.inventory,  6);		break;
	}
	
	// Fill the array with -1 values since each index defaults to 0 when a resize adds new indices.
	var _length = array_length(global.inventory);
	for (var i = 0; i < _length; i++)
		array_set(global.inventory, i, INV_EMPTY_SLOT);
}

/// @description 
///	Adds some variable amount of an item to the player's inventory. The value returned will be the remainder
/// of the item that didn't fit within the inventory. The same value as the _amount parameter is returned if
/// it couldn't be added to the inventory due to the inventory not being initialized, the item id being invalid
/// or the inventory being completely full.
///	
///	@param {Real}	itemID		Number representing the item within the game's data.
///	@param {Real}	amount		How many of said item will be added to the inventory.
function inventory_add_item(_itemID, _amount){
	// Don't try adding anything to an uninitialized inventory.
	if (!is_array(global.inventory))
		return _amount;
	
	// Make sure the item id points to a valid item. Otherwise, don't even attempt to add it to the inventory.
	var _itemData = global.itemData[? _itemID];
	if (is_undefined(_itemData))
		return _amount;
	
	// Being looping through the inventory from its first slot to its last slot; checking to see where the item
	// in question can be placed within it. It can either be added to an existing slot containing the same item
	// if there is room, or occupy the first empty slot that's found, or both is required.
	var _maxPerSlot	= _itemData.stackLimit;
	var _invItem	= -1;
	var _length		= array_length(global.inventory);
	for (var i = 0; i < _length; i++){
		_invItem = global.inventory[i];
		if (is_struct(_invItem)){
			with(_invItem){
				// Either the item id doesn't match the current item in the slot OR the slot is already maxed
				// out in capacity for the item in question. Move onto the next slot.
				if (index != _itemID || quantity == _maxPerSlot)
					break;
				
				// The amount to be added exceeds what can be stored inside a single slot. So, the amount that
				// can fit within the slot is added and the remainder from the total amount to add will move
				// onto the next slot to find a vacant place to be added.
				if (quantity + _amount > _maxPerSlot){
					_amount -= (_maxPerSlot - quantity);
					quantity = _maxPerSlot;
					break;
				}
				
				// The full amount can fit in the current slot. Add it to the existing quantity and return 0.
				quantity += _amount;
				return 0;
			}
			
			// Item exists within the slot so the next slot will be considered if the return 0 seen above
			// wasn't hit by the code.
			continue;
		}
		
		// Create a new inventory item struct and set the inventory slot to its reference value.
		_invItem = {
			index		: _itemID,
			quantity	: _amount,
			durability	: 0	// This function will always set this value to 0.
		};
		global.inventory[i] = _invItem;
		
		// Check if the amount to be added can fit into this newly added inventory item. If it exceeds the max
		// capacity per slot, the loop will continue. Otherwise, the value 0 is returned to signify every item
		// was successfully added to the inventory.
		with(_invItem){
			if (_amount > _maxPerSlot){
				_amount -= _maxPerSlot;
				quantity = _maxPerSlot;
				break;
			}
			return 0;
		}
	}
	
	// Return whatever the remainder is for what needed to be added to the inventory. If this happens, it means
	// the inventory doesn't have enough room to store all of the items that were picked up.
	return _amount;
}

/// @description 
///	Removes some variable amount of an item from the inventory. It will search through the entire array to find
/// the slots containing an item with the matching id/index and remove as much as it can from each slot until
/// the _amount value hits zero. A non-zero value is returned to signify there weren't enough items to match
/// the amount that was requested to be removed.
///	
///	@param {Real}	itemID		Number representing the item within the game's data.
/// @param {Real}	amount		How many of said item will be removed from the inventory.
function inventory_remove_item(_itemID, _amount){
	// Don't try adding anything to an uninitialized inventory.
	if (!is_array(global.inventory))
		return _amount;
	
	// Loop through the inventory in search of any slots containing the required item. If any are found,
	// remove as much as possible from its current quantity within the slot to satisfy the amount to remove.
	var _invItem	= -1;
	var _quantity	= 0;
	var _length		= array_length(global.inventory);
	for (var i = 0; i < _length; i++){
		_invItem = global.inventory[i];
		if (!is_struct(_invItem) || _invItem.index != _itemID) // Ignore all empty inventory slots or items with non-matching IDs.
			continue;
		
		// Check to see if there is enough of the item within the slot to meet the required amount to remove.
		// If the amount is equal to or exceeds the quantity, the item is removed from the inventory and the
		// loop will continue its execution.
		_quantity = _invItem.quantity;
		if (_quantity <= _amount){
			array_set(global.inventory, i, INV_EMPTY_SLOT);
			_amount -= _quantity;
			delete _invItem;
			continue;
		}
		
		// There was enough in the current slot to satisfy the amount to be removed, so decrement the quantity
		// by said amount and return 0 to signify the removal was a success.
		_invItem.quantity -= _amount;
		return 0;
	}
	
	// Return the amount that couldn't be successfully removed from the inventory due to the amount within the
	// inventory currently not meeting the requirement set by this funciton's initial _amount parameter.
	return _amount;
}

/// @description 
///	Removes some amount of an item from a specified slot within the inventory. Should an empty slot be used
/// as the parameter of this function nothing will happen. Otherwise, as much of the quantity as possible is
/// removed from the slot to satisfy what amount was requested to be removed. Any remainder is returned if
/// the slot has a smaller quantity than what was to be removed.
///	
///	@param {Real}	slot		The slot that will have quantity removed from it.
/// @param {Real}	amount		How many of the item within the slot will be removed.
function inventory_remove_slot(_slot, _amount){
	// Don't try removing anything to an uninitialized inventory, an out of bounds index.
	if (!is_array(global.inventory) || _slot < 0 || _slot >= array_length(global.inventory))
		return _amount;
	
	// Also don't try removing anything if the slot in question doesn't have an item occupying it currently.
	var _item = global.inventory[_slot];
	if (!is_struct(_item))
		return _amount;
	
	// Remove _amount from the current quantity. If there is less in the slot than what should be removed, the
	// remainder will be returned. Otherwise, the amount if removed and the item remains in the slot if the
	// quantity is above zero, or it is removed should the quantity be zero.
	var _quantity = _item.quantity;
	if (_quantity <= _amount){
		array_set(global.inventory, _slot, INV_EMPTY_SLOT);
		delete _item;
		return (_amount - _quantity);
	}
	_item.quantity -= _amount;
	return 0;
}

/// @description
///	Moves the contents of one inventory slot to another; moving whatever was contained in the destination into 
/// that initial slot.
///	
///	@param {Real}	first		The first slot to swap.
/// @param {Real}	second		The second slot to swap.
function inventory_slot_swap(_first, _second){
	// Don't attempt to swap anything if the inventory hasn't been initialized or if either of the slot values
	// happen to be out of the bounds of the inventory array.
	if (!is_array(global.inventory) || _first < 0 || _second < 0 || 
			_first >= array_length(global.inventory) || _second >= array_length(global.inventory))
		return;
		
	var _temp = global.inventory[_first];
	global.inventory[_first] = global.inventory[_second];
	global.inventory[_second] = _temp;
}

/// @description 
///	Returns the struct containing the information about the item that occupies a slot within the inventory.
/// If no item currently occupies the slot, the value -1 (INV_EMPTY_SLOT) will be returned. This value is also
/// returned if for some reason the provided value for "slot" is out of bounds or the inventory hasn't been
/// initialized properly.
///	
/// @param {Real}	slot	The slot within the inventory to grab the information from.
function inventory_slot_get_item_data(_slot){
	if (!is_array(global.inventory) || _slot < 0 || _slot >= array_length(global.inventory))
		return INV_EMPTY_SLOT;	// Default value will simply be treated as an empty inventory slot.
		
	var _slotContents	= global.inventory[_slot];
	var _itemData		= ds_map_find_value(global.itemData, _slotContents);
	if (is_undefined(_itemData)) // No item data exists for the id value in the slot; return default value.
		return INV_EMPTY_SLOT;
	return _itemData;
}

/// @description
/// Returns the sum of a given item within the inventory.
///	
/// @param {Real}	itemID		Number representing the item within the game's data.
function inventory_count_item(_itemID){
	// Don't try counting items in an inventory that hasn't been initialized.
	if (!is_array(global.inventory))
		return 0;
	
	// Loop through inventory and count up the requested item IDs quantity within.
	var _invItem	= -1;
	var _count		= 0; // Stores the sum of quantities.
	var _length		= array_length(global.inventory);
	for (var i = 0; i < _length; i++){
		_invItem = global.inventory[i];
		if (is_struct(_invItem) && _invItem.index == _itemID)
			_count += _invItem.quantity;
	}
	return _count;
}