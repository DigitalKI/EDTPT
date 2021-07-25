extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/VBoxContainer/BtCMDR.clear()
	for cmdr_id in data_reader.cmdrs.keys():
		$Panel/VBoxContainer/BtCMDR.add_item(data_reader.cmdrs[cmdr_id])


func _on_BtLogs_pressed():
	$TabContainer.current_tab = 0

func _on_BtShips_pressed():
	$TabContainer.current_tab = 1
	$TabContainer/TabShips/Shipyard.initialize_ships_tab()

func _on_BtGalaxy_pressed():
	$TabContainer.current_tab = 2
	data_reader.galaxy_manager.get_all_jumped_systems()
#	$TabContainer/TabsGalaxy/GalaxyMap.initialize_galaxy_map()


func _on_BtCMDR_item_selected(index):
	data_reader.selected_cmdr = $Panel/VBoxContainer/BtCMDR.get_item_text(index)
	$TabContainer/TabLogs/JournalReader._on_DataReader_thread_completed_get_log_objects()

