#region Macros Utilized Primarily by the Inventory System

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
#macro	WEAPON_IS_MELEE					((flags & WEAP_FLAG_IS_MELEE)		!= 0)
#macro	WEAPON_IS_AUTOMATIC				((flags & WEAP_FLAG_IS_AUTOMATIC)	!= 0)
#macro	WEAPON_IS_BURSTFIRE				((flags & WEAP_FLAG_IS_BURSTFIRE)	!= 0)
#macro	WEAPON_IS_THROWN				((flags & WEAP_FLAG_IS_THROWN)		!= 0)

// Macros for the bit values of the flags that exist within every consumable-type item.
#macro	CNSM_FLAG_CURE_POISON			0x00000001
#macro	CNSM_FLAG_CURE_BLEED			0x00000002
#macro	CNSM_FLAG_CURE_CRIPPLE			0x00000004
#macro	CNSM_FLAG_TMPIMU_POISON			0x00000008
#macro	CNSM_FLAG_TMPIMU_BLEED			0x00000010
#macro	CNSM_FLAG_TMPIMU_CRIPPLE		0x00000020

// Macros that represent the checks for specific bit states within the flags variable of a consumable-type item.
#macro	CNSM_CURES_POISON				((flags & CNSM_FLAG_CURE_POISON)	!= 0)
#macro	CNSM_CURES_BLEED				((flags & CNSM_FLAG_CURE_BLEED)		!= 0)
#macro	CNSM_CURES_CRIPPLE				((flags & CNSM_FLAG_CURE_CRIPPLE)	!= 0)
#macro	CNSM_GIVES_TMPIMU_POISON		((flags & CNSM_FLAG_TMPIMU_POISON)	!= 0)
#macro	CNSM_GIVES_TMPIMU_BLEED			((flags & CNSM_FLAG_TMPIMU_BLEED)	!= 0)
#macro	CNSM_GIVES_TMPIMU_CRIPPLE		((flags & CNSM_FLAG_TMPIMU_CRIPPLE)	!= 0)

// Macro that represents an inventory slot that current has no item contained within it.
#macro	INV_EMPTY_SLOT				   -1

#endregion Macros Utilized Primarily by the Inventory System

#region Item Name/Key Value Macros

// --- Weapon Item Keys --- //
#macro	ITEM_HANDGUN					"9mm Handgun"
#macro	ITEM_INF_HANDGUN				"Inf. Handgun"
#macro	ITEM_PUMP_SHOTGUN				"Pump Shotgun"
#macro	ITEM_AUTO_SHOTGUN				"Full-Auto Shotgun"
#macro	ITEM_BOLT_RIFLE					"Bolt-Action Rifle"
#macro	ITEM_SUBMACHINE_GUN				"Submachine Gun"
#macro	ITEM_INF_SUBMACHINE_GUN			"Inf. Submachine Gun"
#macro	ITEM_MAGNUM_REVOLVER			"Magnum Revolver"
#macro	ITEM_HAND_CANNON				"Hand Cannon"
#macro	ITEM_GRENADE_LAUNCHER			"Grenade Launcher"
#macro	ITEM_INF_NAPALM_LAUNCHER		"Inf. Napalm Launcher"
#macro	ITEM_POCKET_KNIFE				"Pocket Knife"
#macro	ITEM_SHARP_POCKET_KNIFE			"Sharp Pocket Knife"
#macro	ITEM_RUSTY_PIPE					"Rusty Pipe"
#macro	ITEM_STURDY_PIPE				"Sturdy Pipe"
#macro	ITEM_DULL_FIRE_AXE				"Dull Fire Axe"
#macro	ITEM_SHARP_FIRE_AXE				"Sharpened Fire Axe"
#macro	ITEM_CHAINSAW					"Chainsaw"
#macro	ITEM_INF_CHAINSAW				"Inf. Chainsaw"
#macro	ITEM_MOLOTOV					"Molotov Cocktail"
#macro	ITEM_GRENADE					"Makeshift Grenade"
#macro	ITEM_INF_MOLOTOV				"Inf. Molotov"
#macro	ITEM_SEMI_RIFLE					"Semi-Auto Rifle"
#macro	ITEM_TRIPLE_HANDGUN				"Triple-Burst Handgun"
#macro	ITEM_AUTO_RIFLE					"Full-Auto Rifle"

