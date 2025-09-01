extends CharacterBody2D

const FLAP_STRENGTH = -300.0
const GRAVITY = 800.0
const MAX_FALL_SPEED = 400.0
const ROTATION_SPEED = 0.0

var is_alive = true
var has_started = false

@onready var game_manager = get_parent()
@onready var jump_sound = $JumpSound

func _ready():
	position = Vector2(100, get_viewport().size.y / 2)
	if jump_sound:
		jump_sound.stream = load("res://jump.mp3")

func _physics_process(delta):
	if not is_alive:
		return
	velocity.y += GRAVITY * delta
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED
	if Input.is_action_just_pressed("ui_accept"):
		if not has_started:
			has_started = true
			game_manager.start_game()
		flap()
	move_and_slide()
	var screen_height = get_viewport().size.y
	if position.y > screen_height + 50 or position.y < -50:
		die()

func flap():
	if is_alive:
		velocity.y = FLAP_STRENGTH
		if jump_sound:
			jump_sound.play()

func die():
	if is_alive:
		is_alive = false
		game_manager.game_over()

func reset():
	is_alive = true
	has_started = false
	position = Vector2(100, get_viewport().size.y / 2)
	velocity = Vector2.ZERO
	rotation_degrees = 0
