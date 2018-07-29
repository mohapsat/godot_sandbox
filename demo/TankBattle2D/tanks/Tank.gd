extends KinematicBody2D

# include all common tank actions

signal health_changed
signal dead
signal shoot # to pass shoot signal to main /map scene

export (PackedScene) var Bullet
export (int) var speed
export (float) var rotation_speed
export (float) var gun_cooldown
export (int) var health

var velocity = Vector2() # velocity vector for movement
var can_shoot = true # for cooldown, applies for both player and enemy tanks
var alive = true # to use in explosion anim etc

func _ready():
	$GunTimer.wait_time = gun_cooldown # set GunTimer wait time to gun_cooldown var

func control(delta):
	pass
# custom function, will call each frame
# we will input controls for the tank
# for player tank, keyboard control
# for enemy tanks, ai control

func shoot():
	if can_shoot: # if can_shoot is true
		can_shoot = false # set it to false
		$GunTimer.start() # start guntimer, when it expires, can shoot is set to false
		
		# temp direction var, a unit vector rotated in dir of turrets position
		var dir = Vector2(1,0).rotated($Turret.global_rotation)
		# emit signal shoot, add bullet and two peices of info it needs
		emit_signal('shoot', Bullet, $Turret/Muzzle.global_position, dir)
		
		
func _physics_process(delta):
	if not alive:
		return # do nothing for now
	control(delta)
	move_and_slide(velocity)



