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

// Macros for the equipment index values for certain item types which will determine which slot of the player's
// current equipment will be occupied by it when equipped.
#macro	ITEM_EQUIP_TYPE_INVALID		   -2
#macro	ITEM_EQUIP_TYPE_FLASHLIGHT		10
#macro	ITEM_EQUIP_TYPE_ARMOR			11
#macro	ITEM_EQUIP_TYPE_MAINWEAPON		12
#macro	ITEM_EQUIP_TYPE_SUBWEAPON		13 // Throwables are considered subweapons.
#macro	ITEM_EQUIP_TYPE_AMULET			14

// Macros for the bit values of the flags that exist within every weapon-type item.
#macro	WEAP_FLAG_IS_MELEE				0x00000001
#macro	WEAP_FLAG_IS_AUTOMATIC			0x00000002
#macro	WEAP_FLAG_IS_BURSTFIRE			0x00000004
#macro	WEAP_FLAG_IS_THROWN				0x00000008
#macro	WEAP_FLAG_IS_HITSCAN			0x00000010

// Macros that represent the checks for specific bit states within the flags variable of a weapon-type item.
#macro	WEAPON_IS_MELEE					((flags & WEAP_FLAG_IS_MELEE)		!= 0)
#macro	WEAPON_IS_AUTOMATIC				((flags & WEAP_FLAG_IS_AUTOMATIC)	!= 0)
#macro	WEAPON_IS_BURSTFIRE				((flags & WEAP_FLAG_IS_BURSTFIRE)	!= 0)
#macro	WEAPON_IS_THROWN				((flags & WEAP_FLAG_IS_THROWN)		!= 0)
#macro	WEAPON_IS_HITSCAN				((flags & WEAP_FLAG_IS_HITSCAN)		!= 0)

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

// Macros that explain what each index in the equipParams array does when the item is considered a flashlight.
#macro	EQUP_PARAM_LIGHT_RADIUS			0
#macro	EQUP_PARAM_LIGHT_COLOR			1
#macro	EQUP_PARAM_LIGHT_STRENGTH		2

// Macro that represents an inventory slot that current has no item contained within it.
#macro	INV_EMPTY_SLOT				   -1

// Macros that store the starting size of the item inventory for each combat difficulty level.
#macro	ITEMINV_START_SIZE_FORGIVING	10
#macro	ITEMINV_START_SIZE_STANDARD		10
#macro	ITEMINV_START_SIZE_PUNISHING	8
#macro	ITEMINV_START_SIZE_NIGHTMARE	8
#macro	ITEMINV_START_SIZE_ONELIFE		6

