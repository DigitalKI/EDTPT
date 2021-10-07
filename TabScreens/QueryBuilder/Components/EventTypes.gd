extends Tabs
class_name EventTypesTable

onready var event_types_table : ItemList = $EventTypesTable

export(Color) var coords_bg : Color = Color("#ff7802")
export(Color) var coords_fg : Color = Color("#230089")
export(Color) var system_bg : Color = Color("#0033cc")
export(Color) var system_fg : Color = Color("#ff7802")

signal event_type_selected(event_type, event_color)

func _on_EventTypesTable_item_activated(index):
	var selected_event_type := event_types_table.get_item_text(index)
	var selected_event_color := event_types_table.get_item_custom_bg_color(index)
	emit_signal("event_type_selected", selected_event_type, selected_event_color)

func list_all_tables():
	event_types_table.clear()
	var event_tables = data_reader.dbm.get_all_event_tables()
	for sys_tbl in data_reader.query_builder.event_tables_coords:
		event_types_table.add_item(sys_tbl)
		event_types_table.set_item_custom_bg_color(event_types_table.get_item_count() - 1, coords_bg)
		event_types_table.set_item_custom_fg_color(event_types_table.get_item_count() - 1, coords_fg)
	for addr_tbl in data_reader.query_builder.event_tables_system_addr:
		if !data_reader.query_builder.event_tables_coords.has(addr_tbl):
			event_types_table.add_item(addr_tbl)
			event_types_table.set_item_custom_bg_color(event_types_table.get_item_count() - 1, system_bg)
			event_types_table.set_item_custom_fg_color(event_types_table.get_item_count() - 1, system_fg)
	for tbl in event_tables:
		if !data_reader.query_builder.event_tables_coords.has(tbl) && !data_reader.query_builder.event_tables_system_addr.has(tbl):
			event_types_table.add_item(tbl)

func get_event_type_color_by_text(_text) -> Color:
	for idx in event_types_table.get_item_count():
		if event_types_table.get_item_text(idx) == _text:
			return event_types_table.get_item_custom_bg_color(idx)
	return Color()
