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


func on_pick_up_gun(player_name):
	rpc("pick_up_gun", get_tree().get_network_unique_id())


remotesync func pick_up_gun(player_id):
	var path_to_player = "/root/World/Players/" + str(player_id)
	var gun = Gun.instance()
	gun.on_floor = false
	gun.position = get_node(path_to_player + "/Flashlight").position
	get_node(path_to_player).add_child(gun)
	get_node(path_to_player).holding = "gun"
	drop_flashlight()


func drop_flashlight():
	$Flashlight.on_floor = true
	$Flashlight.position = global_position
	if $Flashlight.on:
		$Flashlight.switch()
	reparent($Flashlight, get_node("/root/World/"))


func on_pick_up_flashlight():
	rpc("pick_up_flashlight", get_tree().get_network_unique_id())


remotesync func pick_up_flashlight(player_id):
	var path_to_player = "/root/World/Players/" + str(player_id)
	var flashlight = Flashlight.instance()
	flashlight.on_floor = false
	flashlight.position = get_node(path_to_player + "/Gun").position
	get_node(path_to_player).add_child(flashlight)
	get_node(path_to_player).holding = "flashlight"
	drop_gun()


func drop_gun():
	$Gun.on_floor = true
	$Gun.position = global_position
	reparent($Gun, get_node("/root/World/"))


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


func reparent(child: Node, new_parent: Node):
	var old_parent = child.get_parent()
	old_parent.remove_child(child)
	new_parent.add_child(child)
