extends CharacterBody2D

@onready var animatedSprite = $AnimatedSprite2D
@onready var splatter = $CPUParticles2D

const SPEED = 500.0
const JUMP_VELOCITY = -350.0
const WALL_SLIDING_SPEED = 1200
const ACCELERATION = 900.0  # Controls how quickly we reach max speed
const DECELERATION = 600.0  # Controls how quickly we stop

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumpsMade = 0
var doWallJump = false

var previous_velocity = Vector2.ZERO
var is_jumping = false 

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Apply gravity or wall sliding effect
	if is_on_wall_only() and direction != 0: 
		velocity.y = WALL_SLIDING_SPEED * delta
	elif !is_on_floor(): 
		velocity.y += gravity * delta
	else: 
		jumpsMade = 0
	
	# Handle jumping
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_wall_only():
			_wall_jump(direction)
		elif is_on_floor() || jumpsMade < 2:
			_jump()
	
	# Smooth acceleration and deceleration
	if direction != 0 and !doWallJump:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	elif !doWallJump:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	
	# Set animation and adjust speed based on movement
	_setAnimation()
	
	move_and_slide()
	
	# Check for impacts
	_check_for_impacts()
	
	# Update previous velocity
	previous_velocity = velocity

func _wall_jump(direction):
	velocity.y = JUMP_VELOCITY
	velocity.x = -direction * SPEED/2
	doWallJump = true
	$WallJumpTimer.start()

func _jump():
	velocity.y = JUMP_VELOCITY
	jumpsMade += 1

func _setAnimation():
	# Flip sprite based on direction
	animatedSprite.flip_h = velocity.x < 0
	
	# Set animation based on character state
	if is_on_wall():
		is_jumping = false
		animatedSprite.play("wall slide")
	elif !is_on_floor():
		if !is_jumping:
			is_jumping = true
			animatedSprite.play("jump")
	elif abs(velocity.x) > 10:  # Small threshold to avoid jitter
		is_jumping = false
		animatedSprite.play("run")
		# Adjust animation speed based on horizontal velocity
		animatedSprite.speed_scale = 0.5 + (abs(velocity.x) / SPEED) * 1.5
	else:
		is_jumping = false
		animatedSprite.play("idle")
		animatedSprite.speed_scale = 1.0  # Default speed for idle

func _on_wall_jump_timer_timeout():
	doWallJump = false
	
func _check_for_impacts():
	var impactThreshold = 200
	if is_on_floor() and previous_velocity.y > impactThreshold:
		_emit_splatter()
	elif is_on_wall() and abs(previous_velocity.x) > impactThreshold:
		_emit_splatter()

func _emit_splatter():
	var PARTICLE_SPEED_MULTIPLIER = 0.5
	splatter.emitting = false
	
	var impact_velocity = velocity.normalized()
	splatter.direction = -impact_velocity
	splatter.initial_velocity_min = velocity.length() * PARTICLE_SPEED_MULTIPLIER * 0.8
	splatter.initial_velocity_max = velocity.length() * PARTICLE_SPEED_MULTIPLIER * 1.2
		
	splatter.emitting = true
