extends Node2D

export var player_scene: PackedScene

onready var player_entry_node: Node2D = find_node("PlayerEntry")
onready var environment_items = find_node("EnvironmentItems")
onready var ground = find_node("Ground")

var player: Node2D


func _ready():
	window_size_setup()


func _exit_tree():
	if no_children():
		return

	get_tree().root.disconnect("size_changed", self, "on_window_resize")


func no_children():
	return get_child_count() == 0


func window_size_setup():
	OS.min_window_size = Vector2(1280, 720)
	var _c = get_tree().root.connect("size_changed", self, "on_window_resize")


func on_window_resize():
	var vp = get_viewport()

	if vp == null:
		return

	vp.set_size_override(true, Vector2(OS.window_size.x, OS.window_size.y))
	vp.size_override_stretch = true

	if player.is_inside_tree():
		var camera: Camera2D = player.camera
		var width: int = int(abs(camera.limit_left) + abs(camera.limit_right))

		if OS.window_size.x > width:
			camera.offset = Vector2(int((OS.window_size.x - width) / 2), 0)
		else:
			camera.offset = Vector2()


