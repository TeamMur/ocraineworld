extends CharacterBody2D
class_name Player

@export var characteristics_res: Resource:
	set (value):
		MasterOfTheFight.player_characteristics = value
		characteristics_res = value

@onready var sprite = $Sprite
@onready var hitbox = $Hitbox
@onready var audio_player = $AudioPlayer

const STEPS_SOUND = preload("res://assets/WORLD/SFXCR_PLAYER_steps.mp3")

@export var speed: float = 1.25

func _ready():
	MasterOfTheGame.set_current_player(self)
	
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	

func _physics_process(delta):
	movement(delta)
	sprite.update_sprite(velocity)
	##^можно передавать direction, чтобы уменьшить код в спрайте
	##но стоит учитывать, что в данный момент velocity важно установке анимации бега/ходьбы (которой нет)

#движение
func movement(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed * (delta*10000)
	if velocity != Vector2.ZERO and sprite.frame_coords.x in [0,4] and not audio_player.playing:
		audio_player.stream = STEPS_SOUND
		audio_player.play()
	move_and_slide()

#переход в боевую сцену
##пока не очень
func _on_hitbox_body_entered(body):
	if body is Enemy:
		MasterOfTheFight.set_fight_enemy(body.characteristics_res)
		MasterOfTheGame.change_to_fight_scene(self, body)
