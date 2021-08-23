extends Object
class_name DateTime

var year := 0
var month := 0
var day := 0
var hour := 0
var minute := 0
var second := 0
var unix_time : int
var dictime : Dictionary


# Example timestamp 2020-11-22T21:25:54Z
# Called when the node enters the scene tree for the first time.
func _init(_datetime : String = ""):
	if !_datetime:
		dictime = OS.get_datetime(true)
		from_dictime()
		to_unix_time()
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

func from_dictime(_value = dictime):
	year = _value["year"]
	month =_value["month"]
	day = _value["day"]
	hour = _value["hour"]
	minute = _value["minute"]
	second = _value["second"]
	
func from_unix_time(_unixtime : int = unix_time):
	dictime = OS.get_datetime_from_unix_time(_unixtime)
	from_dictime(dictime)

func to_unix_time():
	unix_time = OS.get_unix_time_from_datetime(dictime)

func date_add(_unit : String, _value : int):
	var multiplier := 1
	if dictime.has(_unit):
		to_unix_time()
		if _unit == "minute":
			multiplier = 60
		elif _unit == "hour":
			multiplier = 3600
		elif _unit == "day":
			multiplier = 3600 * 24
		elif _unit == "month":
			multiplier = 3600 * 24 * 30 #this needs a proper calculation
		elif _unit == "year":
			multiplier = 3600 * 24 * 365
		unix_time += _value * multiplier
	from_unix_time(unix_time)

func _to_string(_original_format = false):
	if _original_format:
		return "%s-%02d-%02dT%02d:%02d:%02dZ" % [year, month, day, hour, minute, second]
	else:
		return "%s/%s/%s - %s:%s:%s" % [year, month, day, hour, minute, second]
