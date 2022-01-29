extends KinematicBody2D


export (int) var speed = 200
export (int) var bullet_speed = 1000


var velocity = Vector2()


func _process(_delta):
	look_at(get_global_mouse_position())


func _physics_process(_delta):
	var direction = Vector2()
	if Input.is_action_pressed("move_left"):
		direction += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		direction += Vector2(1, 0)
	if Input.is_action_pressed("move_up"):
		direction += Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		direction += Vector2(0, 1)

	move_and_slide(direction * speed)
