extends Node

var scene_music_file = load(MasterOfTheGame.global_music_package + "17. Forest Chillin'" + ".mp3")

func _ready():
	#включение настроек мастера, ибо настроек в сцене нет
	MasterOfTheGame.set_scene_pausable(true)
	MasterOfTheGame.set_scene_has_settings(false)
	
	#включение музыки сцены
	MasterOfTheSenses.play_new_music(scene_music_file)
