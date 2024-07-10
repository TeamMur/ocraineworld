extends Node

const SCENE_MUSIC = preload("res://assets/BATTLE/MUSICCR_75. Forest Frenzy.mp3")

@onready var info = $GUI/Info
@onready var turn_label = $GUI/Info/TurnLabel

@onready var pause_button = $GUI/PauseButton
@onready var run_button = $GUI/RunButton

@onready var skills = $GUI/Hotbar/Skills

@onready var enemy_pivot = $EnemyPivot
@onready var player_pivot = $PlayerPivot

@onready var battle_player = $PlayerPivot/BattlePlayer
var battle_enemy: Object

func _ready():
	#включение настроек мастера, ибо настроек в сцене нет
	MasterOfTheGame.set_scene_pausable(true)
	MasterOfTheGame.set_scene_has_settings(false)
	
	#включение музыки сцены
	MasterOfTheSenses.play_new_music(SCENE_MUSIC)
	
	#настройка кнопок
	run_button.pressed.connect(MasterOfTheSenses.change_scene_with_transition.bind(MasterOfTheGame.SCENE_PATH_WORLD, "dissolve_in", "dissolve_out"))
	pause_button.pressed.connect(_on_pause_button_pressed)
	
	#сигналы завершения ходов игрока и врага
	battle_player.turn_finished.connect(_on_player_turn_finished)
	
	battle_enemy = MasterOfTheBattle.current_enemy
	if battle_enemy:
		##добавление врага на сцену
		enemy_pivot.add_child(battle_enemy)
		battle_enemy.successful_attack.connect(battle_player.get_damage)
		battle_enemy.turn_finished.connect(_on_enemy_turn_finished)
	
	
	for i in range(battle_player.current_skills.size()):
		skills.get_child(i).get_node("Icon").texture = battle_player.current_skills[i]["texture"]
		skills.get_child(i).pressed.connect(battle_player.current_skills[i]["method"])
	

#переключение ходов игрока и врага
func _on_player_turn_finished():
	if not battle_enemy: return
	battle_player.is_active = false
	battle_enemy.is_active = true
	turn_label .text = "Ход врага"
	battle_enemy.attack()

func _on_enemy_turn_finished():
	if not battle_enemy: return
	battle_enemy.is_active = false
	battle_player.is_active = true
	turn_label .text = "Ход игрока"

#показ доп.инфы
func _input(event):
	if event is InputEventKey and event.keycode == KEY_TAB and event.is_pressed() and not event.is_echo():
		info.visible = !info.visible

#пауза
func _on_pause_button_pressed():
	MasterOfTheGame.set_game_pause(!get_tree().is_paused())
