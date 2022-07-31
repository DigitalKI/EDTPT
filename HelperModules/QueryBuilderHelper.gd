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
			fields_query += ", %s.\'%s\'" % [tbl, fld]
			if _query_structure[tbl][fld]["filter"]:
				filters_query += " AND %s.\'%s\' %s" % [tbl, fld, _query_structure[tbl][fld]["filter"]]
			if fld == "timestamp":
				sort_query = " ORDER BY {tbl}.{fld}".format({"tbl": tbl, "fld": fld})
		var prev_sysaddress = "SystemAddress" if prev_tbl != "edsm_systems" else "id64"
		var tbl_sysaddress = "SystemAddress" if tbl != "edsm_systems" else "id64"
		tables_query += " INNER JOIN {tbl} ON {prev_tbl}.{prev_sysaddress} = {tbl}.{tbl_sysaddress}".format({"prev_tbl": prev_tbl, "tbl": tbl, "prev_sysaddress": prev_sysaddress, "tbl_sysaddress": tbl_sysaddress}) if has_sys_addr && prev_tbl.length() > 0 else tbl
		prev_tbl = tbl
	resulting_query += fields_query.trim_prefix(",") + tables_query + filters_query + sort_query
	return resulting_query

func get_query_structure_fields(_struct : Dictionary, _details : bool = false) -> Array:
	var fld_lst = []
	for tbl in _struct:
		for fld in _struct[tbl]:
			if _details && _struct[tbl][fld]["detail"]:
				fld_lst.append(fld)
			elif _struct[tbl][fld]["list"]:
				fld_lst.append(fld)
	return fld_lst
