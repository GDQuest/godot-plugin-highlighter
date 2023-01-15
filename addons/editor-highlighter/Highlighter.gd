extends Panel


var stylebox: StyleBox = null:
	set(value):
		set("theme_override_styles/panel", value)
	get:
		return get("theme_override_styles/panel")


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	#material = ShaderMaterial.new()
	#material.shader = preload("./highlighter.gdshader")


func fit_control(target_control: Control) -> void:
	size = target_control.size
	global_position = target_control.global_position
