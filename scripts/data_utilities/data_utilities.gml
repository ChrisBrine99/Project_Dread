#region Globals Related to General Data Management

// Two data structures that will store references to a given item's data which is stored in a struct (The
// global.itemData ds_map will be responsible for cleaning up those structs when they need to be deleted).
// The first is a map of these references to allow grabbing it by name/key, and the second is a number-based
// system to get the reference by item ID value.
global.itemData			= -1;
global.itemIDs			= -1;

// A map struct that will contain information about items in the game world. It will contain items that have
// been placed manually within GameMaker's room editor. Any dynamic items (Those that were collected previously 
// and then removed by the player from their item iventory) are stored in a seperate map structure.
global.worldItems		= ds_map_create();

// Two important values for how dynamic items will be created within the game. The list stores the keys for
// each dynamic item that is found within global.worldItems, and the number is increment for every dynamic item
// created by the player. The list is used to check on room start for any items that need to be created.
global.dynamicItemKeys	= ds_list_create();
global.nextDynamicKey	= 1000000;

// A list containing the keys for items that have been collected by the player. This prevents the item from
// being collected multiple times since the game's rooms/areas aren't flagged as persistent.
global.collectedItems	= ds_list_create();

#endregion Globals Related to General Data Management

#region File Loading/Saving Functions

/// @description
/// Loads in and automatically decodes a JSON-formatted file into a GML data structure made up of ds_maps 
/// and ds_lists which is then returned by the function to be utilized as required in the code.
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
#macro	KEY_VALID_COMBOS				"Valid_Combos"

// Macros for keys that show up in multiple sections of the unprocessed global item data structure contents. 
// Each will be placed into a variable within the struct found in the processed item data structure list.
#macro	KEY_NAME						"Name"
#macro	KEY_STACK						"Stack"
#macro	KEY_INFO						"Info"
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
#macro	KEY_IS_HITSCAN_FLAG				"Is_Hitscan"
#macro	KEY_AMMO_TYPES					"Ammo_Types"

// Macros for keys that show up exclusively within the Ammo section of the unprocessed item data structure.
#macro	KEY_IS_SPLASH_FLAG				"Is_Splash"

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

// Macros for the unprocessed string representations of the non-weapon/ammo equipment types.
#macro	IDATA_STR_TYPE_LIGHT			"light"
#macro	IDATA_STR_TYPE_ARMOR			"armor"
#macro	IDATA_STR_TYPE_AMULET			"amulet"

// Macros for keys that only appear within the Key_Items section of the unprocessed item data structure.
#macro	KEY_CAN_USE_FLAG				"Can_Use"
#macro	KEY_CAN_DROP_FLAG				"Can_Drop"
#macro	KEY_USE_FUNCTION				"Use_Func"

// Macros for the keys that only appear within the Valid_Combos section of the unprocessed item data structure.
#macro	KEY_FIRST_ITEM					"First"
#macro	KEY_SECOND_ITEM					"Second"
#macro	KEY_RESULT_ITEM					"Result"
#macro	KEY_MIN_AMOUNT					"Min"
#macro	KEY_MAX_AMOUNT					"Max"

// Macro to explain what this character is doing within the JSON data for the item combo data.
#macro	CDATA_VALUE_DELIM				"x"

