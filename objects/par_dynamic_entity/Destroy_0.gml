// Clear the light source from memory if it happens to be occupied for the Entity in question.
if (lightRef != noone)
	light_destroy(lightRef);