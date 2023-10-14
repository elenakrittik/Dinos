@tool

# Entity Post-Import Template for LDTK-Importer.

func post_import(entity_layer: LDTKEntityLayer) -> LDTKEntityLayer:
	var definition: Dictionary = entity_layer.definition
	var entities: Array[Dictionary] = entity_layer.entities
	for entity in entities:
		if entity.name == "Start":
			entity_layer.get_parent().player_start_pos = entity.position

	return entity_layer
