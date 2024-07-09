extends Node2D
class_name FightPlayer

const fire_sfx = preload("res://prototype_things/audio/sfx/Выстрел из револьера Никто.mp3")

@onready var sprite = $Sprite
@onready var skills_animation = $SkillsAnimation

@export var characteristics_res: Resource

var is_busy: bool = false
var is_active: bool = true

const DAMAGE_SOUND = preload("res://prototype_things/audio/sfx/damage.mp3")

signal turn_finished

var skills_dict = {
	"shot_revolver": {
		"texture": load("res://game/scenes/objects/player/sprites/skills/skill_icon_pistol.png"),
		"method": shot_revolver.bind(5)
	},
	"eyes": {
		"texture": load("res://game/scenes/objects/player/sprites/skills/skill_icon_eyes.png"),
		"method": eyes.bind(3)
	},
	"shot_revolver_double": {
		"texture": load("res://game/scenes/objects/player/sprites/skills/skill_icon_pistol.png"),
		"method": shot_revolver.bind(10)
	}
}

var current_skills = [skills_dict["shot_revolver"],skills_dict["eyes"], skills_dict["shot_revolver_double"]]

func _ready():
	MasterOfTheFight.current_player = self
	if MasterOfTheFight.player_characteristics: characteristics_res = MasterOfTheFight.player_characteristics

func get_damage(value):
	if characteristics_res.health <= 0:
		return
	characteristics_res.health -= value
	MasterOfTheSenses.play_sfx(DAMAGE_SOUND)
	sprite.play("damage")
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
	if MasterOfTheFight.current_enemy:
		MasterOfTheFight.current_enemy.get_damage(damage)
	await sprite.animation_finished
	play_idle_animation()
	is_busy = false
	turn_finished.emit()

func eyes(value):
	if characteristics_res.health <= 0 or not is_active or is_busy:
		return
	characteristics_res.health -= value
	sprite.play("damage")
	await sprite.animation_finished
	if characteristics_res.health <= 0:
		death()
		return
	else:
		play_idle_animation()
	is_busy = false
	turn_finished.emit()
