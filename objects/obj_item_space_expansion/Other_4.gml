// Check if the relevant event flag has been set. If so, the player has already picked up this item inventory
// expansion and it should no longer spawn in. It also destroys itself if the flag is an invalid ID.
if (flagID == ID_INVALID || event_get_flag(flagID))
	instance_destroy(id);