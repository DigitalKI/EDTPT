extends Node
class_name edsmDataManager

var get_systems_cube := "https://www.edsm.net/api-v1/cube-systems/"
var http_request : HTTPRequest

var star_systems := []

signal systems_received

# Called when the node enters the scene tree for the first time.
func add_html_reader():
	if !http_request:
		http_request = HTTPRequest.new()

func get_systems_in_cube(_coords : Vector3, _size_ly : float):
	http_request.connect("request_completed", self, "_http_request_completed")
	var params := "%s/%s/%s/%s?showCoordinates=1&showPermit=1&showInformation=1&showPrimaryStar=1" % [_coords.x, _coords.y, _coords.z, _size_ly]
	var error = http_request.request(get_systems_cube + params)
	if error != OK:
		data_reader.log_event("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	star_systems = parse_json(body.get_string_from_utf8())
	emit_signal("systems_received")

