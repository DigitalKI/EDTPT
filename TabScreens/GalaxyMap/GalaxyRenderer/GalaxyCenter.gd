extends Spatial
class_name GalaxyCenter

var min_zoom = 10.0
var max_zoom = 130000.0
var max_tween_duration := 3.0
var min_tween_duration := 0.5
var galaxy_clouds_fade_dist_close = 1100.0
var galaxy_clouds_fade_dist = 20000.0

var relative_mov : Vector3 = Vector3()
var galaxy_plane = Plane(Vector3(0, 1, 0), 0)

onready var stars_multimesh : MultiMeshInstance = $StarsMultiMesh
onready var edsm_multimesh : MultiMeshInstance = $EDSMMultiMesh
onready var camera := $PlaneGrid/CameraCenter/CameraRotation/Camera
onready var camera_plane : Spatial = $PlaneGrid
onready var camera_grid : MeshInstance = $PlaneGrid/CameraCenter/CameraGrid
onready var camera_center : Spatial = $PlaneGrid/CameraCenter
onready var camera_rotation : Spatial  = $PlaneGrid/CameraCenter/CameraRotation
onready var galaxy_particles : GalaxyParticles = $GalaxyParticles
onready var galaxy_plane_mesh : GalaxyPlane = $GalaxyPlane
onready var galaxy_sector : GalaxySector = $GalaxySector
onready var galaxy_plotter : GalaxyPlotter = $GalaxyPlotter
onready var tween_pos : Tween = $TweenPos
onready var tween_plane : Tween = $TweenPlane
onready var tween_zoom : Tween = $TweenZoom
onready var tween_fade : Tween = $TweenFade


func _on_Timer_timeout():
	galaxy_particles.set_speed_scale(0)

func start_timer():
	galaxy_particles.set_speed_scale(1)
	# sets particle alpha to the max value
	galaxy_particles.GalaxyParticlesFade(galaxy_clouds_fade_dist - 0.1)
	camera_center.translation.z = $GalaxyPlane.translation.z
	$Timer.start()

