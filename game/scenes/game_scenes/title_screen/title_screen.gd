extends Node

@onready var statics = $Statics
@onready var start_buttons = $Statics/StartButtons
@onready var settings_buttons = $Statics/SettingsButtons

@onready var version_label = $Statics/VersionLabel
@onready var copyright_label = $Statics/CopyrightLabel

var scene_music_file = load(MasterOfTheGame.global_music_package + "Cocktails_and_Lobsters.mp3")

func _ready():
	#отключение настроек мастера, ибо есть настройки в самой сцене
	MasterOfTheGame.set_scene_pausable(false)
	MasterOfTheGame.set_scene_has_settings(true)
	
	start_buttons.connect_settings_scene(settings_buttons)
	settings_buttons.connect_previous_ui(start_buttons)
	
	#действия кнопок
	start_buttons.settings_button.pressed.connect(button_transition)
	settings_buttons.back_button.pressed.connect(button_transition)
	
	#музыка и звуки
	MasterOfTheSenses.play_new_music(scene_music_file)

#действия кнопок
func button_transition():
	buttons_children_visible(statics)

##скрытие/раскрытие необходимых элементов
func buttons_children_visible(object):
	for element in object.get_children():
		if element not in [start_buttons, settings_buttons, version_label, copyright_label]:
			element.visible = start_buttons.visible
