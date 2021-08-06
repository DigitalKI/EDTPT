extends Control

var mouse_left_pressed : = false
var mouse_middle_pressed : = false
var mouse_right_pressed : = false
var rl_pressed : = false
var fb_pressed : = false
onready var galaxy : GalaxyCenter = $GalaxyMapView/Viewport/GalaxyCenter
var zoom_speed = 0.1
var rotation_speed = 0.025
var movement_speed = 0.025
var relative_mov : Vector3 = Vector3()
var galaxy_plane = Plane(Vector3(0, 1, 0), 0)


# Called when the node enters the scene tree for the first time.
func _ready():
	data_reader.galaxy_manager.get_all_visited_systems()
	galaxy.spawn_stars(data_reader.galaxy_manager.star_systems)

func _on_GalaxyMapView_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			mouse_left_pressed =  event.pressed
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
	elif event is InputEventMouseMotion:
		if mouse_left_pressed:
			galaxy.camera_rotation.rotation_degrees.y += event.speed.x * rotation_speed
			galaxy.camera_rotation.rotation_degrees.x += event.speed.y * rotation_speed

func _input(event):
	if event is InputEventKey:
		# Allow to move left or right
		if OS.get_scancode_string(event.scancode) == "A" && event.pressed:
			fb_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "x", false)
		elif OS.get_scancode_string(event.scancode) == "D" && event.pressed:
			fb_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "x", true)
			
		# Allow to move forward or backward
		if OS.get_scancode_string(event.scancode) == "W" && event.pressed:
			rl_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "z", false)
		elif OS.get_scancode_string(event.scancode) == "S" && event.pressed:
			rl_pressed = event.pressed
			galaxy.camera_movement(movement_speed, "z", true)
		# Allow to move up or down relative to the alaxy plane
		if OS.get_scancode_string(event.scancode) == "R" && event.pressed:
			galaxy.plane_movement(movement_speed)
		elif OS.get_scancode_string(event.scancode) == "F" && event.pressed:
			galaxy.plane_movement(-movement_speed)

func get_clicked_star():
	var mouse_pos = self.get_local_mouse_position()
	var close_stars : Array = galaxy.get_stars_closer_than(mouse_pos, 10)
	var distance_to_camera := 99999.9999
	var closest_star_idx = -1
	var closest_star_pos : Vector3
	for star_idx in close_stars:
		var starpos := galaxy.stars_multimesh.multimesh.get_instance_transform(star_idx).origin
		if  starpos.distance_to(galaxy.camera_center.translation) < distance_to_camera:
			distance_to_camera = starpos.distance_to(galaxy.camera_center.translation)
			closest_star_idx = star_idx
			closest_star_pos = starpos
	
	if closest_star_idx >= 0:
		$SystemDetails.title = ""
		$SystemDetails.body = ""
		var found_star : Dictionary = data_reader.galaxy_manager.star_systems[closest_star_idx]
		if found_star.has("StarSystem"):
			$SystemDetails.title += found_star["StarSystem"] + ", " 
			for key in found_star.keys():
				var string_value = "null" if (found_star[key] == null) else String(found_star[key])
				$SystemDetails.body += String(key) + " - " + string_value + "\n"
		$SystemDetails.title = $SystemDetails.title.trim_suffix(", ")
		galaxy.camera_move_to(closest_star_pos)
