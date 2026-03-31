#region Macros Utilized When Certain Items Are Used

// Macros that are returned by functions that are called upon a given item's usage by the player. Depending on what bits here are set, the 
// game can take action to ensure the proper process occurs as a result.
#macro	USEITM_FLAG_CONSUMED			0x00000001
#macro	USEITM_FLAG_CLOSE_MENU			0x00000002
#macro	USEITM_FLAG_OPEN_TEXTBOX		0x00000004

// The amounts to increase each of the player's main values when their respective item for increasing those maximum is used.
#macro	ITEM_HITPOINT_UP_AMOUNT			10
#macro	ITEM_STAMINA_UP_AMOUNT			25
#macro	ITEM_SANITY_UP_AMOUNT			25

#endregion Macros Utilized When Certain Items Are Used

#region Functions Utilized By Items When Used

/// @description 
///	Increases the player's maximum hitpoints by 10 points; capping out at a maximum of 150 regardless of the current difficulty level. 
/// Returns *0x00000005* if the item was successfully used.
/// @returns 	{Real}
/// @param 		{Real}	slot	(Unused) Where the item is located within the player's inventory.
function item_use_hitpoint_up(_slot){
	with(PLAYER){
		if (maxHitpoints >= PLYR_MAX_POSSIBLE_HITPOINTS)
			return 0; // Player cannot increase their hitpoints any longer. Return 0 so nothing happens on use.
		maxHitpoints += ITEM_HITPOINT_UP_AMOUNT;
		curHitpoints += ITEM_HITPOINT_UP_AMOUNT;
	}
	with(TEXTBOX){ // Flavor text informing the player that their max health has been increased.
		queue_new_text("Hmm... I feel like I'll be able to take another hit or two after drinking this... What the hell is it made with?\n(@0x3050F8{Your maximum health has permanently been increased})");
	}
	return USEITM_FLAG_CONSUMED | USEITM_FLAG_OPEN_TEXTBOX;
}

/// @description 
///	Increases the player's maximum stamina by 25 points; capping out at a maximum of 250 regardless of the current difficulty level. Returns
/// *0x00000005* if the item was successfully used.
/// @returns 	{Real}
/// @param 		{Real}	slot	(Unused) Where the item is located within the player's inventory.
function item_use_stamina_up(_slot){
	with(PLAYER){
		if (maxStamina >= PLYR_MAX_POSSIBLE_STAMINA)
			return 0; // Player cannot increase their stamina any longer. Return 0 so nothing happens on use.
		maxStamina += ITEM_STAMINA_UP_AMOUNT;
		curStamina = maxStamina; // Completely restore stamina on use.
	}
	with(TEXTBOX){ // Flavor text informing the player that their max stamina has been increased.
		queue_new_text("Huh... I feel like I have a bit more energy than I did before; guess it really did what it says on the label...\n(@0x00F800{Your maximum stamina has permanently been increased})");
	}
	return USEITM_FLAG_CONSUMED | USEITM_FLAG_OPEN_TEXTBOX;
}

/// @description 
///	Increases the player's maximum sanity level by 25 points; capping out at a maximum of 300 regardless of the current difficulty level. 
/// Returns *0x00000005* if the item was successfully used.
/// @returns 	{Real}
/// @param 		{Real}	slot	(Unused) Where the item is located within the player's inventory.
function item_use_sanity_up(_slot){
	with(PLAYER){
		if (maxSanity >= PLYR_MAX_POSSIBLE_SANITY)
			return 0; // Player cannot increase their sanity level any longer. Return 0 so nothing happens on use.
		maxSanity += ITEM_SANITY_UP_AMOUNT;
	}
	with(TEXTBOX){ // Flavor text informing the player that their max sanity has been increased.
		queue_new_text("I feel calmer after drinking this... Hopefully that feeling lasts.\n(@0xF894B8{Your maximum sanity has permanently been increased})");
	}
	return USEITM_FLAG_CONSUMED | USEITM_FLAG_OPEN_TEXTBOX;
}

