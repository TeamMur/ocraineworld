extends Node2D
class_name BattleEnemy

@onready var sprite = $Sprite


#vход врага?v
var is_active: bool = false
var has_dodge_chance: bool = false
var is_dodged: bool = false

signal dodged
signal successful_attack(damage)
signal turn_finished
signal died

const DAMAGE_SOUND = preload("res://assets/BATTLE/SFXCR_damage.mp3")

@export var characteristics_res: Resource

func _ready():
	if characteristics_res.health <= 0:
		death()

func _input(event):
	if event is InputEventKey and event.keycode == KEY_Z and event.is_pressed() and not event.is_echo():
		if has_dodge_chance:
			print("задоджено")
			is_dodged = true
			has_dodge_chance = false
			dodged.emit()

#получение урона врагом
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

#смерть врага
func death():
	sprite.play("death")
	if sprite.animation == "death": #лучше убрать когда будет возможность
		await sprite.animation_finished
	else:
		queue_free()
	if MasterOfTheBattle.current_enemy == self:
		MasterOfTheBattle.current_enemy = null
	died.emit()
	#queue_free()

func start_turn():
	#функция для вызова атаки
	pass

#подготовка к атаке
func preparation():
	#тут враг должен подбежать к цели и т.п.
	pass

#атака
func attack():
	#тут враг должен вызвать возможность нажать Z
	has_dodge_chance = true

func make_damage(damage):
	#тут враг наносит урон по факту
	has_dodge_chance = false
	#player.health -= damage

func end_turn():
	#тут перс завершает ход и возвращается на позицию
	pass
