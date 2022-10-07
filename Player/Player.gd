extends KinematicBody2D
class_name Player

# Check out this repo's Readme for tips on how to tweak the movement!
# Sprites and tile sheet were made by Buch: https://opengameart.org/users/buch

### Node access variables
# visual nodes
onready var sprite : Sprite = $Sprite
onready var animator : AnimationTree = $AnimationTree

### World Constants
const UP_DIRECTION : Vector2 = Vector2.UP # needed for move_and_slide function

### Physics Constants
# These are physics constants that affect how characters move
# They are exported so you can easily tweak them on the editor
## Horizontal speed variables
export(float) var MAX_SPEED = 120.0 # maximum speed at which the player character can move
export(float) var ACCELERATION = 10.0 # rate at which player character's speed rises
export(float) var FRICTION = 30.0 # rate at which player character's speed lowers
## Vertical speed variables
export(float) var GRAVITY = 4.0 # force that pulls player character down, also known as gravity
export(float) var MAX_FALL_SPEED = 200.0 # maximum speed at which player character can fall
export(float) var JUMP_FORCE = 140.0 # force with which the player jumps, has to counter gravity for a little bit. The higher this is, the higher and floatier the jump will be
export(float) var MIN_AIR_DISTANCE = 60.0 # minimum distance a jump will go through before it can be stopped by letting go of the jump button

### Physics Variables 
# These are physics variables that are changed during runtime, not manually set
var velocity : Vector2 = Vector2.ZERO # velocity at which player character is moving

# State Machine Variables
enum {IDLE, RUN, RISE, FALL} # states of the state machine
var state = IDLE # current state at which player character is at
var double_jumped : bool = false # flag for if the player has double jumped or not

### Functions that run every frame
# Physics process, main loop separated into subroutines
func _physics_process(_delta):
	var horizontal_input : float = get_horizontal_input() 
	state = get_current_state(horizontal_input)
	vertical_movement()
	horizontal_movement(horizontal_input)
	animation(horizontal_input)

### State machine routines
# This function uses the Input singleton to get what direction the player is pressing
# Returns -1 if player is pressing the left key, +1 if player is pressing the right key, 0 if player is pressing neither or both
func get_horizontal_input() -> float:
	return Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

# This function returns the current state of the state machine the player is in
func get_current_state(horizontal_input):
	if is_on_floor(): # player character is touching the ground
		if horizontal_input != 0: # check if player character is moving
			return RUN # running state
		return IDLE # idle state (not moving)
	else: # if player character is not touching the ground
		if velocity.y < 10: # if the player is rising, or just started falling
			return RISE # rising state
		else:
			return FALL # falling state

# This function will apply gravity and other forces (like jump force) to the player character
func vertical_movement():
	velocity.y += GRAVITY # gravity is added to the current velocity
	velocity.y = min(velocity.y, MAX_FALL_SPEED) # velocity's Y value cannot go past max fall speed
	if is_on_floor(): # if player character is on the floor, reset double jump and check for jump input
		double_jumped = false
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = -JUMP_FORCE # when the jump button is pressed, jump force is subtracted from velocity's Y value
	else: # player is not on floor, therefore falling or rising
		if Input.is_action_just_released("ui_up") and velocity.y < -MIN_AIR_DISTANCE: # if the jump button is released and player has already raised the minimum distance
			velocity.y = -MIN_AIR_DISTANCE # cut velocity's Y value down so the player stops when letting go of the jump button
		if not double_jumped: # if player is not on the ground and has not yet double jumped, check for double jump input
			if Input.is_action_just_pressed("ui_up"):
				double_jumped = true # double_jumped flag is set to true, so player cannot double jump again
				velocity.y = -JUMP_FORCE # jump again

# This function is responsible for moving the player character through space according to the input
func horizontal_movement(horizontal_input):
	if horizontal_input == 0: # when player character is not moving, apply friction
		velocity.x = move_toward(velocity.x, 0, FRICTION)
	else: # when player character is moving, apply acceleration
		velocity.x = move_toward(velocity.x, horizontal_input * MAX_SPEED, ACCELERATION)
	velocity = move_and_slide(velocity, UP_DIRECTION) # function that actually moves the player based on velocity. 
	# obs: up direction is needed for "is_on_floor()" and "is_on_wall()" to work

# This function will display the correct animation for the player character based on its state and horizontal input
func animation(horizontal_input):
	match state: # animations are chosen based on the state, they are set by the animation tree node
		IDLE: 
			animator.travel("idle")
		RUN:
			if horizontal_input > 0: # when facing left, the player character's sprite must be flipped
				flip_character(false)
			else:
				flip_character(true)
			animator.travel("run")
		RISE:
			if horizontal_input > 0: # when facing left, the player character's sprite must be flipped
				flip_character(false)
			elif horizontal_input < 0:
				flip_character(true)
			animator.travel("rise")
		FALL:
			if horizontal_input > 0: # when facing left, the player character's sprite must be flipped
				flip_character(false)
			elif horizontal_input < 0:
				flip_character(true)
			animator.travel("fall")

# This function flips the sprite backwards to face the left or right when called
# When called with true, the character faces left, when called with false, the character faces right
func flip_character(flip : bool):
	sprite.flip_h = flip
