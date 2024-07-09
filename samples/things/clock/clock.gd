extends Label

func _process(delta):
	text = Time.get_time_string_from_system()
