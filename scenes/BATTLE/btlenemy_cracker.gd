extends BattleEnemy

var final_pos = Vector2(-400, 24)

func start_turn():
	if characteristics_res.health <= 0:
		return
	if sprite.animation == "damage" and sprite.is_playing():
		await sprite.finished
	is_dodged = false
	preparation()

func preparation():
	var tween = create_tween()
	tween.tween_property(self, "position", final_pos*0.8, 1)
	sprite.play("walk")
	tween.tween_callback(attack)
	print("бегу")

func attack():
	print("пытаюсь укусить")
	has_dodge_chance = true
	var tween = create_tween()
	tween.tween_property(self, "position", final_pos, 1)
	await tween.finished
	if not is_dodged:
		make_damage(characteristics_res.damage)
	else:
		end_turn()

func make_damage(damage):
	sprite.play("attack")
	await sprite.animation_finished
	successful_attack.emit(characteristics_res.damage)
	print("укусил")
	end_turn()

func end_turn():
	sprite.play("walk")
	sprite.flip_h = true
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2.ZERO, 1)
	tween.tween_callback(sprite.play.bind("idle"))
	await tween.finished
	turn_finished.emit()
	sprite.flip_h = false
	is_dodged = false