// --- Ammunition Item Keys --- //
#macro	ITEM_HANDGUN_AMMO				"Handgun Ammo"
#macro	ITEM_HANDGUN_AMMO_POOR			"Handgun Ammo (-)"
#macro	ITEM_HANDGUN_AMMO_GOOD			"Handgun Ammo (+)"
#macro	ITEM_SHOTGUN_SHELL				"Shotgun Shell"
#macro	ITEM_SHOTGUN_SHELL_POOR			"Shotgun Shell (-)"
#macro	ITEM_SHOTGUN_SHELL_GOOD			"Shotgun Shell (+)"
#macro	ITEM_RIFLE_ROUND				"Rifle Round"
#macro	ITEM_RIFLE_ROUND_POOR			"Rifle Round (-)"
#macro	ITEM_RIFLE_ROUND_GOOD			"Rifle Round (+)"
#macro	ITEM_SMG_AMMO					"SMG Ammo"
#macro	ITEM_SMG_AMMO_POOR				"SMG Ammo (-)"
#macro	ITEM_SMG_AMMO_GOOD				"SMG Ammo (+)"
#macro	ITEM_MAGNUM_ROUND				"Magnum Round"
#macro	ITEM_MAGNUM_ROUND_POOR			"Magnum Round (-)"
#macro	ITEM_MAGNUM_ROUND_GOOD			"Magnum Round (+)"
#macro	ITEM_EXPLOSIVE_SHELL			"Explosive Shell"
#macro	ITEM_EXPLOSIVE_SHELL_POOR		"Explosive Shell (-)"
#macro	ITEM_FRAGMENT_SHELL				"Fragment Shell"
#macro	ITEM_FRAGMENT_SHELL_POOR		"Fragment Shell (-)"
#macro	ITEM_FROST_SHELL				"Frost Shell"
#macro	ITEM_NAPALM_SHELL				"Napalm Shell"
#macro	ITEM_CRUDE_FUEL					"Crude Fuel"
#macro	ITEM_CRUDE_FUEL_POOR			"Crude Fuel (-)"
#macro	ITEM_REFINED_FUEL				"Refined Fuel"
#macro	ITEM_REFINED_FUEL_GOOD			"Refined Fuel (+)"

// --- Consumable Item Keys --- //
#macro	ITEM_WEAK_MEDICINE				"Weak Medicine"
#macro	ITEM_POTENT_MEDICINE			"Potent Medicine"
#macro	ITEM_WEAK_PAINKILLER			"Weak Painkiller"
#macro	ITEM_POTENT_PAINKILLER			"Potent Painkiller"
#macro	ITEM_CALMING_COMPOUND			"Calming Compound"
#macro	ITEM_DETOXING_COMPOUND			"Detoxing Compound"
#macro	ITEM_CHEM_MIX_WM_PM				"Chemical Mix (WM+PM)"
#macro	ITEM_CHEM_MIX_WM_WP				"Chemical Mix (WM+WP)"
#macro	ITEM_CHEM_MIX_WM_PP				"Chemical Mix (WM+PP)"
#macro	ITEM_CHEM_MIX_WM_CC				"Chemical Mix (WM+CC)"
#macro	ITEM_CHEM_MIX_WM_DC				"Chemical Mix (WM+DC)"

#endregion Item Name/Key Value Macros

#region Globals Related to the Inventory System

// Upon initialization, it stores the value -1, but will contain an array of items the player current has on
// their person during gameplay; with the starting and maximum sizes being determined by the difficulty the
// user selected when starting a new playthrough.
global.curItems = -1;

