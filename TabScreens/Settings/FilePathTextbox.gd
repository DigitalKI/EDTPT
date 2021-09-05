extends LineEdit

var file_dialog : FileDialog = FileDialog.new()
export(NodePath) var file_dialog_parent_node
signal file_selected

func _on_Button_pressed():
	get_node(file_dialog_parent_node).add_child(file_dialog)
#	get_parent().add_child(file_dialog)
	file_dialog.filters = PoolStringArray(["*.exe ; 7Zip executable"])
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.current_path = text.get_base_dir().trim_prefix("C:")
	file_dialog.current_dir = text.get_base_dir().trim_prefix("C:")
	file_dialog.current_file = text.get_file()
	file_dialog.window_title = "Select the 7-Zip command-line executable"
	file_dialog.connect("file_selected", self, "_on_file_selected")
	file_dialog.anchor_left = 0.5
	file_dialog.anchor_top = 0.5
	file_dialog.anchor_right = 0.5
	file_dialog.anchor_bottom = 0.5
	file_dialog.rect_min_size = Vector2(400, 300)
	file_dialog.margin_left = -file_dialog.rect_min_size.x / 2.0
	file_dialog.margin_top = -file_dialog.rect_min_size.y / 2.0
	file_dialog.show_modal()
	file_dialog.invalidate()

func _on_file_selected(_file):
	text = _file
	emit_signal("file_selected")
