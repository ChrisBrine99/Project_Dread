// Clear the light source from memory if it happens to be occupied for the Entity in question.
if (lightSource != noone)
	light_destroy(lightSource);