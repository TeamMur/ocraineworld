extends Control

@onready var accept_button = $ButtonsContainer/AcceptButton
@onready var back_button = $ButtonsContainer/BackButton
@onready var close_button = $CloseButton


@onready var vsync_button = $GraphicsContainer/VSYNCContainer/VSYNCButton
@onready var fullscreen_button = $GraphicsContainer/FullscreenContainer/FullscreenButton

@onready var music_slider = $SoundContainer/MusicContainer/MusicSlider
@onready var sfx_slider = $SoundContainer/SFXContainer/SFXSlider

@onready var sfx_label = $SoundContainer/SFXContainer/SFXLabel
@onready var music_label = $SoundContainer/MusicContainer/MusicLabel

@onready var resolution_container = $GraphicsContainer/ResolutionContainer
@onready var res_button_left = $GraphicsContainer/ResolutionContainer/ResButtonLeft
@onready var res_button_right = $GraphicsContainer/ResolutionContainer/ResButtonRight
@onready var resolution_value_label = $GraphicsContainer/ResolutionContainer/ResolutionValueLabel

var resolutions: Array = [Vector2i(1152, 648),Vector2i(1600, 900),Vector2i(1920, 1080)]
var current_resolution_index: int = 0

@onready var button_pressed_sfx = preload("res://assets/MENU/SFXCR_button_up.mp3")
@onready var button_mouse_entered_sfx = preload("res://assets/MENU/SFXCR_mouse_entered.wav")

var previous_ui: Object

func _ready():
	#небольшие правки
	sfx_label.custom_minimum_size = music_label.size
	update_resolution_children(DisplayServer.window_get_size())

	##get_window().size_changed.connect(update_accept_button)
	##изменения размера окна вручную должны обновлять кнопку accept
	##однако по умолчанию ратакое изменение я отключил
	
	#установка значений на слайдерах по громкости bus'ов
	##перед назначением сигналов, чтобы они не сработали преждевременно
	update()
	
	#действия кнопок
	music_slider.value_changed.connect(_on_audio_value_changed.bind("Music"))
	sfx_slider.value_changed.connect(_on_audio_value_changed.bind("SFX"))
	
	##Graphics
	fullscreen_button.toggled.connect(update_accept_button)
	vsync_button.toggled.connect(update_accept_button)
	
	###update_accept_button() для кнопок ниже происходит в set_current_resolution_index()
	res_button_left.pressed.connect(set_current_resolution_index.bind(-1))
	res_button_right.pressed.connect(set_current_resolution_index.bind(+1))
	
	accept_button.pressed.connect(_on_accept_button_pressed)
	back_button.pressed.connect(update)
	
	#эффекты кнопок
	for button in [accept_button, back_button, res_button_left, res_button_right, vsync_button, fullscreen_button, close_button]:
		button.mouse_entered.connect(play_buttons_mouse_entered_effects)
		button.pressed.connect(play_buttons_pressed_effects)
	
	#подключение предыдущего интерфейса
	if previous_ui:
		connect_previous_ui(previous_ui)

#region действия кнопок
func _on_back_button_pressed():
	hide()
	previous_ui.show()

##смена текста на кнопке back. back/menu/close
func set_back_button_text(text: String):
	back_button.text = text

##смена текста на кнопке close. close/continue
func set_close_button_text(text: String):
	close_button.text = text

func _on_accept_button_pressed():
	set_vsync_mode(vsync_button.button_pressed)
	set_fullscreen_mode(fullscreen_button.button_pressed)
	
	##решил скрывать resolution в полноэкранном режиме
	##потому что оно в нем почему-то не изменяется (я хотел типо как в кске растягивание при 4:3)
	resolution_container.visible = DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN
	set_resolution(resolutions[current_resolution_index])
	
	accept_button.disabled = true

