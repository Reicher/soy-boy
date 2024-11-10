extends Node2D

signal lost
signal win

var soyboy_scene = preload("res://scene/soyBoy.tscn")
var soyboy

func _ready() -> void:
	soyboy = soyboy_scene.instantiate()
	soyboy.position = Vector2(0, 0)
	add_child(soyboy)

func _on_goal_body_entered(body: Node2D) -> void:
	if body == soyboy:
		emit_signal("win")


func _on_game_over_body_entered(body: Node2D) -> void:
	if body == soyboy:
		emit_signal("lost")