// Macros to explain what each index in the _splitStr variable represent during the process of parsing an item
// ID and its quantity cost out of the combo data being loaded in.
#macro	CDATA_INDEX_ITEM_ID				0
#macro	CDATA_INDEX_ITEM_COST			1

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
	
	// Attempt to load in the data from the JSON file specified. If the load fails no items will be loaded.
	var _itemData = load_json(_filename);
	if (_itemData == -1) // Invalid file was provided; no data will be parsed.
		return;
	
	// Try and get a reference to the loaded in combination data. If that data cannot be found, the item data
	// is malformed in some way, so the loading process is aborted before anything can be loaded.
	var _comboData = _itemData[? KEY_VALID_COMBOS];
	if (is_undefined(_comboData)){
		ds_map_destroy(_itemData);
		return;
	}
	global.itemData = ds_map_create();	// Stores the item data in structs; manages the references.
	global.itemIDs	= array_create(0, ID_INVALID); // Stores an ID/reference pair for access via ID instead of name/key.
	
	// Loop through all combo data before any items are loaded due to how this information is stored relative
	// to the other sections in the JSON.
	var _validCombos = ds_list_create();
	var _firstItem	 = "";
	var _firstCost	 = 1;
	var _secondItem	 = "";
	var _secondCost	 = 1;
	var _splitStr	 = array_create(0);
	var _curData	 = -1;
	var _length		 = ds_list_size(_comboData);
	for (var i = 0; i < _length; i++){
		_curData = _comboData[| i];
		
		// Parse the first item's ID and its potential additional cost data. By default, the cost will be 1,
		// but a unique valud may be parsed if the item ID is stored as a string instead of a number.
		_firstItem = _curData[? KEY_FIRST_ITEM];
		if (is_string(_firstItem)){
			_splitStr = string_split(_firstItem, CDATA_VALUE_DELIM, true, 2);
			_firstItem = real(_splitStr[CDATA_INDEX_ITEM_ID]);
			_firstCost = real(_splitStr[CDATA_INDEX_ITEM_COST]);
		}
		
		// Parse the second item's ID and its potential additional cost data in the same way that the first
		// item has its information parsed.
		_secondItem = _curData[? KEY_SECOND_ITEM];
		if (is_string(_secondItem)){
			_splitStr = string_split(_secondItem, "x", false, 2);
			_secondItem = real(_splitStr[CDATA_INDEX_ITEM_ID]);
			_secondCost = real(_splitStr[CDATA_INDEX_ITEM_COST]);
		}
		
		// Create a struct that stores the information about the combination and place said struct into the
		// list that will be placed into the global item data structure after this loop is completed.
		ds_list_add(_validCombos, {
			firstItem	: _firstItem,
			firstCost	: _firstCost,
			secondItem	: _secondItem,
			secondCost	: _secondCost,
			resultItem	: _curData[? KEY_RESULT_ITEM],
			minAmount	: load_item_value(_curData[? KEY_MIN_AMOUNT], 1),
			maxAmount	: load_item_value(_curData[? KEY_MAX_AMOUNT], 1)
		});
		
		// Set these values back to 1 in case they were changed due to a unique cost in the combo being present
		// on either item.
		_firstCost	= 1;
		_secondCost = 1;
	}
	ds_map_add(global.itemData, KEY_VALID_COMBOS, _validCombos);
	
	// After the combo data is loaded, the remaining sections will have their information loaded into the
	// structure as they all simply contain different items.
	var _sectionContents = -1;
	var _itemContents	 = -1;
	var _curSection		 = ds_map_find_first(_itemData);
	var _curItemID		 = "";
	while(!is_undefined(_curSection)){
		// If the current section is the chunk that contains the game's combination data, skip over it so it
		// isn't loaded using the logic below, as it is not compatible with it like the rest of the data is.
		if (_curSection == KEY_VALID_COMBOS){
			_curSection = ds_map_find_next(_itemData, _curSection);
			continue;
		}
		
		_sectionContents = _itemData[? _curSection];
		if (is_undefined(_sectionContents)) // The section in question doesn't exist; exit main loop early.
			break;
		
		// Find the first element in the section that is being parsed. Then, loop through that section until
		// there are no more items in the sections to parse (The loop exits early if invalid data is found).
		_curItemID = ds_map_find_first(_sectionContents);
		while(!is_undefined(_curItemID)){
			_itemContents = _sectionContents[? _curItemID];
			if (is_undefined(_itemContents)) // Item with the current ID is invalid; exit inner loop early.
				break;
			
			// Load the item into the correct format that the game expects; parsing out its combo data from a
			// string into structs containing the requirements and outcomes for a combo.
			load_item(_curSection, _itemContents[? KEY_NAME], _curItemID, _itemContents);
			_curItemID = ds_map_find_next(_sectionContents, _curItemID); // Move onto the next item.
		}
		
		_curSection = ds_map_find_next(_itemData, _curSection);
	}
	
	ds_map_destroy(_itemData);
	show_debug_message(
		"Processed and parsed all item data ({1} items and {2} combo recipes) in {0} microseconds.", 
		get_timer() - _startTime,
		ds_map_size(global.itemData) - 1,
		ds_list_size(_validCombos)
	);
}

