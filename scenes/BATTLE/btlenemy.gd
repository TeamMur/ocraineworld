extends Node2D
class_name BattleEnemy

@onready var sprite = $Sprite

signal successful_attack(damage)

var damage: float = 3

var is_active: bool = false
@export var characteristics_res: Resource

signal turn_finished

const DAMAGE_SOUND = preload("res://assets/BATTLE/SFXCR_damage.mp3")

func get_damage(value):
	characteristics_res.health -= value
	sprite.play("damage")
	MasterOfTheSenses.play_sfx(DAMAGE_SOUND)
	if sprite.animation == "damage": #лучше убрать когда будет возможность
		await sprite.animation_finished
	else:
		modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		modulate = Color.WHITE
	if characteristics_res.health <= 0:
		death()
		return
	sprite.play("idle")

func death():
	sprite.play("death")
	if sprite.animation == "death": #лучше убрать когда будет возможность
		await sprite.animation_finished
	else:
		queue_free()
	if MasterOfTheBattle.current_enemy == self:
		MasterOfTheBattle.current_enemy = null
	#queue_free()

func attack():
	pass

#тут типо скиллы
