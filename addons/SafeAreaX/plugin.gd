@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"SafeAreaX",
		"Control",
		preload("SafeAreaX.gd"),
		preload("SafeAreaX.svg"),
	)
	
func _exit_tree() -> void:
	remove_custom_type("SafeAreaX")
