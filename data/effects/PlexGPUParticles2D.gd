@tool

@icon("res://assets/icons/PlexGPUParticles2D.png")
class_name PlexGPUParticles2D extends Node2D

signal finished

@export var in_progress: bool = false
@export var emitting: bool = false
@export var one_shot: bool = false
@export var amount: int = 0:
	set(value):
		amount = value

		if Engine.is_editor_hint():
			update_configuration_warnings()
			_update_particles()

@export_file("*.tscn") var particles: String:
	set(value):
		particles = value

		if Engine.is_editor_hint():
			update_configuration_warnings()

@export var reset: bool = false:
	set(_value):
		if Engine.is_editor_hint():
			_update_particles()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if self.particles == null or self.particles.is_empty():
		warnings.append("Particles must be set.")
	else:
		if not load(self.particles).instantiate() is GPUParticles2D:
			warnings.append("Particles must inherit from GPUParticles2D")

	if self.amount <= 0:
		warnings.append("Amount can't be 0 or less.")

	return warnings

func _ready():
	if Engine.is_editor_hint():
		update_configuration_warnings()
		_update_particles()

func _update_particles() -> void:
	if self.get_tree() == null:
		# @tool scripts are for some reason initialised before _enter_tree
		return

	if self.particles == null or self.particles.is_empty():
		push_error("particles are empty")
		return

	# Clean-up any existing children
	for p in self.get_children():
		p.get_parent().remove_child(p)

	var p_scene = load(self.particles);

	for num in range(self.amount):
		var p: GPUParticles2D = p_scene.instantiate()

		p.one_shot = self.one_shot # to be sure
		p.name = p.name + str(num)

		self.add_child(p)

		# Persist in editor
		p.set_owner(self.get_tree().edited_scene_root)

# Runtime code
func _process(_delta):
	if self.in_progress or Engine.is_editor_hint():
		return

	for child in self.get_children():
		(child as GPUParticles2D).emitting = self.emitting

	self.in_progress = true

	var instance: GPUParticles2D = self.get_child(0) # get any particles instance

	# https://github.com/godotengine/godot-proposals/issues/649#issuecomment-995761510
	# above formula + 0.2s since we're running on GPU
	var time = (instance.lifetime * (1 - instance.explosiveness)) + 0.2
	self.get_tree().create_timer(time).timeout.connect(func():
		if self.one_shot:
			self.emitting = false
		self.in_progress = false
		self.finished.emit()
	)
