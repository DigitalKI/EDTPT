extends Spatial
class_name GalaxyParticles

export(float) var galaxy_clouds_fade_dist_close = 1100.0
export(float) var galaxy_clouds_fade_dist = 20000.0
export(float) var alpha_dim_max = 0.15
export(float) var alpha_max = 0.4

func GalaxyParticlesFade(_zoom_level):
	if _zoom_level < galaxy_clouds_fade_dist:
		var interpolated_a = inverse_lerp(galaxy_clouds_fade_dist_close, galaxy_clouds_fade_dist, _zoom_level)
		if interpolated_a < 0:
			interpolated_a = 0
		elif interpolated_a > 1:
			interpolated_a = 1
		$GalaxyParticlesRed.draw_pass_1.material.albedo_color.a = alpha_max * interpolated_a
		$GalaxyParticlesBlue.draw_pass_1.material.albedo_color.a = alpha_max * interpolated_a
		$GalaxyParticlesGreen.draw_pass_1.material.albedo_color.a = alpha_dim_max * interpolated_a
		$GalaxyParticlesCenter.draw_pass_1.material.albedo_color.a = alpha_dim_max * interpolated_a
		$GalaxyParticlesCenterSmall.draw_pass_1.material.albedo_color.a = alpha_max * interpolated_a

func set_speed_scale(_speed):
	$GalaxyParticlesRed.speed_scale = _speed
	$GalaxyParticlesBlue.speed_scale = _speed
	$GalaxyParticlesGreen.speed_scale = _speed
	$GalaxyParticlesCenter.speed_scale = _speed
	$GalaxyParticlesCenterSmall.speed_scale = _speed
