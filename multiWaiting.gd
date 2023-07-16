extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	discord_sdk.state = "waiting for other players in multiplayer lobby"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_2_pressed():
	pass


func _on_exit_pressed():
	get_tree().change_scene_to_file("res://mainMenu.tscn")


func _on_join_lobby_pressed():
	Global.start_socket()
	get_tree().change_scene_to_file("res://MultiPlayerTestArena.tscn")


func _on_text_edit_text_changed():
	Global.username = $TextEdit.text
	print($TextEdit.text)
