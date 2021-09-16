extends Panel

onready var timer = $Timer
onready var materials_table : Tree = $MarginContainer/MaterialsTree
var tree_root : TreeItem
var material_categories : Dictionary
var expanded_items : Array = []
export(Color) var material_min_color : Color = Color(1,0,0)
export(Color) var material_max_color : Color = Color(0,0,1)
export(Color) var category_bg_color : Color = Color("#ffffff")
export(Color) var category_color : Color = Color("#000000")
export(Color) var type_bg_color : Color = Color("#9c4600")
export(Color) var type_color : Color = Color("#cccccc")

func _ready():
	data_reader.connect("new_cached_events", self, "_on_DataReader_new_cached_events")
	materials_table.set_column_titles_visible(true)
	create_mats_tree()
	
func _on_DataReader_new_cached_events(_events: Array):
	for evt in _events:
		if "MaterialCollected" == evt["event"]:
			update_mats_tree(evt["Category"], evt["Name"], evt["Count"], true)
		elif "Materials" == evt["event"]:
			for mat in evt["Raw"]:
				update_mats_tree("Raw", mat["Name"], mat["Count"])
			for mat in evt["Manufactured"]:
				update_mats_tree("Manufactured", mat["Name"], mat["Count"])
			for mat in evt["Encoded"]:
				update_mats_tree("Encoded", mat["Name"], mat["Count"])

func _on_InventoryAndMaterials_visibility_changed():
	if is_visible_in_tree():
#		timer.start(30)
		pass
	else:
		timer.stop()

func _on_Timer_timeout():
	create_mats_tree()

func create_mats_tree():
	materials_table.clear()
	materials_table.set_column_title(0, "Grade 1")
	materials_table.set_column_expand(0, true)
	materials_table.set_column_title(1, "Grade 2")
	materials_table.set_column_expand(1, true)
	materials_table.set_column_title(2, "Grade 3")
	materials_table.set_column_expand(2, true)
	materials_table.set_column_title(3, "Grade 4")
	materials_table.set_column_expand(3, true)
	materials_table.set_column_title(4, "Grade 5")
	materials_table.set_column_expand(4, true)
	tree_root = materials_table.create_item()
	var mats = data_reader.matinv_manager.get_updated_materials()
	for cat in data_reader.matinv_manager.material_categories.keys():
		var cat_item : TreeItem = materials_table.create_item(tree_root)
		cat_item.set_text(0, cat.capitalize())
		cat_item.set_metadata(0, cat)
		cat_item.set_text_align(0, TreeItem.ALIGN_CENTER)
		cat_item.set_custom_bg_color(0, category_bg_color)
		cat_item.set_custom_color(0, category_color)
		cat_item.set_expand_right(0, true)
		for type in data_reader.matinv_manager.material_categories[cat].keys():
			var type_item : TreeItem = materials_table.create_item(cat_item)
			type_item.set_text(0, type.capitalize())
			type_item.set_metadata(0, type)
			type_item.set_text_align(0, TreeItem.ALIGN_CENTER)
			type_item.set_custom_color(0, type_color)
			type_item.set_custom_bg_color(0, type_bg_color)
			type_item.set_expand_right(0, true)
			add_mats(cat, mats, data_reader.matinv_manager.material_categories[cat][type], type_item)

# Adds an event to the list using the event object
func add_mats(_type : String, _data : Dictionary, _mat_types : Array, _root_node : TreeItem):
	var col_idx:= 0
	var mats_item : TreeItem = materials_table.create_item(_root_node)
#	var mats_bar : TreeItem = materials_table.create_item(_root_node)
	for mat_type in _mat_types:
		var mat_amount : int = _get_material_amount(mat_type, _data[_type.capitalize()])
		var percentage : float = mat_amount / (300.0 - 50.0 * col_idx)
		var amount_color := material_min_color.linear_interpolate(material_max_color, percentage)
		mats_item.set_text(col_idx, _get_material_localized(mat_type, _data[_type.capitalize()]).capitalize())
		mats_item.set_metadata(col_idx, mat_type)
		mats_item.set_custom_bg_color(col_idx, amount_color)
		mats_item.set_text_align(col_idx, TreeItem.ALIGN_RIGHT)
		mats_item.set_suffix(col_idx, String(mat_amount))
