extends Control

@onready var new_game_button = $NewGameButton
@onready var continue_button = $ContinueButton
@onready var settings_button = $SettingsButton
@onready var exit_button = $ExitButton

var new_game_scene_path: String = MasterOfTheGame.global_game_scenes_package + "world_scene/world_scene.tscn"
var continue_game_scene_path: String
var settings_scene: Object

@onready var button_pressed_sfx = load(MasterOfTheGame.global_sfx_package + "button_up.mp3")
@onready var button_mouse_entered_sfx = load(MasterOfTheGame.global_sfx_package + "mouse_entered.wav")

func _ready():
	#действия кнопок
	if new_game_scene_path:
		new_game_button.pressed.connect(MasterOfTheSenses.change_scene_with_transition.bind(new_game_scene_path, "dissolve_in", "dissolve_out"))
	if continue_game_scene_path:
		continue_button.pressed.connect(MasterOfTheSenses.change_scene_with_transition.bind(new_game_scene_path, "dissolve_in", "dissolve_out"))
	else:
		#continue_button.disabled = true
		continue_button.hide()
	
	if settings_scene:
		connect_settings_scene(settings_scene)
		
	exit_button.pressed.connect(get_tree().quit)
	
	#эффекты кнопок
	for button in get_children():
		if not button is Button:
			return
		button.mouse_entered.connect(play_buttons_mouse_entered_effects)
		if not button == new_game_button:
			button.pressed.connect(play_buttons_pressed_effects)
	new_game_button.pressed.connect(MasterOfTheSenses.play_sfx.bind(load("res://prototype_things/audio/sfx/start_game.mp3")))

#эффекты кнопок (музыка и звуки)
func play_buttons_mouse_entered_effects():
	MasterOfTheSenses.play_sfx(button_mouse_entered_sfx)

func play_buttons_pressed_effects():
	MasterOfTheSenses.play_sfx(button_pressed_sfx)

#сцена, содержащая настройки
func connect_settings_scene(new_settings_scene):
	settings_scene = new_settings_scene
	settings_button.pressed.connect(_on_setting_button_pressed)

func _on_setting_button_pressed():
	if settings_scene:
		hide()
		settings_scene.show()
