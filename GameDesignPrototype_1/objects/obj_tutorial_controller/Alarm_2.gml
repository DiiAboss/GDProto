/// @description Bat pickup instruction

var textbox = obj_main_controller.textbox_system;
textbox.QueueMessage("FRIEND", "Now grab that bat!");
textbox.QueueMessage("FRIEND", "Press [E] near it!");
textbox.ShowNextInQueue();