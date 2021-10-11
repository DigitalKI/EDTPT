tool
extends Button
class_name ExplorationModeToggle
export(String, MULTILINE) var button_text setget _set_button_text, _get_button_text

func _set_button_text(_value):
	$ExpContainer/Label.text = _value

func _get_button_text():
	return $ExpContainer/Label.text

func _on_Exploration_toggled(button_pressed):
	if button_pressed:
		$ExpContainer/LabelOnOff.text = "On"
	else:
		$ExpContainer/LabelOnOff.text = "Off"
