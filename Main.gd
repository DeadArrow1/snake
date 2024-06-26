extends Node

@export var snake_scene : PackedScene

@export var snake_head : PackedScene

var score : int
var game_started : bool = false

var cells : int = 20
var cell_size : int = 50

var food_pos : Vector2
var regen_food: bool = true

var old_data : Array
var snake_data : Array
var snake : Array

var start_pos = Vector2(9,9)

var up = Vector2(0,-1)

var down = Vector2(0,1)
var left = Vector2(-1,0)
var right = Vector2(1,0)

var move_direction : Vector2

var can_move: bool

func _ready():
	initialize()
	
func initialize():
	get_tree().paused = false
	get_tree().call_group("segments","queue_free")
	get_tree().call_group("head","queue_free")
	$GameOverMenu.hide()
	score=0
	move_direction = up
	can_move=true
	create_snake()
	generate_berry()
	
func create_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	
	add_head(start_pos + Vector2(0,0))
	
	for i in range(4):
		add_segment(start_pos + Vector2(0,i+1))
		
func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0,cell_size)
	
	
	add_child(SnakeSegment)
	snake.append(SnakeSegment)
	
func add_head(pos):
	snake_data.append(pos)
	var SnakeHead = snake_head.instantiate()
	SnakeHead.position = (pos * cell_size) + Vector2(0,cell_size)
	add_child(SnakeHead)
	snake.append(SnakeHead)
	
	
func _process(delta):
	process_user_input()
	
func process_user_input():
	if can_move:
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction=down
			can_move = false
			if not game_started:
				start_game()
				
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction=up
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction=left
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction=right
			can_move = false
			if not game_started:
				start_game()
func start_game():
	game_started = true
	$MoveTimer.start()


func _on_move_timer_timeout():
	update()
	
func update():
	can_move = true
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range (len(snake_data)):
		if i>0:
			snake_data[i]= old_data[i-1]
		snake[i].position = (snake_data[i] * cell_size)+Vector2(0,cell_size)
	check_snake_border_collision()
	check_snake_body_collision()
	check_snake_berry_collision()
	
	
	
func check_snake_berry_collision():
	if snake_data[0]==food_pos:
		score+=1
		add_segment(old_data[-1])
		generate_berry()
	
func check_snake_border_collision():
	if(snake_data[0].x < 0 or snake_data[0].x > cells - 1 or snake_data[0].y <0-1 or snake_data[0].y > cells-2):
		end_game()
		
func check_snake_body_collision():
	for i in range(1, len(snake_data)):
		if(snake_data[0] == snake_data[i]):
			end_game()
			
func generate_berry():
	while regen_food:
		regen_food= false
		food_pos = Vector2(randi_range(1,cells-1),randi_range(1,cells-2))
		for i in snake_data:
			if food_pos ==i:
				regen_food= true
	$Food.position = (food_pos * cell_size)+Vector2(0,cell_size)
	regen_food=true
func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	$GameOverMenu.get_node("ResultLabel").text = "GAME OVER: SCORE: "+ str(score)
	game_started=false
	get_tree().paused=true
	


func _on_game_over_menu_restart():
	initialize()
