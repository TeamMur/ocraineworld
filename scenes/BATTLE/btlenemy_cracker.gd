extends BattleEnemy

var final_pos = Vector2(-400, 24)

#начало хода. дополнительные проверки
func start_turn():
	if characteristics_res.health <= 0:
		return
	if sprite.animation == "damage" and sprite.is_playing():
		await sprite.finished
	preparation()

#подготовка. часть хода перед шансом доджа 
func preparation():
	var tween = create_tween()
	tween.tween_property(self, "position", final_pos*0.8, 1)
	sprite.play("walk")
	tween.tween_callback(attack)
	print("бегу")

#атака. на ее протежении можно задоджить
func attack():
	print("пытаюсь укусить")
	has_dodge_chance = true
	var tween = create_tween()
	tween.tween_property(self, "position", final_pos, 1)
	await tween.finished
	if not is_dodged:
		make_damage(characteristics_res.damage)
	else:
		make_damage(characteristics_res.damage/2)
		#end_turn() #раньше щелкун просто убегал, но давление сказал наносить в 2 раза меньше урона

func make_damage(damage):
	sprite.play("attack")
	await sprite.animation_finished
	successful_attack.emit(characteristics_res.damage)
	print("укусил")
	end_turn()

#завершение хода. возврат к исходной точке
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
