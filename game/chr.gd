extends Node2D

const RADIUS: float = 50.0

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_RIGHT):
		position += Vector2(10, 0)
	if Input.is_key_pressed(KEY_LEFT):
		position += Vector2(-10, 0)
	if Input.is_key_pressed(KEY_UP):
		position += Vector2(0, -10)
	if Input.is_key_pressed(KEY_DOWN):
		position += Vector2(0, 10)


func _on_draw():
	draw_circle(Vector2(100, 1), 100, Color.BLUE_VIOLET)
