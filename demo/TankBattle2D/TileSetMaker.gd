extends Node

# split tiles to 128*128 chunks
var tile_size = Vector2(128,128) # size of the drawings

onready var texture = $Sprite.texture # texture we'll use

# do everythign in ready, when we run the scene
# tileset will be created
func _ready():
	# size of each tile
	var texture_width = texture.get_width() / tile_size.x
	var texture_height = texture.get_height() / tile_size.y
	
	var ts= TileSet.new() # create a new TileSet object
	# create as many tiles there are
	for x in range(texture_width):
		for y in range(texture_height):
			#slice out of the texture is a rectangle
			var region = Rect2(x * tile_size.x, y * tile_size.y,
								tile_size.x, tile_size.y)
			# assign an id before putting in a tileset
			# comeup with a unique id
			var id = x + y * 10
			ts.create_tile(id)
			ts.tile_set_texture(id, texture)
			ts.tile_set_region(id, region)
			# at the end of the loop all tiles will be created
			# use resource saver to save the results i.e a resource
	ResourceSaver.save("res://terrain/terrain_tiles.tres", ts)
	# terrain_tiles.tres is created inside res://terrain folder
	
			
	
	