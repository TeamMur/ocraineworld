extends Node2D
class_name FightPlayer

const fire_sfx = preload("res://assets/BATTLE/SFXCR_PLAYER_Выстрел из револьера Никто.mp3")

@onready var sprite = $Sprite
@onready var skills_animation = $SkillsAnimation

@export var characteristics_res: Resource

var is_busy: bool = false
var is_active: bool = true

const DAMAGE_SOUND = preload("res://assets/BATTLE/SFXCR_damage.mp3")

signal turn_finished
signal damaged(value)

var skills_dict = {
	"shot_revolver": {
		"texture": preload("res://assets/BATTLE/SKILL_icon_pistol.png"),
		"method": shot_revolver.bind(5),
		"cost": 0
	},
	"eyes": {
		"texture": preload("res://assets/BATTLE/SKILL_icon_eyes.png"),
		"method": eyes.bind(3),
		"cost": 1
	},
	"shot_revolver_double": {
		"texture": preload("res://assets/BATTLE/SKILL_icon_pistol.png"),
		"method": shot_revolver.bind(10),
		"cost": 5
	}
}

var current_skills = [skills_dict["shot_revolver"],skills_dict["eyes"], skills_dict["shot_revolver_double"]]

func _ready():
	MasterOfTheBattle.current_player = self
	if MasterOfTheBattle.player_characteristics: characteristics_res = MasterOfTheBattle.player_characteristics
	play_idle_animation()

func get_damage(value):
	if characteristics_res.health <= 0:
		return
	characteristics_res.health -= value
	MasterOfTheSenses.play_sfx(DAMAGE_SOUND)
	sprite.play("damage")
	damaged.emit(value)
	await sprite.animation_finished
	if characteristics_res.health <= 0:
		death()
		return
	else:
		play_idle_animation()

func death():
	sprite.play("death")
	await sprite.animation_finished
	sprite.play("idle_death")
	#game_over

func play_idle_animation():
	if characteristics_res.health <= 2:
		sprite.play("idle_lowhp")
	else:
		sprite.play("idle")

#скиллы
func shot_revolver(damage):
	if characteristics_res.health <= 0 or not is_active or is_busy:
		return
	is_busy = true
	sprite.play("pullout_revolver")
	await sprite.animation_finished
	sprite.play("revolver_shot")
	MasterOfTheSenses.play_sfx(fire_sfx)
	skills_animation.play("shot")
	if MasterOfTheBattle.current_enemy:
		MasterOfTheBattle.current_enemy.get_damage(damage)
	await sprite.animation_finished
	play_idle_animation()
	is_busy = false
	turn_finished.emit()

func eyes(value):
	if characteristics_res.health <= 0 or not is_active or is_busy:
		return
	characteristics_res.health -= value
	sprite.play("damage")
	damaged.emit(value)
	await sprite.animation_finished
	if characteristics_res.health <= 0:
		death()
		return
	else:
		play_idle_animation()
	is_busy = false
	turn_finished.emit()
