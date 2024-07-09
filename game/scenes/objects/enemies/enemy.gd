extends CharacterBody2D
class_name Enemy

@onready var collision = $Collision
@onready var visibility_area = $VisibilityArea
@onready var sprite = $Sprite

@export var characteristics_res: Resource
@export var speed = 1.0

var target: Object

func _ready():
	#чтобы у каждой сущности оно было разным
	#characteristics_res = characteristics_res.duplicate()
	
	visibility_area.body_entered.connect(_on_visibility_area_body_entered)

func _physics_process(delta):
	if target and global_position.distance_to(target.global_position) > 10:
		velocity = global_position.direction_to(target.global_position) * speed * (delta*10000)
	else:
		velocity = Vector2.ZERO
	
	update_side()
	update_animation()
	
	move_and_slide()

func update_animation():
	if velocity == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("walk")

func update_side():
	var side = sign(velocity.x)
	if side:
		sprite.flip_h = true if side == 1 else false

func _on_visibility_area_body_entered(body):
	if body == MasterOfTheGame.get_current_player():
		target = body
		MasterOfTheSenses.play_sfx(load("res://prototype_things/audio/sfx/attention.mp3"))

func _on_visibility_area_body_exited(body):
	if body == target:
		target = null
