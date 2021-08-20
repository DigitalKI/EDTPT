extends Spatial
class_name GalaxyParticles

export(float) var galaxy_clouds_fade_dist_close = 1100.0
export(float) var galaxy_clouds_fade_dist = 20000.0
export(float) var alpha_dim_max = 0.2
export(float) var alpha_max = 1

func GalaxyParticlesFade(_zoom_level):
	if _zoom_level < galaxy_clouds_fade_dist:
		var interpolated_a = inverse_lerp(galaxy_clouds_fade_dist_close, galaxy_clouds_fade_dist, _zoom_level)
		if interpolated_a < 0:
			interpolated_a = 0
		elif interpolated_a > 1:
			interpolated_a = 1
		$GalaxyParticlesRed.draw_pass_1.material.albedo_color.a = alpha_max * interpolated_a
		$GalaxyParticlesMainArmsBlue.draw_pass_1.material.albedo_color.a = alpha_max * interpolated_a
		$GalaxyParticlesFainterArm.draw_pass_1.material.albedo_color.a = alpha_max * interpolated_a
		$GalaxyParticlesCloud.draw_pass_1.material.albedo_color.a = alpha_dim_max * interpolated_a
		$GalaxyParticlesBulge.draw_pass_1.material.albedo_color.a = alpha_dim_max * interpolated_a
		$GalaxyParticlesBulgeSmall.draw_pass_1.material.albedo_color.a = alpha_max * interpolated_a

func set_speed_scale(_speed):
	$GalaxyParticlesRed.speed_scale = _speed
	$GalaxyParticlesMainArmsBlue.speed_scale = _speed
	$GalaxyParticlesFainterArm.speed_scale = _speed
	$GalaxyParticlesCloud.speed_scale = _speed
	$GalaxyParticlesBulge.speed_scale = _speed
	$GalaxyParticlesBulgeSmall.speed_scale = _speed
