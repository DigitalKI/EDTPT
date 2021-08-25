extends Node
class_name DatabaseManager

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db : SQLite

var db_creation_script := "res://Database/db_json_schema"
var db_path := "user://Database/"
var db_name := "edtpt"

var not_usable_columns := ["Id", "ID"]
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
#	db.export_to_json("user://Database/edtpt_jsnbkp")
	if db.select_rows("sqlite_master", "type = 'table'", ["*"]).empty():
		result = db.import_from_json(db_creation_script)
	return result

func clean_database():
	var tables = db.select_rows("sqlite_master", "type = 'table'", ["*"]).duplicate()
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
	# I should also add a counter reset for the autoincrement fields

func update_event_types():
	event_types.clear()
	for evt in db.select_rows("event_types", "", ["*"]):
		event_types.append(evt["event_type"])
	event_types.sort()

func get_all_event_tables():
	var table_evt_types := []
	for evt_tbl in db.select_rows("sqlite_master", "type = 'table'", ["*"]):
		table_evt_types.append(evt_tbl["name"])
	return table_evt_types

func db_set_event_type(_event_type):
	# Create the event type
	if db.select_rows("event_types", "event_type = '" + _event_type + "'", ["*"]).empty():
		if !db.insert_rows("event_types", [{"event_type": _event_type}]):
			logger.log_event("There was a problem adding a new event type")

# Creates a table from the event type, 
# automatically generating columns with its respective type.
# Table is not created if it already exists in the database.
func create_table_from_event(_event : Dictionary):
	var table_name = _event["event"]
	# Do not create if exists already
	if !event_types.has(table_name):
		db_set_event_type(table_name)
		update_event_types()
		var table_dict : Dictionary = {}
		table_dict["Id"] = {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment" : true}
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
		