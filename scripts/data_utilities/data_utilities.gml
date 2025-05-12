#region File Loading/Saving Functions

/// @description
/// Loads in and automatically decodes a JSON-formatted file into a GML data structure made up of ds_maps and
/// ds_lists which is then returned by the function to be utilized as required in the code.
///	
///	@param {String}	filename	The JSON file to load.
function load_json(_filename){
	var _buffer = buffer_load(_filename);
	if (_buffer == -1)
		return "";
		
	var _string = buffer_read(_buffer, buffer_string);
	buffer_delete(_buffer);
	
	return json_decode(_string);
}

#endregion File Loading/Saving Functions

#region Item Data Parsing Macros

// Macros for the main sections of the unprocessed global item data structure contents. These are only required 
// on the initial load of the item data, as it will all be parsed and condensed into a single list once loaded.
#macro	KEY_WEAPONS						"Weapons"
#macro	KEY_AMMO						"Ammo"
#macro	KEY_CONSUMABLE					"Consumable"
#macro	KEY_COMBINABLE					"Combinable"
#macro	KEY_EQUIPABLE					"Equipable"
#macro	KEY_KEY_ITEMS					"Key_Items"

// Macros for keys that show up in multiple sections of the unprocessed global item data structure contents. 
// Each will be placed into a variable within the struct found in the processed item data structure list.
#macro	KEY_NAME						"Name"
#macro	KEY_STACK						"Stack"
#macro	KEY_DURABILITY					"Durability"

// Macros for keys that show up in the Weapon and Ammo sections of the unprocessed item data structure.
#macro	KEY_DAMAGE						"Damage"
#macro	KEY_RANGE						"Range"
#macro	KEY_ACCURACY					"Accuracy"
#macro	KEY_ATTACK_SPEED				"A_Speed"
#macro	KEY_RELOAD_SPEED				"R_Speed"
#macro	KEY_BULLET_COUNT				"Bullets"

// Macros for keys that show up exclusively within the Weapon section of the unprocessed item data structure.
#macro	KEY_IS_MELEE_FLAG				"Is_Melee"
#macro	KEY_IS_AUTO_FLAG				"Is_Auto"
#macro	KEY_IS_BURST_FLAG				"Is_Burst"
#macro	KEY_IS_THROWN_FLAG				"Is_Thrown"
#macro	KEY_AMMO_TYPES					"Ammo_Types"

// Macros for keys that show up exclusively within the Ammo section of the unprocessed item data structure.
#macro	KEY_IS_SPLASH_FLAG				"Is_Splash"

// Macros for keys that show up in the Consumable, Combinable, and Key_Items sections of the unprocessed global
// item data structure.
#macro	KEY_VALID_COMBOS				"Valid_Combos"
#macro	KEY_COMBO_RESULTS				"Combo_Results"

// Macros for keys that only show up within the Consumable section of the unprocessed item data structure.
#macro	KEY_HEALTH_RESTORE				"Heal%"
#macro	KEY_SANITY_RESTORE				"Sanity%"
#macro	KEY_CURE_POISON_FLAG			"Cur_Psn"
#macro	KEY_CURE_BLEED_FLAG				"Cur_Bld"
#macro	KEY_CURE_CRIPPLE_FLAG			"Cur_Crpl"
#macro	KEY_TEMP_POISON_IMMUNITY_FLAG	"TmpImu_P"
#macro	KEY_TEMP_BLEED_IMMUNITY_FLAG	"TmpImu_B"
#macro	KEY_TEMP_CRIPPLE_IMMUNITY_FLAG	"TmpImu_C"
#macro	KEY_IMMUNITY_TIME				"Imu_Time"

// Macros for keys that only appear within the Equipable section of the unprocessed item data structure.
#macro	KEY_TYPE						"Type"
#macro	KEY_EQUIP_PARAMS				"Equip_Params"

// Macros for keys that only appear within the Key_Items section of the unprocessed item data structure.
#macro	KEY_CAN_USE_FLAG				"Can_Use"
#macro	KEY_CAN_DROP_FLAG				"Can_Drop"
#macro	KEY_USE_FUNCTION				"Use_Func"

#endregion item Data Parsing Macros

#region Item Data Parsing Functions

