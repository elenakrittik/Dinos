class_name Pickable extends Area2D

enum PickableType {
	Unknown,
}

@export var type: PickableType

static func from_entity(entity: Dictionary, child: Node) -> Pickable:
	var pickable = load("res://game/pickable/Pickable.tscn").instantiate()

	pickable.position = entity.position
	pickable.get_child(0).shape.size = entity.size
	pickable.add_child(child)
	pickable.type = PickableType.Unknown

	return pickable
