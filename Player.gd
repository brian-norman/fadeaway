extends KinematicBody2D


export (PackedScene) var Flashlight

export (int) var speed = 200

var velocity = Vector2()

puppet var puppet_pos = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_look_direction = Vector2()

# Can be "gun" or "flashlight"
var holding = "gun"


func _ready():
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


# TODO: This is weird
func _input(event):
	if event.is_action_pressed("pick_up") and not holding == "flashlight" and is_network_master():
		var flashlight = Flashlight.instance()
		flashlight.on_floor = false
		flashlight.position = $Gun.position
		add_child(flashlight)
		$Gun.drop(position)
		holding = "flashlight"
	if event.is_action_pressed("switch_flashlight") and holding == "flashlight"  and is_network_master():
		$Flashlight.switch()


func _on_Area2D_body_entered(body):
	if body.is_in_group("enemy"):
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
