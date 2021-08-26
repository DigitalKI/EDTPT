extends MeshInstance
class_name GalaxyPlane

export(float) var galaxy_clouds_fade_dist_close = 1100.0
export(float) var galaxy_clouds_fade_dist = 20000.0
export(float) var alpha_max = 0.24


func GalaxyPlaneFade(_zoom_level):
	if _zoom_level < galaxy_clouds_fade_dist:
		var interpolated_a = inverse_lerp(galaxy_clouds_fade_dist_close, galaxy_clouds_fade_dist, _zoom_level)
		if interpolated_a < 0:
			interpolated_a = 0
		elif interpolated_a > 1:
			interpolated_a = 1
		mesh.material.albedo_color.a = alpha_max * interpolated_a
