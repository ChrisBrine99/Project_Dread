if (lightRef != noone) // Update the position of the light source to match the entity's position at the start of the room's existence.
	lightRef.light_set_position(x + xLight, y + yLight);