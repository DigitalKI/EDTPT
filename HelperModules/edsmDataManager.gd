extends Node
class_name edsmDataManager

var get_systems_cube := "https://www.edsm.net/api-v1/cube-systems"
var http_request : HTTPRequest

var star_systems := []

signal systems_received

# Called when the node enters the scene tree for the first time.
func add_html_reader():
	if !http_request:
		http_request = HTTPRequest.new()
		http_request.connect("request_completed", self, "_http_request_completed")

func get_systems_in_cube(_coords : Vector3, _size_ly : float):
	if http_request.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		var params := "?x=%s&y=%s&z=%s&size=%s&showId=1&showCoordinates=1&showPermit=1&showInformation=1&showPrimaryStar=1" % [_coords.x, _coords.y, _coords.z, _size_ly]
		var error = http_request.request(get_systems_cube + params)
		if error != OK:
			data_reader.log_event("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	var string_result : String = body.get_string_from_utf8()
	if string_result.length() > 2:
		star_systems = parse_json(string_result)
	else:
		star_systems = []
	emit_signal("systems_received")

