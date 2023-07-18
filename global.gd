extends Node

var websocket_url = "wss://new-blue-jelly3-websocket-server.jonathanbreitg.repl.co"
var username = "roei123"
var appid = 1129814416062427137
var socket
var MOUSE_SENSITIVITY = 0.1
var version = "V-0.5"
var name2ref
@onready var crosshair = load("res://assets/kenney_crosshair-pack/PNG/White/crosshair038.png")
var realPlayer
var crosshair_color = Color(1,1,1,1)
var crosshairPath = "res://assets/kenney_crosshair-pack/PNG/White/crosshair038.png"
var customMusic = null
var customMusicPath = null
var mapping = {}
var settings = {"crosshairPath":crosshairPath,"crosshair_color":[crosshair_color.r,crosshair_color.g,crosshair_color.b,crosshair_color.a],"customMusicPath":customMusicPath,"MOUSE_SENSITIVITY":MOUSE_SENSITIVITY,"keybinds":mapping,"MASTER_VOLUME":AudioServer.get_bus_volume_db(0),"GUNSHOT_VOLUME":AudioServer.get_bus_volume_db(1)}

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
	var actions = InputMap.get_actions()
	for action in actions:
		mapping[action] = InputMap.action_get_events(action)
	settings["keybinds"] = mapping

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

func save_settings():
	var file_save = FileAccess.open("user://settings-custom.save",FileAccess.WRITE_READ)
	print(InputMap.to_string())
	var actions = InputMap.get_actions()
	for action in actions:
		mapping[action] = InputMap.action_get_events(action)
	settings = {"crosshairPath":crosshairPath,"crosshair_color":[crosshair_color.r,crosshair_color.g,crosshair_color.b,crosshair_color.a],"customMusicPath":customMusicPath,"MOUSE_SENSITIVITY":MOUSE_SENSITIVITY,"keybinds":mapping,"MASTER_VOLUME":AudioServer.get_bus_volume_db(0),"GUNSHOT_VOLUME":AudioServer.get_bus_volume_db(1)}
	file_save.store_line(JSON.stringify(settings))
	file_save.close()
	load_settings()

func load_settings():
	
	if FileAccess.file_exists("user://settings-custom.save"):
		var file_save = FileAccess.open("user://settings-custom.save",FileAccess.READ)
	#print(file_save.get_as_text())
		var dic = JSON.parse_string(file_save.get_as_text())
		for setting in dic:
			settings[setting] = dic[setting]
	
	#load music from path
	
	customMusicPath = settings["customMusicPath"]
	if customMusicPath != null:
		customMusic = AudioStreamMP3.new()
		var file = FileAccess.open(customMusicPath,FileAccess.READ)
		customMusic.data = file.get_buffer(file.get_length())
	
	#load crosshair
	crosshairPath = settings["crosshairPath"]
	crosshair = load(crosshairPath)
	crosshair_color=Color(settings["crosshair_color"][0],settings["crosshair_color"][1],settings["crosshair_color"][2],settings["crosshair_color"][3])
	#sens
	MOUSE_SENSITIVITY=settings["MOUSE_SENSITIVITY"]
	print(settings)
	
	AudioServer.set_bus_volume_db(0,settings["MASTER_VOLUME"])
	AudioServer.set_bus_volume_db(1,settings["GUNSHOT_VOLUME"])
	
