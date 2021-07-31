extends Control

export onready var notification_text setget _set_notification, _get_notification

func _ready():
	data_reader.connect("log_event_generated", self, "_set_notification")

func _set_notification(_value):
	$VBoxContainer/Notifications.text = data_reader.log_event_last
	$NotificationsHistory/NotificationsText.text = data_reader.log_events
	
func _get_notification():
	return $VBoxContainer/Notifications.text


func _on_Notifications_pressed():
	$NotificationsHistory.visible = !$NotificationsHistory.visible
	$VBoxContainer/Notifications.text = data_reader.log_event_last
	$NotificationsHistory/NotificationsText.text = data_reader.log_events
