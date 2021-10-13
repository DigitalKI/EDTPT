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

var tree_root : TreeItem
var query_structure : Dictionary

var example_settings1 = [{"addr": ["RingsAmount"]
	, "size_scales":{"min": 0, "max": 15, "min_scale": 0.5, "max_scale": 4}
	, "is_array": false},
	{"addr": ["RingsAmount"]
	, "color_scales":{"min": 1, "max": 15, "min_scale": Color(0.0,0.1,0.8), "max_scale": Color(0.0,0.6,0.6)}
	, "is_array": false},
	{"addr": ["Ringed"]
	, "color_matrix": {"0": Color(0.0,0.0,1.0)}
	, "is_array": false}
	,{"addr": ["prospected"]
	, "color_matrix":{"True": Color(1.0,1.0,1.0)}
	, "is_array": false}]

var example_settings2 = [
	{"addr": ["SystemEconomy"]
	, "color_matrix": {"$economy_Refinery;": Color(1.0,0.0,0.0)
					, "$economy_HighTech;": Color(0.0,0.0,1.0)
					, "$economy_Agri;": Color(0.0,1.0,0.0)}
	, "is_array": false}
	,{"addr": ["Visits"]
	, "color_matrix":{"0": Color(0.5,0.5,0.0)}
	, "is_array": false}
	,{"addr": ["Visits"]
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
		rule_fields_popup.set_item_disabled(0, true)
		rule_fields_popup.set_item_disabled(2, false)
		rule_fields_CM_popup.set_item_disabled(0, true)
		rule_fields_CM_popup.set_item_disabled(1, false)
		rule_fields_popup.set_item_disabled(3, true)
		rule_fields_popup.set_item_disabled(4, true)
	elif rules_table.get_item_at_position(position).has_meta("color_scales"):
		rule_fields_popup.set_item_disabled(0, true)
		rule_fields_popup.set_item_disabled(2, true)
		rule_fields_popup.set_item_disabled(3, false)
		rule_fields_CS_popup.set_item_disabled(0, true)
		rule_fields_CS_popup.set_item_disabled(1, false)
		rule_fields_popup.set_item_disabled(4, true)
	elif rules_table.get_item_at_position(position).has_meta("size_scales"):
		rule_fields_popup.set_item_disabled(0, true)
		rule_fields_popup.set_item_disabled(2, true)
		rule_fields_popup.set_item_disabled(3, true)
		rule_fields_popup.set_item_disabled(4, false)
		rule_fields_SS_popup.set_item_disabled(0, true)
		rule_fields_SS_popup.set_item_disabled(1, false)
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
		elif id == 10:
			add_color_matrix_ruleset(selected_item)
		elif id == 11:
			add_color_matrix_rule(selected_item)
		elif id == 30:
			add_color_matrix_rule(selected_item)

func _on_RuleFields_button_pressed(item, column, id):
	if item.has_meta("color_rule"):
		select_color_picker.color = item.get_meta("color_rule")
		select_color_picker.set_meta("button_item", item)
		select_color_picker.set_meta("button_id", id)
		select_color_picker.set_meta("button_column", column)
		var position : Vector2 = rules_table.rect_global_position + rules_table.get_item_area_rect(item, column).size + rules_table.get_item_area_rect(item, column).position
		select_color_popup.popup(Rect2(position, select_color_popup.rect_size))

func _on_PopupColorPicker_popup_hide():
	var selected_button : TreeItem = select_color_picker.get_meta("button_item")
	var button_id : int = select_color_picker.get_meta("button_id")
	var button_column : int = select_color_picker.get_meta("button_column")
	var color_texture := generate_color_texture(selected_button, button_column, select_color_picker.color)
	selected_button.erase_button(button_column, button_id)
	selected_button.add_button(button_column, color_texture)
	selected_button.set_meta("color_rule", select_color_picker.color)
	generate_ruleset()

func _on_BtRemoveAll_pressed():
	rules_table.clear()
	generate_ruleset()

func add_field_addr(_addr : Array, _field_color : Color):
	if !tree_root is TreeItem:
		tree_root = rules_table.create_item()
	var table_item : TreeItem = rules_table.create_item(tree_root)
	# adds the address field, that will be parent of the other parameters
	table_item.set_text(0, String(_addr))
	table_item.set_meta("address", _addr)
	table_item.set_custom_color(0, Color(0,0,0))
	table_item.set_custom_bg_color(0, _field_color)
	table_item.set_expand_right(0, true)
	table_item.set_text_align(0, TreeItem.ALIGN_CENTER)
	generate_ruleset()

func add_color_matrix_ruleset(_addr_item : TreeItem):
	var cmatrix_ruleset : TreeItem = rules_table.create_item(_addr_item)
	cmatrix_ruleset.set_meta("color_matrix", [])
	cmatrix_ruleset.set_text(0, "Color matrix rule")
	cmatrix_ruleset.set_expand_right(0, true)
	cmatrix_ruleset.set_text_align(0, TreeItem.ALIGN_CENTER)
	cmatrix_ruleset.set_custom_color(0, rule_field_fg)
	cmatrix_ruleset.set_custom_bg_color(0, rule_field_bg)
	#Add at least 1 color rule
	add_color_matrix_rule(cmatrix_ruleset)

func add_color_matrix_rule(_cmatrix_ruleset : TreeItem):
	var c_matrix_rule : TreeItem = rules_table.create_item(_cmatrix_ruleset)
	c_matrix_rule.add_button(0, generate_color_texture(c_matrix_rule, 0, Color(1,1,1)))
	c_matrix_rule.set_text(1, "edit to set value")
	c_matrix_rule.set_editable(1, true)
	c_matrix_rule.set_meta("color_rule", Color(1,1,1))
	generate_ruleset()

func generate_color_texture(_item : TreeItem, _column : int, _color : Color = Color(1,1,1)) -> ImageTexture:
	var c_matrix_color : ImageTexture = ImageTexture.new()
	var color_image : Image = Image.new()
	color_image.create(rules_table.get_item_area_rect(_item, _column).size.x - 4, rules_table.get_item_area_rect(_item, _column).size.y - 4, true, Image.FORMAT_RGBA8)
	color_image.lock()
	color_image.fill(_color)
	color_image.unlock()
	c_matrix_color.create_from_image(color_image, ImageTexture.FLAGS_DEFAULT)
	return c_matrix_color

func generate_ruleset():
	query_structure["rules"] = []
	var root_item : TreeItem = rules_table.get_root()
	var ruleset_item : TreeItem = root_item.get_children()
	while ruleset_item:
		var cmatrix_item : TreeItem = ruleset_item.get_children()
		while cmatrix_item:
			# if we find a "color_matrix" metadata then we add this ruleset
			# to the query structure "rules" array 
			if cmatrix_item.has_meta("color_matrix"):
				var cmatrix_ruleset : Dictionary = {"color_matrix": {}}
				var color_matrix_item : TreeItem = cmatrix_item.get_children()
				var cmatrix_item_color : TreeItem = cmatrix_item.get_children()
				if cmatrix_item_color.has_meta("color_rule"):
					var rule_color : Color = cmatrix_item_color.get_meta("color_rule")
					var rule_value : String = cmatrix_item_color.get_text(1)
					cmatrix_ruleset["color_matrix"][rule_value] = rule_color
				query_structure["rules"].append(cmatrix_ruleset)
			cmatrix_item = cmatrix_item.get_next()
		ruleset_item = ruleset_item.get_next()
	pass

