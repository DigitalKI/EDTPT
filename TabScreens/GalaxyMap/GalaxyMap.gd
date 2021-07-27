extends ViewportContainer

var fsdjumps = []
var star_systems = []
var mouse_left_pressed : = false
var mouse_middle_pressed : = false
var mouse_right_pressed : = false
var rl_pressed : = false
var fb_pressed : = false
onready var stars_multimesh : MultiMeshInstance = $Viewport/GalaxyCenter/MultiMeshInstance
onready var camera : Camera = $Viewport/GalaxyCenter/CameraCenter/Camera
onready var camera_center = $Viewport/GalaxyCenter/CameraCenter
var zoom_speed = 0.05
var rotation_speed = 0.05
var movement_speed = 0.05


# Called when the node enters the scene tree for the first time.
func _ready():
	fsdjumps = data_reader.galaxy_manager.get_all_jumped_systems()
	star_systems = data_reader.galaxy_manager.star_systems
	stars_multimesh.multimesh.instance_count = star_systems.size()
	stars_multimesh.multimesh.visible_instance_count = star_systems.size()
	var idx = 0
	for system in star_systems:
		var jumps : Array = []
		var sys_coord : Vector3
		for jump in fsdjumps:
			if jump["SystemAddress"] == system:
				jumps.append(jump)
		sys_coord = Vector3(jumps[0]["StarPos"][0], jumps[0]["StarPos"][1], jumps[0]["StarPos"][2])
		stars_multimesh.multimesh.set_instance_transform(idx, Transform(Basis(), sys_coord))
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
				camera.translation.z -= zoom_speed * camera.translation.z
		if event.button_index == BUTTON_WHEEL_DOWN:
			if camera.translation.z < 100000:
				camera.translation.z += zoom_speed * camera.translation.z
	elif event is InputEventMouseMotion:
		if mouse_left_pressed:
			camera_center.rotation_degrees.y += event.speed.x * rotation_speed
			camera_center.rotation_degrees.x += event.speed.y * rotation_speed

func _input(event):
	if event is InputEventKey:
		# Allow to move left or right
		if OS.get_scancode_string(event.scancode) == "A":
			fb_pressed = event.pressed
			camera_center.translate(Vector3(-1 * camera.translation.length() * movement_speed, 0,0))
		elif OS.get_scancode_string(event.scancode) == "D":
			fb_pressed = event.pressed
			camera_center.translate(Vector3(1 * camera.translation.length() * movement_speed, 0,0))
			
		# Allow to move forward or backward
		if OS.get_scancode_string(event.scancode) == "W":
			rl_pressed = event.pressed
			camera_center.translate(Vector3(0,0,-1 * camera.translation.length() * movement_speed))
		elif OS.get_scancode_string(event.scancode) == "S":
			rl_pressed = event.pressed
			camera_center.translate(Vector3(0,0,1 * camera.translation.length() * movement_speed))
