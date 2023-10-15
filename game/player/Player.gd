class_name Player extends CharacterBody2D

@export var facing_direction: Vector2i = Vector2i.RIGHT
@export var gravity: int = 500
@export var speed: int = 100
@export var jump_speed: int = -150
@export_range(0.0, 1.0) var friction = 0.5
@export_range(0.0 , 1.0) var acceleration = 0.20

func _ready():
	$Camera2D.make_current()

func _process(_delta):
	_process_animations()

func _physics_process(delta):
	var x_axis = Input.get_axis("movement_left", "movement_right")

	if x_axis != 0:
		self.velocity.x = lerp(self.velocity.x, x_axis * speed, acceleration)
	else:
		self.velocity.x = lerp(self.velocity.x, 0.0, friction)

	self.velocity.y += gravity * delta
	self.move_and_slide()

	if Input.is_action_just_pressed("movement_jump") and is_on_floor():
		self.velocity.y = jump_speed

func _process_animations():
	var x_axis = Input.get_axis("movement_left", "movement_right")

	if x_axis != 0:
		if x_axis > 0:
			self.facing_direction = Vector2i.RIGHT
		else:
			self.facing_direction = Vector2i.LEFT

	if Input.is_action_just_pressed("movement_jump") and is_on_floor():
		if self.facing_direction == Vector2i.RIGHT:
			$AnimatedSprite2D.play("jump_right")
		else:
			$AnimatedSprite2D.play("jump_left")

		return

	if $AnimatedSprite2D.animation.begins_with("jump_") and $AnimatedSprite2D.is_playing():
		var frame = $AnimatedSprite2D.frame
		var frame_progress = $AnimatedSprite2D.frame_progress

		if self.facing_direction == Vector2i.RIGHT:
			$AnimatedSprite2D.play("jump_right")
		else:
			$AnimatedSprite2D.play("jump_left")

		$AnimatedSprite2D.frame = frame
		$AnimatedSprite2D.frame_progress = frame_progress

		return

	if x_axis != 0:
		if x_axis > 0:
			$AnimatedSprite2D.play("run_right")
		else:
			$AnimatedSprite2D.play("run_left")
	else:
		$AnimatedSprite2D.pause()
		$AnimatedSprite2D.frame = 0
