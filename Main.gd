extends Node2D

var score = 0
var is_game_active = false
var high_score = 0

@onready var player = $Player
@onready var score_label = $UI/ScoreLabel
@onready var high_score_label = $UI/HighScoreLabel
@onready var camera = $Camera2D
@onready var music = $Music

var game_over_panel
var final_score_label  
var restart_button
var start_label

func _ready():
	#DisplayServer.window_set_size(Vector2i(700, 700))
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
	create_boundaries()
	game_over_panel = get_node_or_null("UI/GameOverPanel")
	final_score_label = get_node_or_null("UI/GameOverPanel/FinalScoreLabel")
	restart_button = get_node_or_null("UI/GameOverPanel/RestartButton")
	start_label = get_node_or_null("UI/StartLabel")
	if game_over_panel:
		game_over_panel.visible = false
	if start_label:
		start_label.text = "Press Space to Start!"
	if restart_button:
		restart_button.pressed.connect(restart_game)
	load_high_score()
	update_labels()
	if music:
		music.stream = load("res://music.mp3")
		music.stream.loop = true
		music.play()

func create_boundaries():
	var thickness = 10
	var size = Vector2(700, 700)
	var boundaries = [
		[Vector2(size.x / 2, -thickness / 2), Vector2(size.x, thickness)],
		[Vector2(size.x / 2, size.y + thickness / 2), Vector2(size.x, thickness)],
		[Vector2(-thickness / 2, size.y / 2), Vector2(thickness, size.y)],
		[Vector2(size.x + thickness / 2, size.y / 2), Vector2(thickness, size.y)]
	]
	for boundary in boundaries:
		var pos = boundary[0]
		var dim = boundary[1]
		var area = Area2D.new()
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.extents = dim / 2
		shape.shape = rect
		area.position = pos
		area.add_child(shape)
		area.connect("body_entered", Callable(self, "_on_boundary_touched"))
		add_child(area)

func _on_boundary_touched(body):
	if body == player:
		game_over()

func update_labels():
	if score_label:
		score_label.text = "Current Score: " + str(score)
	if high_score_label:
		high_score_label.text = "High Score: " + str(high_score)

func start_game():
	is_game_active = true
	if start_label:
		start_label.visible = false
	score = 0
	update_labels()

func game_over():
	is_game_active = false
	if score > high_score:
		high_score = score
		save_high_score()
	if final_score_label:
		final_score_label.text = "Score: " + str(score) + "\nHigh Score: " + str(high_score)
	if game_over_panel:
		game_over_panel.visible = true
	update_labels()

func add_score():
	if is_game_active:
		score += 1
		update_labels()

func restart_game():
	score = 0
	is_game_active = false
	if game_over_panel:
		game_over_panel.visible = false
	if start_label:
		start_label.visible = true
		start_label.text = "Press Space to Start!"
	player.reset()
	update_labels()

func save_high_score():
	var file = FileAccess.open("user://high_score.txt", FileAccess.WRITE)
	if file:
		file.store_string(str(high_score))
		file.close()

func load_high_score():
	if FileAccess.file_exists("user://high_score.txt"):
		var file = FileAccess.open("user://high_score.txt", FileAccess.READ)
		if file:
			var text = file.get_as_text().strip_edges()
			if text.is_valid_int():
				high_score = int(text)
			file.close()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if not is_game_active:
			start_game()
		else:
			add_score()
