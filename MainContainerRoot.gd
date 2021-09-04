extends Control

export onready var notification_text setget _set_notification, _get_notification

func _ready():
	data_reader.connect("new_cached_events", self, "_on_DataReader_new_cached_events")
	logger.connect("log_event_generated", self, "_set_notification")
	$VBoxContainer/Notifications.text = logger.log_event_last
	$NotificationsHistory/NotificationsText.text = logger.log_events
	$VBoxContainer/MainContainer/TabContainer/TabLogs/JournalReader.initialize_journal_reader()

func _set_notification(_value):
	$VBoxContainer/Notifications.text = logger.log_event_last
	$NotificationsHistory/NotificationsText.text = logger.log_events
	
func _get_notification():
	return $VBoxContainer/Notifications.text


func _on_Notifications_button_down():
	$VBoxContainer/Notifications.text = logger.log_event_last
	$NotificationsHistory/NotificationsText.text = logger.log_events
	$NotificationsHistory.visible = !$NotificationsHistory.visible

func _on_Notifications_pressed():
	var lines = $NotificationsHistory/NotificationsText.get_line_count()
	$NotificationsHistory/NotificationsText.scroll_vertical = lines

func _on_BtLogs_pressed():
	$VBoxContainer/MainContainer/TabContainer.current_tab = 0
	$VBoxContainer/MainContainer/TabContainer/TabLogs/JournalReader.initialize_journal_reader()

func _on_BtShips_pressed():
	$VBoxContainer/MainContainer/TabContainer.current_tab = 1
	$VBoxContainer/MainContainer/TabContainer/TabShips/Shipyard.initialize_ships_tab()

func _on_BtGalaxy_pressed():
	$VBoxContainer/MainContainer/TabContainer.current_tab = 2
	$VBoxContainer/MainContainer/TabContainer/TabsGalaxy/GalaxyMap.initialize_galaxy_map()

func _on_BbtSettings_pressed():
	$VBoxContainer/MainContainer/TabContainer.current_tab = 3
	$VBoxContainer/MainContainer/TabContainer/TabsGalaxy/GalaxyMap.initialize_galaxy_map()

func _on_BtCMDR_item_selected(index):
	data_reader.selected_cmdr = $VBoxContainer/MainContainer/Panel/VBoxContainer/BtCMDR.get_item_text(index)
#	$VBoxContainer/MainContainer/TabContainer/TabLogs/JournalReader._on_DataReader_new_cached_events()

func _on_DataReader_new_cached_events(_evts):
	$VBoxContainer/MainContainer/Panel/VBoxContainer/BtLogs.disabled = false
	$VBoxContainer/MainContainer/Panel/VBoxContainer/BtShips.disabled = false
	$VBoxContainer/MainContainer/Panel/VBoxContainer/BtGalaxy.disabled = false
	fill_cmdrs_listbox()


func fill_cmdrs_listbox():
	$VBoxContainer/MainContainer/Panel/VBoxContainer/BtCMDR.clear()
	for cmdr_id in data_reader.cmdrs.keys():
		$VBoxContainer/MainContainer/Panel/VBoxContainer/BtCMDR.add_item(data_reader.cmdrs[cmdr_id])

