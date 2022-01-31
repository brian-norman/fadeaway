extends KinematicBody2D


export (int) var speed = 200
export (int) var bullet_speed = 1000

var velocity = Vector2()

puppet var puppet_pos = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_look_direction = Vector2()


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
	
	move_and_slide(direction * speed)
	
	if not is_network_master():
		puppet_pos = position # To avoid jitter


func set_player_name(name):
	$Name/NameLabel.text = name
