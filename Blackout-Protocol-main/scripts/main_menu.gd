extends Control

const GAME_SCENE_PATH = "res://scenes/facility.tscn" 

func _on_new_game_pressed() -> void:
	if FileAccess.file_exists("user://savegame.json"):
		var dir = DirAccess.open("user://")
		dir.remove("savegame.json")
		
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_load_game_pressed() -> void:
	if FileAccess.file_exists("user://savegame.json"):
		get_tree().change_scene_to_file(GAME_SCENE_PATH)
	else:
		print("No save file exists yet!")
		
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
