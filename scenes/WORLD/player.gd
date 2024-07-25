extends CharacterBody2D
class_name Player

@export var characteristics_res: Resource:
	set (value):
		MasterOfTheBattle.player_characteristics = value
		characteristics_res = value

@onready var sprite = $Sprite
@onready var hitbox = $Hitbox
@onready var collision = $Collision

@onready var audio_player = $AudioPlayer

const STEPS_SOUND = preload("res://assets/WORLD/SFXCR_PLAYER_steps.mp3")

@export var speed: float = 1.75

var effects: Array

var unique_id

func _ready():
	update_interstage_saves()
	#временная неуязвимость при появлении на сцене
	activate_invisible_mode(3)
	
	MasterOfTheGame.current_player = self
	
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta):
	movement(delta)
	sprite.update_sprite(velocity)
	##^можно передавать direction, чтобы уменьшить код в спрайте
	##но стоит учитывать, что в данный момент velocity важно в установке анимации бега/ходьбы (которой нет)

#движение
func movement(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed * (delta*10000)
	if velocity != Vector2.ZERO and sprite.frame_coords.x in [0,4] and not audio_player.playing:
		audio_player.stream = STEPS_SOUND
		audio_player.play()
	move_and_slide()

func activate_invisible_mode(effect_time: float):
	if "invisible" in effects:
		return #тут можно сбросить эфект обратно до максимального времени или складывать время
	effects.append("invisible")
	collision.disabled = true
	var invisible_timer = Timer.new()
	invisible_timer.one_shot = true
	invisible_timer.autostart = true
	invisible_timer.wait_time = effect_time
	add_child(invisible_timer)
	var delete: Callable = func ():
		effects.erase("invisible")
		collision.disabled = false #< строго после очистки "invisible"
		remove_child(invisible_timer)
		invisible_timer.queue_free()
	invisible_timer.timeout.connect(delete)
	

#переход в боевую сцену
##пока не очень
func _on_hitbox_body_entered(body):
	if body is Enemy:
		MasterOfTheBattle.set_fight_enemy(body.characteristics_res)
		MasterOfTheSenses.change_scene_with_transition(MasterOfTheGame.SCENE_PATH_BATTLE, "dissolve_in", "dissolve_out")
		MasterOfTheLogic.interstage_saves[unique_id]["global_position"] = global_position


##ПЕРЕНЕСТИ В МАСТЕРА ЛОГИКИ
func update_interstage_saves():
	unique_id = str(get_index()) + str(name)
	if unique_id in MasterOfTheLogic.interstage_saves:
		global_position = MasterOfTheLogic.interstage_saves[unique_id]["global_position"]
	else:
		MasterOfTheLogic.interstage_saves[unique_id] = {"global_position": global_position}