/// @description 
///	Attempts to load in the game's item data, which is taken in as a JSON file automatically converted by
/// GameMaker before it gets further converted into a custom struct-based format that is easier to manage as
/// it condenses all the sections and data structures into a single ds_map of struct references.
///	
///	@param {String} filename	The name of the item data file to load into the game.
function load_item_data(_filename){
	if (global.itemData != -1) // Item data has already been loaded; don't bother trying to load it again.
		return;
		
	var _startTime = get_timer();
	
	var _itemData = load_json(_filename);
	if (_itemData == -1) // Invalid file was provided; no data was parsed.
		return;
	global.itemData = ds_map_create();
	
	var _sectionContents = -1;
	var _itemContents	 = -1;
	var _curSection		 = ds_map_find_first(_itemData);
	var _curItemID		 = "";
	while(!is_undefined(_curSection)){
		_sectionContents = _itemData[? _curSection];
		if (is_undefined(_sectionContents))
			break;
			
		_curItemID = ds_map_find_first(_sectionContents);
		while(!is_undefined(_curItemID)){
			_itemContents = _sectionContents[? _curItemID];
			if (is_undefined(_itemContents))
				break;
			
			load_item(_curSection, _curItemID, _itemContents);
			_curItemID = ds_map_find_next(_sectionContents, _curItemID);
		}
		
		_curSection = ds_map_find_next(_itemData, _curSection);
	}
	
	ds_map_destroy(_itemData);
	
	show_debug_message("Processed and parsed all item data in {0} microseconds.", get_timer() - _startTime);
}