/// @description
///	Attempts to load in the provided ds_map data as an item that can then be referenced by other objects in
/// the game via the item's provided id value. The section parameter will determine the contents of the item
/// struct past what is provided by default, and will be treated different when interacted with by the player
/// in their inventory depending on that parameter's determined numerical value.
///	
/// @param {String}		section		The key that determines how the item's data will be considered when parsed.
/// @param {String}		itemKey		What will be used to reference the item within the map; it is equal to the name of the item itself.
/// @param {String}		itemIndex	The string numerical value that will be used for the item's index value.
///	@param {Id.DsMap}	data		The raw contents of the item within the unprocessed data.
function load_item(_section, _itemKey, _itemIndex, _data){
	if (string_digits(_itemIndex) == "")
		return; // Don't load the item if there isn't a proper ID that can be used for storing the item's data.
		
	// Create the struct and add it to the global item data structure (This data struct is responsible for 
	// deleting the struct once it is no longer needed). Also add that reference to a list at the position
	// that matches the id value of the item.
	var _itemID			= real(_itemIndex);
	var _itemInfo		= _data[? KEY_INFO];
	if (is_undefined(_itemInfo)) // If no description exists a default will be created.
		_itemInfo		= "ITEM ID " + string(_itemID) + " HAS NO DESCRIPTION";
	var _itemStructRef	= {
		typeID		:   ITEM_TYPE_INVALID,
		itemName	:	_itemKey,
		itemID		:	_itemID,
		itemInfo	:	string_split_lines(_itemInfo, fnt_small, MENUITM_OPTION_INFO_MAX_WIDTH, MENUITM_OPTION_INFO_MAX_LINES),
		stackLimit	:	load_item_value(_data[? KEY_STACK], 1),
		flags		:	0,
	};
	array_set(global.itemIDs, _itemID, _itemStructRef);
	ds_map_add(global.itemData, _itemKey, _itemStructRef);
	
	switch(_section){
		case KEY_WEAPONS: // Parse through the data of a weapon item.
			with(_itemStructRef){
				typeID		= ITEM_TYPE_WEAPON;

				// Begin adding parameters that are unique to a weapon type item (Some are also the same as 
				// what an ammo-type item will have defined for it, and durability is the same as what is also
				// defined in an equipable-type item).
				durability	= load_item_value(_data[? KEY_DURABILITY], 0);		// Also found in equipable-type items.
				damage		= load_item_value(_data[? KEY_DAMAGE], 0);			// Also found in ammo-type items.
				range		= load_item_value(_data[? KEY_RANGE], 0);			//		"
				accuracy	= load_item_value(_data[? KEY_ACCURACY], 0);		//		"
				attackSpeed	= load_item_value(_data[? KEY_ATTACK_SPEED], 0);	//		"
				reloadSpeed	= load_item_value(_data[? KEY_RELOAD_SPEED], 0);
				bulletCount	= load_item_value(_data[? KEY_BULLET_COUNT], 1);	// Also found in ammo-type items.
				
				// Set the flag bits utilized by weapon-type items based on the values parsed through the item
				// data for the weapon in question; offseting them to match the bit's position in the variable.
				flags	    = (bool(_data[? KEY_IS_MELEE_FLAG])				) |
							  (bool(_data[? KEY_IS_AUTO_FLAG])		<<	 1	) |
							  (bool(_data[? KEY_IS_BURST_FLAG])		<<	 2	) |
							  (bool(_data[? KEY_IS_THROWN_FLAG])	<<	 3	) |
							  (bool(_data[? KEY_IS_HITSCAN_FLAG])	<<	 4	);
							  
				// Determine which type of weapon this is when equipped by checking if the item is thrown or
				// not. If it is thrown, it will always be considered a subweapon.
				if (WEAPON_IS_THROWN)	{ equipType = ITEM_EQUIP_TYPE_SUBWEAPON; }
				else					{ equipType = ITEM_EQUIP_TYPE_MAINWEAPON; }
				
				// Copy over the item IDs for the various ammo types the given weapon can utilize from the raw
				// JSON data's ds_list that the text arrays are converted to by GML.
				var _ammoTypes	= _data[? KEY_AMMO_TYPES];
				if (is_undefined(_ammoTypes)){ // Default to a single element array with -1 as a value when no ammo data is present.
					ammoTypes = [-1];
					break;
				}
				var _size = ds_list_size(_ammoTypes);
				ammoTypes = array_create(_size);
				for (var i = 0; i < _size; i++)
					ammoTypes[i] = _ammoTypes[| i];
			}
			break;
		case KEY_AMMO: // Parse through the data of an ammo item.
			with(_itemStructRef){
				typeID		= ITEM_TYPE_AMMO;
				
				// Begin adding parameters to the default item struct so that it can contain all the values
				// needed for an ammo-type item (All are the same as variables found in weapon-type items).
				damage		= load_item_value(_data[? KEY_DAMAGE], 0);
				range		= load_item_value(_data[? KEY_RANGE], 0);
				accuracy	= load_item_value(_data[? KEY_ACCURACY], 0);
				attackSpeed	= load_item_value(_data[? KEY_ATTACK_SPEED], 0);
				bulletCount	= load_item_value(_data[? KEY_BULLET_COUNT], 0); 
				
				// Finally, copy the flag values (0 or 1) into their proper bit position in the flags variable.
				flags		= bool(_data[? KEY_IS_SPLASH_FLAG]);
			}
			break;
		case KEY_CONSUMABLE: // Parse through the data of a consumable item.
			with(_itemStructRef){
				typeID		= ITEM_TYPE_CONSUMABLE;

				// Begin adding parameters to the default item struct so that it can contain all the values
				// needed for a consumable-type item.
				hpHeal		= load_item_value(_data[? KEY_HEALTH_RESTORE], 0) / 255.0; // Convert values to be between 0.0 and 1.0.
				sanityHeal	= load_item_value(_data[? KEY_SANITY_RESTORE], 0) / 255.0;
				immuneTime	= load_item_value(_data[? KEY_IMMUNITY_TIME], 0) * GAME_TARGET_FPS; // Convert from real-world seconds to units per second within the game.
				
				// Set the flag bits utilized by consumable-type items based on the values parsed through the 
				// item data for the consumable in question; offseting them to match the bit's position in
				// the variable's numerical value.
				flags		= (bool(_data[? KEY_CURE_POISON_FLAG])						) |
							  (bool(_data[? KEY_CURE_BLEED_FLAG])				<<  1	) |
							  (bool(_data[? KEY_CURE_CRIPPLE_FLAG])				<<	2	) |
							  (bool(_data[? KEY_TEMP_POISON_IMMUNITY_FLAG])		<<  3	) |
							  (bool(_data[? KEY_TEMP_BLEED_IMMUNITY_FLAG])		<<  4	) |
							  (bool(_data[? KEY_TEMP_CRIPPLE_IMMUNITY_FLAG])	<<  5	);
			}
			break;
		case KEY_COMBINABLE: // Parse through the data of a combinable item.
			with(_itemStructRef) { typeID = ITEM_TYPE_COMBINABLE; }
			break;
		case KEY_EQUIPABLE: // Parse through the data of an equipable item.
			with(_itemStructRef){
				typeID		= ITEM_TYPE_EQUIPABLE;

				// Begin adding parameters to the default item struct so that it can contain all the values
				// needed for an equipable-type item (The durability variable serves the same purpose as the 
				// one found in weapon-type items).
				durability	= load_item_value(_data[? KEY_DURABILITY], 0);
				equipType	= equipment_get_type_index(_data[? KEY_TYPE]);
				
				// Don't bother parsing out equip parameters if the item in question has none.
				var _paramList = _data[? KEY_EQUIP_PARAMS];
				if (is_undefined(_paramList))
					break;
				
				// Create the array within the item struct that will store the data used when equipping it.
				var _totalParams = ds_list_size(_paramList);
				equipParams = array_create(_totalParams, -1);
				for (var i = 0; i < _totalParams; i++)
					equipParams[i] = _paramList[| i];
			}
			break;
		case KEY_KEY_ITEMS: // Parse through the data of a key item.
			with(_itemStructRef) { typeID = ITEM_TYPE_KEY_ITEM; }
			break;
	}
}

