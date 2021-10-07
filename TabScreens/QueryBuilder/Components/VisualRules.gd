extends Tabs
class_name VisualRules

export(Color) var selected_field_bg : Color = Color("#d5d5d5")
export(Color) var selected_field_fg : Color = Color("#3a3a3a")

onready var rule_fields : Tree = $PanelVisualRules/RuleFields
onready var rule_fields_popup : PopupMenu = $PanelVisualRules/RuleFields/PopupVisualRuleField

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


func add_rule_field(_event_name : String, _event_color : Color, _addr : Array, _value : String = ""):
	if !tree_root is TreeItem:
		tree_root = rule_fields.create_item()
	var table_item : TreeItem = rule_fields.create_item(tree_root)
	table_item.set_text(0, _event_name)
	table_item.set_custom_color(0, Color(0,0,0))
	table_item.set_custom_bg_color(0, _event_color)
	table_item.set_expand_right(0, true)
	table_item.set_text_align(0, TreeItem.ALIGN_CENTER)
	var event_fields = data_reader.dbm.get_table_fields(_event_name)
	# Address field, will be readonly
	var addr_item : TreeItem = rule_fields.create_item(table_item)
	addr_item.set_text(0, "Address")
	addr_item.set_text(1, String(_addr))
	addr_item.set_metadata(1, _addr)
	# Value field to be used in filters
	var matrix_value : TreeItem = rule_fields.create_item(table_item)
	matrix_value.set_text(0, "Value")
	matrix_value.set_text(1, String(_addr))
	matrix_value.set_metadata(1, _addr)
