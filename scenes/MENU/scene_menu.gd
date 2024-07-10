extends Node

@onready var statics = $Statics

@onready var start_buttons = $Statics/StartButtons
@onready var new_game_button = $Statics/StartButtons/NewGameButton
@onready var continue_button = $Statics/StartButtons/ContinueButton
@onready var settings_button = $Statics/StartButtons/SettingsButton
@onready var exit_button = $Statics/StartButtons/ExitButton

@onready var settings_buttons = $Statics/SettingsButtons

@onready var game_name = $Statics/GameName
@onready var game_title = $Statics/GameTitle

@onready var version_label = $Statics/VersionLabel
@onready var copyright_label = $Statics/CopyrightLabel

var new_game_scene_path: String = MasterOfTheGame.SCENE_PATH_WORLD
var continue_game_scene_path: String

const SCENE_MUSIC = null
const SFX_START_GAME = preload("res://assets/MENU/SFXCR_start_game.mp3")

func _ready():
	#отключение настроек мастера, ибо есть настройки в самой сцене
	MasterOfTheGame.set_scene_pausable(false)
	MasterOfTheGame.set_scene_has_settings(true)
	
	#действия кнопок
	if new_game_scene_path: new_game_button.pressed.connect(MasterOfTheSenses.change_scene_with_transition.bind(new_game_scene_path, "dissolve_in", "dissolve_out"))
	if continue_game_scene_path: continue_button.pressed.connect(MasterOfTheSenses.change_scene_with_transition.bind(new_game_scene_path, "dissolve_in", "dissolve_out"))
	else: continue_button.hide()
	
	settings_button.pressed.connect(change_settings_visible.bind(true))
	settings_buttons.back_button.pressed.connect(change_settings_visible.bind(false))
	
	exit_button.pressed.connect(get_tree().quit)
	
	#эффекты кнопок
	for button in start_buttons.get_children():
		button.mouse_entered.connect(MasterOfTheSenses.play_sfx.bind(MasterOfTheSenses.SFX_BUTTON_ENTERED))
		if button == new_game_button:
			button.pressed.connect(MasterOfTheSenses.play_sfx.bind(SFX_START_GAME))
			continue
		button.pressed.connect(MasterOfTheSenses.play_sfx.bind(MasterOfTheSenses.SFX_BUTTON_PRESSED))
	
	#музыка и звуки
	MasterOfTheSenses.play_new_music(SCENE_MUSIC)

func change_settings_visible(toggle_on):
	for child in statics.get_children():
		if child in [start_buttons, game_name, game_title]:
			child.visible = not toggle_on
	settings_buttons.visible = toggle_on
