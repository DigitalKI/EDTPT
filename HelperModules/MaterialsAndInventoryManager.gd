extends Object
class_name MaterialsAndInventoryManager
var mat_data_path = "res://Database/MaterialCategories.json"
var material_categories = {}

func _init():
	var file : File = File.new()
	var file_status = file.open(mat_data_path, File.READ)
	if file_status == OK:
		material_categories = parse_json(file.get_as_text())
	file.close()

func get_type_from_materialname(_matname : String):
	for type in material_categories.keys():
		for cat in material_categories[type].keys():
			if material_categories[type][cat].has(_matname.to_lower()):
				return cat
	return ""

# Get last logged materials list
func get_updated_materials():
	var return_data := []
	var raw_mats : Array = []
	var manufactured_mats : Array = []
	var encoded_mats : Array = []
	var mats_collected : Array = []
	var missions_rewards : Array = []
	if data_reader.dbm.db.query("SELECT * "
								+ " FROM Materials"
								+ " ORDER by timestamp desc"
								+ " LIMIT 1"):
		var mats_data = data_reader.dbm.db.query_result.duplicate()
		if mats_data:
			raw_mats = parse_json(mats_data[0]["Raw"])
			manufactured_mats = parse_json(mats_data[0]["Manufactured"])
			encoded_mats = parse_json(mats_data[0]["Encoded"])
			var mats_timestamp = mats_data[0]["timestamp"]
			if data_reader.dbm.db.query("SELECT * "
										+ " FROM MaterialCollected"
										+ " WHERE timestamp >= %s" % mats_timestamp
										+ " ORDER by timestamp"):
				mats_collected = data_reader.dbm.db.query_result.duplicate()
			if data_reader.dbm.db.query("SELECT timestamp, MaterialsReward "
										+ " FROM MissionCompleted"
										+ " WHERE timestamp >= '%s'" % mats_timestamp
										+ " AND MaterialsReward is not null"
										+ " ORDER by timestamp"):
				missions_rewards = data_reader.dbm.db.query_result.duplicate()
			for mat in raw_mats:
				if mats_collected:
					for cmat in mats_collected:
						if mat["Name"].to_lower() == cmat["Name"].to_lower():
							mat["Count"] += cmat["Count"]
				if missions_rewards:
					for reward in missions_rewards:
						var miss_reward : Array = parse_json(reward["MaterialsReward"])
						for rwd in miss_reward:
							if mat["Name"].to_lower() == rwd["Name"].to_lower():
								mat["Count"] += rwd["Count"]
			for mat in manufactured_mats:
				if mats_collected:
					for cmat in mats_collected:
						if mat["Name"].to_lower() == cmat["Name"].to_lower():
							mat["Count"] += cmat["Count"]
				if missions_rewards:
					for reward in missions_rewards:
						var miss_reward : Array = parse_json(reward["MaterialsReward"])
						for rwd in miss_reward:
							if mat["Name"].to_lower() == rwd["Name"].to_lower():
								mat["Count"] += rwd["Count"]
			for mat in encoded_mats:
				if mats_collected:
					for cmat in mats_collected:
						if mat["Name"].to_lower() == cmat["Name"].to_lower():
							mat["Count"] += cmat["Count"]
				if missions_rewards:
					for reward in missions_rewards:
						var miss_reward : Array = parse_json(reward["MaterialsReward"])
						for rwd in miss_reward:
							if mat["Name"].to_lower() == rwd["Name"].to_lower():
								mat["Count"] += rwd["Count"]
	return {"Raw": raw_mats, "Manufactured": manufactured_mats, "Encoded": encoded_mats}
