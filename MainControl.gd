extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var log_files = $DataReader.get_files()
	for file_log in log_files:
		$HBoxContainer/LogEntries.add_item(file_log)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
