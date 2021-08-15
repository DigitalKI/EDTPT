extends Spatial

# This function should:
# - Generate several MultiMeshInstance nodes for each "Sector" of the galaxy
# - Each MultiMeshInstance should be a separate scene that allows a custom LOD
# The LOD could be something like:
# - At galaxy level a series of static particles showing groups of "Clouds" forming the typical shape
# - At mid distance it will become a cube of points, possibly with different sizes
# - At close distance it should display a sphere, possibly with some cool shader
func spawn_stars(_stars : Array, _interpolation_key : String, _maxval : float, _star_color_low : Color = Color(1.0, 0.2, 0.2), _star_color_high : Color = Color(1.0, 1.0, 1.0)):
	var stars_multimesh := MultiMeshInstance.new()
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
