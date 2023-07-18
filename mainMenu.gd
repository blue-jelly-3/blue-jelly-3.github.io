extends Control

var single_map = preload("res://Playground.tscn")
var optionsMap = preload("res://options.tscn")
var multiWaiting = preload("res://multiWaiting.tscn")
var listener = -1
var listening=false
@onready var LineEditRegEx = RegEx.new()
var old_text = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	discord_sdk.state = "in main menu"
	$Label.text = Global.version
	Global.load_settings()
	LineEditRegEx.compile("^[0-9.]*$")
	for box in $options.get_children():
		if box is HBoxContainer:
			for potential_button in box.get_children():
				
				if potential_button is Button and not potential_button is ColorPickerButton and potential_button.name.length() > "Button ".length() and potential_button.name.contains(" "):
					print(potential_button.name.get_slice(" ",1))
					#black magic, dont touch
					potential_button.text = str(Global.settings["keybinds"][potential_button.name.get_slice(" ",1)][0]).get_slice("(",1).get_slice(")",0)
					print(potential_button)
					print(potential_button.text)
	if Global.customMusicPath != null:
		$options/HBoxContainer4/Label2.text = Global.customMusicPath
	$options/HBoxContainer/HSlider2.value = AudioServer.get_bus_volume_db(0)
	$options/HBoxContainer6/gunSlider.value = AudioServer.get_bus_volume_db(1)
	$options/HBoxContainer2/TextureRect.texture = Global.crosshair
	$options/HBoxContainer2/TextureRect.set_size(Vector2(64,64),true)
	$options/HBoxContainer2/TextureRect.modulate = Global.crosshair_color
	$options/HBoxContainer3/ColorPickerButton.color = Global.crosshair_color
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_single_pressed():
	get_tree().change_scene_to_packed(single_map)


func _on_options_pressed():
	$name.visible=false
	$VBoxContainer.visible=false
	$options.visible=true


func _on_multi_pressed():
	get_tree().change_scene_to_packed(multiWaiting)


func _on_button_pressed():
	$options/HBoxContainer2/FileDialog.set_filters(PackedStringArray(["*.png ; PNG Images"]))
	$options/HBoxContainer2/FileDialog.show()


func _on_file_dialog_file_selected(path):
	print("confirmed")
	
	print("res://assets/kenney_crosshair-pack/PNG/White/" + $options/HBoxContainer2/FileDialog.current_path)
	var fullpath = "res://assets/kenney_crosshair-pack/PNG/White/" + $options/HBoxContainer2/FileDialog.current_path
	var tex = load(fullpath)
	#print(typeof($options/HBoxContainer2/FileDialog.current_path))
	Global.crosshair=tex
	Global.crosshairPath = fullpath
	$options/HBoxContainer2/TextureRect.texture = Global.crosshair


func _on_color_picker_button_color_changed(color):
	Global.crosshair_color = color
	$options/HBoxContainer2/TextureRect.modulate = color


func _on_file_dialog_song_file_selected(path):
	print(path)
	Global.customMusic = AudioStreamMP3.new()
	var file = FileAccess.open(path,FileAccess.READ)
	Global.customMusic.data = file.get_buffer(file.get_length())
	Global.customMusicPath = path
	$options/HBoxContainer4/Label2.text = path

func _on_button_song_pressed():
	$options/HBoxContainer4/FileDialogSong.popup()


func _on_button_car_pressed():
	$"options/car interact/Button car interact".text = "-press any key-"
	InputMap.action_erase_events("car interact")
	listener = "car interact"
	listening=true
	
	
func _unhandled_key_input(event):
	if listening:
		print(event)
		InputMap.action_add_event(listener,event)
		get_node("options/"+listener+"/Button "+listener).text = event.as_text()
		listening=false


func _on_exit_pressed():
	if $options.visible:
		$options.visible=false
		$VBoxContainer.visible =true
	Global.save_settings()


func _on_button_flashlight_pressed():
	var action = "flashlight"
	$"options/flashlight/Button flashlight".text = "-press any key-"
	InputMap.action_erase_events(action)
	listener = action
	listening=true


func _on_button_next_spectate_pressed():
	var action = "next_spectate"
	get_node("options/"+action+"/Button "+action).text  = "-press any key-"
	InputMap.action_erase_events(action)
	listener = action
	listening=true


func _on_button_previous_spectate_pressed():
	var action = "previous_spectate"
	get_node("options/"+action+"/Button "+action).text  = "-press any key-"
	InputMap.action_erase_events(action)
	listener = action
	listening=true


func _on_button_grapple_pressed():
	var action = "grapple"
	get_node("options/"+action+"/Button "+action).text  = "-press any key-"
	InputMap.action_erase_events(action)
	listener = action
	listening=true


func _on_button_crouch_pressed():
	var action = "crouch"
	get_node("options/"+action+"/Button "+action).text  = "-press any key-"
	InputMap.action_erase_events(action)
	listener = action
	listening=true


func _on_h_slider_2_value_changed(value):
	var volume = value
	var As = AudioServer
	As.set_bus_volume_db(0,value)
	print(As.get_bus_volume_db(As.get_bus_index("Master")))


func _on_gun_slider_value_changed(value):
	var As = AudioServer
	As.set_bus_volume_db(1,value)
	print(As.get_bus_volume_db(As.get_bus_index("GunShots")))


func _on_aim_slider_value_changed(value):
	$options/HBoxContainer7/TextEdit.text = str(value).get_slice(".",1)
	Global.MOUSE_SENSITIVITY = value


func _on_text_edit_text_changed(new_text):
	if LineEditRegEx.search(new_text):
		old_text = str(new_text)
		$options/HBoxContainer7/aimSlider.value = float(new_text) / (10 ** new_text.length())
		Global.MOUSE_SENSITIVITY = float(new_text) / (10 ** new_text.length())
	else:
		print("illegal!!")
		$options/HBoxContainer7/TextEdit.text = old_text
	$options/HBoxContainer7/TextEdit.set_caret_column(old_text.length())

