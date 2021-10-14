extends Control

var mouse_left_pressed : = false
var mouse_middle_pressed : = false
var mouse_right_pressed : = false
var rl_pressed := false
var fb_pressed := false
var view_mode := "Galaxy"
var current_view_settings : Array = []
onready var galaxy : GalaxyCenter = $GalaxyMapView/Viewport/GalaxyCenter
onready var details : DetailsWindow = $HBoxContainer/GalaxyContainer/UpperGalaxyContainer/SystemDetails
onready var table : FloatingTable = $HBoxContainer/GalaxyContainer/UpperGalaxyContainer/FloatingTable
onready var navlabel : Label = $HBoxContainer/GalaxyContainer/LabelNav
onready var right_buttons_container : ButtonsContainer = $HBoxContainer/RightButtonsContainer
onready var exploration_mode : ExplorationModeToggle = $HBoxContainer/LeftButtonsContainer/Exploration
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
	data_reader.connect("new_cached_events", self, "_on_DataReader_new_cached_events")
	table.visible = false
	details.visible = false
	right_buttons_container.query_views = data_reader.settings_manager.get_setting("query_views")

	if data_reader.settings_manager.get_setting("GalaxyPlaneOnOff") != null:
		galaxy.GalaxyPlaneOnOff(data_reader.settings_manager.get_setting("GalaxyPlaneOnOff"))
	if data_reader.settings_manager.get_setting("GalaxyParticlesPlaneOnOff") != null:
		galaxy.GalaxyParticlesPlaneOnOff(data_reader.settings_manager.get_setting("GalaxyParticlesPlaneOnOff"))

func _exit_tree():
	save_pos_and_zoom()

func _on_GalaxyMap_visibility_changed():
	right_buttons_container.query_views = data_reader.settings_manager.get_setting("query_views")
	if !is_visible_in_tree() :
		save_pos_and_zoom()

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
			galaxy.zoom(- zoom_speed)
		if event.button_index == BUTTON_WHEEL_DOWN:
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
			table.visible = false
		elif OS.get_scancode_string(event.scancode) == "D" && event.pressed:
			fb_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "x", true)
			details.visible = false
			table.visible = false
			
		# Allow to move forward or backward
		if OS.get_scancode_string(event.scancode) == "W" && event.pressed:
			rl_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "z", false)
			details.visible = false
			table.visible = false
		elif OS.get_scancode_string(event.scancode) == "S" && event.pressed:
			rl_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "z", true)
			details.visible = false
			table.visible = false
		# Allow to move up or down relative to the alaxy plane
		if OS.get_scancode_string(event.scancode) == "R" && event.pressed:
			galaxy.plane_movement(movement_speed)
			details.visible = false
			table.visible = false
		elif OS.get_scancode_string(event.scancode) == "F" && event.pressed:
			galaxy.plane_movement(-movement_speed)
			details.visible = false
			table.visible = false
		update_navlabel()

func _on_Exploration_toggled(button_pressed):
	# this could be used to show just the latest jumps, or all of them.
	# doubleclicked a system could provide last events on the same system
	pass # Replace with function body.

func _on_BtMining_pressed():
	view_mode = "Mining"
	current_view_settings = [{"address": ["RingsAmount"]
	, "size_scales":{"min": 0, "max": 15, "min_scale": 0.5, "max_scale": 4}
	, "is_array": false},
	{"address": ["RingsAmount"]
	, "color_scales":{"min": 1, "max": 15, "min_scale": Color(0.0,0.1,0.8), "max_scale": Color(0.0,0.6,0.6)}
	, "is_array": false},
	{"address": ["Ringed"]
	, "color_matrix": {"0": Color(0.0,0.0,1.0)}
	, "is_array": false}
	,{"address": ["prospected"]
	, "color_matrix":{"True": Color(1.0,1.0,1.0)}
	, "is_array": false}]
	galaxy.spawn_sector_stars(data_reader.galaxy_manager.get_systems_by_rings(), current_view_settings, Color(0.0,0.0,1.0))
	update_navlabel()
	pause_unpause_game()

func _on_BtGalaxy_pressed():
	view_mode = "Galaxy"
	current_view_settings = [
	{"address": ["SystemEconomy"]
	, "color_matrix": {"$economy_Refinery;": Color(1.0,0.0,0.0)
					, "$economy_HighTech;": Color(0.0,0.0,1.0)
					, "$economy_Agri;": Color(0.0,1.0,0.0)}
	, "is_array": false}
	,{"address": ["Visits"]
	, "color_matrix":{"0": Color(0.5,0.5,0.0)}
	, "is_array": false}
	,{"address": ["Visits"]
	, "size_scales":{"min": 1, "max": 150, "min_scale": 0.5, "max_scale": 6}
	, "is_array": false}]
	galaxy.spawn_sector_stars(data_reader.galaxy_manager.get_systems_by_visits(), current_view_settings)
#	galaxy.spawn_stars(data_reader.galaxy_manager.star_systems, "Visits", 100, Color(0.4, 0.1, 0.1), Color(1.0, 0.87, 0.4))
	update_navlabel()
	pause_unpause_game()

func _on_DataReader_new_cached_events(_events: Array):
	if exploration_mode.pressed:
		for evt in _events:
			if "FSDJump" == evt["event"]:
				var new_pos : Vector3 = DataConverter.get_position_vector(evt["StarPos"])
				galaxy.add_single_star(evt, current_view_settings)
				camera_move(new_pos, galaxy.camera.translation.z)