/// @description 
///	A simple function that takes in a value, and either returns it unchanged or returns the provided default
/// should the value provided be undefined.
///
///	@param {Any}	value		The value that is being loaded.
/// @param {Any}	default		What will be returned if the default value is invalid/undefined.
function load_item_value(_value, _default){
	return (is_undefined(_value)) ? _default : _value;
}

/// @description 
///	Returns a numerical value that is tied to the human-readable string version of that number's purpose
/// within the game's logic.
///	
/// @param {String}		typeString	The unformatted version of the euqipment's "type", which will be converted to its proper numerical value.
function equipment_get_type_index(_typeString){
	switch(string_lower(_typeString)){
		default:						return ITEM_EQUIP_TYPE_INVALID;
		case IDATA_STR_TYPE_LIGHT:		return ITEM_EQUIP_TYPE_FLASHLIGHT;
		case IDATA_STR_TYPE_ARMOR:		return ITEM_EQUIP_TYPE_ARMOR;
		case IDATA_STR_TYPE_AMULET:		return ITEM_EQUIP_TYPE_AMULET;
	}
}

#endregion Item Data Parsing Functions

#region World Item Data Management Functions

/// @description 
///	Initializes a new element within the world item data structure. This element will store information about
/// an item: the room it exists in (This is useful for items that were dropped by the player form their current
/// items), the item's ID, the amount of the item that can be collected, and its durability.
///	
/// @param {Any}		key			The value tied to this world item's information.
///	@param {String}		itemName	Value that can be used to reference the item's characteristics from the global item data.
/// @param {Real}		quantity	The current amount of the item found within this world item.
/// @param {Real}		durability	(Optional; Higher Difficulties Only) The item's current condition.
///	@param {Real}		ammoIndex	(Optional; Weapon-Type Items Only) The ammunition found within the item relative to its list of valid ammo types.
function world_item_initialize(_key, _itemName, _quantity, _durability, _ammoIndex){
	var _value = ds_map_find_value(global.worldItems, _key);
	if (!is_undefined(_value)) // The item already exists; don't try to initialize it again.
		return;
		
	ds_map_add(global.worldItems, _key, {
		itemName	: _itemName,
		quantity	: _quantity,
		durability	: _durability,
		ammoIndex	: _ammoIndex,
	});
}

