tool
extends Panel
class_name DetailsWindow
onready var title_label : Label = $MarginContainer/Panel/VBoxContainer/Title
onready var body_text : RichTextLabel = $MarginContainer/Panel/VBoxContainer/DetailsMargin/BodyContent/Body
onready var body_content : VBoxContainer = $MarginContainer/Panel/VBoxContainer/DetailsMargin/BodyContent
onready var table : Tree = $MarginContainer/Panel/VBoxContainer/DetailsMargin/BodyContent/Tree

export(String) var title setget _set_title, _get_title
export(String, MULTILINE) var body setget _set_body, _get_body
export(Dictionary) var data setget _set_data


func _set_title(_value):
	if is_inside_tree() && _value is String && title_label:
		title_label.text = _value

func _get_title():
	if is_inside_tree() && title_label:
		return title_label.text
	else:
		return ""

func _set_body(_value):
	if is_inside_tree() && _value is String && body_text:
		body_text.text = _value

func _get_body():
	if is_inside_tree() && body_text:
		return body_text.text
	else:
		return ""

func _set_data(_value):
	if table:
		table.clear()
		data = _value
		var body_text :String = ""
		if _value is Dictionary:
			TreeHelper.var_to_table(table, title, _value)
			_set_body(body_text)

func _on_Title_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			OS.clipboard = title_label.text
