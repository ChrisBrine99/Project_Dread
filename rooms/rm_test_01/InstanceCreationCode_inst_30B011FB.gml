var _setNextIndex = TEXTBOX.set_next_index;
var _setEventFlag = TEXTBOX.set_event_flag;
var _queueTextbox = SCENE_QUEUE_TEXTBOX;

ds_list_add(actionQueue, 
	[SCENE_WAIT, 60.0],
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
		[SCENE_MOVE_ENTITY, PLAYER, 200, 150, 1.0],
	]],
	[SCENE_ACTIVATE_TEXTBOX],
	[SCENE_WAIT_CONCURRENT, 20.0],
	[SCENE_MOVE_CAMERA, 200, 150, 0.25],
	[SCENE_WAIT_TEXTBOX, 20.0]
);