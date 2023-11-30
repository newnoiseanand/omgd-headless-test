extends Node2D

export var character_scene: PackedScene
export var player_scene: PackedScene

onready var player_entry_node: Node2D = find_node("PlayerEntry")
onready var environment_items = find_node("EnvironmentItems")
onready var ground = find_node("Ground")

var player: Node2D
var user_ids: Array = []


func _ready():
	var _gc # NOTE: avoiding code warnings with a dummy var

	if PlayerManager.is_server():
		_gc = PlayerManager.connect("player_joined", self, "_add_networked_player_to_scene")
		_gc = PlayerManager.connect("player_left", self, "_remove_networked_player_from_scene")
	else:
		_gc = PlayerManager.connect("user_joined", self, "_add_player_to_scene")
		OS.min_window_size = Vector2(1280, 720)
		_gc = get_tree().root.connect("size_changed", self, "_on_window_resize")


func _exit_tree():
	if PlayerManager.is_server():
		PlayerManager.disconnect("player_joined", self, "_add_networked_player_to_scene")
		PlayerManager.disconnect("player_left", self, "_remove_networked_player_from_scene")
	else:
		PlayerManager.disconnect("user_joined", self, "_add_player_to_scene")
		get_tree().root.disconnect("size_changed", self, "on_window_resize")


func _add_player_to_scene(user_id: int):
	user_ids.append(user_id)

	if player == null:
		player = player_scene.instance()

	# player.position = player_entry_node.position
	player.name = String(user_id)
	player.user_id = String(user_id)
	player.set_network_master(PlayerManager.get_network_id())

	environment_items.call_deferred("add_child", player)


puppet func _setup_users_on_join(user_ids_from_server, user_pos_json, user_rots_json):
	print_debug("_setup_users_on_join called")

	var user_pos = JSON.parse(user_pos_json).result
	var user_rots = JSON.parse(user_rots_json).result

	for user_id in user_ids_from_server:
		var v2 = str2var("Vector2" + user_pos["p%s" % user_id])
		var rot = int(user_rots["p%s" % user_id])

		_add_character_to_scene(user_id, v2, rot)


func _add_networked_player_to_scene(user_id: int):
	print_debug("calling _add_networked_player_to_scene")

	var user_pos = {}
	var user_rots = {}

	for existing_player in environment_items.get_children():
		user_pos["p%s" % existing_player.name] = existing_player.position
		user_rots["p%s" % existing_player.name] = existing_player.icon.rotation_degrees

	rpc_id(
		user_id,
		"_setup_users_on_join",
		user_ids,
		to_json(user_pos),
		to_json(user_rots)
	)

	rpc("_add_character_to_scene", user_id)
	_add_character_to_scene(user_id)


remote func _add_character_to_scene(user_id: int, pos: Vector2 = Vector2.ZERO, rot: float = 0):
	if (user_id == PlayerManager.get_network_id()): return

	print_debug("calling _add_character_to_scene for user_id ", user_id)

	user_ids.append(user_id)

	var player_node = character_scene.instance()

	player_node.set_network_master(user_id)
	player_node.user_id = String(user_id)
	player_node.name = String(user_id)
	player_node.position = pos
	player_node.find_node("Godot_icon").rotation_degrees = rot

	environment_items.add_child(player_node)


func _remove_networked_player_from_scene(user_id: int):
	print_debug("calling _remove_networked_player_from_scene")

	for uid in user_ids:
		if uid != user_id:
			rpc_id(uid, "_rid_networked_player", user_id)

	_rid_networked_player(user_id)


remote func _rid_networked_player(user_id: int):
	print_debug("calling _rid_networked_player")

	user_ids.erase(user_id)
	environment_items.find_node(String(user_id), true, false).queue_free()


func _on_window_resize():
	var vp = get_viewport()

	if vp == null:
		return

	vp.set_size_override(true, Vector2(OS.window_size.x, OS.window_size.y))
	vp.size_override_stretch = true


