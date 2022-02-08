extends KinematicBody2D


export (PackedScene) var Flashlight
export (PackedScene) var Gun

export (int) var speed = 200

var velocity = Vector2()

puppet var puppet_pos = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_look_direction = Vector2()

# Can be "gun" or "flashlight"
var holding = "gun"


func _ready():
	$Gun.connect("pick_up", self, "on_pick_up_gun")
	puppet_pos = position


func _process(_delta):
	if is_network_master():
		look_at(get_global_mouse_position())
		rset("puppet_look_direction", get_global_mouse_position())
	else:
		look_at(puppet_look_direction)


func _physics_process(_delta):
	var direction = Vector2()
	if is_network_master():
		if Input.is_action_pressed("move_left"):
			direction += Vector2(-1, 0)
		if Input.is_action_pressed("move_right"):
			direction += Vector2(1, 0)
		if Input.is_action_pressed("move_up"):
			direction += Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			direction += Vector2(0, 1)
		
		rset("puppet_velocity", velocity)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		velocity = puppet_velocity
	
	var _velocity = move_and_slide(direction * speed)
	
	# To avoid jitter
	if not is_network_master():
		puppet_pos = position


func _on_Area2D_body_entered(body):
	if body.is_in_group("enemy"):
		rpc("die", get_tree().get_network_unique_id())


func on_pick_up_gun(player_name, node):
	var player = get_tree().root.get_node("World/Players/" + player_name)
	gamestate.reparent(node, player)
	rpc("pick_up_gun", get_tree().get_network_unique_id())


remotesync func pick_up_gun(player_id):
	var player = get_tree().root.get_node("World/Players/" + str(player_id))
	var gun = player.get_node("Gun")
	gun.on_floor = false
	gun.position = player.get_node("Flashlight").position	   # TODO: Switch to using an "Held Object Position2D" fixed on the Player
	player.add_child(gun)
	player.holding = "gun"
	drop_flashlight()


func drop_flashlight():
	$Flashlight.on_floor = true
	$Flashlight.position = global_position
	if $Flashlight.on:
		$Flashlight.switch()
	gamestate.reparent($Flashlight, get_node("/root/World/"))


func on_pick_up_flashlight():
	rpc("pick_up_flashlight", get_tree().get_network_unique_id())


remotesync func pick_up_flashlight(player_id):
	var player = get_tree().root.get_node("World/Players/" + str(player_id))
	var flashlight = player.get_node("Flashlight")
	flashlight.on_floor = false
	flashlight.position = player.get_node("Gun").position
	player.holding = "flashlight"
	drop_gun(player)


func drop_gun(player):
	var gun = player.get_node("Gun")
	gun.on_floor = true
	gun.position = global_position
	gamestate.reparent(gun, get_node("/root/World/"))


remotesync func die(player_id):
	if int(player_id) == get_tree().get_network_unique_id():
		position = get_node("/root/World/SpawnPoints/0").position
		rset("puppet_pos", position)
		gamestate.deaths += 1
	else:
		position = puppet_pos
		gamestate.players_deaths[player_id] += 1


func set_player_name(name):
	$Name/NameLabel.text = name
