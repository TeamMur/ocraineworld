extends Node

const SCENE_PATH_BATTLE: String = "res://scenes/BATTLE/SCENE_battle.tscn"
const SCENE_PATH_WORLD: String = "res://scenes/WORLD/SCENE_world.tscn"
const SCENE_PATH_MENU: String = "res://scenes/MENU/SCENE_menu.tscn"

@onready var settings_panel = $SettingsPanel
@onready var settings_buttons = $SettingsPanel/SettingsButtons

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
	settings_buttons.back_button.pressed.connect(MasterOfTheSenses.change_scene_with_transition.bind(SCENE_PATH_MENU, "dissolve_in", "dissolve_out"))
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

#глобальные настройки
##в основном те, что нельзя установить через настройки проекта (через редактор)
func _apply_global_settings():
	DisplayServer.window_set_min_size(Vector2i(640,360))