/// @description 
/// Initializes a special type of world item element within the world item data structure. These are items that
/// were collected previously and have been removed by the player from their item inventory. They don't need
/// to be tracked within the global list of collected items, and contain additional information about the
/// position of the item instance and the room it was created within so they can be created again if the room
/// unloads and then reloads without the player collecting the item.
///	
/// @param {Real}		x			X position to create the item at within the room.
/// @param {Real}		y			Y position to create the item at within the room.
///	@param {String}		itemName	Value that can be used to reference the item's characteristics from the global item data.
/// @param {Real}		quantity	The current amount of the item found within this world item.
/// @param {Real}		durability	(Optional; Higher Difficulties Only) The item's current condition.
///	@param {Real}		ammoIndex	(Optional; Weapon-Type Items Only) The ammunition found within the item relative to its list of valid ammo types.
function dynamic_item_initialize(_x, _y, _itemName, _quantity, _durability, _ammoIndex){
	var _value = ds_map_find_value(global.worldItems, global.nextDynamicKey);
	if (!is_undefined(_value)) // The item already exists; don't try to initialize it again.
		return;
		
	ds_list_add(global.dynamicItemKeys, global.nextDynamicKey);
	ds_map_add(global.worldItems, global.nextDynamicKey++, {
		xPos		: _x,
		yPos		: _y,
		roomIndex	: room,
		itemName	: _itemName,
		quantity	: _quantity,
		durability	: _durability,
		ammoIndex	: _ammoIndex,
	});
}

/// @description 
///	Returns a reference to the struct containing an item's data in respect to the world and not just the area
/// it exists in. If there is no data found with the provided key, the value returned is -1 to signify there
/// isn't any data for the item.
///	
///	@param {Any}	key		The value tied to the world item struct reference that will be returned.
function world_item_get(_key){
	var _value = ds_map_find_value(global.worldItems, _key);
	if (is_undefined(_value)) // Return the value -1 to signify the key doesn't exist in the map.
		return ID_INVALID;
	return _value;
}

/// @description 
///	Removes an element from the current world item data structure while adding its key to the list of collected
/// items. This means that the item object that used this data will no longer exist within the game, as it will 
/// destory itself during its room start event.
///	
///	@param {Any}	key			The value tied to the to-be-deleted world item information.
/// @param {Real}	isDynamic	If true, the item's key will not be added the collected item list as that isn't needed.
function world_item_remove(_key, _isDynamic){
	var _value = ds_map_find_value(global.worldItems, _key);
	if (is_undefined(_value)) // Item with the desired key doesn't exist; don't delete anything.
		return;
		
	ds_map_delete(global.worldItems, _key);
	if (!_isDynamic) // Only add the key to the collected items list if the item wasn't consdiered dynamic.
		ds_list_add(global.collectedItems, _key);
	delete _value; // Signals to GM's garbage collector to come and collect.
}

#endregion World Item Data Management Functions