extends Node2D

export (PackedScene) var Enemy


func _ready():
	randomize()


func _on_EnemyTimer_timeout():
	$EnemySpawnPath/PathFollow2D.offset = randi()
	var enemy = Enemy.instance()
	add_child(enemy)
	enemy.position = $EnemySpawnPath/PathFollow2D.position
