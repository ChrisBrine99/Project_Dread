// Delete this collider if the flag it is associated with has been set to the state it requires.
if (flagID == EVENT_ID_INVALID || event_get_flag(flagID) == flagState)
	instance_destroy(self);