# Smoothly moves the camera to a set position,
# interpolates position, zoom, and albedo of particles and galaxy 2d map
func camera_move_to(_final_pos : Vector3):
	var distance = camera_center.translation.distance_to(_final_pos)
	var plane_final_pos := Vector3(camera_plane.translation.x, _final_pos.y, camera_plane.translation.z)
	var camera_final_pos := Vector3(_final_pos.x, camera_center.translation.y, _final_pos.z)
	var camera_final_zoom : float = 150.0
	
	# Zooms in only if farther than the initial value in in camera_final_zoom
	if camera.translation.z < camera_final_zoom:
		camera_final_zoom = camera.translation.z
	
	# Tweaking the values below should make the movement feel a bit closer to ED
	var duration : float = distance * 0.002
	if duration > max_tween_duration:
		duration = max_tween_duration
	elif duration < min_tween_duration:
		duration = min_tween_duration
	tween_plane.interpolate_property(camera_plane, "translation",
	camera_plane.translation, plane_final_pos, duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_plane.start()
	
	tween_pos.interpolate_property(camera_center, "translation",
	camera_center.translation, camera_final_pos, duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos.start()
	
	tween_zoom.interpolate_property(camera, "translation",
	camera.translation, Vector3(camera.translation.x, camera.translation.y, camera_final_zoom), duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_zoom.start()
	
	tween_fade.interpolate_method(galaxy_particles, "GalaxyParticlesFade",
	camera.translation.z, camera_final_zoom, duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween_fade.interpolate_method(galaxy_plane_mesh, "GalaxyPlaneFade",
	camera.translation.z, camera_final_zoom, duration,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_fade.start()

# Moves the camera according to keyboard/mouse input
func camera_movement(_movement_speed, _direction, _pos):
	var final_pos : Vector3 = camera.translation
	var offset_direction : Vector3 = camera_grid.get_active_material(0).uv1_offset
	if _direction == "x":
		relative_mov = (1 if _pos else -1) * galaxy_plane.project(camera_rotation.transform.basis.x).normalized() * camera.translation.length() * _movement_speed
		final_pos = camera_center.translation + relative_mov
		offset_direction = offset_direction + Vector3(offset_direction.x + relative_mov.x, offset_direction.y + relative_mov.z, 0)
	elif _direction == "z":
		relative_mov = (1 if _pos else -1) * galaxy_plane.project(camera_rotation.transform.basis.z).normalized() * camera.translation.length() * _movement_speed
		final_pos = Vector3(camera_center.translation.x + relative_mov.x, camera_center.translation.y, camera_center.translation.z + relative_mov.z)
		offset_direction = Vector3(offset_direction.x + relative_mov.x, offset_direction.y + relative_mov.z, 0)
	tween_pos.interpolate_property(camera_center, "translation",
	camera_center.translation, final_pos, 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween_pos.interpolate_property(camera_grid.get_active_material(0), "uv1_offset",
#	camera_grid.get_active_material(0).uv1_offset, offset_direction, 0.1,
#	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos.start()
	
func plane_movement(_speed):
	var final_pos = Vector3(camera_plane.translation.x, camera_plane.translation.y + _speed * camera.translation.z, camera_plane.translation.z)
	tween_pos.interpolate_property(camera_plane, "translation",
	camera_plane.translation, final_pos, 0.1,
	Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_pos.start()

func zoom(_zoom_speed):
	if (camera.translation.z >= min_zoom && _zoom_speed < 0.0) || (camera.translation.z <= max_zoom && _zoom_speed > 0.0):
		tween_pos.interpolate_property(camera, "translation",
		camera.translation, Vector3(camera.translation.x, camera.translation.y, camera.translation.z + _zoom_speed * camera.translation.z), 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween_pos.start()
		galaxy_particles.GalaxyParticlesFade(camera.translation.z)
		galaxy_plane_mesh.GalaxyPlaneFade(camera.translation.z)

func GalaxyPlaneOnOff(_force_state : int = -1):
	if _force_state != -1:
		$GalaxyPlane.visible = bool(_force_state)
	else:
		$GalaxyPlane.visible = !$GalaxyPlane.visible
	return $GalaxyPlane.visible

func GalaxyParticlesPlaneOnOff(_force_state : int = -1):
	if _force_state != -1:
		$GalaxyParticles.visible = bool(_force_state)
	else:
		$GalaxyParticles.visible = !$GalaxyParticles.visible
	return $GalaxyParticles.visible

func spawn_sector_stars(_stars : Array, _config : Array, _default_color : Color = Color(0.2, 0.2, 0.2), _default_size : float = 1.0):
	galaxy_sector.spawn_stars(_stars, _config, _default_color, _default_size)

func spawn_edsm_stars(_stars : Array, _interpolation_key : String, _maxval : float, _star_color_low : Color = Color(1.0, 0.2, 0.2), _star_color_high : Color = Color(1.0, 1.0, 1.0)):
	edsm_multimesh.multimesh.instance_count = 0
	edsm_multimesh.multimesh.instance_count = _stars.size()
	edsm_multimesh.multimesh.visible_instance_count = _stars.size()
	for idx in _stars.size():
		var sys_coord : Vector3 = DataConverter.get_position_vector(_stars[idx]["coords"])
			
		var intensity : float = (_stars[idx][_interpolation_key]/_maxval) if _stars[idx][_interpolation_key] else 0
		if intensity > 1:
			intensity = 1
		var color_intensity = intensity #ease(intensity, 0.5)
		var star_color : Color = _star_color_low.linear_interpolate(_star_color_high, color_intensity)
		var star_size : Basis = Basis().scaled(Vector3(0.5,0.5,0.5).linear_interpolate(Vector3(2.5,2.5,2.5),intensity))
		edsm_multimesh.multimesh.set_instance_transform(idx, Transform(star_size, sys_coord))
		edsm_multimesh.multimesh.set_instance_color(idx, star_color)

func get_stars_closer_than(_mouse_pos : Vector2, _max_distance : float):
	var close_stars := []
	for idx in range(galaxy_sector.get_multimesh().instance_count):
		var star_transform = galaxy_sector.get_multimesh().get_instance_transform(idx)
		var distance = _mouse_pos.distance_to(camera.unproject_position(star_transform.origin))
		if distance < _max_distance:
			close_stars.append(idx)
	return close_stars
	
func get_clicked_star(_mouse_pos : Vector2):
	var close_stars : Array = get_stars_closer_than(_mouse_pos, 20)
	var distance_to_camera := 99999.9999
	var closest_star_idx = -1
	var closest_star_pos : Vector3
	for star_idx in close_stars:
		var starpos : Vector3 = galaxy_sector.get_multimesh().get_instance_transform(star_idx).origin
		if  starpos.distance_to(camera.global_transform.origin) < distance_to_camera:
			distance_to_camera = starpos.distance_to(camera.global_transform.origin)
			closest_star_idx = star_idx
			closest_star_pos = starpos
	return {"idx": closest_star_idx, "pos": closest_star_pos}
