extends KinematicBody2D
class_name Player

# Check out this repo's Readme for tips on how to tweak the movement!
# Sprites and tile sheet were made by Buch: https://opengameart.org/users/buch

### Node access variables
# visual nodes
onready var sprite : Sprite = $Sprite
onready var animator : AnimationTree = $AnimationTree
onready var damage_animator : AnimationPlayer = $DamageAnimator
# raycast nodes
onready var left_wall_raycasts : Node2D = $WallRaycasts/LeftRays
onready var right_wall_raycasts : Node2D = $WallRaycasts/RightRays
# timers
onready var jump_buffer_timer : Timer = $Timers/JumpBufferTimer
onready var coyote_jump_timer : Timer = $Timers/CoyoteJumpTimer
onready var invulnerability_timer : Timer = $Timers/InvulnerabilityTimer
# hud elements
onready var health_bar = $HUD/HealthBar
onready var death_screen = $HUD/DeathOverlay

### World Constants
const UP_DIRECTION : Vector2 = Vector2.UP # needed for move_and_slide function

### Physics Constants
# These are physics constants that affect how characters move
# They are exported so you can easily tweak them on the editor
## Horizontal speed variables
export(float) var MAX_SPEED = 120.0 # maximum speed at which the player character can move
export(float) var ACCELERATION = 600.0 # rate at which player character's speed rises
export(float) var FRICTION = 1200.0 # rate at which player character's speed lowers
## Vertical speed variables
export(float) var GRAVITY = 240.0 # force that pulls player character down, also known as gravity
export(float) var MAX_FALL_SPEED = 200.0 # maximum speed at which player character can fall
export(float) var JUMP_FORCE = 140.0 # force with which the player jumps, has to counter gravity for a little bit. The higher this is, the higher and floatier the jump will be
export(float) var MIN_AIR_DISTANCE = 60.0 # minimum distance a jump will go through before it can be stopped by letting go of the jump button
## Other speed variables
export(float) var MAX_WALL_SPEED = 48.0 # maximum speed when wall sliding
export(float) var WALL_JUMP_DISTANCE = 128.0 # minimum walljump distance
export(float) var KNOCKBACK_H_FORCE = 136.0 # horizontal force at which the player character is knocked when taking damage
export(float) var KNOCKBACK_V_FORCE = 56.0 # vertical force at which the player character is knocked when taking damage

### Ability variables
export var can_double_jump : bool = true # allows player character to double jump
export var can_wall_jump : bool = true # allows player to wall slide and wall jump

### Physics Variables 
# These are physics variables that are changed during runtime, not manually set
var velocity : Vector2 = Vector2.ZERO # velocity at which player character is moving

### State Machine Variables
enum {IDLE, RUN, RISE, FALL, WALL_SLIDE, DEAD} # states of the state machine
var state = IDLE # current state at which player character is at
var double_jumped : bool = false # flag for if the player has double jumped or not
var buffered_jump : bool = false # flag for it the jump button was pressed right before hitting the ground
var can_coyote_jump : bool = false # flag for coyote jump (when running off ledge)

### Health variables
export (float) var max_health = 100.0
onready var health = max_health setget set_health
export (float) var invulnerable_time = 1.4

### Setup function that runs at the start
func _ready():
	for raycast in left_wall_raycasts.get_children():
		raycast.add_exception(self)
	for raycast in right_wall_raycasts.get_children():
		raycast.add_exception(self)
	invulnerability_timer.wait_time = invulnerable_time

### Functions that run every frame
# Physics process, main loop separated into subroutines
func _physics_process(delta):
	var horizontal_input : float = get_horizontal_input() 
	var wall_direction : int = get_wall_direction()
	var was_on_floor : bool = is_on_floor()
	state = get_current_state(horizontal_input, wall_direction)
	vertical_movement(delta)
	horizontal_movement(horizontal_input, delta)
	wall_jump_override(wall_direction)
	velocity = move_and_slide(velocity, UP_DIRECTION) # function that actually moves the player based on velocity
	# !!! up direction is needed for "is_on_floor()" and "is_on_wall()" to work
	animation(horizontal_input)
	extra_movement(was_on_floor)

### State machine routines
# This function uses the Input singleton to get what direction the player is pressing
# Returns -1 if player is pressing the left key, +1 if player is pressing the right key, 0 if player is pressing neither or both
func get_horizontal_input() -> float:
	return Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

