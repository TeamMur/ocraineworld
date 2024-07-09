extends Node

@onready var settings_panel = $SettingsPanel
@onready var settings_buttons = $SettingsPanel/SettingsButtons

#глобальные папки
##не уверен, что в этом мастере
var global_game_scenes_package: String = "res://game/scenes/game_scenes/"

var global_audio_package: String = "res://prototype_things/audio/"
var global_sfx_package: String = "res://prototype_things/audio/sfx/"
var global_music_package: String = "res://prototype_things/audio/music/"

const title_screen_path: String = "res://scenes/MENU/SCENE_menu.tscn"

var scene_is_pausable: bool = false
var scene_has_settings: bool = false

var current_player: Object = null

func _ready():
	#глобальные настройки
	_apply_global_settings()
	
	#тут настройки настроек
	set_settings_visible(false)
	
	settings_buttons.close_button.show()
	settings_buttons.set_back_button_text("menu")
	
	#при изменении сцены снятие паузы
	MasterOfTheSenses.scene_changed.connect(get_tree().set_pause.bind(false))
	
	#назначения кнопок
	settings_buttons.back_button.pressed.connect(MasterOfTheSenses.change_scene_with_transition.bind(title_screen_path, "dissolve_in", "dissolve_out"))
	settings_buttons.back_button.pressed.connect(settings_panel.hide)
	settings_buttons.close_button.pressed.connect(set_game_pause.bind(false))

#включение/отключение паузы
func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			if event.keycode == KEY_ESCAPE:
				set_game_pause(!get_tree().is_paused())

func set_game_pause(toggle_on):
	if scene_is_pausable:
		get_tree().paused = toggle_on
	set_settings_visible(toggle_on)

func set_settings_visible(toggle_on):
	if not scene_has_settings:
		settings_panel.visible = toggle_on
		if toggle_on:
			settings_buttons.update()

func set_scene_pausable(toggle_on):
	scene_is_pausable = toggle_on

func set_scene_has_settings(toggle_on):
	scene_has_settings = toggle_on
	if toggle_on and settings_panel.visible == true:
		settings_panel.hide()

func cause_game_over():
	pass

func cause_victory():
	pass

#Игрок: сеттер и геттер
##в основном для игр с одним игроком
func set_current_player(new_player):
	current_player = new_player
	#сюда стоит добавить проверку на то, что new_player - объект класса Player, однако и без такого класса можно обойтись

func get_current_player():
	return current_player

#глобальные настройки
##в основном те, что нельзя установить через настройки проекта (через редактор)
func _apply_global_settings():
	DisplayServer.window_set_min_size(Vector2i(640,360))


#боевая сцена
##Думаю стоит не переключать сцену а както поверх вызывать боевку
const fight_scene_path: String = "res://scenes/BATTLE/SCENE_battle.tscn"

func change_to_fight_scene(player, enemy):
	MasterOfTheSenses.change_scene_with_transition(fight_scene_path, "dissolve_in", "dissolve_out")
