extends VBoxContainer
class_name ButtonsContainer

var query_views : Dictionary setget _set_buttons_array, _get_buttons_array
signal view_button_pressed(_text)

func _set_buttons_array(_query_views):
	if _query_views:
		query_views = _query_views
		for ctl in get_children():
			if ctl is Button:
				remove_child(ctl)
		for view in query_views.keys():
			var new_btn := Button.new()
			var new_btn_spacer := Control.new()
			new_btn.connect("pressed", self, "_on_ViewButton_pressed")
			new_btn.text = view
			add_child(new_btn)
			add_child(new_btn_spacer)
			print("Adding button \"%s\"" % view)
	pass

func _get_buttons_array():
	return query_views

func _ready():
	pass


func _on_ViewButton_pressed():
	var view_name := ""
	for ctl in get_children():
		if ctl is Button:
			if ctl.pressed:
				view_name = ctl.text
	emit_signal("view_button_pressed", view_name)