/// @description
///	Attempts to load in the provided ds_map data as an item that can then be referenced by other objects in
/// the game via the item's provided id value. The section parameter will determine the contents of the item
/// struct past what is provided by default, and will be treated different when interacted with by the player
/// in their inventory depending on that parameter's determined numerical value.
///	
/// @param {String}		section		The key that determines how the item's data will be considered when parsed.
/// @param {String}		itemID		String value of the numerical id value as read in from the raw item JSON data.
///	@param {Id.DsMap}	data		The raw contents of the item within the unprocessed data.
function load_item(_section, _itemID, _data){
	if (string_digits(_itemID) == "")
		return;
	var _index = real(_itemID);
	ds_map_add(global.itemData, _index, {
		index		:	_index,
		type		:   ITEM_TYPE_INVALID,
		itemName	:	_data[? KEY_NAME],
		itemInfo	:	"",
		stackLimit	:	0,
		flags		:	0,
	});
	var _item = global.itemData[? _index];
	
	// Before implementing anything about the item, the first step is to check if there is a list of valid
	// combos and resulting item from said combo being performed. If they both exist, their lists will be
	// parsed and processed here instead of repeating this chunk of code for various items based on type.
	with(_item){
		// Immediately stops attempting to parse any combination data if either piece of data doesn't exist.
		if (is_undefined(_data[? KEY_VALID_COMBOS]) || is_undefined(_data[? KEY_COMBO_RESULTS]))
			continue;
		
		// Parse the input combination list by first storing it the array's reference into a local variable.
		// Then, if that reference is actually an array (-1 can also be returned), its contents are copied
		// into the newly created validCombo array. Otherwise, the array is deleted since it only exists in
		// local scope.
		var _outputArray = item_parse_input_combo_data(_data[? KEY_VALID_COMBOS]);
		if (is_array(_outputArray)){ // Only attempt to copy the contents if there is an array returned to copy.
			validCombo = array_create(0);
			array_copy(validCombo, 0, _outputArray, 0, array_length(_outputArray));
		}
		
		// Do the same process as above but for each combination's resulting item data. If a proper array ref
		// is returned, the array comboResult is created and has the contents from _outputArray copied to it.
		_outputArray = item_parse_result_combo_data(_data[? KEY_COMBO_RESULTS]);
		if (is_array(_outputArray)){ // Only attempt to copy the contents if there is an array returned to copy.
			comboResult = array_create(0);
			array_copy(comboResult, 0, _outputArray, 0, array_length(_outputArray));
		}
	}
	
	switch(_section){
		case KEY_WEAPONS: // Parse through the data of a weapon item.
			with(_item){
				type		= ITEM_TYPE_WEAPON;
				stackLimit	=_data[? KEY_STACK];
				
				// Begin adding parameters that are unique to a weapon type item (Some are also the same as 
				// what an ammo-type item will have defined for it, and durability is the same as what is also
				// defined in an equipable-type item).
				durability	=_data[? KEY_DURABILITY];		// Also found in equipable-type items.
				damage		=_data[? KEY_DAMAGE];			// Also found in ammo-type items.
				range		=_data[? KEY_RANGE];			//		"
				accuracy	=_data[? KEY_ACCURACY];			//		"
				attackSpeed	=_data[? KEY_ATTACK_SPEED];		//		"
				reloadSpeed	=_data[? KEY_RELOAD_SPEED];
				bulletCount	=_data[? KEY_BULLET_COUNT];		// Also found in ammo-type items.
				
				// Set the flag bits utilized by weapon-type items based on the values parsed through the item
				// data for the weapon in question; offseting them to match the bit's position in the variable.
				flags	    = (bool(_data[? KEY_IS_MELEE_FLAG])				) |
							  (bool(_data[? KEY_IS_AUTO_FLAG])		<<	 1	) |
							  (bool(_data[? KEY_IS_BURST_FLAG])		<<	 2	) |
							  (bool(_data[? KEY_IS_THROWN_FLAG])	<<	 3	);
				
				// Copy over the item IDs for the various ammo types the given weapon can utilize from the raw
				// JSON data's ds_list that the text arrays are converted to by GML.
				var _ammoTypes	= _data[? KEY_AMMO_TYPES];
				var _size		= ds_list_size(_ammoTypes);
				ammoTypes		= array_create(_size);
				for (var i = 0; i < _size; i++)
					ammoTypes[i] = _ammoTypes[| i];
			}
			break;
		case KEY_AMMO: // Parse through the data of an ammo item.
			with(_item){
				type		= ITEM_TYPE_AMMO;
				stackLimit	= _data[? KEY_STACK];
				
				// Begin adding parameters to the default item struct so that it can contain all the values
				// needed for an ammo-type item (All are the same as variables found in weapon-type items).
				damage		= _data[? KEY_DAMAGE];
				range		= _data[? KEY_RANGE];
				accuracy	= _data[? KEY_ACCURACY];
				attackSpeed	= _data[? KEY_ATTACK_SPEED];
				bulletCount	= _data[? KEY_BULLET_COUNT]; 
				
				// Finally, copy the flag values (0 or 1) into their proper bit position in the flags variable.
				flags		= bool(_data[? KEY_IS_SPLASH_FLAG]);
			}
			break;
		case KEY_CONSUMABLE: // Parse through the data of a consumable item.
			with(_item){
				type		= ITEM_TYPE_CONSUMABLE;
				stackLimit	= 1;	// Consumable items will ALWAYS have a limit of one per inventory slot.
				
				// Begin adding parameters to the default item struct so that it can contain all the values
				// needed for a consumable-type item.
				hpHeal		= _data[? KEY_HEALTH_RESTORE] / 255.0; // Convert values to be between 0.0 and 1.0.
				sanityHeal	= _data[? KEY_SANITY_RESTORE] / 255.0;
				immuneTime	= _data[? KEY_IMMUNITY_TIME] * GAME_TARGET_FPS; // Convert from real-world seconds to units per second within the game.
				
				// Set the flag bits utilized by consumable-type items based on the values parsed through the 
				// item data for the consumable in question; offseting them to match the bit's position in
				// the variable's numerical value.
				flags		= (bool(_data[? KEY_CURE_POISON_FLAG])						) |
							  (bool(_data[? KEY_CURE_BLEED_FLAG])				<<  1	) |
							  (bool(_data[? KEY_CURE_CRIPPLE_FLAG])				<<	2	) |
							  (bool(_data[? KEY_TEMP_POISON_IMMUNITY_FLAG])		<<  3	) |
							  (bool(_data[? KEY_TEMP_BLEED_IMMUNITY_FLAG])		<<  4	) |
							  (bool(_data[? KEY_TEMP_CRIPPLE_IMMUNITY_FLAG])	<<  5	);
				
				// Initialize these two variables with the default values of -1 should they not exist. 
				// Otherwise, they will have already been initialized as arrays in the code block directly 
				// above this switch statement.
				if (!variable_struct_exists(_item, "validCombo"))	{ validCombo = -1; }
				if (!variable_struct_exists(_item, "comboResult"))	{ comboResult = -1; }
			}
			break;
		case KEY_COMBINABLE: // Parse through the data of a combinable item.
			with(_item){
				type		= ITEM_TYPE_COMBINABLE;
				stackLimit	= 1;	// Combinable items will ALWAYS have a limit of one per inventory slot.
				
				// Initialize these two variables with the default values of -1 should they not exist. 
				// Otherwise, they will have already been initialized as arrays in the code block directly 
				// above this switch statement.
				if (!variable_struct_exists(_item, "validCombo"))	{ validCombo = -1; }
				if (!variable_struct_exists(_item, "comboResult"))	{ comboResult = -1; }
			}
			break;
		case KEY_EQUIPABLE: // Parse through the data of an equipable item.
			with(_item){
				type		= ITEM_TYPE_EQUIPABLE;
				stackLimit	= 1;	// Equipable items will ALWAYS have a limit of one per inventory slot.
				
				// Begin adding parameters to the default item struct so that it can contain all the values
				// needed for an equipable-type item (The durability variable serves the same purpose as the 
				// one found in weapon-type items).
				durability	= _data[? KEY_DURABILITY];
				equipType	= _data[? KEY_TYPE];
				equipParams	= _data[? KEY_EQUIP_PARAMS];
			}
			break;
		case KEY_KEY_ITEMS: // Parse through the data of a key item.
			with(_item){
				type		= ITEM_TYPE_KEY_ITEM;
				stackLimit	= _data[? KEY_STACK];
				
				// Initialize these two variables with the default values of -1 should they not exist. 
				// Otherwise, they will have already been initialized as arrays in the code block directly 
				// above this switch statement.
				if (!variable_struct_exists(_item, "validCombo"))	{ validCombo = -1; }
				if (!variable_struct_exists(_item, "comboResult"))	{ comboResult = -1; }
			}
			break;
	}
	//show_debug_message("item {0} has been created. (structRef: {1})", _index, _item);
}

