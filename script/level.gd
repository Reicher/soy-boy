extends Node2D

signal lost
signal win

func _on_goal_body_entered(body: Node2D) -> void:
	if body.name == "SoyBoy":
		emit_signal("win")


func _on_game_over_body_entered(body: Node2D) -> void:
	if body.name == "SoyBoy":
		emit_signal("lost")
