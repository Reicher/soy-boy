extends Node2D

var levels = []
var current_level
var currentLevelNum = 1

func _ready() -> void:
	load_levels()
	start_level(currentLevelNum)

func load_levels() -> void:
	var level_num = 1
	while true:
		var level_path = "res://scene/level/level%d.tscn" % level_num
		if ResourceLoader.exists(level_path):
			var scene = load(level_path)
			if scene and scene is PackedScene:
				levels.append(scene)
				level_num += 1
			else:
				print("Failed to load level at path: ", level_path)
				break
		else:
			break  # No more levels found

func start_level(level_num: int) -> void:
	# Clean up previous instances
	if current_level:
		current_level.queue_free()

	# Load the new level
	if level_num > levels.size():
		print("No more levels!")
		return
		
	current_level = levels[level_num - 1].instantiate()
	current_level.win.connect(_on_level_win)
	current_level.lost.connect(_on_level_lost)
	add_child(current_level)

func _on_level_win() -> void:
	print("Level won!")
	currentLevelNum += 1
	start_level(currentLevelNum)

func _on_level_lost() -> void:
	print("Level lost!")
	# Restart the current level
	start_level(currentLevelNum)
