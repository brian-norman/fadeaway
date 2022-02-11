extends KinematicBody2D


export (int) var speed = 200

var path: Array = []
var levelNavigation: Navigation2D
var target_player
var velocity = Vector2()


func _ready():
	yield(get_tree(), "idle_frame")
	if get_tree().has_group("LevelNavigation"):
		levelNavigation = get_tree().get_nodes_in_group("LevelNavigation")[0]


func _physics_process(_delta):
	$Line2D.global_position = Vector2()
	if target_player and levelNavigation:
		generate_path()
		navigate()
	move()


func navigate():
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * speed
		if global_position == path[0]:
			path.pop_front()


func generate_path():
	if is_instance_valid(target_player):
		path = levelNavigation.get_simple_path(global_position, target_player.global_position)
		$Line2D.points = path


func move():
	velocity = move_and_slide(velocity)


func die(player_id):
	if player_id == get_tree().get_network_unique_id():
		gamestate.kills += 1
	else:
		gamestate.players_kills[player_id] += 1
	queue_free()


func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("player"):
		body._on_enemy_collision(body.name)
		queue_free()
