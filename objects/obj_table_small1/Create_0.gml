// Simply inherit the parent's create event and then toggle the Entity to be visible and active.
event_inherited();
flags		= ENTT_FLAG_VISIBLE | ENTT_FLAG_ACTIVE;
interactY	= y - 2;