extends Control

var mouse_left_pressed : = false
var mouse_middle_pressed : = false
var mouse_right_pressed : = false
var rl_pressed := false
var fb_pressed := false
var view_mode := "Galaxy"
onready var galaxy : GalaxyCenter = $GalaxyMapView/Viewport/GalaxyCenter
onready var details : DetailsWindow = $HBoxContainer/GalaxyContainer/SystemDetails
onready var navlabel : Label = $HBoxContainer/GalaxyContainer/LabelNav
onready var search_text : LineEdit = $HBoxContainer/GalaxyContainer/Search
onready var found_stars : PopupMenu = $HBoxContainer/GalaxyContainer/Search/PopupMenuFound
var zoom_speed = 0.15
var rotation_speed = 0.02
var movement_speed = 0.03
var relative_mov : Vector3 = Vector3()
var galaxy_plane = Plane(Vector3(0, 1, 0), 0)


# Called when the node enters the scene tree for the first time.
func _ready():
	details.visible = false
	# Sorry EDSM, I'm going to bother you more than I should
	data_reader.edsm_manager.connect("systems_received", self, "_on_edsm_manager_systems_received")
	pass

func _on_GalaxyMap_gui_input(event):
	if event is InputEventMouseButton:
		pause_unpause_game()
		if event.button_index == BUTTON_LEFT:
			mouse_left_pressed =  event.pressed
			$HBoxContainer/LeftButtonsContainer/BtGalaxy.grab_focus()
			if !event.pressed:
				galaxy.camera_rotation.transform = galaxy.camera_rotation.transform.orthonormalized()
			if event.doubleclick:
				get_clicked_star()
		if event.button_index == BUTTON_MIDDLE:
			mouse_middle_pressed =  event.pressed
		if event.button_index == BUTTON_RIGHT:
			mouse_right_pressed =  event.pressed
		if event.button_index == BUTTON_WHEEL_UP:
			if galaxy.camera.translation.z >= 10:
				galaxy.zoom(- zoom_speed)
		if event.button_index == BUTTON_WHEEL_DOWN:
			if galaxy.camera.translation.z < 100000:
				galaxy.zoom(zoom_speed)
		update_navlabel()
	elif event is InputEventMouseMotion:
		if mouse_left_pressed:
			pause_unpause_game()
			galaxy.camera_rotation.rotation_degrees.y += event.speed.x * rotation_speed
			galaxy.camera_rotation.rotation_degrees.x += event.speed.y * rotation_speed
			update_navlabel()

func _unhandled_input(event):
	if event is InputEventKey:
		pause_unpause_game()
		# Allow to move left or right
		if OS.get_scancode_string(event.scancode) == "A" && event.pressed:
			fb_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "x", false)
			details.visible = false
		elif OS.get_scancode_string(event.scancode) == "D" && event.pressed:
			fb_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "x", true)
			details.visible = false
			
		# Allow to move forward or backward
		if OS.get_scancode_string(event.scancode) == "W" && event.pressed:
			rl_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "z", false)
			details.visible = false
		elif OS.get_scancode_string(event.scancode) == "S" && event.pressed:
			rl_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "z", true)
			details.visible = false
		# Allow to move up or down relative to the alaxy plane
		if OS.get_scancode_string(event.scancode) == "R" && event.pressed:
			galaxy.plane_movement(movement_speed)
			details.visible = false
		elif OS.get_scancode_string(event.scancode) == "F" && event.pressed:
			galaxy.plane_movement(-movement_speed)
			details.visible = false
		update_navlabel()

func _on_BtMining_pressed():
	view_mode = "Mining"
	data_reader.galaxy_manager.get_systems_by_rings()
	galaxy.spawn_stars(data_reader.galaxy_manager.star_systems, "Rings", 4, Color(0.0, 0.1, 0.5), Color(0.28, 1.0, 0.0))
	update_navlabel()

func _on_BtGalaxy_pressed():
	data_reader.galaxy_manager.get_systems_by_visits()
	view_mode = "Galaxy"
	galaxy.spawn_stars(data_reader.galaxy_manager.star_systems, "Visits", 100, Color(0.4, 0.1, 0.1), Color(1.0, 0.87, 0.4))
	update_navlabel()

func _on_BtEDSM_pressed():
	data_reader.edsm_manager.get_systems_in_cube(galaxy.camera_center.global_transform.origin, 70)

func _on_PopupMenuFound_id_pressed(id):
	var starpos := galaxy.stars_multimesh.multimesh.get_instance_transform(id).origin
	set_selected_star(id, starpos)
#	found_stars.visible = false

func _on_Timer_timeout():
	pause_unpause_game(true)
	$Timer.stop()

func _on_edsm_manager_systems_received():
	galaxy.spawn_edsm_stars(data_reader.edsm_manager.star_systems, "bodyCount", 100, Color(0.1, 0.1, 0.1), Color(0.9, 0.9, 0.9))
	$Timer.stop()

func pause_unpause_game(_pause : bool = false):
	if _pause:
		$GalaxyMapView/Viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	else:
		$GalaxyMapView/Viewport.render_target_update_mode = Viewport.UPDATE_WHEN_VISIBLE
		$Timer.start(1)
