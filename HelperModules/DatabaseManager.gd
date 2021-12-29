extends Object
class_name DatabaseManager

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db : SQLite

var db_creation_script := "res://Database/db_json_schema"
var db_path := "user://Database/"
var db_name := "edtpt"

var not_usable_columns := ["Id", "ID", "id"]
var forbidden_columns := ["From", "To", "Group", "By", "Sort", "Asc"]
var event_types : Array = []

func _init():
	db = SQLite.new()
	db.path = db_path + db_name
	# Open the database using the db_name found in the path variable
	db.open_db()
	prepare_database()
	update_event_types()

func _ready():
	pass

func _exit_tree():
	db.close_db()

func prepare_database(_verbose : bool = false):
	var result := true
	var dir : Directory = Directory.new()
	if !dir.dir_exists(db_path):
		dir.make_dir(db_path)
	
	db.verbose_mode = _verbose
	if db.select_rows("sqlite_master", "type = 'table'", ["*"]).empty():
		result = db.import_from_json(db_creation_script)
		create_index_on_table("edsm_systems", ["id64","sector_x", "sector_y", "sector_z"])
	return result

func clean_database_and_export():
	clean_database(true)
	db.export_to_json("user://Database/edtpt_jsnbkp")

func clean_database(_onlydata = false):
	var tables = db.select_rows("sqlite_master", "type = 'table'", ["*"]).duplicate()
	if _onlydata:
		for table in tables:
			db.delete_rows(table["name"],"")
	else:
		for table in tables:
			if table["name"] != "sqlite_sequence" && table["name"] != "Commander" && table["name"] != "Fileheader" && table["name"] != "event_types":
				if db.drop_table(table["name"]):
					logger.log_event("Dropping table %s" % table["name"])
				else:
					logger.log_event("Could not delete table %s" % table["name"])
	db.delete_rows("Commander","")
	db.delete_rows("Fileheader","")
	db.delete_rows("event_types","")
	var selected_rows = db.select_rows("sqlite_sequence", "", ["*"])
	for seq in selected_rows:
		seq["seq"] = 0
		db.update_rows("sqlite_sequence", "name = '" + seq["name"] + "'", seq)
	db.query("VACUUM;")
	db.query("CREATE TABLE IF NOT EXISTS Backpack (Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,CMDRId INTEGER NOT NULL,FileheaderId INTEGER NOT NULL,'timestamp' text,'Items' text,'Components' text,'Consumables' text,'Data' text);")

func update_event_types():
	event_types.clear()
	for evt in db.select_rows("event_types", "", ["*"]):
		event_types.append(evt["event_type"])
	event_types.sort()

func get_all_event_tables(_filter : String = ""):
	var sql_all_tables : Array = db.select_rows("sqlite_master", "type = 'table' AND tbl_name != 'sqlite_sequence' " + _filter + " ORDER BY tbl_name ASC", ["tbl_name"])
	var table_evt_types := []
	for evt_tbl in sql_all_tables:
		table_evt_types.append(evt_tbl["tbl_name"])
	return table_evt_types

func get_table_fields(_table_name : String):
	if data_reader.dbm.db.query("PRAGMA table_info(%s);" % _table_name):
		return data_reader.dbm.db.query_result.duplicate(true)
	return []

func db_set_event_type(_event_type):
	# Create the event type
	if db.select_rows("event_types", "event_type = '" + _event_type + "'", ["*"]).empty():
		if !db.insert_rows("event_types", [{"event_type": _event_type}]):
			logger.log_event("There was a problem adding a new event type")

func db_execute_select(_select : String) -> Array:
	if _select.trim_prefix(" ").to_lower().begins_with("select"):
		if db.query(_select):
			return db.query_result.duplicate(true)
	return []

# Creates a table from the event type, 
# automatically generating columns with its respective type.
# Table is not created if it already exists in the database.
func create_table_from_event(_event : Dictionary, _is_event : bool = true):
	var table_name : String = _event["event"]
	# Do not create if exists already
	if  db.select_rows("event_types", "event_type = '" + table_name + "'", ["*"]).empty():
		db_set_event_type(table_name)
		update_event_types()
		var table_dict : Dictionary = {}
		table_dict["Id"] = {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment" : true}
		if _is_event:
			table_dict["CMDRId"] = {"data_type":"int", "not_null": true}
			table_dict["FileheaderId"] = {"data_type":"int", "not_null": true}
		
		for column in _event.keys():
			if column != "event":
				var data_type = "text"
				if _event[column] is String && (_event[column] == "true" ||  _event[column] == "false"):
					data_type = "int"
#				elif typeof(_event[column]) == TYPE_ARRAY:
#					data_type = "blob"
				elif typeof(_event[column]) == TYPE_INT:
					data_type = "int"
				elif typeof(_event[column]) == TYPE_REAL:
					data_type = "numeric"
				
				# Apparently this column name cannot work
				# We add single quotes
				# forbidden_columns is defined at the beginning of this script
				# , as we're gong to use it for inserts too
				if forbidden_columns.has(column):
					table_dict["'" + column + "'"] = {"data_type": data_type}
				elif not_usable_columns.has(column):
					table_dict[column + "_" + column] = {"data_type": data_type}
				else:
					table_dict[column] = {"data_type": data_type}
		if !db.create_table(table_name, table_dict):
			logger.log_event("There was an error creating table %s" % table_name)
	else:
			logger.log_event("Table %s already exists!" % table_name)

func update_or_insert_multiple(_table_name : String, _data : Array):
	var query_string = "INSERT OR REPLACE INTO " + _table_name + " "
	var fields : String = "("
	var values : String = ""
	var result = true
	var got_fields = false
	for _row in _data:
		values += "("
		for key in _row.keys():
			if !got_fields:
				fields += String(key) + ", "
			if _row[key] is String:
				values += ", '" + _row[key] + "'"
			elif _row[key] == null:
				values += ", null"
			else:
				values += String(_row[key])
		values = values.trim_prefix(", ") + ")\n"
		got_fields = true
		query_string += ")"
	query_string +=  fields.trim_suffix(", ") + ") VALUES " + values
	result = db.query(query_string)
	return result

func create_index_on_table(_table_name : String, _fields : Array, _is_unique : bool = false):
	var index_query : String = "CREATE %s INDEX %s_idx" % [("UNIQUE" if _is_unique else ""), _table_name]
	index_query += " ON edsm_systems (%s)" % PoolStringArray(_fields).join(", ")
	return db.query(index_query)

func convert_data_to_inserts(_evt, _is_event = true):
	# we now assign the appropriate value to certain fields
	# such as true/false, Dictionary, Array
	for col_key in _evt.keys():
		if _evt[col_key] is Array:
			_evt[col_key] = JSON.print(_evt[col_key])
		elif _evt[col_key] is Dictionary:
			_evt[col_key] = JSON.print(_evt[col_key])
		elif _evt[col_key] is String:
			if _evt[col_key] == "false":
				_evt[col_key] = 0
			elif _evt[col_key] == "true":
				_evt[col_key] = 1
		
		# Some columns have to be changed as they are reserved keywords or already used
		# leave this code last, as it is iterating through the columns
		if forbidden_columns.has(col_key) && _is_event:
			_evt["'" + col_key + "'"] = _evt[col_key]
			_evt.erase(col_key)
		elif not_usable_columns.has(col_key) && _is_event:
			_evt[col_key + "_" + col_key] = _evt[col_key]
			_evt.erase(col_key)
	return _evt
