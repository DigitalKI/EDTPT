extends ViewportContainer

var fsdjumps = []
onready var stars_multimesh : MultiMeshInstance = $Viewport/GalaxyCenter/MultiMeshInstance


# Called when the node enters the scene tree for the first time.
func _ready():
	fsdjumps = data_reader.galaxy_manager.get_all_jumped_systems()
	stars_multimesh.multimesh.instance_count = fsdjumps.size()
	stars_multimesh.multimesh.visible_instance_count = fsdjumps.size()
	var idx = 0
	for fsd_jump in fsdjumps:
		stars_multimesh.multimesh.set_instance_transform(idx, Transform(Basis(), Vector3(fsd_jump["StarPos"][0], fsd_jump["StarPos"][1], fsd_jump["StarPos"][2])))
		idx += 1
