extends Area2D

# default script that all bullets will inherit

# what attributes does a bullet need
export (int) var speed
export (int) var damage
export (float) var lifetime # timer

var velocity = Vector2()

# when the bullet spawns we need to place it at the muzzle
# and pointed in the right direction
# and velocity needs to travel in that direction
# we need to pass all this info to the bullet when it spawns
# to do so, lets make a start function and pass position and direction

func start(_position, _direction):
	position = _position # set position of our bullet to _position
	rotation = _direction.angle() # set rotation to angle in the direction
	$Lifetime.wait_time = lifetime
	
	velocity = _direction * speed

func _process(delta):
	# update the position
	position += velocity * delta
	
# we also need signals, when a body enters and when timer (lifetime) timesout

func explosion():
	queue_free() # for now

func _on_Bullet_body_entered(body):
	# if the bullet hits a wall it should just explore
	# if it hits and enemy tank it should deal damage
	explode()
	if body.has_method('take_damage'): #if the body it hits can take damage, then call
		take_damage(damage) # pass the damage amount


func _on_Lifetime_timeout():
# on timeout we want to remove the bullet and do an explosion
	explosion()