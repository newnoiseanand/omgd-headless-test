extends KinematicBody2D

class_name Character

const SPEED: int = 250
const DAMAGE_PER_BULLET: int = 10

onready var target: Vector2 = position
onready var icon = find_node("Godot_icon")
onready var chamber = find_node("Chamber")

export var bullet_scene: PackedScene
export var user_id: String
export var starting_health: int = 50

var velocity: Vector2


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


remote func _fire_event():
	var bullet: Area2D = bullet_scene.instance()
	bullet.fire_dir = Vector2(0, 1).rotated(icon.rotation)
	bullet.position = position
	bullet.fired_from = PlayerManager.get_network_id()
	get_parent().call_deferred("add_child", bullet)


func take_damage():
	starting_health -= DAMAGE_PER_BULLET

	if starting_health <= 0:
		queue_free()


