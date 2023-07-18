extends VehicleBody3D


@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
var steer_target = 0
var can_exit = false
@export var engine_force_value = 40
var player_res = preload("res://assets/simple_fpsplayer/Player.tscn")
var puppet = preload("res://multiplayerPuppet.tscn")
@export var MULTIPLAYER = false
var socket = Global.socket
var CONNECTED

var grapplingData = [false,Transform3D(),0.001]

var transgenders = {}
var players = []
var carTransgender
var refWires = {}
var name2ref = {}
var can_exit_frame = false
var startTime = 74
func _ready():
	if Global.customMusic != null:
		$AudioStreamPlayer3D.stream = Global.customMusic
		$AudioStreamPlayer.stream = Global.customMusic
		startTime = 0
	$AudioStreamPlayer3D.play(startTime)
	var player = $"../Player"
	#player.connect("tree_exited",entered_car)
	CONNECTED = MULTIPLAYER

func _physics_process(delta):
	var speed = linear_velocity.length()*Engine.get_frames_per_second()*delta
	traction(speed)
	var fwd_mps = transform.basis.x.x
	steer_target = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	steer_target *= STEER_LIMIT
	if Input.is_action_pressed("ui_down"):
	# Increase engine force at low speeds to make the initial acceleration faster.

		if speed < 20 and speed != 0:
			engine_force = clamp(engine_force_value * 3 / speed, 0, 300)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0
	if Input.is_action_pressed("ui_up"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		if fwd_mps >= -1:
			if speed < 30 and speed != 0:
				engine_force = -clamp(engine_force_value * 10 / speed, 0, 300)
			else:
				engine_force = -engine_force_value
		else:
			brake = 1
	else:
		brake = 0.0
		
	if Input.is_action_pressed("ui_select"):
		brake=3
		$wheal2.wheel_friction_slip=0.8
		$wheal3.wheel_friction_slip=0.8
	else:
		$wheal2.wheel_friction_slip=3
		$wheal3.wheel_friction_slip=3
	steering = move_toward(steering, steer_target, STEER_SPEED * delta)
	if Input.is_action_just_pressed("car_interact") and can_exit:
		freeze=true
		print("creating player again")
		var player_inst = player_res.instantiate()
		
		$"..".add_child(player_inst)
		player_inst.global_transform.origin = Vector3(global_transform.origin.x,global_transform.origin.y + 5,global_transform.origin.z)
		player_inst.get_node("rotation_helper/Camera3D").current = true
		$AudioStreamPlayer.stream_paused = true
		$AudioStreamPlayer3D.stream_paused = false
		$AudioStreamPlayer3D.seek($AudioStreamPlayer.get_playback_position())
		can_exit=false
		#player_inst.connect("tree_exited",entered_car)
		if MULTIPLAYER:
			print("\n \n here \n \n \n")
			print("players are " + str(players))
			player_inst.socket = socket
			player_inst.MULTIPLAYER=true
			player_inst.car = $"."
			player_inst.puppet = puppet
			player_inst.carTransgender = global_transform
			player_inst.players = players
			for other in name2ref:
				print(other)
				delete_player(other)
			Global.send_readd_player_sig()
	if MULTIPLAYER and can_exit:
		socket.poll()
		handleMultiplayer()
		send_data_marked(global_transform)
		if CONNECTED:
			for mover in transgenders:
				var ref = name2ref[mover]
				ref.global_transform.origin = lerp(ref.global_transform.origin,transgenders[mover].origin,0.5)
				ref.global_transform.basis = transgenders[mover].basis
			for muWire in refWires:
				muWire.global_transform = refWires[muWire]
	if can_exit_frame:
		can_exit=true
		can_exit_frame=false
func handlePacket(pak):
	CONNECTED=true
	var data=pak.decode_var(0,true)
	if data is Array:
		var mover = data[0]
		if mover != Global.username:
			print(data)
			#movement stuff
			if data[4] == false:
				transgenders[mover] = data[1]
				print(transgenders)
			if data[4]:
				print("car transgender  is " + str(data[1]))
				carTransgender = data[1]
			#shooting stuff
			if data[2]:
				name2ref[mover].shootingAnim()
			
			if data[3][0] == true:
				var grapStuff = data[3]
				var refWire = name2ref[mover].wire
				refWire.height = grapStuff[2]
				refWire.global_transform = grapStuff[1]
				refWire.visible = true
				refWires[refWire]= grapStuff[1]
			elif mover in name2ref:
				var refWire = name2ref[mover].wire
				refWire.visible = false

func handleMultiplayer():
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			#print("Packet: ", socket.get_packet())
			handlePacket(socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		CONNECTED=false
func traction(speed):
	apply_central_force(Vector3.DOWN*speed)

func entered_car():
	print("entered_car func called")
	$AudioStreamPlayer3D.stream_paused = true
	$AudioStreamPlayer.play($AudioStreamPlayer3D.get_playback_position())
	#get_tree().get_root().get_node(".").print_tree_pretty()
	var player = $"../Player"
	print(player)
	if MULTIPLAYER:
		name2ref = player.name2ref
		transgenders = player.transgenders
		Global.send_delete_player_sig()
	player.queue_free()
	can_exit_frame = true
	can_exit=false

func delete_player(username):
	print("deleting")
	var ref = name2ref[username]
	ref.queue_free()
	name2ref.erase(username)
	transgenders.erase(username)
	refWires.clear()

func send_data_marked(data):
	socket.send(var_to_bytes([Global.username,data,false,[false],true]))
