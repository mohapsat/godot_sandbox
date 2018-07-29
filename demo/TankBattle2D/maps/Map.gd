extends Node2D

# script to set camera limits based on map size
# do this inside ready 
# all other maps will use the same script

func _ready():
	set_camera_limits() # custom func

func set_camera_limits():
	# to set camera limits, we need to know how much map is used
	var map_limits = $Ground.get_used_rect()
	# returns a rect telling how much space map is taking up
	
	var map_cellsize = $Ground.cell_size
	# returns how big cells of the map are
	
	$Player/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
	$Player/Camera2D.limit_right = map_limits.end.x * map_cellsize.x 
	$Player/Camera2D.limit_top = map_limits.position.y * map_cellsize.y	
	$Player/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y
	# now camera does not go outside the map limits

# func to receive bullets that are spawned
# needs to be connected any tanks shoot signal
func _on_Tank_shoot(bullet, _position, _direction):
	var b = bullet.instance() # make a new bullet instance
	add_child(b) # add child
	b.start(_position, _direction)