#	print("Game %s" % "Paused" if _pause else "Unpaused")

func initialize_galaxy_map():
	_on_BtGalaxy_pressed()

func update_navlabel():
	var pos = galaxy.camera_center.global_transform.origin
	var zoom = galaxy.camera.translation.z
	navlabel.text = "%s view - Pos: %s/%s/%s-%s" % [view_mode, pos.x, pos.y, pos.z, zoom]

func get_clicked_star():
	var mouse_pos = self.get_local_mouse_position()
	var close_stars : Array = galaxy.get_stars_closer_than(mouse_pos, 20)
	var distance_to_camera := 99999.9999
	var closest_star_idx = -1
	var closest_star_pos : Vector3
	for star_idx in close_stars:
		var starpos := galaxy.stars_multimesh.multimesh.get_instance_transform(star_idx).origin
		if  starpos.distance_to(galaxy.camera.global_transform.origin) < distance_to_camera:
			distance_to_camera = starpos.distance_to(galaxy.camera.global_transform.origin)
			closest_star_idx = star_idx
			closest_star_pos = starpos
	set_selected_star(closest_star_idx, closest_star_pos)

func set_selected_star(_star_idx, _star_pos):
	if _star_idx >= 0:
		details.title = ""
		details.body = ""
		var found_star : Dictionary = data_reader.galaxy_manager.star_systems[_star_idx]
		if found_star.has("StarSystem"):
			details.title += found_star["StarSystem"]
			details.body += "Last Visit: %s\n" % data_reader.get_value(found_star["timestamp"])
			if found_star.has("Visits"):
				details.body += "Visits: %s\n" % data_reader.get_value(found_star["Visits"])
			if found_star.has("Rings"):
				details.body += "Rings: %s\n" % data_reader.get_value(found_star["Rings"])
			details.body += "Population: %s \n" % data_reader.get_value(found_star["Population"])
			details.body += "Allegiance: %s \n" % data_reader.get_value(found_star["SystemAllegiance"])
			details.body += "Economy: %s \n" % (found_star["SystemEconomy_Localised"] + ", " + found_star["SystemSecondEconomy_Localised"])
			details.body += "Government: %s\n" % data_reader.get_value(found_star["SystemGovernment_Localised"])
			details.body += "Security: %s\n" % data_reader.get_value(found_star["SystemSecurity_Localised"])
		
		var prospected_asteroids_events = []
		if found_star.has("SystemAddress"):
			prospected_asteroids_events = data_reader.galaxy_manager.get_events_per_location(String(found_star["SystemAddress"]), -1, ["ProspectedAsteroid"])
			details.body += "\n-------------\n"
			var all_events_per_location := {}
			for events_loc in prospected_asteroids_events:
				if !all_events_per_location.has(events_loc["BodyID"]):
					all_events_per_location[events_loc["BodyID"]] = {"Body": events_loc["Body"], "Events_Materials": {}}
				for event in events_loc["local_events"]:
					if event["Remaining"] == 100:
						var materials_json = parse_json(event["Materials"])
						for mat in materials_json:
							if !all_events_per_location[events_loc["BodyID"]]["Events_Materials"].has(mat["Name"]):
								all_events_per_location[events_loc["BodyID"]]["Events_Materials"][mat["Name"]] = {"Name": mat["Name"], "total": 0, "count" : 0}
							
							all_events_per_location[events_loc["BodyID"]]["Events_Materials"][mat["Name"]]["total"] += mat["Proportion"]
							all_events_per_location[events_loc["BodyID"]]["Events_Materials"][mat["Name"]]["count"] += 1
			
			for body_id in all_events_per_location:
				var location = all_events_per_location[body_id]["Body"]
				var location_events = all_events_per_location[body_id]["Events_Materials"].values()
				data_reader.sort_by_key(location_events, "total")
				if location_events:
					details.body += "\n%s\n" % location
					data_reader.sort_by_key(location_events, "total")
					for mat in location_events:
						if mat["count"] > 0:
							details.body += "%s (%s): %.2f%%\n" % [mat["Name"], mat["count"], (mat["total"] / mat["count"])]
		details.visible = true
		galaxy.camera_move_to(_star_pos)

func _on_Search_text_changed(new_text):
	if new_text.length() > 2:
		found_stars.clear()
		found_stars.rect_size.y = 20
		for idx in range(data_reader.galaxy_manager.star_systems.size()):
			var system = data_reader.galaxy_manager.star_systems[idx]
			if system["StarSystem"].to_upper().find(new_text.to_upper()) > -1 && found_stars.get_item_count() < 11:
				found_stars.add_item(system["StarSystem"], idx)
		if found_stars.get_item_count() > 0:
			found_stars.rect_size.x = found_stars.get_parent().rect_size.x
			found_stars.set_position(Vector2(found_stars.get_parent().rect_global_position.x, found_stars.get_parent().rect_size.y + 16))
			found_stars.popup()
			search_text.grab_focus()

