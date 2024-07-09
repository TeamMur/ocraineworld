extends Node

var current_enemy: Object

var current_player: Object
var player_characteristics: Resource

func set_fight_enemy(characteristics_res):
	var new_enemy = load(characteristics_res.fight_version_path).instantiate()
	new_enemy.characteristics_res = characteristics_res
	current_enemy = new_enemy
