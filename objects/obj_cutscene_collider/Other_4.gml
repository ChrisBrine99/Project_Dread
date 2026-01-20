// Delete this collider (When allowed to) if the flag it is associated with has been set to the state it 
// requires.
if (!CUTCOL_NEVER_DESTROY && (flagID == EVENT_ID_INVALID || event_get_flag(flagID) == CUTCOL_EVENT_FLAG_STATE))
	instance_destroy(self);