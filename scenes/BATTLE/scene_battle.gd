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

var fx_methods: Array

func _ready():
	#включение настроек мастера, ибо настроек в сцене нет
	MasterOfTheGame.set_scene_pausable(true)
	MasterOfTheGame.set_scene_has_settings(false)
	
	#включение музыки сцены
	MasterOfTheSenses.play_music_continues(SCENE_MUSIC)
	
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
		var skill_pressed_method = func():
			if battle_player.current_skills[i]["cost"] <= battle_player.characteristics_res.mana:
				battle_player.characteristics_res.mana -= battle_player.current_skills[i]["cost"]
				battle_player.current_skills[i]["method"].call()
		skills.get_child(i).pressed.connect(skill_pressed_method)
	
	#функция на летающую цифру при получении кем-либо урона
	var add_flying_num = func(damage, g_pos):
		var flying_num = Label.new()
		flying_num.text = str(damage)
		flying_num.add_theme_font_size_override("font_size", 48)
		flying_num.global_position = g_pos
		add_child(flying_num)
		var side = -1 if g_pos.x<1152/2 else 1
		var y_rand = randi_range(-100,100)
		y_rand+=100*sign(y_rand)
		var fn_anim = func():
			if not flying_num:
				return false
			flying_num.global_position.x += side*2
			if abs(flying_num.global_position.y-(g_pos.y+y_rand))>10:
				flying_num.global_position.y += sign(y_rand)*2
			else:
				flying_num.queue_free()
			return true
		fx_methods.append(fn_anim)
		set_process(true)
		
	for entity in [battle_player,battle_enemy]:
		if entity:
			entity.damaged.connect(add_flying_num.bind(entity.global_position))
	
	var healthbar = $GUI/Panel/VContainer/HealthContainer/HealthBar
	var bp_cr = battle_player.characteristics_res
	healthbar.max_value = bp_cr.max_health
	var update_health_bar = func(damage = null): healthbar.value = bp_cr.health
	update_health_bar.call()
	battle_player.damaged.connect(update_health_bar)

func _process(delta):
	#вызов всех методов из массива методов, если методов нет процесс отключается
	if fx_methods:
		for method in fx_methods:
			#сразу вызов, проверка, и удаление
			if not method.call(): fx_methods.erase(method)
			##при удалении метода из массива, происходит ошибка (не критичная)
			##типа функция освобождена, но вызвана, пока незнаю как исправить
	else:
		set_process(false)

#переключение ходов игрока и врага
func _on_player_turn_finished():
	if not battle_enemy: return
	battle_player.is_active = false
	battle_enemy.is_active = true
	turn_label .text = "Ход врага"
	battle_enemy.start_turn()

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
