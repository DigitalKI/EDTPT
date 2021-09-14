extends Panel

onready var timer = $Timer
onready var materials_table : Tree = $MarginContainer/MaterialsTree
var tree_root : TreeItem
var material_categories : Dictionary
var expanded_items : Array = []

func _ready():
	materials_table.set_column_titles_visible(true)
	create_mats_tree()

func _on_InventoryAndMaterials_visibility_changed():
	if is_visible_in_tree():
		timer.start(30)
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
	for type in data_reader.matinv_manager.material_categories.keys():
		var type_item : TreeItem = materials_table.create_item(tree_root)
		type_item.set_text(0, type)
		type_item.set_text_align(0, TreeItem.ALIGN_CENTER)
		type_item.set_custom_bg_color(0, Color("#ff3300"))
		type_item.set_expand_right(0, true)
		for cat in data_reader.matinv_manager.material_categories[type].keys():
			var cat_item : TreeItem = materials_table.create_item(type_item)
			cat_item.set_text(0, cat)
			cat_item.set_text_align(0, TreeItem.ALIGN_CENTER)
			cat_item.set_custom_color(0, Color("#ff3300"))
			cat_item.set_expand_right(0, true)
			add_mats(type, mats, data_reader.matinv_manager.material_categories[type][cat], cat_item)

# Adds an event to the list using the event object
func add_mats(_type : String, _data : Dictionary, _mat_types : Array, _root_node : TreeItem):
	var col_idx:= 0
	var mats_item : TreeItem = materials_table.create_item(_root_node)
	for mat_type in _mat_types:
		mats_item.set_text(col_idx, _get_material_localized(mat_type, _data[_type]))
		mats_item.set_text_align(col_idx, TreeItem.ALIGN_RIGHT)
		mats_item.set_suffix(col_idx, String(_get_material_amount(mat_type, _data[_type])))
		col_idx += 1

func _get_material_localized(_mat : String, _data : Array):
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

func _get_material_amount(_mat, _data):
	for _m_data in _data:
		if _m_data["Name"].to_lower() == _mat.to_lower():
			return _m_data["Count"]
	return  0

func _on_MaterialsTree_item_activated():
	var selected_item : TreeItem = materials_table.get_selected()
	if selected_item.get_children():
		selected_item.collapsed = !selected_item.collapsed
