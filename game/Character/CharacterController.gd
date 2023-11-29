extends KinematicBody2D

const SPEED: int = 250

onready var target: Vector2 = position
onready var icon = find_node("Godot_icon")

var velocity: Vector2
export var user_id: String


func _ready():
	var label: Label = find_node("UsernameLabel")
	label.text = user_id


func _physics_process(_delta):
	if position.distance_to(target) > 5:
		velocity = position.direction_to(target) * SPEED
		velocity = move_and_slide(velocity)


remote func _move_event(args):
	target = args


remote func _rotate_event(args):
	icon.rotation += args

