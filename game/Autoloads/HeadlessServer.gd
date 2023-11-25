extends Node

const PORT = 9999
const USE_WEBSOCKETS = true

func _is_server():
	return "--server" in OS.get_cmdline_args()

func _ready():
	var _gc

	if _is_server():
		print_debug("Server")

		_gc = get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	else:
		print_debug("Client")

		_gc = get_tree().connect("connection_failed", self, "_client_connect_failed")
		_gc = get_tree().connect("connected_to_server", self, "_client_connect_success")

	if USE_WEBSOCKETS:
		_setup_network_peer_as_ws()
	else:
		_setup_network_peer_as_udp()


func _setup_network_peer_as_ws():
	var peer

	if _is_server():
		peer = WebSocketServer.new()
		peer.listen(PORT, PoolStringArray(), true)
		print_debug("WS Server should be setup at port ", PORT)
	else:
		peer = WebSocketClient.new();
		var url = "ws://%s:%s" % [GameConfig.nakama_host, PORT]
		print_debug("Attempting connection to ", url)
		peer.connect_to_url(url, PoolStringArray(), true);

	get_tree().network_peer = peer


func _setup_network_peer_as_udp():
	var peer

	if _is_server():
		peer = NetworkedMultiplayerENet.new()
		peer.create_server(PORT, 8)
		print_debug("UDP Server should be setup at port ", PORT)
	else:
		peer = NetworkedMultiplayerENet.new()
		print_debug("Attempting connection to ", GameConfig.nakama_host, " at port ", PORT)
		peer.create_client(GameConfig.nakama_host, PORT)

	get_tree().network_peer = peer


func _exit_tree():
	if _is_server():
		get_tree().disconnect("network_peer_connected", self, "_network_peer_connected")
	else:
		get_tree().disconnect("connection_failed", self, "_client_connect_failed")
		get_tree().disconnect("connected_to_server", self, "_client_connect_success")


func _client_connect_success():
	print_debug("client connect to server success")


func _client_connect_failed():
	print_debug("client connect to server failed")


func _network_peer_connected(id):
	print_debug("network peer connected!")
	print_debug(id)
