tool
extends Panel


export(String) var title setget _set_title, _get_title
export(String, MULTILINE) var body setget _set_body, _get_body


func _set_title(_value):
	if _value is String && $MarginContainer/Panel/VBoxContainer/Title:
		$MarginContainer/Panel/VBoxContainer/Title.text = _value

func _get_title():
	if $MarginContainer/Panel/VBoxContainer/Title:
		return $MarginContainer/Panel/VBoxContainer/Title.text
	else:
		return ""

func _set_body(_value):
	if _value is String && $MarginContainer/Panel/VBoxContainer/DetailsMargin/Body:
		$MarginContainer/Panel/VBoxContainer/DetailsMargin/Body.text = _value

func _get_body():
	if $MarginContainer/Panel/VBoxContainer/DetailsMargin/Body:
		return $MarginContainer/Panel/VBoxContainer/DetailsMargin/Body.text
	else:
		return ""
