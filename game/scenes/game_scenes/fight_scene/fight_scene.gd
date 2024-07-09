extends Node

var scene_music_file = preload("res://assets/BATTLE/MUSICCR_75. Forest Frenzy.mp3")
var main_scene_path: String = MasterOfTheGame.global_game_scenes_package + "world_scene/world_scene.tscn"

@onready var info = $GUI/Info

@onready var pause_button = $GUI/PauseButton
@onready var run_button = $GUI/RunButton
@onready var skills = $GUI/Hotbar/Skills

@onready var enemy_pivot = $EnemyPivot
@onready var player_pivot = $PlayerPivot
@onready var fight_player = $PlayerPivot/FightPlayer

var fight_enemy: Object

func _ready():
	#включение настроек мастера, ибо настроек в сцене нет
	MasterOfTheGame.set_scene_pausable(true)
	MasterOfTheGame.set_scene_has_settings(false)
	
	#включение музыки сцены
	MasterOfTheSenses.play_new_music(scene_music_file)
	
	#настройка кнопок
	run_button.pressed.connect(MasterOfTheSenses.change_scene_with_transition.bind(main_scene_path, "dissolve_in", "dissolve_out"))
	pause_button.pressed.connect(_on_pause_button_pressed)
	
	##временно
	if MasterOfTheFight.current_enemy:
		fight_enemy = MasterOfTheFight.current_enemy
		enemy_pivot.add_child(fight_enemy)
	
	fight_player.turn_finished.connect( _on_player_turn_finished)
	
	if fight_enemy:
		fight_enemy.successful_attack.connect(fight_player.get_damage)
		fight_enemy.turn_finished.connect(_on_enemy_turn_finished)
	
	
	for i in range(fight_player.current_skills.size()):
		skills.get_child(i).get_node("Icon").texture = fight_player.current_skills[i]["texture"]
		skills.get_child(i).pressed.connect(fight_player.current_skills[i]["method"])
	

func _input(event):
	if event is InputEventKey and event.keycode == KEY_TAB and event.is_pressed() and not event.is_echo():
		info.visible = !info.visible

func _on_pause_button_pressed():
	MasterOfTheGame.set_game_pause(!get_tree().is_paused())

func _on_player_turn_finished():
	fight_player.is_active = false
	if fight_enemy: fight_enemy.is_active = true
	$GUI/Info/TurnLabel.text = "Ход врага"
	fight_enemy.attack()

func _on_enemy_turn_finished():
	if fight_enemy: fight_enemy.is_active = false
	fight_player.is_active = true
	$GUI/Info/TurnLabel.text = "Ход игрока"
