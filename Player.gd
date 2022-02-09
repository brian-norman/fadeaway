extends KinematicBody2D


export (PackedScene) var Flashlight
export (PackedScene) var Gun

export (int) var speed = 200

var velocity = Vector2()

puppet var puppet_pos = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_look_direction = Vector2()


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


func on_pick_up_gun(player_name, node):
	rpc("gun_pick_up", player_name, node.name)


remotesync func gun_pick_up(player_name, node_name):
	var player = get_tree().root.get_node("World/Players/" + player_name)
	var gun = get_tree().root.get_node("World/" + node_name)
	gamestate.reparent(gun, player)
	pick_up_gun()


func pick_up_gun():
	$Gun.on_floor = false
	$Gun.position = $ObjectPos.position
	drop_flashlight()


func drop_gun():
	$Gun.on_floor = true
	$Gun.position = global_position
	gamestate.reparent($Gun, get_node("/root/World/"))


func pick_up_flashlight():
	$Flashlight.on_floor = false
	$Flashlight.position = $ObjectPos.position
	drop_gun()


func drop_flashlight():
	$Flashlight.on_floor = true
	$Flashlight.position = global_position
	if $Flashlight.on:
		$Flashlight.switch()
	gamestate.reparent($Flashlight, get_node("/root/World/"))


func _on_enemy_collision():
	rpc("die", get_tree().get_network_unique_id())


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
