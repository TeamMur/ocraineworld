extends DashesSprite

var textures = {
	"idle": {
		"texture": preload("res://game/scenes/objects/player/sprites/animations/idle.png"),
		"hframes": 4,
	},
	"walk": {
		"texture": preload("res://game/scenes/objects/player/sprites/animations/walk.png"),
		"hframes": 9
	}
}

var view_dir_index: int = -1

#основной сеттер
func update_sprite(view_dir):
	set_sprite_texture(view_dir)
	##особенность calculate_side временно требует двойного применения set_sprite_side
	set_sprite_side(view_dir_index)
	calculate_side(view_dir)
	set_sprite_side(view_dir_index)

func set_sprite_side(view_dir_idx):
	if view_dir_idx >= 0:
		frame_coords.y = clamp(view_dir_idx, 0, vframes-1)

func calculate_side(view_dir):
	var view_dir_normalized = view_dir.normalized()
	#4 стороны
	if view_dir_normalized == Vector2.UP:
		view_dir_index = 0
	elif view_dir_normalized == Vector2.RIGHT:
		view_dir_index = 2
	elif view_dir_normalized == Vector2.DOWN:
		view_dir_index = 4
	elif view_dir_normalized == Vector2.LEFT:
		view_dir_index = 6
	#8 сторон
	elif view_dir_normalized == (Vector2.UP+Vector2.RIGHT).normalized():
		view_dir_index = 1
	elif view_dir_normalized == (Vector2.RIGHT+Vector2.DOWN).normalized():
		view_dir_index = 3
	elif view_dir_normalized == (Vector2.DOWN+Vector2.LEFT).normalized():
		view_dir_index = 5
	elif view_dir_normalized == (Vector2.LEFT+Vector2.UP).normalized():
		view_dir_index = 7
	else:
		view_dir_index = -1

#установка правильного спрайта
func set_sprite_texture(velocity):
	##потребует изменения
	var texture_name = "idle" if velocity == Vector2.ZERO else "walk"
	hframes = textures[texture_name]["hframes"]
	texture = textures[texture_name]["texture"]
	
	##скорость анимации
	#timer.wait_time = 0.5/hframes