/// @description 
///	The function that is executed by the player using a consumable found within their item inventory. When completely healthy, a textbox
/// appears and the function exits with the value *0x00000004* and doesn't consume the item or applies its consumption effects. Otherwise,
/// everything that the consumable does will be applied to the player's various stats (Ex. hitpoints, sanity, etc.).
/// @returns 	{Real}
/// @param 		{Real}	slot	Where the item is located within the player's inventory.
function item_use_consumable(_slot){
	var _itemName = global.curItems[_slot].itemName;
	with(PLAYER){
		// If the player already has maximum health and sanity, as well as not being inflicted with any status conditions, a textbox will 
		// appear preventing the item from being consumed.
		if (curHitpoints == maxHitpoints && curSanity == maxSanity && !PLYR_HAS_AILMENT){
			with(TEXTBOX) { queue_new_text("I should avoid using this until I'm @0x0010BC{actually injured}."); }
			return USEITM_FLAG_OPEN_TEXTBOX;
		}
		
		var _hpHeal		= 0.0;
		var _sanityHeal	= 0.0;
		var _timers		= timers;
		var _flags		= flags;
		with(global.itemData[? _itemName]){
			_hpHeal		= hpHeal;
			_sanityHeal	= sanityHeal;

			// Check to see if the consumable stops the player from being poisoned. Also set the immunity timer for poison if a temporary 
			// immunity is also applied by the item upon consumption.
			if (CNSM_CURES_POISON){
				_flags = _flags & ~PLYR_FLAG_POISONED;
				if (CNSM_GIVES_TMPIMU_POISON)
					_timers[PLYR_POISON_IMMUNE_TIMER] = immuneTime;
			}
			
			// Next, do the same as the code above, but for the "bleeding" status if the item affects that.
			if (CNSM_CURES_BLEED){
				_flags = _flags & ~PLYR_FLAG_BLEEDING;
				if (CNSM_GIVES_TMPIMU_BLEED)
					_timers[PLYR_BLEED_IMMUNE_TIMER] = immuneTime;
			}
			
			// Finally, do the same as the code above, but for the "crippled" status if the item affects that.
			if (CNSM_CURES_CRIPPLE){
				_flags = _flags & ~PLYR_FLAG_CRIPPLED;
				if (CNSM_GIVES_TMPIMU_CRIPPLE)
					_timers[PLYR_CRIPPLE_IMMUNE_TIMER] = immuneTime;
			}
		}
		flags = _flags;
		
		if (_hpHeal > 0.0) // Update HP if the consumable heals the player.
			update_hitpoints(max(1, floor(_hpHeal * maxHitpoints)));
		//if (_sanityHeal > 0.0) // Update sanity level if the consumable restores the player's sanity.
			//update_sanity(max(1, floor(_sanityHeal * maxSanity)));
	}
	return USEITM_FLAG_CONSUMED;
}

/// @description 
/// A general function for using a single key on a door with one or more locks. It checks to see if a door is currently close enough to the
/// player that they can unlock it. If so, the door itself is then checked to see if it has a lock that can be opened by this key. If it does,
/// the door will have that lock opened. Otherwise, various textboxes will appears telling the player why they cannot use the key.
/// @returns 	{Real} 
/// @param 		{Real}	slot		Where the item is located within the player's inventory. 
function item_use_door_key(_slot){
	var _door = noone;
	with(PLAYER){ // Check if the player is actually standing near a door. If not, pop up a textbox to say they can't use the key.
		var _xInteract 	= PLYR_X_INTERACT;
		var _yInteract 	= PLYR_Y_INTERACT;
		_door 			= instance_nearest(_xInteract, _yInteract, obj_door_warp);
		with(_door){
			show_debug_message("Distance: {0}, radius: {1}", point_distance(_xInteract, _yInteract, interactX, interactY), interactRadius);
			if (!DOOR_IS_LOCKED || point_distance(_xInteract, _yInteract, interactX, interactY) > interactRadius){
				with(TEXTBOX) { queue_new_text("There's no reason to use this key right now."); }
				return USEITM_FLAG_OPEN_TEXTBOX;
			}
		}
	}
	
	// Get the name of the key being used (Used when the textbox queues text that contains the item's name) and its ID. That ID value is what
	// is used to see if the door is using a lock that can be opened by the key in question.
	var _itemName 	= MENUITM_DEFAULT_STRING;
	var _itemID 	= ID_INVALID;
	with(global.curItems[_slot]){
		_itemName 	= string_lower(itemName);
		_itemID		= itemID;
	}
	
	// Jump into the door that is being checked. From there, its lock data is looped through to see if the key being used can open any of
	// its available locks. Locks that are already opened are skipped over, but will increment a value that will check if all locks have been
	// opened at the end of the loop.
	with(_door){
		var _keyUsed		= false;
		var _locksOpened 	= 0;
		var _length 		= ds_list_size(lockData);
		for (var i = 0; i < _length; i++){
			with(lockData[| i]){
				// If the lock is already open, increment the _locksOpened value and iterate the loop.
				if (event_get_flag(flagID) == flagState){
					_locksOpened++;
					continue;
				}
				
				// Don't run any of the code for using the key on the door until the key's ID matches one of the door lock's key IDs. The
				// code for using the item is also skipped if another locked already used the key, as one can't be used on two or more locks.
				if (_keyUsed || _itemID != keyID)
					continue;
				event_set_flag(flagID, flagState);
				textbox_queue_used_item(_itemName);
				_keyUsed = true;
				_locksOpened++;
			}
		}
		
		// If the door is unlocked by this key's use, queue up the door's unlock message in the textbox before returning from this function.
		if (_locksOpened == _length){
			var _unlockMessage = unlockMessage;
			with(TEXTBOX) { queue_new_text(_unlockMessage); }
		}
		
		// If the key could not be used on any of the locks on the door in question, queue up a textbox letting the player know that the key
		// isn't meant for this door.
		if (!_keyUsed){
			with(TEXTBOX) { queue_new_text("The @0x0010BC{" + _itemName + "} doesn't work on this door..."); } 
			return USEITM_FLAG_OPEN_TEXTBOX;
		}
	}
	
	return USEITM_FLAG_CONSUMED | USEITM_FLAG_CLOSE_MENU | USEITM_FLAG_OPEN_TEXTBOX;
}

#endregion Functions Utilized By Items When Used