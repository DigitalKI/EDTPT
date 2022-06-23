extends Tabs
class_name VisualRules

export(Color) var rule_field_bg : Color = Color("#f6ca00")
export(Color) var rule_field_fg : Color = Color("#3a3a3a")

onready var rules_table : Tree = $PanelVisualRules/RuleFields
onready var select_color_popup : PopupPanel = $PanelVisualRules/RuleFields/PopupColorPicker
onready var select_color_picker : ColorPicker = $PanelVisualRules/RuleFields/PopupColorPicker/ColorPicker
onready var rule_fields_popup : PopupMenu = $PanelVisualRules/RuleFields/PopupVisualRuleField
onready var rule_fields_CM_popup : PopupMenu = $PanelVisualRules/RuleFields/PopupVisualRuleField/PopupVisualRuleCMatrix
onready var rule_fields_CS_popup : PopupMenu = $PanelVisualRules/RuleFields/PopupVisualRuleField/PopupVisualRuleCScale
onready var rule_fields_SS_popup : PopupMenu = $PanelVisualRules/RuleFields/PopupVisualRuleField/PopupVisualRuleSScale
onready var default_color : ColorRect = $PanelVisualRules/HBoxContainer/DefaultColor

signal config_changed

var tree_root : TreeItem
var query_structure : Dictionary

var example_settings1 = [{"address": ["RingsAmount"]
	, "size_scales":{"min": 0, "max": 15, "min_scale": 0.5, "max_scale": 4}
	, "is_array": false},
	{"address": ["RingsAmount"]
	, "color_scales":{"min": 1, "max": 15, "min_scale": Color(0.0,0.1,0.8), "max_scale": Color(0.0,0.6,0.6)}
	, "is_array": false},
	{"address": ["Ringed"]
	, "color_matrix": {"0": Color(0.0,0.0,1.0)}
	, "is_array": false}
	,{"address": ["prospected"]
	, "color_matrix":{"True": Color(1.0,1.0,1.0)}
	, "is_array": false}]

var example_settings2 = [
	{"address": ["SystemEconomy"]
	, "color_matrix": {"$economy_Refinery;": Color(1.0,0.0,0.0)
					, "$economy_HighTech;": Color(0.0,0.0,1.0)
					, "$economy_Agri;": Color(0.0,1.0,0.0)}
	, "is_array": false}
	,{"address": ["Visits"]
	, "color_matrix":{"0": Color(0.5,0.5,0.0)}
	, "is_array": false}
	,{"address": ["Visits"]
	, "size_scales":{"min": 1, "max": 150, "min_scale": 0.5, "max_scale": 6}
	, "is_array": false}]

func _ready():
	rule_fields_popup.add_submenu_item("Color Matrix", "PopupVisualRuleCMatrix", 2)
	rule_fields_popup.add_submenu_item("Color Scale", "PopupVisualRuleCScale", 3)
	rule_fields_popup.add_submenu_item("Size Scale", "PopupVisualRuleSScale", 4)

func _on_RuleFields_item_rmb_selected(position):
	rule_fields_popup.popup(Rect2(position, rule_fields_popup.rect_size))
	if rules_table.get_item_at_position(position).has_meta("address"):
		rule_fields_popup.set_item_disabled(0, false)
		rule_fields_popup.set_item_disabled(2, false)
		rule_fields_CM_popup.set_item_disabled(0, false)
		rule_fields_CM_popup.set_item_disabled(1, true)
		rule_fields_popup.set_item_disabled(3, false)
		rule_fields_CS_popup.set_item_disabled(0, false)
		rule_fields_CS_popup.set_item_disabled(1, true)
		rule_fields_popup.set_item_disabled(4, false)
		rule_fields_SS_popup.set_item_disabled(0, false)
		rule_fields_SS_popup.set_item_disabled(1, true)
	elif rules_table.get_item_at_position(position).has_meta("color_matrix"):
		rule_fields_popup.set_item_disabled(0, false)
		rule_fields_popup.set_item_disabled(2, false)
		rule_fields_CM_popup.set_item_disabled(0, true)
		rule_fields_CM_popup.set_item_disabled(1, false)
		rule_fields_popup.set_item_disabled(3, true)
		rule_fields_popup.set_item_disabled(4, true)
	elif rules_table.get_item_at_position(position).has_meta("color_scales"):
		rule_fields_popup.set_item_disabled(0, false)
		rule_fields_popup.set_item_disabled(2, true)
		rule_fields_popup.set_item_disabled(3, false)
		rule_fields_CS_popup.set_item_disabled(0, true)
		rule_fields_CS_popup.set_item_disabled(1, false)
		rule_fields_popup.set_item_disabled(4, true)
	elif rules_table.get_item_at_position(position).has_meta("size_scales"):
		rule_fields_popup.set_item_disabled(0, false)
		rule_fields_popup.set_item_disabled(2, true)
		rule_fields_popup.set_item_disabled(3, true)
		rule_fields_popup.set_item_disabled(4, false)
		rule_fields_SS_popup.set_item_disabled(0, true)
		rule_fields_SS_popup.set_item_disabled(1, false)
	elif rules_table.get_item_at_position(position).has_meta("color_rule"):
		rule_fields_popup.set_item_disabled(0, false)
		rule_fields_popup.set_item_disabled(2, true)
		rule_fields_popup.set_item_disabled(3, true)
		rule_fields_popup.set_item_disabled(4, true)
	else:
		rule_fields_popup.set_item_disabled(0, true)
		rule_fields_popup.set_item_disabled(2, true)
		rule_fields_popup.set_item_disabled(3, true)
		rule_fields_popup.set_item_disabled(4, true)