var sector_x = -1
var sector_y = -1
var sector_z = -1
func _on_BtEDSM_pressed():
#	data_reader.edsm_manager.get_systems_by_sector(Vector3(sector_x, sector_y, sector_z))
#	data_reader.edsm_manager.get_systems_in_db(["*"], data_reader.edsm_manager.get_systems_cube_array(Vector3(), 0), true)
#	data_reader.edsm_manager.get_systems_in_cubes_radius(Vector3(), 1)
	pause_unpause_game()

func _on_Bt2dOverlay_pressed():
	data_reader.settings_manager.save_setting("GalaxyPlaneOnOff", galaxy.GalaxyPlaneOnOff())
	pause_unpause_game()

func _on_Bt3dOverlay_pressed():
	data_reader.settings_manager.save_setting("GalaxyParticlesPlaneOnOff", galaxy.GalaxyParticlesPlaneOnOff())
	pause_unpause_game()

func _on_Timer_timeout():
	save_pos_and_zoom()
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
		$Timer.start(5)

func save_pos_and_zoom():
	data_reader.settings_manager.save_setting("camera_pos", galaxy.camera_center.translation)
	data_reader.settings_manager.save_setting("camera_zoom", galaxy.camera.translation.z)

func initialize_galaxy_map():
	var camzoom := -1.0
	if data_reader.settings_manager.get_setting("camera_zoom") != null:
		camzoom = data_reader.settings_manager.get_setting("camera_zoom")
	if data_reader.settings_manager.get_setting("camera_pos") != null:
		camera_move(data_reader.settings_manager.get_setting("camera_pos"), camzoom)
	galaxy.start_timer()
	_on_BtGalaxy_pressed()

func update_navlabel():
	var pos = galaxy.camera_center.global_transform.origin
	var zoom = galaxy.camera.translation.z
	navlabel.text = "%s view - Pos: %s/%s/%s-%s" % [view_mode, pos.x, pos.y, pos.z, zoom]

func camera_move(_position : Vector3, _zoom : float = -1):
	galaxy.camera_move_to(_position, _zoom)
	data_reader.settings_manager.save_setting("camera_pos", _position)
	data_reader.settings_manager.save_setting("camera_zoom", _zoom)
	pause_unpause_game()

func get_clicked_star():
	var mouse_pos = self.get_local_mouse_position()
	var clicked_star = galaxy.get_clicked_star(mouse_pos)
	if clicked_star["idx"] >= 0:
		var found_star : Dictionary = data_reader.galaxy_manager.star_systems[clicked_star["idx"]]
		set_selected_star(found_star)
		camera_move(clicked_star["pos"])

func set_selected_star(_star):
		details.title = ""
		details.body = ""
		if _star.has("StarSystem"):
			details.title += _star["StarSystem"]
			for key in _star.keys():
				if !(DataConverter.get_value(_star[key]).begins_with("$") && _star[key].ends_with(";")):
					if key != "System":
						details.body += "%s: %s\n" % [key.replace("_Localised", "").replace("System", "").capitalize(), DataConverter.get_value(_star[key])]
					else:
						details.body += "%s: %s\n" % [key.replace("_Localised", ""), DataConverter.get_value(_star[key])]
		
		var prospected_asteroids_events = []
		if _star.has("SystemAddress"):
			prospected_asteroids_events = data_reader.galaxy_manager.get_events_per_location(String(_star["SystemAddress"]), -1, ["ProspectedAsteroid"])
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
				ArraySorter.sort_by_key(location_events, "total")
				if location_events:
					details.body += "\n%s\n" % location
					ArraySorter.sort_by_key(location_events, "total")
					for mat in location_events:
						if mat["count"] > 0:
							details.body += "%s (%s): %.2f%%\n" % [mat["Name"], mat["count"], (mat["total"] / mat["count"])]
		details.visible = true
		table.visible = false

func _on_Search_SearchItemSelected(id):
	var found_star : Dictionary = data_reader.galaxy_manager.star_systems[id]
	var starpos := galaxy.galaxy_sector.get_star_position_by_id(id)
	set_selected_star(found_star)
	camera_move(starpos)

func _on_FloatingTable_item_selected(tree_item):
	if tree_item.has("StarPos"):
		var starpos = DataConverter.get_position_vector(tree_item["StarPos"])
		camera_move(starpos)

func _on_FloatingTable_item_doubleclicked(tree_item):
	set_selected_star(tree_item)
	if tree_item.has("StarPos"):
		var starpos = DataConverter.get_position_vector(tree_item["StarPos"])
		camera_move(starpos)

func _on_RightButtonsContainer_view_button_pressed(_text):
	var query_views : Dictionary = data_reader.settings_manager.get_setting("query_views")
	if query_views.has(_text):
		var view_select = ""
		if query_views[_text].has("query"):
			view_select = query_views[_text]["query"]
		if view_select.empty():
			view_select = data_reader.query_builder.query_structure_to_select(query_views[_text]["structure"])
		var events := data_reader.dbm.db_execute_select(view_select)
		data_reader.galaxy_manager.star_systems = events
		show_table_view(events, _text)
		galaxy.spawn_sector_stars(events, query_views[_text]["rules"])
	#	galaxy.spawn_stars(data_reader.galaxy_manager.star_systems, "Visits", 100, Color(0.4, 0.1, 0.1), Color(1.0, 0.87, 0.4))
		update_navlabel()
		pause_unpause_game()

func show_table_view(_data : Array, _title : String):
	table.visible = !table.visible
	if table.visible:
		details.visible = false
		table.title_text = _title
		table.visible_columns = []
		table.table_array = _data
#		if !_data.empty():
#			if _data[0].has("timestamp"):
#				galaxy.galaxy_plotter.draw_path(table.table_array, "StarPos")
	else:
		galaxy.galaxy_plotter.clear_path()


func _on_GalaxyMap_resized():
	pause_unpause_game()
