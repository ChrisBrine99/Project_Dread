// Clean up everything inherited from the parent object.
event_inherited();

// Then, clean up any local structs and dynamic memory allocated throughout the player object's existence.s
delete equipment;