func _on_PopupVisualRuleField_id_pressed(id):
	var selected_item : TreeItem = rules_table.get_selected()
	if selected_item:
		if id == 0:
			rules_table.get_selected().free()
			rules_table.update()
			generate_rulesets()
		elif id == 10:
			add_color_matrix_ruleset(selected_item)
		elif id == 11:
			add_color_matrix_rules(selected_item)
		elif id == 20:
			add_color_scales_ruleset(selected_item)
		elif id == 30:
			add_size_scales_ruleset(selected_item)

func _on_RuleFields_button_pressed(item, column, id):
	var contain_meta : bool = false
	if item.has_meta("color_rule"):
		select_color_picker.color = item.get_meta("color_rule")
		contain_meta = true
	elif item.has_meta("min_scale"):
		select_color_picker.color = item.get_meta("min_scale")
		contain_meta = true
	elif item.has_meta("max_scale"):
		select_color_picker.color = item.get_meta("max_scale")
		contain_meta = true
	if contain_meta:
		select_color_picker.set_meta("button_item", item)
		select_color_picker.set_meta("button_id", id)
		select_color_picker.set_meta("button_column", column)
		var position : Vector2 = rules_table.rect_global_position + rules_table.get_item_area_rect(item, column).size + rules_table.get_item_area_rect(item, column).position
		select_color_popup.popup(Rect2(position, select_color_popup.rect_size))

# When teh color picker hides, it pass the selected color
# to the appropriate control:
# - if there is metadata, it goes to the tree control seleced item
# - if there is NO metadata, it's the default color
func _on_PopupColorPicker_popup_hide():
	if select_color_picker.get_meta_list():
		var selected_button : TreeItem = select_color_picker.get_meta("button_item")
		var button_id : int = select_color_picker.get_meta("button_id")
		var button_column : int = select_color_picker.get_meta("button_column")
		var color_texture := generate_color_texture(selected_button, button_column, select_color_picker.color)
		selected_button.erase_button(button_column, button_id)
		selected_button.add_button(button_column, color_texture)
		for meta in selected_button.get_meta_list():
			selected_button.set_meta(meta, select_color_picker.color)
	else:
		default_color.color = select_color_picker.color
	generate_rulesets()

func _on_RuleFields_item_edited():
	generate_rulesets()

func _on_BtDefaultColor_pressed():
	for meta in select_color_picker.get_meta_list():
		select_color_picker.remove_meta(meta)
	select_color_popup.popup_centered()

func _on_BtRemoveAll_pressed():
	rules_table.clear()
	generate_rulesets()

func add_field_addr(_addr : Array, _field_color : Color = Color(1,1,1), _generate_ruleset : bool = true):
	tree_root = rules_table.get_root()
	if !tree_root:
		tree_root = rules_table.create_item()
	var table_item : TreeItem = rules_table.create_item(tree_root)
	# adds the address field, that will be parent of the other parameters
	table_item.set_text(0, String(_addr))
	table_item.set_meta("address", _addr)
	table_item.set_custom_color(0, Color(0,0,0))
	table_item.set_custom_bg_color(0, _field_color)
	table_item.set_expand_right(0, true)
	table_item.set_text_align(0, TreeItem.ALIGN_CENTER)
	if _generate_ruleset:
		generate_rulesets()
	return table_item