#endregion Globals Related to the Inventory System

#region Item Inventory Initialization Function

/// @description
///	Initializes the inventory data structure. It's starting size will be determined by what difficulty the
/// player selected for their playthrough. The maximum size will also be affected by the selected difficulty,
/// but not as a hard limit. Instead, it will limit how many capacity upgrades can be found in the world.
///	
///	@param {Real}	cmbDiffFlagBit		Determines how inventory will be initialized.
function item_inventory_initialize(_cmbDiffFlagBit){
	if (is_array(global.curItems)){ // Clear out old inventory contents to prevent memory leaks.
		var _length = array_length(global.curItems);
		for (var i = 0; i < _length; i++){
			if (is_struct(global.curItems[i]))
				delete global.curItems[i];
		}
	} else{ // Initialize the inventory array with a default size of 0.
		global.curItems = array_create(0, INV_EMPTY_SLOT);
	}
	
	switch(_cmbDiffFlagBit){
		default: /* Invalid difficulty param */	array_resize(global.curItems,  0);		break;
		case GAME_FLAG_CMBTDIFF_FORGIVING:		array_resize(global.curItems, 10);		break;
		case GAME_FLAG_CMBTDIFF_STANDARD:		// Also starts with 8 slots available.
		case GAME_FLAG_CMBTDIFF_PUNISHING:		array_resize(global.curItems,  8);		break;
		case GAME_FLAG_CMBTDIFF_NIGHTMARE:		// Also starts with 6 slots available.
		case GAME_FLAG_CMBTDIFF_ONELIFE:		array_resize(global.curItems,  6);		break;
	}
	
	// Fill the array with -1 values since each index defaults to 0 when a resize adds new indices.
	var _length = array_length(global.curItems);
	for (var i = 0; i < _length; i++)
		array_set(global.curItems, i, INV_EMPTY_SLOT);
}

#endregion Item Inventory Initialization Function

#region Functions for Manipulating the Item Inventory's Contents

