extends HTTPRequest
class_name XHRHandler
# ANTIMONY 'XHRHandler' by Banderi --- v1.0

var uri = ""

signal finished

func _finished(result, response_code, headers, body):
	Log.generic(XHR,str("<",name,"> ",uri," responded with ",body.size()," bytes"))
	var response = {
		"result": result,
		"response_code": response_code,
		"headers": headers,
		"body": body.get_string_from_utf8(),
	}
	emit_signal("finished", response)
	queue_free()

func _enter_tree():
	var _r = self.connect("request_completed", self, "_finished")
