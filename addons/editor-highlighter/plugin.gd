@tool
extends EditorPlugin

const Highlighter := preload("./Highlighter.gd")

const PLUGIN_ID := "highlighter"
const PLUGIN_PATH := "plugins/"+PLUGIN_ID

var shortcut := _get_or_set_shortcut()
var panel_stylebox := _get_or_set_highlight()

var highlight_panel := Highlighter.new()


func _enter_tree() -> void:
	highlight_panel.stylebox = panel_stylebox
	var base_control := get_editor_interface().get_base_control()
	base_control.add_child(highlight_panel)
	highlight_panel.hide()


func _exit_tree() -> void:
	highlight_panel.queue_free()


func _input(event: InputEvent) -> void:
	if shortcut and shortcut.matches_event(event):
		get_viewport().set_input_as_handled()
		if event.is_pressed():
			highlight_panel.show()
			place_highlight()
		else:
			highlight_panel.hide()
	elif event is InputEventKey and event.is_pressed() == false:
		highlight_panel.hide()


# Finds the closest control under the mouse, and wraps the highlighter so it appears above it.
func place_highlight() -> void:
	var base_control := get_editor_interface().get_base_control()
	var mouse_position := base_control.get_global_mouse_position()

	
	var target_control := find_deepest_control_under_point(base_control, mouse_position)
	
	if target_control != null:
		highlight_panel.fit_control(target_control)
	else:
		highlight_panel.global_position = mouse_position


# Returns the keyboard shortcut
static func _get_or_set_shortcut() -> Shortcut:
	var key := PLUGIN_PATH + "/shortcut"
	if not ProjectSettings.has_setting(key):
		var default_input: InputEventKey = preload("./default_shortcut.tres").duplicate()
		var property_info := {
				"name": key,
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "InputEventKey"
		}
		ProjectSettings.set_setting(key, default_input)
		ProjectSettings.add_property_info(property_info)
	var loaded_input: InputEventKey = ProjectSettings.get_setting(key)
	var loaded_shortcut := Shortcut.new()
	loaded_shortcut.events = [loaded_input]
	return loaded_shortcut


# Returns the stylebox for highlight
static func _get_or_set_highlight() -> StyleBox:
	var key := PLUGIN_PATH + "/highlight_style"
	if not ProjectSettings.has_setting(key):
		var stylebox := preload("./highlight_style.tres")
		var property_info := {
			"name": key,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tres"
		}
		ProjectSettings.set_setting(key, stylebox.resource_path)
		ProjectSettings.add_property_info(property_info)
	var stylebox_path: String = ProjectSettings.get_setting(key)
	if stylebox_path == "":
		return null
	var loaded_stylebox: StyleBox = load(stylebox_path)
	return loaded_stylebox


# Use this to lock selection to specific control depth
static func _get_or_set_min_depth() -> int:
	var key := PLUGIN_PATH + "/min_depth"
	if not ProjectSettings.has_setting(key):
		var property_info := {
			"name": key,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0,50"
		}
		ProjectSettings.set_setting(key, 4)
		ProjectSettings.add_property_info(property_info)
	return ProjectSettings.get_setting(key)


# Use this to lock selection to specific control depth
static func _get_or_set_max_depth() -> int:
	var key := PLUGIN_PATH + "/max_depth"
	if not ProjectSettings.has_setting(key):
		var property_info := {
			"name": key,
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0,50"
		}
		ProjectSettings.set_setting(key, 20)
		ProjectSettings.add_property_info(property_info)
	return ProjectSettings.get_setting(key)


# Finds the control under the specified global point, and recursively finds its children under that point,
# until reaching the most nested child available.
static func find_deepest_control_under_point(target_control: Control, global_point: Vector2) -> Control:

	var max_iterations := _get_or_set_max_depth()
	var min_iterations := _get_or_set_min_depth()

	var maybe_control := target_control
	var current_iteration := 0
	# instead of recursion, use a while loop with a control condition
	while (maybe_control and current_iteration < max_iterations):
		current_iteration += 1

		maybe_control = find_closest_child_control_under_point(target_control.get_children(), global_point)
		if maybe_control is Control:
			target_control = maybe_control

	if current_iteration <= min_iterations:
		return null
	return target_control


# Returns a the first child control that is under the given global position
static func find_closest_child_control_under_point(children: Array[Node], global_point: Vector2) -> Control:
	for child in children:
		if child is Control and child.visible:
			var child_control := child as Control
			var control_rect := child_control.get_global_rect()
			if control_rect.has_point(global_point):
				return child_control
	return null
