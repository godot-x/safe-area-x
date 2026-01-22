@icon("./safe_area_x.svg")
@tool
class_name SafeAreaX
extends Control

# automatically adjust ui to fit inside the display safe area

enum SetFromSafeAreaMode {
	OFF,    # never auto-set from safe area
	ONCE,   # set once on ready
	ALWAYS  # continuously update every frame
}

@export var set_from_safe_area: SetFromSafeAreaMode = SetFromSafeAreaMode.ALWAYS

@export_group("Extra Offsets")

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var left: int = 0:
	set(value):
		left = max(value, 0)
		_on_manual_offsets_changed()

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var top: int = 0:
	set(value):
		top = max(value, 0)
		_on_manual_offsets_changed()

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var right: int = 0:
	set(value):
		right = max(value, 0)
		_on_manual_offsets_changed()

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var bottom: int = 0:
	set(value):
		bottom = max(value, 0)
		_on_manual_offsets_changed()

@export_group("Debug")
@export var show_safe_area_debug: bool = false:
	set(value):
		show_safe_area_debug = value
		_update_debug_overlay()

var current_offsets: Array[int] = [0, 0, 0, 0] # left, top, right, bottom
var _debug_rect: ColorRect


func _init() -> void:
	# make this control fill the whole viewport
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	_refresh_safe_area(true)
	_update_debug_overlay()


func _process(_delta: float) -> void:
	if set_from_safe_area == SetFromSafeAreaMode.ALWAYS and not Engine.is_editor_hint():
		_refresh_safe_area()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if get_parent() is Container:
		warnings.append("SafeAreaX should not be a child of a Container node.")
	return warnings


func _on_manual_offsets_changed() -> void:
	if Engine.is_editor_hint():
		_apply_offsets([left, top, right, bottom])
	else:
		_refresh_safe_area(true)


# compute offsets based on safe area + manual extras
func _refresh_safe_area(force: bool = false) -> void:
	if Engine.is_editor_hint():
		_apply_offsets([left, top, right, bottom])
		return

	if set_from_safe_area == SetFromSafeAreaMode.OFF and not force:
		return

	var window_size := DisplayServer.window_get_size()
	var window_rect := Rect2(Vector2.ZERO, window_size)
	var safe_rect := Rect2(DisplayServer.get_display_safe_area())

	var new_left := max(left, int(safe_rect.position.x - window_rect.position.x))
	var new_top := max(top, int(safe_rect.position.y - window_rect.position.y))
	var new_right := max(right, int(window_rect.end.x - safe_rect.end.x))
	var new_bottom := max(bottom, int(window_rect.end.y - safe_rect.end.y))

	_apply_offsets([new_left, new_top, new_right, new_bottom])


# apply final margins to the control
func _apply_offsets(offsets: Array[int]) -> void:
	current_offsets = offsets
	offset_left = current_offsets[0]
	offset_top = current_offsets[1]
	offset_right = -current_offsets[2]
	offset_bottom = -current_offsets[3]
	_update_debug_overlay()


# draw or remove the debug overlay showing the safe area
func _update_debug_overlay() -> void:
	if not is_inside_tree():
		return

	if _debug_rect and _debug_rect.is_inside_tree():
		_debug_rect.queue_free()
		_debug_rect = null

	if not show_safe_area_debug:
		return

	_debug_rect = ColorRect.new()
	_debug_rect.color = Color(1.0, 0.0, 0.0, 0.18)
	_debug_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_debug_rect.anchor_left = 0.0
	_debug_rect.anchor_top = 0.0
	_debug_rect.anchor_right = 1.0
	_debug_rect.anchor_bottom = 1.0
	_debug_rect.offset_left = 0.0
	_debug_rect.offset_top = 0.0
	_debug_rect.offset_right = 0.0
	_debug_rect.offset_bottom = 0.0

	add_child(_debug_rect)
