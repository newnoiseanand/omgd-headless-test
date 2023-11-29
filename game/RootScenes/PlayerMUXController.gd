extends "res://RootScenes/RootController.gd"

export var character_scene: PackedScene

var user_ids: Array = []


func _ready():
	var _gc

	if PlayerManager.is_server():
		_gc = PlayerManager.connect("player_joined", self, "_add_networked_player_to_scene")
		_gc = PlayerManager.connect("player_left", self, "_remove_networked_player_from_scene")
	else:
		_gc = PlayerManager.connect("user_joined", self, "_add_player_to_scene")


func _exit_tree():
	if PlayerManager.is_server():
		PlayerManager.disconnect("player_joined", self, "_add_networked_player_to_scene")
		PlayerManager.disconnect("player_left", self, "_remove_networked_player_from_scene")
	else:
		PlayerManager.disconnect("user_joined", self, "_add_player_to_scene")


func _add_player_to_scene(user_id: int):
	user_ids.append(user_id)

	if player == null:
		player = player_scene.instance()

	# player.position = player_entry_node.position
	player.name = String(user_id)
	player.user_id = String(user_id)
	player.set_network_master(PlayerManager.get_network_id())

	environment_items.call_deferred("add_child", player)


puppet func _setup_users_on_join(_user_ids, _user_pos):
	print_debug("_setup_users_on_join called")

	var user_pos = JSON.parse(_user_pos).result

	for user_id in _user_ids:
		var v2 = str2var("Vector2" + user_pos["p%s" % user_id])

		_add_character_to_scene(user_id, v2)


func _add_networked_player_to_scene(user_id: int):
	print_debug("calling _add_networked_player_to_scene")

	var user_pos = {}

	for player in environment_items.get_children():
		user_pos["p%s" % player.name] = player.position

	rpc_id(user_id, "_setup_users_on_join", user_ids, to_json(user_pos))

	rpc("_add_character_to_scene", user_id)
	_add_character_to_scene(user_id)


remote func _add_character_to_scene(user_id: int, pos: Vector2 = Vector2.ZERO):
	if (user_id == PlayerManager.get_network_id()): return

	print_debug("calling _add_character_to_scene for user_id ", user_id)

	user_ids.append(user_id)

	var player_node = character_scene.instance()

	player_node.set_network_master(PlayerManager.get_network_id())
	player_node.user_id = String(user_id)
	player_node.name = String(user_id)
	player_node.position = pos

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


