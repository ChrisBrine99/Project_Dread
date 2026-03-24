#region Macros Utilized When Certain Items Are Used

// Macros that are returned by functions that are called upon a given item's usage by the player. Depending
// on what bits here are set, the game can take action to ensure the proper process occurs as a result.
#macro	USEITM_FLAG_CONSUMED			0x00000001
#macro	USEITM_FLAG_CLOSE_MENU			0x00000002
#macro	USEITM_FLAG_OPEN_TEXTBOX		0x00000004

// The amounts to increase each of the player's main values when their respective item for increasing those
// maximum is used by them during gameplay.
#macro	ITEM_HITPOINT_UP_AMOUNT			10
#macro	ITEM_STAMINA_UP_AMOUNT			25
#macro	ITEM_SANITY_UP_AMOUNT			25

#endregion Macros Utilized When Certain Items Are Used

#region Functions Utilized By Items When Used

/// @description 
///	Increases the player's maximum hitpoints by 10 points; capping out at a maximum of 150 regardless of the
/// current difficulty level. Returns 0x00000001 if the item was successfully used.
///	
/// @param {Real}	slot	(Unused) Where the item is located within the player's inventory.
function item_use_hitpoint_up(_slot){
	with(PLAYER){
		if (maxHitpoints >= PLYR_MAX_POSSIBLE_HITPOINTS)
			return 0; // Player cannot increase their hitpoints any longer. Return 0 so nothing happens on use.
		maxHitpoints += ITEM_HITPOINT_UP_AMOUNT;
		curHitpoints += ITEM_HITPOINT_UP_AMOUNT;
	}
	with(TEXTBOX){ // Flavor text informing the player that their health has been increased.
		queue_new_text("Hmm... I feel like I'll be able to take another hit or two after drinking this... What the hell is it made with?\n(@0xF87C58{Your maximum health has permanently been increased})");
	}
	return USEITM_FLAG_CONSUMED | USEITM_FLAG_OPEN_TEXTBOX;
}

/// @description 
///	Increases the player's maximum stamina by 25 points; capping out at a maximum of 250 regardless of the
/// current difficulty level. Returns 0x00000001 if the item was successfully used.
///	
/// @param {Real}	slot	(Unused) Where the item is located within the player's inventory.
function item_use_stamina_up(_slot){
	with(PLAYER){
		if (maxStamina >= PLYR_MAX_POSSIBLE_STAMINA)
			return 0; // Player cannot increase their stamina any longer. Return 0 so nothing happens on use.
		maxStamina += ITEM_STAMINA_UP_AMOUNT;
		curStamina = maxStamina; // Completely restore stamina on use.
	}
	with(TEXTBOX){ // Flavor text informing the player that their stamina has been increased.
		queue_new_text("Huh... I feel like I have a bit more energy than I did before; guess it really did what it says on the label...\n(@0xF87C58{Your maximum stamina has permanently been increased})");
	}
	return USEITM_FLAG_CONSUMED | USEITM_FLAG_OPEN_TEXTBOX;
}

/// @description 
///	Increases the player's maximum sanity level by 25 points; capping out at a maximum of 300 regardless of the
/// current difficulty level. Returns 0x00000001 if the item was successfully used.
///	
/// @param {Real}	slot	(Unused) Where the item is located within the player's inventory.
function item_use_sanity_up(_slot){
	with(PLAYER){
		if (maxSanity >= PLYR_MAX_POSSIBLE_SANITY)
			return 0; // Player cannot increase their sanity level any longer. Return 0 so nothing happens on use.
		maxSanity += ITEM_SANITY_UP_AMOUNT;
		show_debug_message("Player's maximum sanity is now {0}.", maxSanity);
	}
	return USEITM_FLAG_CONSUMED;
}

/// @description 
///	
/// 
/// @param {Real}	slot	Where the item is located within the player's inventory.
function item_use_consumable(_slot){
	var _itemName = global.curItems[_slot].itemName;
	with(PLAYER){
		var _hpHeal			= 0.0;
		var _sanityHeal		= 0.0;
		var _timers			= timers;
		var _flags			= flags;
		with(global.itemData[? _itemName]){
			_hpHeal			= hpHeal;
			_sanityHeal		= sanityHeal;

			// Check to see if the consumable stops the player from being poisoned. Also set the immunity timer
			// for poison if a temporary immunity is also applied by the item upon consumption.
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
///	
///	
/// @param {Real}	slot	Where the item is located within the player's inventory.
function item_use_upgrade_parts(_slot){
	
}

#endregion Functions Utilized By Items When Used