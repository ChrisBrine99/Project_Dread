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
function item_use_hitpoint_up(){
	with(PLAYER){
		if (maxHitpoints >= PLYR_MAX_POSSIBLE_HITPOINTS)
			return 0; // Player cannot increase their hitpoints any longer. Return 0 so nothing happens on use.
		maxHitpoints += ITEM_HITPOINT_UP_AMOUNT;
		curHitpoints += ITEM_HITPOINT_UP_AMOUNT;
		show_debug_message("Player's maximum hitpoints is now {0}.", maxHitpoints);
	}
	return USEITM_FLAG_CONSUMED;
}

/// @description 
///	Increases the player's maximum stamina by 25 points; capping out at a maximum of 250 regardless of the
/// current difficulty level. Returns 0x00000001 if the item was successfully used.
///	
function item_use_stamina_up(){
	with(PLAYER){
		if (maxStamina >= PLYR_MAX_POSSIBLE_STAMINA)
			return 0; // Player cannot increase their stamina any longer. Return 0 so nothing happens on use.
		maxStamina += ITEM_STAMINA_UP_AMOUNT;
		curStamina = maxStamina; // Completely restore stamina on use.
		show_debug_message("Player's maximum stamina is now {0}.", maxStamina);
	}
	return USEITM_FLAG_CONSUMED;
}

/// @description 
///	Increases the player's maximum sanity level by 25 points; capping out at a maximum of 300 regardless of the
/// current difficulty level. Returns 0x00000001 if the item was successfully used.
///	
function item_use_sanity_up(){
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
/// @param {Struct._structRef}	itemRef		The consumable item that was selected for use by the player.
function item_use_consumable(_itemRef){
	with(TEXTBOX){
		queue_new_text("This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. This is a test.\n(@0xF86040{to see if color formatting isn't bugged here}).");
	}
	return USEITM_FLAG_OPEN_TEXTBOX;
}

/// @description
///	
///	
/// @param {Real}	weaponID	The id for the weapon that is being upgraded.
function item_use_upgrade_parts(_weaponID){
	
}

#endregion Functions Utilized By Items When Used