# This function returns the current state of the state machine the player is in
func get_current_state(horizontal_input, wall_direction):
	if is_on_floor(): # player character is touching the ground
		if horizontal_input != 0:
			return RUN 
		return IDLE 
	else: 
		if velocity.y < 10: # if the player is rising, or just started falling
			return RISE 
		else:
			if can_wall_jump:
				if horizontal_input != 0 and horizontal_input == wall_direction:
					return WALL_SLIDE
			return FALL 

# This function will apply gravity and other forces (like jump force) to the player character
func vertical_movement(delta):
	velocity.y += GRAVITY * delta
	
	if state == WALL_SLIDE:
		velocity.y = min(velocity.y, MAX_WALL_SPEED)
	else:
		velocity.y = min(velocity.y, MAX_FALL_SPEED) 
	
	if is_on_floor() or can_coyote_jump:
		double_jumped = false
		if Input.is_action_just_pressed("ui_up") or buffered_jump:
			velocity.y = -JUMP_FORCE 
			buffered_jump = false
			can_coyote_jump = false
	else: 
		if not Input.is_action_pressed("ui_up") and velocity.y < -MIN_AIR_DISTANCE: 
			velocity.y = -MIN_AIR_DISTANCE # cut velocity's Y value down so the player stops when letting go of the jump button
		if Input.is_action_just_pressed("ui_up"):
			if not double_jumped and can_double_jump:
				double_jumped = true 
				velocity.y = -JUMP_FORCE
			else:
				buffered_jump = true
				jump_buffer_timer.start()

# This function is responsible for moving the player character through space according to the input
# When there is no input, apply friction, when there is, apply acceleration
func horizontal_movement(horizontal_input, delta):
	if horizontal_input == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, horizontal_input * MAX_SPEED, ACCELERATION * delta)

# This function overrides the velocity value in order to perform the wall jump consistently
func wall_jump_override(wall_direction):
	if not can_wall_jump or wall_direction == 0 or is_on_floor():
		return
	double_jumped = false
	if not Input.is_action_just_pressed("ui_up"):
		return
	velocity.x = WALL_JUMP_DISTANCE * -wall_direction
	velocity.y = -JUMP_FORCE

# This function will display the correct animation for the player character based on its state and horizontal input
func animation(horizontal_input):
	match state: # animations are chosen based on the state, they are set by the animation tree node
		IDLE: 
			animator.travel("idle")
		RUN:
			if horizontal_input > 0: 
				flip_character(false)
			else:
				flip_character(true)
			animator.travel("run")
		RISE:
			if horizontal_input > 0: 
				flip_character(false)
			elif horizontal_input < 0:
				flip_character(true)
			animator.travel("rise")
		FALL:
			if horizontal_input > 0: 
				flip_character(false)
			elif horizontal_input < 0:
				flip_character(true)
			animator.travel("fall")
		WALL_SLIDE:
			if horizontal_input > 0:
				flip_character(true) # here the values are opposite
			elif horizontal_input < 0:
				flip_character(false)
			animator.travel("fall")
		DEAD:
			damage_animator.play("kill")

func extra_movement(was_on_floor):
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		can_coyote_jump = true
		coyote_jump_timer.start()

# This function flips the sprite backwards to face the left or right when called
# When called with true, the character faces left, when called with false, the character faces right
func flip_character(flip : bool):
	sprite.flip_h = flip

# This function returns the direction of a wall next to the player character
# If left wall, it returns -1, if right wall, it returns +1, if neither or both, it returns 0
func get_wall_direction():
	var on_left_wall = int(check_wall(left_wall_raycasts))
	var on_right_wall = int(check_wall(right_wall_raycasts))
	
	return -on_left_wall + on_right_wall

# This function checks if the raycasts are colliding for wall jumping
# will not work with slopes
func check_wall(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false


### Damage functions
func damage(value):
	if state == DEAD: return
	if invulnerability_timer.is_stopped():
		knockback()
		invulnerability_timer.start()
		damage_animator.play("damage")
		damage_animator.queue("blink")
		set_health(health - value)

func knockback():
	var facing_direction = 1
	if sprite.flip_h: # facing left
		facing_direction = -1
	velocity.x = KNOCKBACK_H_FORCE * -facing_direction
	velocity.y = -KNOCKBACK_V_FORCE 

func kill():
	invulnerability_timer.stop()
	damage_animator.play("disappear")
	state = DEAD
	set_physics_process(false)
	death_screen.display_death_panel()

### Setters
func set_health(new_health):
	var previous_health = health
	health = clamp(new_health, 0, max_health)
	if health != previous_health:
		health_bar.update_health(health)
		if health <= 0:
			kill()

### Signal functions
func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	can_coyote_jump = false

func _on_InvulnerabilityTimer_timeout():
	damage_animator.play("normalize")
