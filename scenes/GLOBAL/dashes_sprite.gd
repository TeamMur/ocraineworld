extends Sprite2D
class_name DashesSprite

@onready var timer: Timer = Timer.new()
@export var timer_wait_time = 0.15

func _ready():
	add_timer()

func add_timer():
	timer.wait_time = timer_wait_time
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(set_sprite_frame)
	add_child(timer)

#для таймера и черточек
func set_sprite_frame():
	frame_coords.x = 0 if frame_coords.x + 1 == hframes else frame_coords.x + 1
	
	##временно
	if frame == hframes-1: reached_last_frame.emit()
	if frame == necessary_frame: reached_necessary_frame.emit()


##временные решения
var necessary_frame = -1

signal reached_last_frame
signal reached_necessary_frame