// Macros that store the maximum possible size of the item inventory for each combat difficulty level.
#macro	ITEMINV_MAX_SIZE_FORGIVING		20
#macro	ITEMINV_MAX_SIZE_STANDARD		20
#macro	ITEMINV_MAX_SIZE_PUNISHING		16
#macro	ITEMINV_MAX_SIZE_NIGHTMARE		12
#macro	ITEMINV_MAX_SIZE_ONELIFE		10

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
		default: // Inventory's size set to 0 slots for an initialization error if that occurs.
			global.maxItemInvCapacity = 0;
			break;
		case GAME_FLAG_CMBTDIFF_FORGIVING:	// Start with 10 slots; max out at 24 slots.
			array_resize(global.curItems, ITEMINV_START_SIZE_FORGIVING);
			global.maxItemInvCapacity = ITEMINV_MAX_SIZE_FORGIVING;
			break;
		case GAME_FLAG_CMBTDIFF_STANDARD:	// Start with 10 slots; max out at 20 slots.
			array_resize(global.curItems, ITEMINV_START_SIZE_STANDARD);
			global.maxItemInvCapacity = ITEMINV_MAX_SIZE_STANDARD;
			break;
		case GAME_FLAG_CMBTDIFF_PUNISHING:	// Start with  8 slots; max out at 16 slots.
			array_resize(global.curItems, ITEMINV_START_SIZE_PUNISHING);
			global.maxItemInvCapacity = ITEMINV_MAX_SIZE_PUNISHING;
			break;
		case GAME_FLAG_CMBTDIFF_NIGHTMARE:	// Start with  8 slots; max out at 14 slots.
			array_resize(global.curItems, ITEMINV_START_SIZE_NIGHTMARE);
			global.maxItemInvCapacity = ITEMINV_MAX_SIZE_NIGHTMARE;
			break;
		case GAME_FLAG_CMBTDIFF_ONELIFE:	// Start with  6 slots; max out at 12 slots.
			array_resize(global.curItems, ITEMINV_START_SIZE_ONELIFE);
			global.maxItemInvCapacity = ITEMINV_MAX_SIZE_ONELIFE;
			break;
	}
	
	// Fill the array with -1 values since each index defaults to 0 when a resize adds new indices.
	var _length = array_length(global.curItems);
	for (var i = 0; i < 20; i++)
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
///	@param {String}	item		String representing the name/key of the item.
///	@param {Real}	amount		How many of said item will be added to the inventory.
/// @param {Real}	durability	(Optional; Higher Difficulties Only) The item's current condition.
///	@param {Real}	ammoIndex	(Optional; Weapon-Type Items Only) The ammunition found within the item relative to its list of valid ammo types.
function item_inventory_add(_item, _amount, _durability = 0, _ammoIndex = 0){
	// Don't try adding anything to an uninitialized inventory.
	if (!is_array(global.curItems))
		return _amount;
	
	// Make sure the item ID points to a valid item. Otherwise, don't even attempt to add it to the inventory.
	var _itemData	= global.itemData[? _item];
	if (is_undefined(_itemData))
		return _amount;
	
	// If said ID was valid, copy the stack limit and type ID for the item into local values for use below.
	var _itemID		= ID_INVALID;
	var _itemType	= ITEM_TYPE_INVALID;
	var _stackLimit	= 0;
	with(_itemData){ // Jump into scope of the item's data to copy into the local values created above.
		_itemID		= itemID;
		_itemType	= typeID;
		_stackLimit	= stackLimit;
	}
	
	// Being looping through the inventory from its first slot to its last slot; checking to see where the item
	// in question can be placed within it. It can either be added to an existing slot containing the same item
	// if there is room, or occupy the first empty slot that's found, or both is required.
	var _invItem	= -1;
	var _length		= array_length(global.curItems);
	for (var i = 0; i < _length; i++){
		_invItem = global.curItems[i];
		if (is_struct(_invItem)){
			// Immediately skip to the next slot in the inventory if the item is a weapon, piece of equipment,
			// or has a stack limit of one since all cases mean the item cannot be stacked.
			if (_stackLimit == 1 || _itemType == ITEM_TYPE_WEAPON || _itemType == ITEM_TYPE_EQUIPABLE)
				continue;
			
			with(_invItem){
				// Either the item id doesn't match the current item in the slot OR the slot is already maxed
				// out in capacity for the item in question. Move onto the next slot.
				if (itemID != _itemID || quantity == _stackLimit)
					break;
				
				// The amount to be added exceeds what can be stored inside a single slot. So, the amount that
				// can fit within the slot is added and the remainder from the total amount to add will move
				// onto the next slot to find a vacant place to be added.
				if (quantity + _amount > _stackLimit){
					_amount -= (_stackLimit - quantity);
					quantity = _stackLimit;
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
			itemName	: _item,
			itemID		: _itemID,
			quantity	: _amount,
			durability	: _durability,
			ammoIndex	: _ammoIndex,
		};
		global.curItems[i] = _invItem;
		
		// The item that was added to the inventory was a weapon, so the value returned is -1 to signify it
		// was successfully added in case the magazine/clip of the wepaon in question was empty.
		if (global.itemIDs[_itemID].typeID == ITEM_TYPE_WEAPON)
			return -1;
		
		// 
		with(_invItem){
			if (_amount > _stackLimit){
				_amount -= _stackLimit;
				quantity = _stackLimit;
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
///	Removes some variable amount of an item from the inventory. It will search through the entire array to 
/// find the slots containing an item with the matching id and remove as much as it can. The remaining amount
/// is returned by the function if there weren't enough of it in the item inventory. Otherwise, a zero is
/// returned for a successful removal, and the full amount is returned in the case of an error or full item
/// inventory.
///	
///	@param {Real}	itemID		Number representing the item within the game's data.
/// @param {Real}	amount		How many of said item will be removed from the inventory.
function item_inventory_remove(_itemID, _amount){
	// Don't try adding anything to an uninitialized inventory.
	if (!is_array(global.curItems))
		return _amount;
	
	// Loop through the inventory in search of any slots containing the required item. If any are found,
	// remove as much as possible from its current quantity within the slot to satisfy the amount to remove.
	var _invItem		= -1;
	var _slotQuantity	= 0;
	var _amountRemoved	= 0;
	var _length			= array_length(global.curItems);
	for (var i = 0; i < _length; i++){
		_invItem = global.curItems[i];
		if (!is_struct(_invItem) || _invItem.itemID != _itemID) // Ignore all empty inventory slots or items with non-matching IDs.
			continue;
		
		// Check to see if there is enough of the item within the slot to meet the required amount to remove.
		// If the amount is equal to or exceeds the quantity, the item is removed from the inventory and the
		// loop will continue its execution.
		_slotQuantity = _invItem.quantity;
		if (_slotQuantity <= _amount){
			_amountRemoved = _slotQuantity;
			array_set(global.curItems, i, INV_EMPTY_SLOT);
			delete _invItem;
			continue;
		}
		
		// There was enough in the current slot to satisfy the amount to be removed, so decrement the quantity
		// by said amount breaking out of the loop to return from the function.
		_invItem.quantity  -= _amount;
		_amountRemoved		= _amount;
		break;
	}
	
	// Jump into scope of the player object to see if the item that was removed from their item inventory is
	// of type ammunition. If so, the player will check and update any ammo currently stored ammo counts that
	// match the ID of this item.
	with(PLAYER){
		if (global.itemIDs[_itemID].typeID == ITEM_TYPE_AMMO)
			update_current_ammo_counts(_itemID, -_amountRemoved);
	}
	
	// Return the amount that was successfully removed from the inventory relative to the amount that was 
	// placed within the _amount parameter.
	return (_amount - _amountRemoved);
}

/// @description 
///	Removes an entire slot's contents from the item inventory; regardless of the quantity of items currently
/// occupying that slot.
/// 
///	@param {Real}	slot		Index for the slot that will be removed from the item inventory.
function item_inventory_remove_slot(_slot){
	// Don't try removing anything to an uninitialized inventory, or an out of bounds index.
	if (!is_array(global.curItems) || _slot < 0 || _slot >= array_length(global.curItems))
		return;
	
	// Also don't try removing the contents of the slot in question doesn't have an item occupying it.
	var _item = global.curItems[_slot];
	if (!is_struct(_item))
		return;
	
	// Jump into scope of the player object to see if the item that was removed from their item inventory is
	// of type ammunition. If so, the player will check and update any ammo currently stored ammo counts that
	// match the ID of this item.
	with(PLAYER){
		if (global.itemIDs[_item.itemID].typeID == ITEM_TYPE_AMMO)
			update_current_ammo_counts(_item.itemID, -_item.quantity);
	}
		
	// Remove reference to the soon-to-be delete struct from the player's item inventory. Then, delete
	// that reference using the local value that was grabbed earlier in the function.
	array_set(global.curItems, _slot, INV_EMPTY_SLOT);
	delete _item;
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

/// @description 
///	A special function for removing an item from an inventory slot that will create said item as an instance
/// of obj_world_item at a given position within the current room. This item is then added to a list of
/// dynamically created items and will remain persistent at where it was dropped until it is picked up again.
///	
/// @param {Real}	x		Position along the room's x axis that the world item object is created at.
/// @param {Real}	y		Position along the room's y axis that the world item object is created at.
///	@param {Real}	slot	The slot that will be converted into a world item.
function item_inventory_slot_create_item(_x, _y, _slot){
	if (_slot < 0 || _slot > array_length(global.curItems))
		return; // Don't attempt to remove an item from invalid slot index.
	
	// Grab the properties for the item within the slot, as they will be used to construct the instance of
	// obj_world_item down below. Then, completely remove this item from its slot in the item inventory.
	var _name		= "";
	var _quantity	= 0;
	var _durability = 0;
	var _ammoIndex	= 0;
	with(global.curItems[_slot]){
		_name		= itemName;
		_quantity	= quantity;
		_durability	= durability;
		_ammoIndex	= ammoIndex;
	}
	item_inventory_remove_slot(_slot);
	
	// Use the properties grabbed above alongside the provided position parameters to create the object and
	// add its data into the world item data structure as a dynamic item. It is flagged as dynamic as well.
	var _worldItem = instance_create_object(_x, _y, obj_world_item);
	with(_worldItem){
		set_item_params(global.nextDynamicKey, _name, _quantity, _durability, _ammoIndex);
		flags = flags | WRLDITM_FLAG_DYNAMIC;
	}
	dynamic_item_initialize(_x, _y, _name, _quantity, _durability, _ammoIndex);
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
	return array_get(global.itemIDs, _slotContents.itemID);
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