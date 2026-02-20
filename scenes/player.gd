extends Area2D
signal hit # Detects when player is hit by enemy

@export var speed = 200 # Player speed
var screen_size # Size of game window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		
	if velocity.length() > 0:
		velocity = velocity * speed
		$AnimatedSprite2D.play()
	else: 
		$AnimatedSprite2D.stop()
		
	position = position.clamp(screen_size * 0.1, screen_size * 0.9)
		
	position += velocity * delta
