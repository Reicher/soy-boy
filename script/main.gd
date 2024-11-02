extends Node2D

var game = preload("res://scene/game.tscn")

func _ready() -> void:
	get_tree().change_scene_to_packed(game)
	
