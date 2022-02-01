extends Node2D


export (PackedScene) var Enemy
export (float) var LIGHTNING_DURATION = 0.5
export (float) var BASE_LIGHT_ENERGY = 0.3
export (float) var BRIGHT_LIGHT_ENERGY = 1


func _ready():
	randomize()
	$LevelLight.energy = BASE_LIGHT_ENERGY


func _on_EnemyTimer_timeout():
	if is_network_master():
		$EnemySpawnPath/PathFollow2D.offset = randi()
		var players = get_tree().get_nodes_in_group("player")
		var target_player_name = players[random_number(0, len(players) - 1)].name
		rpc("spawn_enemy", $EnemySpawnPath/PathFollow2D.position, target_player_name)


func _on_LightningTimer_timeout():
	$LevelLight.energy = BRIGHT_LIGHT_ENERGY
	yield(get_tree().create_timer(LIGHTNING_DURATION), "timeout")	
	$LevelLight.energy = BASE_LIGHT_ENERGY
	$LightningTimer.start()


func _on_House_body_entered(body):
	if body.is_in_group("player") and int(body.name) == get_tree().get_network_unique_id():
		$House/HouseLight.enabled = true


func _on_House_body_exited(body):
	if body.is_in_group("player") and int(body.name) == get_tree().get_network_unique_id():
		$House/HouseLight.enabled = false


remotesync func spawn_enemy(position, target_player_name):
	var enemy = Enemy.instance()
	enemy.position = position
	for player in get_tree().get_nodes_in_group("player"):
		if player.name == target_player_name:
			enemy.target_player = player
	add_child(enemy)


func random_number(from: int, to: int):
	return range(from, to + 1)[randi() % range(from, to + 1).size()]
