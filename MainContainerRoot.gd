extends Control

export onready var notification_text setget _set_notification, _get_notification

func _set_notification(_value):
	$VBoxContainer/Notifications.text = _value
	
func _get_notification():
	return $VBoxContainer/Notifications.text
