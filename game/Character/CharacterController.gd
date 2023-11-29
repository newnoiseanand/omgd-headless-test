extends KinematicBody2D

const SPEED: int = 150

onready var target: Vector2 = position

var velocity: Vector2
export var user_id: String


func _ready():
	var label: Label = find_node("UsernameLabel")
	label.text = user_id


func _physics_process(_delta):
	velocity = position.direction_to(target) * SPEED

	if position.distance_to(target) > 5:
		velocity = move_and_slide(velocity)


remote func _move_event(args):
	target = args


