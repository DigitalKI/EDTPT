extends Control

export onready var notification_text setget _set_notification, _get_notification

func _ready():
	data_reader.connect("log_event_generated", self, "_set_notification")
	$VBoxContainer/Notifications.text = data_reader.log_event_last
	$NotificationsHistory/NotificationsText.text = data_reader.log_events

func _set_notification(_value):
	$VBoxContainer/Notifications.text = data_reader.log_event_last
	$NotificationsHistory/NotificationsText.text = data_reader.log_events
	
func _get_notification():
	return $VBoxContainer/Notifications.text


func _on_Notifications_button_down():
	$VBoxContainer/Notifications.text = data_reader.log_event_last
	$NotificationsHistory/NotificationsText.text = data_reader.log_events
	$NotificationsHistory.visible = !$NotificationsHistory.visible

func _on_Notifications_pressed():
	var lines = $NotificationsHistory/NotificationsText.get_line_count()
	$NotificationsHistory/NotificationsText.scroll_vertical = lines
