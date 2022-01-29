extends KinematicBody2D


export (int) var speed = 200

var path: Array = []
var levelNavigation: Navigation2D
var player
var velocity = Vector2()


func _ready():
	yield(get_tree(), "idle_frame")
	if get_tree().has_group("LevelNavigation"):
		levelNavigation = get_tree().get_nodes_in_group("LevelNavigation")[0]
	if get_tree().has_group("player"):
		player = get_tree().get_nodes_in_group("player")[0]


func _physics_process(delta):
	$Line2D.global_position = Vector2()
	if player and levelNavigation:
		generate_path()
		navigate()
	move()


func navigate():
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * speed
		if global_position == path[0]:
			path.pop_front()


func generate_path():
	if player and levelNavigation:
		path = levelNavigation.get_simple_path(global_position, player.global_position)
		$Line2D.points = path


func move():
	velocity = move_and_slide(velocity)


func die():
	queue_free()
