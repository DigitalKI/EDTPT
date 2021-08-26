extends LineEdit
signal SearchItemSelected(id)

func _on_Search_text_changed(new_text):
	if new_text.length() > 2:
		$PopupMenuFound.clear()
		$PopupMenuFound.rect_size.y = 20
		for idx in range(data_reader.galaxy_manager.star_systems.size()):
			var system = data_reader.galaxy_manager.star_systems[idx]
			if system["StarSystem"].to_upper().find(new_text.to_upper()) > -1 && $PopupMenuFound.get_item_count() < 11:
				$PopupMenuFound.add_item(system["StarSystem"], idx)
		if $PopupMenuFound.get_item_count() > 0:
			$PopupMenuFound.rect_size.x = $PopupMenuFound.get_parent().rect_size.x
			$PopupMenuFound.set_position(Vector2($PopupMenuFound.get_parent().rect_global_position.x, $PopupMenuFound.get_parent().rect_size.y + 16))
			$PopupMenuFound.popup()
			self.grab_focus()

func _on_Search_text_entered(new_text):
	if $PopupMenuFound.get_item_count() == 1:
		emit_signal("SearchItemSelected", $PopupMenuFound.get_item_id(0))
		$PopupMenuFound.hide()
		find_prev_valid_focus().grab_focus()

func _on_PopupMenuFound_id_pressed(id):
	emit_signal("SearchItemSelected", id)

