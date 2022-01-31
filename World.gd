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
		rpc("spawn_enemy", $EnemySpawnPath/PathFollow2D.position)


func _on_LightningTimer_timeout():
	$LevelLight.energy = BRIGHT_LIGHT_ENERGY
	$LightningTimer.stop()
	yield(get_tree().create_timer(LIGHTNING_DURATION), "timeout")	
	$LevelLight.energy = BASE_LIGHT_ENERGY
	$LightningTimer.start()


func _on_House_body_entered(body):
	if body.is_in_group("player"):
		$House/HouseLight.enabled = true


func _on_House_body_exited(body):
	if body.is_in_group("player"):
		$House/HouseLight.enabled = false


remotesync func spawn_enemy(position):
	var enemy = Enemy.instance()
	add_child(enemy)
	enemy.position = position
