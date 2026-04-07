set_warp_params(200, 56, rm_test_01);
set_facing_direction(DOOR_FLAG_SOUTHBOUND);

add_lock(ITEM_TEST_DOOR_KEY, 0, true);
add_lock(ITEM_TEST_DOOR_KEY, 1, true);
add_lock(ITEM_TEST_DOOR_KEY, 2, true);

textboxMessage	= "The door is locked with what looks to be three keys... I'll have to find them all if I want to get it open.";
semiLockMessage = "I still need the remaining keys if I want to get inside.";
unlockMessage	= "Looks like the door is finally unlocked. I wonder what they needed so much security for... Were they keeping people out, or something inside...?";