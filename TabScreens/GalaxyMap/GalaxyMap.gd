extends ViewportContainer

var mouse_left_pressed : = false
var mouse_middle_pressed : = false
var mouse_right_pressed : = false
var rl_pressed : = false
var fb_pressed : = false
onready var stars_multimesh : MultiMeshInstance = $Viewport/GalaxyCenter/MultiMeshInstance
onready var camera : Camera = $Viewport/GalaxyCenter/CameraCenter/Camera
onready var camera_center = $Viewport/GalaxyCenter/CameraCenter
onready var tween_pos = $Viewport/GalaxyCenter/Tween
var zoom_speed = 0.1
var rotation_speed = 0.025
var movement_speed = 0.025
var relative_mov : Vector3 = Vector3()
var galaxy_plane = Plane(Vector3(0, 1, 0), 0)


# Called when the node enters the scene tree for the first time.
func _ready():
	data_reader.galaxy_manager.get_all_visited_systems()
	stars_multimesh.multimesh.instance_count = data_reader.galaxy_manager.star_systems.size()
	stars_multimesh.multimesh.visible_instance_count = data_reader.galaxy_manager.star_systems.size()
	var idx = 0
	for system in data_reader.galaxy_manager.star_systems:
		var sys_coord_json = JSON.parse(system["StarPos"]).result
		var sys_coord : Vector3 = Vector3(sys_coord_json[0], sys_coord_json[1], sys_coord_json[2])
		var intensity : float = system["Visits"]/100.0
		if intensity > 1:
			intensity = 1
		var color_intensity = intensity #ease(intensity, 0.5)
		var star_color : Color = Color(1.0, 0.2, 0.2).linear_interpolate(Color(1.0, 1.0, 1.0), color_intensity)
		var star_size : Basis = Basis().scaled(Vector3(0.5,0.5,0.5).linear_interpolate(Vector3(2.5,2.5,2.5),intensity))
		stars_multimesh.multimesh.set_instance_transform(idx, Transform(star_size, sys_coord))
		stars_multimesh.multimesh.set_instance_color(idx, star_color)
		idx += 1


func _on_GalaxyMap_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			mouse_left_pressed =  event.pressed
			if !event.pressed:
				camera_center.transform = camera_center.transform.orthonormalized()
		if event.button_index == BUTTON_MIDDLE:
			mouse_middle_pressed =  event.pressed
		if event.button_index == BUTTON_RIGHT:
			mouse_right_pressed =  event.pressed
		if event.button_index == BUTTON_WHEEL_UP:
			if camera.translation.z >= 10:
#				camera.translation.z -= zoom_speed * camera.translation.z
				_smooth_camra_zoom(camera.translation, Vector3(camera.translation.x, camera.translation.y, camera.translation.z - zoom_speed * camera.translation.z))
		if event.button_index == BUTTON_WHEEL_DOWN:
			if camera.translation.z < 100000:
#				camera.translation.z += zoom_speed * camera.translation.z
				_smooth_camra_zoom(camera.translation, Vector3(camera.translation.x, camera.translation.y, camera.translation.z + zoom_speed * camera.translation.z))
	elif event is InputEventMouseMotion:
		if mouse_left_pressed:
			camera_center.rotation_degrees.y += event.speed.x * rotation_speed
			camera_center.rotation_degrees.x += event.speed.y * rotation_speed

func _input(event):
	if event is InputEventKey:
		# Allow to move left or right
		if OS.get_scancode_string(event.scancode) == "A" && event.pressed:
			fb_pressed = event.pressed
			relative_mov = galaxy_plane.project(camera_center.transform.basis.x).normalized() * camera.translation.length() * movement_speed
			_smooth_camra_movement(camera_center.translation, camera_center.translation - relative_mov)
#			camera_center.translate(Vector3(-1 * camera.translation.length() * movement_speed, 0,0))
		elif OS.get_scancode_string(event.scancode) == "D" && event.pressed:
			fb_pressed = event.pressed
			relative_mov = galaxy_plane.project(camera_center.transform.basis.x).normalized() * camera.translation.length() * movement_speed
			_smooth_camra_movement(camera_center.translation, camera_center.translation + relative_mov)
#			camera_center.translate(Vector3(1 * camera.translation.length() * movement_speed, 0,0))
			
		# Allow to move forward or backward
		if OS.get_scancode_string(event.scancode) == "W" && event.pressed:
			rl_pressed = event.pressed
			relative_mov = galaxy_plane.project(camera_center.transform.basis.z).normalized() * camera.translation.length() * movement_speed
#			camera_center.translation.x -= relative_z.x
#			camera_center.translation.z -= relative_z.z
			_smooth_camra_movement(camera_center.translation, Vector3(camera_center.translation.x - relative_mov.x, camera_center.translation.y, camera_center.translation.z - relative_mov.z))
		elif OS.get_scancode_string(event.scancode) == "S" && event.pressed:
			rl_pressed = event.pressed
			relative_mov = galaxy_plane.project(camera_center.transform.basis.z).normalized() * camera.translation.length() * movement_speed
#			camera_center.translation.x += relative_z.x
#			camera_center.translation.z += relative_z.z
			_smooth_camra_movement(camera_center.translation, Vector3(camera_center.translation.x + relative_mov.x, camera_center.translation.y, camera_center.translation.z + relative_mov.z))

func _smooth_camra_movement(_initial : Vector3, _final : Vector3):
	tween_pos.interpolate_property(camera_center, "translation",
	_initial, _final, 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos.start()
	
func _smooth_camra_zoom(_initial : Vector3, _final : Vector3):
	tween_pos.interpolate_property(camera, "translation",
	_initial, _final, 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos.start()
