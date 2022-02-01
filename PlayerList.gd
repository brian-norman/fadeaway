extends ItemList


var player_stat_str = "%s - Kills: %d"


func _ready():
	update_scores()


func _process(delta):
	clear()
	update_scores()


func update_scores():
	add_item(player_stat_str % [gamestate.player_name, gamestate.kills])
	for player in gamestate.players:
		add_item(player_stat_str % [gamestate.players[player], gamestate.players_kills[player]])
