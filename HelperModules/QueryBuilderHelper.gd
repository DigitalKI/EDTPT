extends Node
class_name QueryBuilderHelper

var event_tables_coords : Array
var event_tables_system_addr : Array

func _init():
	event_tables_coords = data_reader.dbm.get_all_event_tables(" AND (sql like '%StarPos%' OR sql LIKE '%coords%')")
	event_tables_system_addr = data_reader.dbm.get_all_event_tables(" AND SQL LIKE '%SystemAddress%'")

func query_structure_to_select(_query_structure : Dictionary):
	var resulting_query : String = "SELECT"
	var tables_query := "\n FROM "
	var fields_query := ""
	var filters_query := "\n WHERE 1=1 "
	var sort_query := ""
	var prev_tbl := ""
	for tbl in _query_structure.keys():
		var has_sys_addr : bool = event_tables_coords.has(tbl) || event_tables_system_addr.has(tbl)
		for fld in _query_structure[tbl].keys():
			fields_query += ", %s.%s" % [tbl, fld]
			if _query_structure[tbl][fld]["filter"]:
				filters_query += " AND %s %s" % [fld, _query_structure[tbl][fld]["filter"]]
			if fld == "timestamp":
				sort_query = " ORDER BY {tbl}.{fld}".format({"tbl": tbl, "fld": fld})
		tables_query += " INNER JOIN {tbl} ON {prev_tbl}.SystemAddress = {tbl}.SystemAddress".format({"prev_tbl": prev_tbl, "tbl": tbl}) if has_sys_addr && prev_tbl.length() > 0 else tbl
		prev_tbl = tbl
	resulting_query += fields_query.trim_prefix(",") + tables_query + filters_query + sort_query
	return resulting_query
