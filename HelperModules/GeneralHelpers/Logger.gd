extends Node
class_name Logger

var log_events : String = ""
var log_event_last : String = ""

signal log_event_generated(log_text)

func log_event(_text):
	log_event_last = _text
	log_events += _text + "\n"
	self.emit_signal("log_event_generated", _text)
	print(log_event_last)