func set_vsync_mode(toggled_on):
	#Режимы:
	##VSYNC_DISABLED : выключает vsync.
	##VSYNC_ENABLED : включает vsync, ограничивая частоту кадров частотой обновления монитора.
	##VSYNC_ADAPTIVE : частота кадров ограничивается монитором, как если бы vsync был включен, однако, когда частота кадров ниже частоты обновления монитора, он ведет себя так, как если бы vsync был отключен.
	##VSYNC_MAILBOX : отображает самое последнее изображение с неограниченной частотой кадров. Изображение отображается максимально быстро, что может уменьшить задержку ввода, но никаких гарантий не предоставляется. Этот режим также известен как «Быстрая» вертикальная синхронизация и работает лучше всего, когда частота кадров как минимум в два раза превышает частоту обновления монитора.
	var mode = DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED
	if DisplayServer.window_get_vsync_mode() != mode:
		DisplayServer.window_set_vsync_mode(mode)

func update_vsync_mode():
	vsync_button.button_pressed = true if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED else false

func set_fullscreen_mode(toggled_on):
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)

func update_fullscreen_mode():
	fullscreen_button.button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else false

func set_resolution(resolution: Vector2i):
	if resolution != DisplayServer.window_get_size():
		DisplayServer.window_set_size(resolution)
		update_resolution_children()
		
		#центрирование окна
		##возможно стоит вынести в синглтон
		var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2
		var window_size = DisplayServer.window_get_size()
		var window_center_position = screen_center - window_size/2
		get_window().set_position(window_center_position)

func set_current_resolution_index(value):
	##почему-то .bind(cur_res_inx-1) не принимает, поэтому такое недоразумение
	##т.е. сеттер не является сеттером, а функцией сложения с числом
	current_resolution_index += value
	current_resolution_index = clamp(current_resolution_index, 0, resolutions.size()-1)
		
	update_resolution_children(resolutions[current_resolution_index])
	update_accept_button()

func update_resolution_children(vector2i: Vector2i = Vector2i.ZERO):
	if vector2i:
		resolution_value_label.text = " " + str(vector2i.x) + "x" + str(vector2i.y) + " "
	
	if vector2i in resolutions:
		current_resolution_index = resolutions.find(vector2i)
	
	res_button_left.disabled = true if current_resolution_index == 0 else false
	res_button_right.disabled = true if current_resolution_index == resolutions.size()-1 else false

func update_accept_button(value = ""):
	##параметр value нужен, чтобы подключить сигнал toggled_on в кнопках
	if vsync_button.button_pressed != bool(DisplayServer.window_get_vsync_mode()):
		accept_button.disabled = false
		return
	if fullscreen_button.button_pressed != bool(DisplayServer.window_get_mode()):
		accept_button.disabled = false
		return
	if resolutions[current_resolution_index] != DisplayServer.window_get_size()  and resolution_container.visible:
		accept_button.disabled = false
		return
	accept_button.disabled = true

func update():
	update_slider_values()
	update_fullscreen_mode()
	resolution_container.visible = DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN
	update_vsync_mode()

#endregion

#region эффекты кнопок (музыка и звуки)
func play_buttons_mouse_entered_effects():
	MasterOfTheSenses.play_sfx(button_mouse_entered_sfx)

func play_buttons_pressed_effects():
	MasterOfTheSenses.play_sfx(button_pressed_sfx)

##смена громкости при смене значений слайдеров
func _on_audio_value_changed(value, bus_name):
	var bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	#проигрывание звука при взаимодействии с соотв. слайдеров
	play_buttons_pressed_effects()

##установка значений на слайдерах по громкости bus'ов
func update_slider_values():
	music_slider.value = set_slider_value_from_bus("Music")
	sfx_slider.value = set_slider_value_from_bus("SFX")

func set_slider_value_from_bus(bus_name):
	var bus_index = AudioServer.get_bus_index(bus_name)
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))

#endregion

#подключение предыдущего интерфеса. На случай, если сцена должна иметь встроенные найстройки
func connect_previous_ui(new_previous_ui):
	previous_ui = new_previous_ui
	back_button.pressed.connect(_on_back_button_pressed)
