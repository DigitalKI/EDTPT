extends Object
class_name DateTime

var year
var month
var day
var hour
var minute
var second
var unix_time : int
var dictime : Dictionary


# Example timestamp 2020-11-22T21:25:54Z
# Called when the node enters the scene tree for the first time.
func _init(_datetime : String = ""):
	if !_datetime:
		dictime = OS.get_datetime()
	else:
		if _datetime.substr(0,4).is_valid_integer():
			year = _datetime.substr(0,4).to_int()
		if _datetime.substr(5,2).is_valid_integer():
			month = _datetime.substr(5,2).to_int()
		if _datetime.substr(8,2).is_valid_integer():
			day = _datetime.substr(8,2).to_int()
		if _datetime.substr(11,2).is_valid_integer():
			hour = _datetime.substr(11,2).to_int()
		if _datetime.substr(14,2).is_valid_integer():
			minute = _datetime.substr(14,2).to_int()
		if _datetime.substr(17,2).is_valid_integer():
			second = _datetime.substr(17,2).to_int()
		dictime["year"] = year
		dictime["month"] = month
		dictime["day"] = day
		dictime["weekday"] = ""
		dictime["dst"] = false
		dictime["hour"] = hour
		dictime["minute"] = minute
		dictime["second"] = second
		to_unix_time()

func from_unix_time(_unixtime : int):
	pass

func to_unix_time():
	unix_time = OS.get_unix_time_from_datetime(dictime)

func _to_string():
	return "%s/%s/%s - %s:%s" % [year, month, day, hour, second]
