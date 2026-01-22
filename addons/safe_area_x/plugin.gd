@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"SafeAreaX",
		"Control",
		preload("safe_area_x.gd"),
		preload("safe_area_x.svg"),
	)

func _exit_tree() -> void:
	remove_custom_type("SafeAreaX")
