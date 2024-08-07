extends Node

const SCENE_MUSIC = preload("res://assets/WORLD/MUSIC_world.mp3")

func _ready():
	#включение настроек мастера, ибо настроек в сцене нет
	MasterOfTheGame.set_scene_pausable(true)
	MasterOfTheGame.set_scene_has_settings(false)
	
	#включение музыки сцены
	MasterOfTheSenses.play_music_continues(SCENE_MUSIC)
