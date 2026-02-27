#region Macros Utilized When Certain Items Are Used

// The amounts to increase each of the player's main values when their respective item for increasing those
// maximum is used by them during gameplay.
#macro	ITEM_HITPOINT_UP_AMOUNT			10
#macro	ITEM_STAMINA_UP_AMOUNT			25
#macro	ITEM_SANITY_UP_AMOUNT			25

#endregion Macros Utilized When Certain Items Are Used

#region Functions Utilized By Items When Used

/// @description 
///	Increases the player's maximum hitpoints by 10 points; capping out at a maximum of 150 regardless of the
/// current difficulty level. Returns true if the item was successfully used.
///	
function item_use_hitpoint_up(){
	with(PLAYER){
		if (maxHitpoints >= PLYR_MAX_POSSIBLE_HITPOINTS)
			return false; // Player cannot increase their hitpoints any longer. Return false so item isn't used.
		maxHitpoints += ITEM_HITPOINT_UP_AMOUNT;
		curHitpoints += ITEM_HITPOINT_UP_AMOUNT;
		show_debug_message("Player's maximum hitpoints is now {0}.", maxHitpoints);
	}
	return true;
}

/// @description 
///	Increases the player's maximum stamina by 25 points; capping out at a maximum of 250 regardless of the
/// current difficulty level. Returns true if the item was successfully used.
///	
function item_use_stamina_up(){
	with(PLAYER){
		if (maxStamina >= PLYR_MAX_POSSIBLE_STAMINA)
			return false; // Player cannot increase their stamina any longer. Return false so item isn't used.
		maxStamina += ITEM_STAMINA_UP_AMOUNT;
		curStamina = maxStamina; // Completely restore stamina on use.
		show_debug_message("Player's maximum stamina is now {0}.", maxStamina);
	}
	return true;
}

/// @description 
///	Increases the player's maximum sanity level by 25 points; capping out at a maximum of 300 regardless of the
/// current difficulty level. Returns true if the item was successfully used.
///	
function item_use_sanity_up(){
	with(PLAYER){
		if (maxSanity >= PLYR_MAX_POSSIBLE_SANITY)
			return false; // Player cannot increase their sanity level any longer. Return false so item isn't used.
		maxSanity += ITEM_SANITY_UP_AMOUNT;
		show_debug_message("Player's maximum sanity is now {0}.", maxSanity);
	}
	return true;
}

/// @description 
///	
/// 
/// @param {Struct._structRef}	itemRef		The consumable item that was selected for use by the player.
function item_use_consumable(_itemRef){
	return true;
}

#endregion Functions Utilized By Items When Used