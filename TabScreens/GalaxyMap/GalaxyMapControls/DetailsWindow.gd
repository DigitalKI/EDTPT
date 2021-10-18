tool
extends Panel
class_name DetailsWindow
onready var title_label : Label = $MarginContainer/Panel/VBoxContainer/Title
onready var body_text : RichTextLabel = $MarginContainer/Panel/VBoxContainer/DetailsMargin/ScrollContainer/BodyContent/Body
onready var body_content : VBoxContainer = $MarginContainer/Panel/VBoxContainer/DetailsMargin/ScrollContainer/BodyContent


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
	data = _value
	if is_inside_tree():
		for cld in body_content.get_children():
			if cld is Tree:
				cld.queue_free()
		var body_text :String = ""
		if _value is Dictionary:
			for key in _value.keys():
				if _value[key] is String && (_value[key].begins_with("[") || _value[key].begins_with("{")):
					_value[key] = parse_json(_value[key])
				if _value[key] is String:
					body_text += "\n%s: %s" % [key, _value[key]]
				elif _value[key] is Dictionary || _value[key] is Array:
					var table : Tree = Tree.new()
					table.rect_min_size = Vector2(10, 100)
					table.size_flags_horizontal += SIZE_EXPAND
					body_content.add_child(table)
					TreeHelper.var_to_table(table, key, _value[key])
		_set_body(body_text)

func _on_Title_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			OS.clipboard = title_label.text