func add_size_scales_ruleset(_addr_item : TreeItem, _scale_rules : Dictionary = {}):
	var sscales_ruleset : TreeItem = rules_table.create_item(_addr_item)
	sscales_ruleset.set_meta("size_scales", _scale_rules)
	sscales_ruleset.set_text(0, "Size scales rule")
	sscales_ruleset.set_expand_right(0, true)
	sscales_ruleset.set_text_align(0, TreeItem.ALIGN_CENTER)
	sscales_ruleset.set_custom_color(0, rule_field_fg)
	sscales_ruleset.set_custom_bg_color(0, rule_field_bg)
	add_size_scale_rules(sscales_ruleset, _scale_rules)

func add_size_scale_rules(_sscale_ruleset : TreeItem, _size_scales_rules : Dictionary = {}):
	if _size_scales_rules.empty():
		_size_scales_rules["min"] = 0
		_size_scales_rules["max"] = 1
		_size_scales_rules["min_scale"] = 0.5
		_size_scales_rules["max_scale"] = 2.0
	for key in _size_scales_rules.keys():
		var s_scale_rule : TreeItem = rules_table.create_item(_sscale_ruleset)
		s_scale_rule.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		s_scale_rule.set_editable(1, true)
		if key.ends_with("_scale"):
			s_scale_rule.set_range_config(1, 0.0, 10.0, 0.1)
		else:
			s_scale_rule.set_range_config(1, -999999999, 999999999, 0.01)
		s_scale_rule.set_range(1, _size_scales_rules[key])
		s_scale_rule.set_text(0, key)
		s_scale_rule.set_meta(key, _size_scales_rules[key])
	generate_rulesets()

func add_color_scales_ruleset(_addr_item : TreeItem, _color_rules : Dictionary = {}):
	var cscales_ruleset : TreeItem = rules_table.create_item(_addr_item)
	cscales_ruleset.set_meta("color_scales", _color_rules)
	cscales_ruleset.set_text(0, "Color scales rule")
	cscales_ruleset.set_expand_right(0, true)
	cscales_ruleset.set_text_align(0, TreeItem.ALIGN_CENTER)
	cscales_ruleset.set_custom_color(0, rule_field_fg)
	cscales_ruleset.set_custom_bg_color(0, rule_field_bg)
	add_color_scale_rules(cscales_ruleset, _color_rules)

func add_color_scale_rules(_cscale_ruleset : TreeItem, _color_scales_rules : Dictionary = {}):
	if _color_scales_rules.empty():
		_color_scales_rules["min"] = 0
		_color_scales_rules["max"] = 1
		_color_scales_rules["min_scale"] = Color(0,0,0)
		_color_scales_rules["max_scale"] = Color(1,1,1)
	for key in _color_scales_rules.keys():
		var c_scale_rule : TreeItem = rules_table.create_item(_cscale_ruleset)
		if key.ends_with("_scale"):
			if _color_scales_rules[key] is Color:
				c_scale_rule.add_button(1, generate_color_texture(c_scale_rule, 0, _color_scales_rules[key]))
		else:
			c_scale_rule.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
			c_scale_rule.set_range_config(1, -999999999, 999999999, 0.01)
			c_scale_rule.set_range(1, _color_scales_rules[key])
			c_scale_rule.set_editable(1, true)
		c_scale_rule.set_text(0, key)
		c_scale_rule.set_meta(key, _color_scales_rules[key])
	generate_rulesets()

func add_color_matrix_ruleset(_addr_item : TreeItem, _color_rules : Dictionary = {}):
	var cmatrix_ruleset : TreeItem = rules_table.create_item(_addr_item)
	cmatrix_ruleset.set_meta("color_matrix", {})
	cmatrix_ruleset.set_text(0, "Color matrix rule")
	cmatrix_ruleset.set_expand_right(0, true)
	cmatrix_ruleset.set_text_align(0, TreeItem.ALIGN_CENTER)
	cmatrix_ruleset.set_custom_color(0, rule_field_fg)
	cmatrix_ruleset.set_custom_bg_color(0, rule_field_bg)
	add_color_matrix_rules(cmatrix_ruleset, _color_rules)

func add_color_matrix_rules(_cmatrix_ruleset : TreeItem, _color_rules : Dictionary = {}):
	if _color_rules.empty():
		_color_rules["edit to set value"] = Color(1,1,1)
	for key in _color_rules.keys():
		var c_matrix_rule : TreeItem = rules_table.create_item(_cmatrix_ruleset)
		var rule_color : = Color(_color_rules[key].split(",")[0], _color_rules[key].split(",")[1], _color_rules[key].split(",")[2], _color_rules[key].split(",")[3])
		c_matrix_rule.add_button(0, generate_color_texture(c_matrix_rule, 0, rule_color))
		c_matrix_rule.set_text(1, key)
		c_matrix_rule.set_meta("color_rule", rule_color)
		c_matrix_rule.set_editable(1, true)
	generate_rulesets()