#		mats_bar.set_cell_mode(col_idx, TreeItem.CELL_MODE_RANGE)
#		mats_bar.set_custom_color(col_idx, material_min_color)
#		mats_bar.set_custom_bg_color(col_idx, material_max_color)
#		mats_bar.set_range_config(col_idx, 0.0, (300.0 - 50.0 * col_idx), 0.01)
#		mats_bar.set_range(col_idx, mat_amount)
		col_idx += 1

func update_mats_tree(_type, _matname, _amount : int, _add : bool = false):
	var current_cat_item : TreeItem = _get_matching_child(tree_root, _type, 0)
	var current_type_name : String = data_reader.matinv_manager.get_type_from_materialname(_matname)
	var current_type_item : TreeItem = _get_matching_child(current_cat_item, current_type_name, 0)
	for _col in materials_table.columns:
		if current_type_item:
			if current_type_item.get_children().get_metadata(_col) == _matname:
				var current_amount : int = int(current_type_item.get_children().get_suffix(_col))
				current_type_item.get_children().set_suffix(_col,String(current_amount + _amount) if _add else String(_amount))

func _get_matching_child(_parent_item : TreeItem, _text_to_search : String, _column : int = 0):
	if _parent_item:
		var max_count := 500
		var matching_item : TreeItem = _parent_item.get_children()
		while matching_item != null && max_count > 0:
#			print("%s -> %s == %s" %  [_parent_item.get_text(0), matching_item.get_text(_column), _text_to_search])
			if matching_item.get_metadata(_column) == _text_to_search.to_lower():
				return matching_item
			matching_item = matching_item.get_next()
			max_count -= 1
	return null

func _get_material_localized(_mat : String, _data : Array) -> String:
	var return_val : String = _mat
	for _m_data in _data:
		if _m_data["Name"].to_lower() == _mat.to_lower():
			return_val = _m_data["Name_Localised"] if _m_data.has("Name_Localised") else _mat
	# For lower res screens and compactness, some terms are shortened
	if return_val.find("Firmware") >= 0:
		return_val = return_val.replace("Firmware", "F.")
	elif return_val.find("Shield") >= 0:
		return_val = return_val.replace("Shield", "S.")
	elif return_val.find("Wake") >= 0:
		return_val = return_val.replace("Wake", "W.")
	elif return_val.find("Emission") >= 0:
		return_val = return_val.replace("Emission", "E.")
	elif return_val.find("Encrypt") >= 0:
		return_val = return_val.replace("Encryption", "E.")
		return_val = return_val.replace("Encrypted", "E.")
		return_val = return_val.replace("Encryptors", "E.")
	elif return_val.find("Pattern") >= 0:
		return_val = return_val.replace("Pattern", "P.")
	return_val = return_val.trim_prefix("Guardian")
	return return_val

func _get_material_amount(_mat, _data) -> int:
	for _m_data in _data:
		if _m_data["Name"].to_lower() == _mat.to_lower():
			return _m_data["Count"]
	return  0

func _on_MaterialsTree_item_activated():
	var selected_item : TreeItem = materials_table.get_selected()
	if selected_item.get_children():
		selected_item.collapsed = !selected_item.collapsed


func _on_BtnUpdate_pressed():
	var evts = data_reader.get_all_db_events_by_type(["MaterialCollected"], 1)
#	for evt in evts:
#		if evt["Raw"] is String:
#			evt["Raw"] = parse_json(evt["Raw"])
#		if evt["Manufactured"] is String:
#			evt["Manufactured"] = parse_json(evt["Manufactured"])
#		if evt["Encoded"] is String:
#			evt["Encoded"] = parse_json(evt["Encoded"])
	_on_DataReader_new_cached_events(evts)
