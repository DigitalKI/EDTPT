extends Spatial
class_name GalaxyCenter

var relative_mov : Vector3 = Vector3()
var galaxy_plane = Plane(Vector3(0, 1, 0), 0)

onready var stars_multimesh : MultiMeshInstance = $MultiMeshInstance
onready var camera := $PlaneGrid/CameraCenter/CameraRotation/Camera
onready var camera_plane : Spatial = $PlaneGrid
onready var camera_center : Spatial = $PlaneGrid/CameraCenter
onready var camera_rotation : Spatial  = $PlaneGrid/CameraCenter/CameraRotation
onready var tween_pos : Tween = $Tween
onready var tween_pos2 : Tween = $Tween2

func camera_move_to(_final_pos : Vector3):
	var distance = camera_center.translation.distance_to(_final_pos)
	var plane_final_pos := Vector3(camera_plane.translation.x, _final_pos.y, camera_plane.translation.z)
	var camera_final_pos := Vector3(_final_pos.x, camera_center.translation.y, _final_pos.z)
	var duration : float = distance * 0.01
	if duration > 5:
		duration = 5
	tween_pos.interpolate_property(camera_plane, "translation",
	camera_plane.translation, plane_final_pos, duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos.start()
	
	tween_pos2.interpolate_property(camera_center, "translation",
	camera_center.translation, camera_final_pos, distance * 0.01,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos2.start()
	

func camera_movement(_movement_speed, _direction, _pos):
	var final_pos : Vector3 = camera.translation
	if _direction == "x":
		relative_mov = (1 if _pos else -1) * galaxy_plane.project(camera_rotation.transform.basis.x).normalized() * camera.translation.length() * _movement_speed
		final_pos = camera_center.translation + relative_mov
	elif _direction == "z":
		relative_mov = (1 if _pos else -1) * galaxy_plane.project(camera_rotation.transform.basis.z).normalized() * camera.translation.length() * _movement_speed
		final_pos = Vector3(camera_center.translation.x + relative_mov.x, camera_center.translation.y, camera_center.translation.z + relative_mov.z)
	tween_pos.interpolate_property(camera_center, "translation",
	camera_center.translation, final_pos, 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos.start()
	
func plane_movement(_speed):
	var final_pos = Vector3(camera_plane.translation.x, camera_plane.translation.y + _speed * camera.translation.z, camera_plane.translation.z)
	tween_pos.interpolate_property(camera_plane, "translation",
	camera_plane.translation, final_pos, 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos.start()

func zoom(_zoom_speed):
	tween_pos.interpolate_property(camera, "translation",
	camera.translation, Vector3(camera.translation.x, camera.translation.y, camera.translation.z + _zoom_speed * camera.translation.z), 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos.start()

func spawn_stars(_stars : Array, _interpolation_key : String, _maxval : float, _star_color_low : Color = Color(1.0, 0.2, 0.2), _star_color_high : Color = Color(1.0, 1.0, 1.0)):
	stars_multimesh.multimesh.color_format = MultiMesh.COLOR_FLOAT
#	stars_multimesh.multimesh.mesh.material.vertex_color_use_as_albedo = true
#	stars_multimesh.multimesh.mesh.material.albedo_color = _star_color_low
#	stars_multimesh.multimesh.mesh.material.emission = _star_color_high
#	stars_multimesh.multimesh.mesh.material.emission_energy = 3.0 * _star_color_high.s
#	print("E %s, S %s" % [stars_multimesh.multimesh.mesh.material.emission_energy, _star_color_high.s])
	stars_multimesh.multimesh.instance_count = _stars.size()
	stars_multimesh.multimesh.visible_instance_count = _stars.size()
	for idx in _stars.size():
		var sys_coord_json = JSON.parse(_stars[idx]["StarPos"]).result
		var sys_coord : Vector3 = Vector3(sys_coord_json[0], sys_coord_json[1], sys_coord_json[2])
		var intensity : float = _stars[idx][_interpolation_key]/_maxval
		if intensity > 1:
			intensity = 1
		var color_intensity = intensity #ease(intensity, 0.5)
		var star_color : Color = _star_color_low.linear_interpolate(_star_color_high, color_intensity)
		var star_size : Basis = Basis().scaled(Vector3(0.5,0.5,0.5).linear_interpolate(Vector3(2.5,2.5,2.5),intensity))
		stars_multimesh.multimesh.set_instance_transform(idx, Transform(star_size, sys_coord))
		stars_multimesh.multimesh.set_instance_color(idx, star_color)

func get_stars_closer_than(_mouse_pos : Vector2, _max_distance : float):
	var close_stars := []
	for idx in range(stars_multimesh.multimesh.instance_count):
		var star_transform = stars_multimesh.multimesh.get_instance_transform(idx)
		var distance = _mouse_pos.distance_to(camera.unproject_position(star_transform.origin))
		if distance < _max_distance:
			close_stars.append(idx)
	return close_stars
