extends FightEnemy

const final_pos = Vector2(-400, 24)

var is_dodged: bool = false
var is_key_chansing: bool = false

signal dodged
signal key_chance_finished

func _input(event):
	if event is InputEventKey and event.keycode == KEY_Z and event.is_pressed() and not event.is_echo():
		if is_key_chansing:
			print("задоджено")
			is_dodged = true
			is_key_chansing = false
			dodged.emit()

func attack():
	if characteristics_res.health <= 0:
		return
	if sprite.animation == "damage" and sprite.is_playing():
		await sprite.finished
	var tween = create_tween()
	
	tween.tween_property(self, "position", final_pos*0.8, 1)
	print("бегу")
	sprite.play("walk")
	
	tween.tween_callback(key_chance)
	await key_chance_finished
	
	if not is_dodged:
		if not tween.is_valid(): tween = create_tween()
		tween.tween_callback(sprite.play.bind("attack"))
		await sprite.animation_finished
		successful_attack.emit(damage)
		print("укусил")
		#тут сделать нанесение урона
	
	sprite.play("walk")
	sprite.flip_h = true
	if not tween.is_valid(): tween = create_tween()
	tween.tween_property(self, "position", Vector2.ZERO, 1)
	tween.tween_callback(sprite.play.bind("idle"))
	await tween.finished
	turn_finished.emit()
	sprite.flip_h = false
	is_dodged = false

func key_chance():
	print("пытаюсь укусить")
	is_key_chansing = true
	var tween = create_tween()
	tween.tween_property(self, "position", final_pos, 1)
	await tween.finished
	key_chance_finished.emit()