func generate_color_texture(_item : TreeItem, _column : int, _color : Color = Color(1,1,1)) -> ImageTexture:
	var c_matrix_color : ImageTexture = ImageTexture.new()
	var color_image : Image = Image.new()
	color_image.create(rules_table.get_item_area_rect(_item, _column).size.x - 4, rules_table.get_item_area_rect(_item, _column).size.y - 4, true, Image.FORMAT_RGBA8)
	color_image.lock()
	color_image.fill(_color)
	color_image.unlock()
	c_matrix_color.create_from_image(color_image, ImageTexture.FLAGS_DEFAULT)
	return c_matrix_color

func generate_rulesets():
	# assign the default color
	query_structure["default_color"] = default_color.color
	# assign the rulesets
	query_structure["rules"] = []
	var root_item : TreeItem = rules_table.get_root()
	if root_item:
		var address_item : TreeItem = root_item.get_children()
		while address_item:
			if address_item.has_meta("address"):
				var cmatrix_ruleset_item : TreeItem = address_item.get_children()
				while cmatrix_ruleset_item:
					# if we find a "color_matrix" metadata then we add this ruleset
					# to the query structure "rules" array
					var ruleset : Dictionary
					var loop_ruleset : String = ""
					if cmatrix_ruleset_item.has_meta("color_matrix"):
						ruleset = {
							"address": address_item.get_meta("address")
							, "color_matrix": {}
							, "is_array": false}
						loop_ruleset = "color_matrix"
					elif cmatrix_ruleset_item.has_meta("color_scales"):
						ruleset = {
							"address": address_item.get_meta("address")
							, "color_scales": {}
							, "is_array": false}
						loop_ruleset = "color_scales"
					elif cmatrix_ruleset_item.has_meta("size_scales"):
						ruleset = {
							"address": address_item.get_meta("address")
							, "size_scales": {}
							, "is_array": false}
						loop_ruleset = "size_scales"
					if !loop_ruleset.empty():
						var rule_item : TreeItem = cmatrix_ruleset_item.get_children()
						while rule_item:
							if rule_item.has_meta("color_rule"):
								var rule_color : Color = rule_item.get_meta("color_rule")
								var rule_value : String = rule_item.get_text(1)
								ruleset[loop_ruleset][rule_value] = rule_color
							elif rule_item.has_meta("min"):
								ruleset[loop_ruleset]["min"] = rule_item.get_range(1)
							elif rule_item.has_meta("max"):
								ruleset[loop_ruleset]["max"] = rule_item.get_range(1)
							elif rule_item.has_meta("min_scale") && cmatrix_ruleset_item.has_meta("color_scales"):
								var rule_color : Color = rule_item.get_meta("min_scale")
								ruleset[loop_ruleset]["min_scale"] = rule_color
							elif rule_item.has_meta("max_scale") && cmatrix_ruleset_item.has_meta("color_scales"):
								var rule_color : Color = rule_item.get_meta("max_scale")
								ruleset[loop_ruleset]["max_scale"] = rule_color
							elif rule_item.has_meta("min_scale") && cmatrix_ruleset_item.has_meta("size_scales"):
								ruleset[loop_ruleset]["min_scale"] = rule_item.get_range(1)
							elif rule_item.has_meta("max_scale") && cmatrix_ruleset_item.has_meta("size_scales"):
								ruleset[loop_ruleset]["max_scale"] = rule_item.get_range(1)
							rule_item = rule_item.get_next()
						query_structure["rules"].append(ruleset)
						
					cmatrix_ruleset_item = cmatrix_ruleset_item.get_next()
			address_item = address_item.get_next()
	emit_signal("config_changed")

func ruleset_to_ui(_rulesets : Array):
	rules_table.clear()
	for ruleset in _rulesets:
		if ruleset is Dictionary:
			for key in ruleset.keys():
				if key == "color_matrix":
					add_color_matrix_ruleset(add_field_addr(ruleset["address"], Color(1,1,1), false), ruleset["color_matrix"])
				elif key == "color_scales":
					add_color_scales_ruleset(add_field_addr(ruleset["address"], Color(1,1,1), false), ruleset["color_scales"])
				elif key == "size_scales":
					add_size_scales_ruleset(add_field_addr(ruleset["address"], Color(1,1,1), false), ruleset["size_scales"])

