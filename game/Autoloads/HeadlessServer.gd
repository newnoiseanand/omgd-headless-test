extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const PORT = 9999
const USE_WS = false


func _ready():
	var _gc

	if "--server" in OS.get_cmdline_args():
		print("Server")

		_gc = get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	else:
		print("Client")

		_gc = get_tree().connect("connection_failed", self, "_client_connect_failed")
		_gc = get_tree().connect("connected_to_server", self, "_client_connect_success")


	if USE_WS:
		_setup_network_peer_as_ws()
	else:
		_setup_network_peer_as_udp()


func _setup_network_peer_as_ws():
	var peer

	if "--server" in OS.get_cmdline_args():
		peer = WebSocketServer.new()
		peer.listen(PORT, PoolStringArray(), true)
		print("WS Server should be setup at port ", PORT)
	else:
		peer = WebSocketClient.new();
		var url = "ws://%s:%s" % [GameConfig.nakama_host, PORT]
		print("Attempting connection to ", url)
		peer.connect_to_url(url, PoolStringArray(), true);

	get_tree().network_peer = peer


func _setup_network_peer_as_udp():
	var peer

	if "--server" in OS.get_cmdline_args():
		peer = NetworkedMultiplayerENet.new()
		peer.create_server(PORT, 8)
		print("UDP Server should be setup at port ", PORT)
	else:
		peer = NetworkedMultiplayerENet.new()
		print("Attempting connection to ", GameConfig.nakama_host, " at port ", PORT)
		peer.create_client(GameConfig.nakama_host, PORT)

	get_tree().network_peer = peer


func _exit_tree():
	if "--server" in OS.get_cmdline_args():
		get_tree().disconnect("network_peer_connected", self, "_network_peer_connected")
	else:
		get_tree().disconnect("connection_failed", self, "_client_connect_failed")
		get_tree().disconnect("connected_to_server", self, "_client_connect_success")


func _client_connect_success():
	print("client connect to server success")


func _client_connect_failed():
	print("client connect to server failed")


func _network_peer_connected(id):
	print("network peer connected!")
	print(id)