/// @description 
///	Attempts to parse an items valid combination data, which is stored as a string of numbers split by commas.
///	Optionally, there can be another value split from the first with the letter x which then becomes the cost
/// (How many of that item needs to be in the inventory) for the combination to be allowed.
///	
///	@param {String}		contents	The string containing item IDs; split by the "," delimiter.
function item_parse_input_combo_data(_contents){
	// Return a default value of -1 if the item doesn't have any combination data associated with it.
	if (_contents == "")
		return -1;
	
	// Remove all spaces from the unformatted string should there be any before each value is split into its
	// own index in the _splitContents array.
	if (string_count(" ", _contents) > 0)
		_contents = string_replace_all(_contents, " ", "")
	var _contentArray	= string_split(_contents, ",");
	var _arrayLength	= array_length(_contentArray);
	var _outputArray	= array_create(_arrayLength, -1);
	
	/// @description
	///	A lambda-like function that will return a new struct containing the index for the item required in the
	///	combo recipe alongside its cost for the combination to actually occur (The default is a value of one).
	///	
	///	@param {String}		indexString		The index of the item required for the combination.
	/// @param {String}		costString		The amount required of the item the player needs in their inventory in order to combine it.
	var create_input_combo_struct = function(_indexString, _costString){
		return {
			index	: (_indexString == "")	? -1 : real(_indexString),
			cost	: (_costString == "")	?  1 : real(_costString),
		};
	}
	
	// Loop through all of the combination input values; parsing them into structs containing numerical values
	// for the item index that was found alongside its cost in the combination process.
	var _itemID			= -1;
	var _cost			= -1;
	var _subStrings		= -1;
	var _curString		= "";
	for (var i = 0; i < _arrayLength; i++){
		_curString = _contentArray[i];
		
		// If there isn't a cost for the item it is assumed to be a value of 1. So, an empty string is passed
		// into the "create_input_combo_struct" to allow that default value to be set automatically.
		if (string_count("x", _curString) == 0){
			_outputArray[i] = create_input_combo_struct(_curString, "");
			continue; // No other processing required; skip onto the next chunk of data.
		}
			
		// Further split the string into another that should only contain the item's index in the first index
		// of the array, and the cost required in the second index. If there isn't anything after the x character
		// the default cost of 1 will be assumed and set. Otherwise, the parsed cost is stored.
		_subStrings = string_split(_curString, "x");
		if (array_length(_subStrings) == 1){
			_outputArray[i] = create_input_combo_struct(_curString, "");
			continue;
		}
		_outputArray[i] = create_input_combo_struct(_subStrings[0], _subStrings[1]);
	}
	
	return _outputArray;
}

