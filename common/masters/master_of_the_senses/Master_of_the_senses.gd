extends Node

@onready var music_player = $MusicPlayer
@onready var sfx_player = $SFXPlayer
@onready var spare_sfx_player = $SpareSFXPlayer

@onready var transition_player = $TransitionPlayer

const SFX_BUTTON_ENTERED = preload("res://assets/MENU/SFXCR_mouse_entered.wav")
const SFX_BUTTON_PRESSED = preload("res://assets/MENU/SFXCR_button_up.mp3")

signal scene_changed

#region смена сцены и переходы
func change_scene_to_file(scene_path: String):
	if not scene_path: return
	get_tree().change_scene_to_file(scene_path)
	scene_changed.emit()

func change_scene_with_transition(scene_path: String, transition_in: String = "", transition_out: String = ""):
	if not scene_path: return
	
	if transition_in:
		#музыку запускаем строго после запуска анимации 
		transition_player.play(transition_in)
		await transition_player.animation_finished
		get_tree().change_scene_to_file(scene_path)
		#сигнал для сообщения об изменении сцены
		scene_changed.emit()
		transition_player.play(transition_out)
	else:
		get_tree().change_scene_to_file(scene_path)
	


#endregion

#region аудио
##музыка
func play_new_music(music_file):
	music_player.stop()
	music_player.stream = null
	set_music(music_file)
	music_player.play()

func set_music(music_file):
	music_player.stream = music_file

func set_music_pause(toggle_on):
	music_player.stream_paused = toggle_on

func play_music():
	if music_player.stream:
		music_player.play()

func stop_music():
	music_player.stop()

##звуки
func play_sfx(sound):
	if sfx_player.is_playing:
		play_spare_sfx(sound)
		return
	
	if sfx_player.stream != sound:
		sfx_player.set_stream(sound)
	sfx_player.play()

func play_spare_sfx(sound):
	var new_sfx_player = AudioStreamPlayer.new()
	new_sfx_player.stream = sound
	new_sfx_player.bus = "SFX"
	add_child(new_sfx_player)
	new_sfx_player.play()
	await new_sfx_player.finished
	remove_child(new_sfx_player)
	new_sfx_player.queue_free()
#endregion
