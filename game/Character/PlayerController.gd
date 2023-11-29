extends "res://Character/CharacterController.gd"

# icon from https://www.reddit.com/r/godot/comments/icagss/i_made_a_claylike_3d_desktop_icon_for_godot_ico/

const INPUT_MOVE: int = 200

var map_constraints: Dictionary = {}

onready var camera: Camera2D = $Camera2D


func _unhandled_input(_event):
	var target = position

	if Input.is_action_pressed("move_right"):
		target.x += INPUT_MOVE
	if Input.is_action_pressed("move_left"):
		target.x -= INPUT_MOVE
	if Input.is_action_pressed("move_down"):
		target.y += INPUT_MOVE
	if Input.is_action_pressed("move_up"):
		target.y -= INPUT_MOVE

	if target != Vector2.ZERO:
		rpc("_move_event", target)
		_move_event(target)


func restrict_camera_to_tile_map(map: TileMap):
	var limits: Rect2 = map.get_used_rect()
	var cell_size: Vector2 = map.cell_size

	camera.limit_left = int(round(limits.position.x * cell_size.x))
	camera.limit_right = int(round(limits.end.x * cell_size.x))
	camera.limit_top = int(round(limits.position.y * cell_size.y))
	camera.limit_bottom = int(round(limits.end.y * cell_size.y))

	map_constraints["left"] = camera.limit_left
	map_constraints["right"] = camera.limit_right
	map_constraints["top"] = camera.limit_top
	map_constraints["bottom"] = camera.limit_bottom