/// @description 
///	A function that is very similar to item_parse_input_combo_data--with the main exception being this will
/// process the resulting item from the combination. This result can have a range of how many are created, and
/// as such needs unique logic to allow processing that.
///	
///	@param {String}		contents	The string containing item IDs; split by the "," delimiter.
function item_parse_result_combo_data(_contents){
	// Return a default value of -1 if the item doesn't have any combination data associated with it.
	if (_contents == "")
		return -1;
		
	// Remove all spaces from the unformatted string should there be any before each value is split into its
	// own index in the _splitContents array.
	if (string_count(" ", _contents) > 0)
		_contents = string_replace_all(_contents, " ", "")
	var _contentArray	= string_split(_contents, ",");
	var _arrayLength	= array_length(_contentArray);
	var _outputArray	= array_create(_arrayLength, -1);
	
	/// @description
	///	A lambda-like function that will return a new struct containing the index for the item that results from
	///	the item combination process. It also stores the minimum and maximum possible amounts that can be
	///	created because of the combiation.
	///
	///	@param {String}		indexString		The index of the item required for the combination.
	/// @param {String}		minString		The minimum potential amount of the item that can be created.
	/// @param {String}		maxString		The maximum potential amount of the item that can be created.
	var create_result_combo_struct = function(_indexString, _minString, _maxString){
		var _minResult = (_minString == "")	?  1 : real(_minString);
		var _maxResult = (_maxString == "")	?  1 : real(_maxString);
		return {
			index		: (_indexString == "")	? -1 : real(_indexString),
			minResult	: _minResult,
			maxResult	: max(_minResult, _maxResult),
		};
	}
	
	// The loop here is very similar to what is found in item_parse_input_combo_data, but with one major
	// exception. In this case, it will have to parse an extra value in order to capture the item's ID as
	// well as the potential minimum and maximum amount of that item that is created on a successful combo.
	var _itemID			= -1;
	var _minResult		= -1;
	var _maxResult		= -1;
	var _subStrings		= -1;
	var _curString		= "";
	for (var i = 0; i < _arrayLength; i++){
		_curString = _contentArray[i];
		
		// If there is no data for the amount crafted within the unprocessed data, it is assumed that the 
		// resulting amount created is always one of the item, so empty strings are passed into the min and
		// max value parameters to cause that default to be set for both.
		if (string_count("x", _curString) == 0){
			_outputArray[i] = create_result_combo_struct(_curString, "", "");
			continue; // No other processing required; skip onto the next chunk of data.
		}
		
		// Attempt to parse out the minimum and maximum item amount values from the unprocessed string. If there
		// isn't any content, the default amount of 1 for the min and max is assumed. Otherwise, the code will
		// continue with parsing even further below this block.
		_subStrings = string_split(_curString, "x");
		if (array_length(_subStrings) == 1){
			_outputArray[i] = create_result_combo_struct(_curString, "", "");
			continue;
		}
		
		// Check if there is the "-" character within the split string (There should only ever be two indices
		// in this array for properly formatted data, but any additional indexes are simply ignored, regardless).
		// If so, the values will overwrite the previous _subStrings array and the first/second indexes will be
		// used as the minimum and maximum amounts, respectively.
		if (string_count("-", _subStrings[1]) > 0){
			_curString = _subStrings[0];
			_subStrings = string_split(_subStrings[1], "-");
			_outputArray[i] = create_result_combo_struct(_curString, _subStrings[0], _subStrings[1]);
			continue;
		}
		
		// Otherwise, it's assumed that the value is both the minimum and the maximum, so it will be passed
		// in as both parameters for the item result container struct.
		_outputArray[i] = create_result_combo_struct(_subStrings[0], _subStrings[1], _subStrings[1]);
	}
	
	return _outputArray;
}

#endregion Item Data Parsing Functions

#region Inventory Management Macros

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
#macro	CONSUMABLE_CURES_POISON			(flags & CNSM_FLAG_CURE_POISON)
#macro	CONSUMABLE_CURES_BLEED			(flags & CNSM_FLAG_CURE_BLEED)
#macro	CONSUMABLE_CURES_CRIPPLE		(flags & CNSM_FLAG_CURE_CRIPPLE)
#macro	CNSM_GIVES_TMPIMU_POISON		(flags & CNSM_FLAG_TMPIMU_POISON)
#macro	CNSM_GIVES_TMPIMU_BLEED			(flags & CNSM_FLAG_TMPIMU_BLEED)
#macro	CNSM_GIVES_TMPIMU_CRIPPLE		(flags & CNSM_FLAG_TMPIMU_CRIPPLE)

// Macro that represents an inventory slot that current has no item contained within it.
#macro	INV_EMPTY_SLOT				   -1

#endregion Inventory Management Macros

#region Inventory Management Functions

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
			if (global.inventory != INV_EMPTY_SLOT && is_struct(global.inventory[i]))
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
		if (_invItem != INV_EMPTY_SLOT && is_struct(_invItem)){
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
///	
///	
///	@param {Real}	itemID		Number representing the item within the game's data.
/// @param {Real}	amount		How many of said item will be removed from the inventory.
function inventory_remove_item(_itemID, _amount){
	// Don't try adding anything to an uninitialized inventory.
	if (!is_array(global.inventory))
		return _amount;
	
	// Make sure the item id points to a valid item. Otherwise, don't even attempt to remove the invalid item.
	var _itemData = global.itemData[? _itemID];
	if (is_undefined(_itemData))
		return _amount;
}

#endregion Invenotry Management Functions