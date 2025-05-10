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

/// @description 
///	Attempts to load in the game's item data, which is taken in as a JSON file automatically converted by
/// GameMaker before it gets further converted into a custom struct-based format that is easier to manage as
/// it condenses all the sections and data structures into a single ds_map of struct references.
///	
///	@param {String} filename	The name of the item data file to load into the game.
function load_item_data(_filename){
	if (global.itemData != -1) // Item data has already been loaded; don't bother trying to load it again.
		return;
	
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
				
				// Finally, parse the string containing the information about items this current one can be
				// combined with, and the string containing the resulting item created through the combo.
				validCombo	= string_split(_data[? KEY_VALID_COMBOS], ",");
				comboResult	= string_split(_data[? KEY_COMBO_RESULTS], ",");
			}
			break;
		case KEY_COMBINABLE: // Parse through the data of a combinable item.
			with(_item){
				type		= ITEM_TYPE_COMBINABLE;
				stackLimit	= 1;	// Combinable items will ALWAYS have a limit of one per inventory slot.
				
				// Parse the string containing the information about items this current one can be combined 
				// with, and the string containing the resulting item created through the combo.
				validCombo	= string_split(_data[? KEY_VALID_COMBOS], ",");
				comboResult	= string_split(_data[? KEY_COMBO_RESULTS], ",");
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
				
				// Parse the string containing the information about items this current one can be combined 
				// with, and the string containing the resulting item created through the combo.
				validCombo	= string_split(_data[? KEY_VALID_COMBOS], ",");
				comboResult	= string_split(_data[? KEY_COMBO_RESULTS], ",");
			}
			break;
	}
}