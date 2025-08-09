with(TEXTBOX){
	queue_new_text("THIS IS A @0x7F80FF{TEST TO SEE IF THE TEXTBOX} IS WORKING PROPERLY!!! And also that the new @0x7F80FF{general purpose} text formatting function can properly format a string.", TBOX_ACTOR_PLAYER);
	queue_new_text("IF THIS CAUSES THE @0xFF7C70{TEXTBOX TO REOPEN IT IS NOT WORKING!!!} And @0xACFF00{also if the debug doesn't properly display what is being shown on the textbox something isn't right. Here is some extra text that shouldn't completely be part of the formatted string since it exceeds three lines.", TBOX_ACTOR_PLAYER);
	queue_new_text("@0x7F80FF{IF} THIS DOES IT MEANS IT IS WORKING PROPERLY!!!");
	queue_new_text("I have aids.", TBOX_ACTOR_PLAYER);
	activate_textbox();
}