/// @description 
///	Adds some variable amount of an item to the player's inventory. The value returned will be the remainder
/// of the item that didn't fit within the inventory. The same value as the _amount parameter is returned if
/// it couldn't be added to the inventory due to the inventory not being initialized, the item id being invalid
/// or the inventory being completely full.
///	
///	@param {Real}	itemID		Number representing the item within the game's data.
///	@param {Real}	amount		How many of said item will be added to the inventory.
/// @param {Real}	durability	The item's current condition (This value is only used on higher difficulties).
function item_inventory_add(_itemID, _amount, _durability){
	// Don't try adding anything to an uninitialized inventory.
	if (!is_array(global.curItems))
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
	var _length		= array_length(global.curItems);
	for (var i = 0; i < _length; i++){
		_invItem = global.curItems[i];
		if (is_struct(_invItem)){
			// Immediately skip to the next slot in the inventory if the item is a weapon, piece of equipment,
			// or has a stack limit of one since all cases mean the item cannot be stacked.
			if (_itemData.stackLimit == 1 || _itemData.typeID == ITEM_TYPE_WEAPON || _itemData.typeID == ITEM_TYPE_EQUIPABLE)
				continue;
			
			with(_invItem){
				// Either the item id doesn't match the current item in the slot OR the slot is already maxed
				// out in capacity for the item in question. Move onto the next slot.
				if (itemID != _itemID || quantity == _maxPerSlot)
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
			itemID		: _itemID,
			quantity	: _amount,
			durability	: _durability
		};
		global.curItems[i] = _invItem;
		
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
function item_inventory_remove(_itemID, _amount){
	// Don't try adding anything to an uninitialized inventory.
	if (!is_array(global.curItems))
		return _amount;
	
	// Loop through the inventory in search of any slots containing the required item. If any are found,
	// remove as much as possible from its current quantity within the slot to satisfy the amount to remove.
	var _invItem	= -1;
	var _quantity	= 0;
	var _length		= array_length(global.curItems);
	for (var i = 0; i < _length; i++){
		_invItem = global.curItems[i];
		if (!is_struct(_invItem) || _invItem.itemID != _itemID) // Ignore all empty inventory slots or items with non-matching IDs.
			continue;
		
		// Check to see if there is enough of the item within the slot to meet the required amount to remove.
		// If the amount is equal to or exceeds the quantity, the item is removed from the inventory and the
		// loop will continue its execution.
		_quantity = _invItem.quantity;
		if (_quantity <= _amount){
			array_set(global.curItems, i, INV_EMPTY_SLOT);
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
function item_inventory_remove_slot(_slot, _amount){
	// Don't try removing anything to an uninitialized inventory, or an out of bounds index.
	if (!is_array(global.curItems) || _slot < 0 || _slot >= array_length(global.curItems))
		return _amount;
	
	// Also don't try removing anything if the slot in question doesn't have an item occupying it currently.
	var _item = global.curItems[_slot];
	if (!is_struct(_item))
		return _amount;
	
	// Remove _amount from the current quantity. If there is less in the slot than what should be removed, the
	// remainder will be returned. Otherwise, the amount if removed and the item remains in the slot if the
	// quantity is above zero, or it is removed should the quantity be zero.
	var _quantity = _item.quantity;
	if (_quantity <= _amount){
		array_set(global.curItems, _slot, INV_EMPTY_SLOT);
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
function item_inventory_slot_swap(_first, _second){
	// Don't attempt to swap anything if the inventory hasn't been initialized or if either of the slot values
	// happen to be out of the bounds of the inventory array.
	if (!is_array(global.curItems) || _first < 0 || _second < 0 || 
			_first >= array_length(global.curItems) || _second >= array_length(global.curItems))
		return;
		
	var _temp					= global.curItems[_first];
	global.curItems[_first]		= global.curItems[_second];
	global.curItems[_second]	= _temp;
}

#endregion Functions for Manipulating the Item Inventory's Contents

#region Functions for Getting Info About the Item Inventory's Contents

/// @description 
///	Returns the struct containing the information about the item that occupies a slot within the inventory.
/// If no item currently occupies the slot, the value -1 (INV_EMPTY_SLOT) will be returned. This value is also
/// returned if for some reason the provided value for "slot" is out of bounds or the inventory hasn't been
/// initialized properly.
///	
/// @param {Real}	slot	The slot within the inventory to grab the information from.
function item_inventory_slot_get_data(_slot){
	if (!is_array(global.curItems) || _slot < 0 || _slot >= array_length(global.curItems))
		return INV_EMPTY_SLOT;	// Default value will simply be treated as an empty inventory slot.
		
	var _slotContents = global.curItems[_slot];
	if (_slotContents == INV_EMPTY_SLOT) // The inventory slot is empty; return -1 to signify such.
		return INV_EMPTY_SLOT;
	
	var _itemData = ds_map_find_value(global.itemData, _slotContents.itemID);
	if (is_undefined(_itemData)) // No item data exists for the id value in the slot; return default value.
		return INV_EMPTY_SLOT;
	return _itemData;
}

/// @description
/// Returns the sum of a given item within the inventory.
///	
/// @param {Real}	itemID		Number representing the item within the game's data.
function item_inventory_count(_itemID){
	// Don't try counting items in an inventory that hasn't been initialized.
	if (!is_array(global.curItems))
		return 0;
	
	// Loop through inventory and count up the requested item IDs quantity within.
	var _invItem	= -1;
	var _count		= 0; // Stores the sum of quantities.
	var _length		= array_length(global.curItems);
	for (var i = 0; i < _length; i++){
		_invItem = global.curItems[i];
		if (is_struct(_invItem) && _invItem.itemID == _itemID)
			_count += _invItem.quantity;
	}
	return _count;
}

#endregion Functions for Getting Info About the Item Inventory's Contents