extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const PORT = 9999


func _ready():
	if "--server" in OS.get_cmdline_args():
		# Run your server startup code here...
		# Using this check, you can start a dedicated server by running
		# a Godot binary (headless or not) with the `--server` command-line argument.
		print("Server")
		var _gc = get_tree().connect("network_peer_connected", self, "_network_peer_connected")

		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(PORT, 8)
		get_tree().network_peer = peer

		print("Up?")
		print(get_tree().is_network_server())
		print("Server should be setup at port ", PORT)
	else:
		print("Client")

		var _gc = get_tree().connect("connection_failed", self, "_client_connect_failed")
		_gc = get_tree().connect("connected_to_server", self, "_client_connect_success")

		var peer = NetworkedMultiplayerENet.new()
		print("Attempting connection to ", GameConfig.nakama_host, " at port ", PORT)
		peer.create_client(GameConfig.nakama_host, PORT)
		get_tree().network_peer = peer


# func _exit_tree():
# 	if "--server" in OS.get_cmdline_args():
# 		get_tree().disconnect("network_peer_connected", self, "_network_peer_connected")
# 	else:
# 		get_tree().disconnect("connection_failed", self, "_client_connect_failed")
# 		get_tree().disconnect("connected_to_server", self, "_client_connect_success")


func _client_connect_success():
	print("client connect to server success")


func _client_connect_failed():
	print("client connect to server failed")


func _network_peer_connected(id):
	print("gogogoo")
	print("network peer connected!")
	print(id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
