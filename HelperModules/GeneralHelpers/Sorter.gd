extends Node
class_name ArraySorter

class EventsSorter:
	static func sort_ascending(a, b):
		if a["timestamp"] < b["timestamp"]:
			return true
		return false
	static func sort_descending(a, b):
		if a["timestamp"] > b["timestamp"]:
			return true
		return false

class Sorter:
	var key_sorter = ""
	func _init(_key : String = "timestamp"):
		key_sorter = _key
	func sort_ascending(a, b):
		if a[key_sorter] < b[key_sorter]:
			return true
		return false
	func sort_descending(a, b):
		if a[key_sorter] > b[key_sorter]:
			return true
		return false

func sort_by_key(_array : Array, _key : String, _desc : bool = 1):
	var _sorter = Sorter.new(_key)
	_array.sort_custom(_sorter, "sort_descending" if _desc else "sort_ascending")
