extends Node

var websocket_url = "wss://new-blue-jelly3-websocket-server.jonathanbreitg.repl.co"
var username = "roei123"
var appid = 1129814416062427137
var socket
var MOUSE_SENSITIVITY = 0.1
var version = "V-0.3"
var name2ref
var realPlayer

func _ready():
	username = "roei" + str(randi_range(1000,9999))
	print(username)
	
	discord_sdk.app_id = appid
	print("Discord working: " + str(discord_sdk.get_is_discord_working())) # A boolean if everything worked
	
	discord_sdk.details = "playing Blue Jelly 3! " + version
	discord_sdk.state = "in main menu"
	
	discord_sdk.large_image = "large-roei" # Image key from "Art Assets"
	discord_sdk.large_image_text = "ROEIDI!!!"


	discord_sdk.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
	# discord_sdk.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00 remaining"

	discord_sdk.refresh() # Always refresh after changing the values!

func start_socket():
	socket = WebSocketPeer.new()
	socket.connect_to_url(websocket_url)

func send_delete_player_sig():
	print("sending delete player sig")
	socket.send(var_to_bytes({"name" : username , "delete" : true , "left": false,"readd":false,"hit":false}))
func send_readd_player_sig():
	socket.send(var_to_bytes({"name" : username , "delete" : false , "left": false,"readd":true,"hit":false}))
func send_hit_other_player_sig(hurtPlayer,dmg):
	socket.send(var_to_bytes({"name" : username , "delete" : false , "left": false,"readd":false,"hit":true,"hitData":[hurtPlayer,dmg]}))
func send_revive_signal():
	socket.send(var_to_bytes({"name" : username , "delete" : false , "left": false,"readd":true,"hit":false}))
