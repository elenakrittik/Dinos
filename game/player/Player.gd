class_name Player extends CharacterBody2D

# Constants
@export var x_speed: int = 100
@export var y_speed: int = -100
@export var y_gravity: int = 400
@export var x_blink_distance: int = 300
@export_range(0.0, 1.0) var x_friction: float = 0.5
@export_range(0.0 , 1.0) var x_acceleration: float = 0.2
@export_range(0.0, 1.0) var y_friction: float = 0.5
@export_range(0.0 , 1.0) var y_acceleration: float = 0.2

# Stateful variables
@export var mov_fall_first_click: bool = false
@export var levitating: bool = false
@export var on_floor: bool = false
@export var facing_direction: Vector2i = Vector2i.RIGHT
@export var health: int = 100
@export var blinked_from: Vector2

# These components need to be calculated and kept track of
# sepately.
@export var y_velocity_component: float
@export var y_grav_component: float

# Superclass re-exports
@export var S_velocity: Vector2:
	get: return self.velocity

func _ready() -> void:
	$Camera2D.make_current()

func _process(_delta) -> void:
	_process_animations()
	_process_ui()
	_process_effects()

func _physics_process(delta) -> void:
	self.on_floor = is_on_floor()

	var x_axis = Input.get_axis("movement_left", "movement_right")

	if x_axis != 0:
		self.velocity.x = lerp(self.velocity.x, x_axis * x_speed, x_acceleration)

		if x_axis > 0:
			self.facing_direction = Vector2i.RIGHT
		else: # x_axis < 0
			self.facing_direction = Vector2i.LEFT
	else:
		self.velocity.x = lerp(self.velocity.x, 0.0, x_friction)

	var blink: bool = Input.is_action_just_pressed("movement_blink") and x_axis != 0

	if blink:
		self.velocity.x += x_axis * x_blink_distance
		self.blinked_from = self.global_position

	var y_axis = Input.get_axis("movement_fall", "movement_rise")

	if not self.levitating and not self.on_floor:
		self.y_grav_component += self.y_gravity * delta
	else:
		self.y_grav_component = 0

	if y_axis != 0:
		self.y_velocity_component = lerp(self.velocity.y, y_axis * y_speed, y_acceleration)

		if y_axis > 0 and self.on_floor:
			self.levitating = true
		elif Input.is_action_just_pressed("movement_fall") and not self.on_floor:
			if self.mov_fall_first_click:
				self.mov_fall_first_click = false
				self.levitating = false
			else:
				self.mov_fall_first_click = true
				self.get_tree().create_timer(0.2).timeout.connect(func(): self.mov_fall_first_click = false)
	else:
		self.y_velocity_component = lerp(self.velocity.y, 0.0, y_friction)

	self.velocity.y = self.y_velocity_component + self.y_grav_component

	self.move_and_slide()

func _process_animations() -> void:
	var x_axis = Input.get_axis("movement_left", "movement_right")

	# Flip sprite according to current facing direction
	if x_axis > 0:
		$AnimatedSprite2D.flip_h = false
	elif x_axis < 0:
		$AnimatedSprite2D.flip_h = true

	if self.levitating:
		$AnimatedSprite2D.play("levitation")
		return

	if x_axis != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

func _process_ui() -> void:
	$UI/Health.value = self.health

func _on_pickable_area_entered(area: Area2D):
	if area.name == "Pickable":
		area.queue_free() # TODO

func _process_effects() -> void:
	var x_axis = Input.get_axis("movement_left", "movement_right")

	if Input.is_action_just_pressed("movement_blink") and x_axis != 0:
		var blink_particles = preload("res://data/effects/BlinkParticles.tscn").instantiate()

		blink_particles.top_level = true
		blink_particles.global_position = self.blinked_from
		blink_particles.emitting = true

		blink_particles.finished.connect(func(): self.remove_child(blink_particles))

		self.add_child(blink_particles)
