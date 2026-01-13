var _setNextIndex = TEXTBOX.set_next_index;
var _setEventFlag = TEXTBOX.set_event_flag;
var _queueTextbox = SCENE_QUEUE_TEXTBOX;

ds_list_add(actionQueue, 
	[SCENE_CONCURRENT_ACTIONS, [
		[_queueTextbox, "Test to see if the textbox can be queued by a cutscene."],
		[_queueTextbox, "One more textbox to see if actions can be queued up and executed concurrently."],
		[_queueTextbox, "This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. This is a test.\n(@0xF86040{to see if color formatting isn't bugged here})."],
		[SCENE_QUEUE_TEXTBOX_EXT, 
			"One more textbox because why not.", [
				"TEST OPTION 1", 
				"TEST OPTION 2",
				"TEST OPTION 3",
			], [
				[ // TEST OPTION 1
					_setNextIndex, TBOX_INDEX_CLOSE
				],
				[ // TEST OPTION 2
					_setNextIndex, 0
				],
				[ // TEXT OPTION 3
					_setEventFlag, 2, true,
					_setEventFlag, 3, true
				]
			]
		],
		[SCENE_MOVE_ENTITY, PLAYER, 200, 150, 0.25],
	]],
	[SCENE_ACTIVATE_TEXTBOX],
	[SCENE_WAIT_CONCURRENT, 20.0],
	[SCENE_MOVE_CAMERA, 200, 150, 0.25],
	[SCENE_WAIT_TEXTBOX, 20.0]
);

/*with(TEXTBOX){
	queue_new_text("This is a test to see if the textbox can still function when it is formatting or parsing text on-the-fly as required.");
	queue_new_text("Instead of having to format everything at once whenever a new string is queued for display.");
	queue_new_text("This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. This is a test. This is a test.\n(@0xF86040{to see if color formatting isn't bugged here}).");
	add_options(
		queue_new_text("One more textbox because why not."),[
			"TEST OPTION 1", 
			"TEST OPTION 2",
			"TEST OPTION 3",
		], [
			[ // TEST OPTION 1
				set_next_index, TBOX_INDEX_CLOSE
			],
			[ // TEST OPTION 2
				set_next_index, 0
			],
			[ // TEXT OPTION 3
				set_event_flag, 2, true,
				set_event_flag, 3, true
			]
		]
	);
	queue_new_text("This is a test to see if the nextIndex value can be updated on-the-fly depending on player choice.");
	activate_textbox();
}*/