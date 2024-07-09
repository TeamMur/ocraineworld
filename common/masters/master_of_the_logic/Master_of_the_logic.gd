extends Node

#region переменные мышки
var mouse_pressed_position: Vector2
var mouse_release_position: Vector2

var mouse_is_dragging: bool
var mouse_is_dragged: bool

var mouse_is_echo: bool

var mouse_fast_clicked: bool

var mouse_is_double_clicked: bool
var mouse_double_click_countdown: float = 0.25
var mouse_double_click_timer: Timer

var mouse_fast_click_countdown: float = 0.075
var mouse_fast_click_length: float = 200.0
var mouse_click_timer: Timer

#endregion

func _ready():
	#небольшие правки
	##таймеры для щелчков
	mouse_click_timer = Timer.new()
	mouse_click_timer.one_shot = true
	add_child(mouse_click_timer)
	
	mouse_double_click_timer = Timer.new()
	mouse_double_click_timer.one_shot = true
	add_child(mouse_double_click_timer)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed() and not event.is_echo():
				mouse_is_echo = true
				mouse_pressed_position = get_viewport().get_mouse_position()
				
				mouse_click_timer.start(mouse_fast_click_countdown)
				
				if mouse_double_click_timer.is_stopped() or mouse_is_double_clicked:
					mouse_double_click_timer.start(mouse_double_click_countdown)
					mouse_is_double_clicked = false
				else:
					mouse_is_double_clicked = true
				
			if event.is_released():
				mouse_is_echo =  false
				mouse_release_position = get_viewport().get_mouse_position()
				
				mouse_is_dragging = false
				mouse_is_dragged = true if (mouse_pressed_position - mouse_release_position).length() > 5 else false
				
	if event is InputEventMouseMotion and mouse_is_echo:
		if mouse_click_timer.is_stopped() or (mouse_pressed_position-mouse_release_position).length() > mouse_fast_click_length:
			mouse_is_dragging = true
			mouse_is_dragged = true
