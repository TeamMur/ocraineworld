extends Area2D

@export var nextSceneName : String


func _on_player_entered(area: Area2D) -> void:
	var nextScene = load("res://scenes/WORLD/" + nextSceneName + ".tscn")
	get_tree().change_scene_to_packed(nextScene)
