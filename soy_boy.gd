extends CharacterBody2D

@onready var animatedSprite = $AnimatedSprite2D
@onready var splatter = $CPUParticles2D

const SPEED = 300.0
const JUMP_VELOCITY = -350.0
const WALL_SLIDING_SPEED = 1200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumpsMade = 0
var doWallJump = false

var previous_velocity = Vector2.ZERO  # To track velocity between frames

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if is_on_wall_only() && (
		Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right")): 
			velocity.y = WALL_SLIDING_SPEED * delta
	elif not is_on_floor(): 
		velocity.y += gravity * delta
	else: 
		jumpsMade = 0
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_wall_only():
			velocity.y = JUMP_VELOCITY
			velocity.x = -direction * SPEED
			doWallJump = true
			$WallJumpTimer.start()
		elif is_on_floor() || jumpsMade < 2:
			velocity.y = JUMP_VELOCITY			
			jumpsMade += 1	
	
	if direction && not doWallJump: velocity.x = direction * SPEED
	elif not doWallJump: velocity.x = move_toward(velocity.x, 0, SPEED)	
	
	_setAnimation(direction)	
	
	move_and_slide()
	
	 # Check for impacts
	_check_for_impacts()
	
	# Update previous velocity
	previous_velocity = velocity
	
func _setAnimation(direction):
	if velocity.x > 0: animatedSprite.flip_h = false
	elif velocity.x < 0: animatedSprite.flip_h = true
	elif velocity.x == 0: 
		if direction > 0: animatedSprite.flip_h = false
		elif direction < 0: animatedSprite.flip_h = true	
		
	
	if is_on_wall_only() && (velocity.x != 0 || direction != 0):
		animatedSprite.flip_h = !animatedSprite.flip_h

	#if !is_on_floor(): animatedSprite.play("jump")
	#elif direction != 0: animatedSprite.play("run")
	#else: animatedSprite.play("idle")

func _on_wall_jump_timer_timeout():
	doWallJump = false
	
func _check_for_impacts():
	var impactThreshold = 200
	# Check if we just landed
	if is_on_floor() and previous_velocity.y > impactThreshold:
		_emit_splatter()
	# Check if we just hit a wall
	elif is_on_wall() and abs(previous_velocity.x) > impactThreshold:
		_emit_splatter()

func _emit_splatter():
	var PARTICLE_SPEED_MULTIPLIER = 0.5
	
	# Stop any existing emission
	splatter.emitting = false
	
	# Calculate the emission direction based on Soyboy's velocity
	var impact_velocity = velocity.normalized()
	
	# Splatter is shot to the opposite direction
	splatter.direction = -impact_velocity
	splatter.initial_velocity_min = velocity.length() * PARTICLE_SPEED_MULTIPLIER * 0.8
	splatter.initial_velocity_max = velocity.length() * PARTICLE_SPEED_MULTIPLIER * 1.2
		# Adjust PARTICLE_SPEED_MULTIPLIER as needed to scale particle speed
		
	# Start emitting
	splatter.emitting = true
