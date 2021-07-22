extends Control
class_name JournalEvent

export(String) onready var event_text setget _set_event_text, _get_event_text
export(String) onready var event_type setget _set_event_type, _get_event_type
export(String) onready var event_time setget _set_event_time, _get_event_time

var date : DateTime

func _set_event_text(_value):
	$BoxContainer/EventDescription.text = _value

func _get_event_text():
	return $BoxContainer/EventDescription.text

func _set_event_type(_value):
	$BoxContainer/EventType.text = _value

func _get_event_type():
	return $BoxContainer/EventType.text

func _set_event_time(_value):
	var date : DateTime
	date = DateTime.new(_value)
	$BoxContainer/EventTime.text = date.to_string()

func _get_event_time():
	return date.to_string()
