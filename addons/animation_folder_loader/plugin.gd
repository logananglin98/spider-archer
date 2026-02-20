@tool
extends EditorPlugin

var inspector_plugin: AnimatedSpriteInspectorPlugin

func _enter_tree() -> void:
	inspector_plugin = AnimatedSpriteInspectorPlugin.new()
	add_inspector_plugin(inspector_plugin)

func _exit_tree() -> void:
	remove_inspector_plugin(inspector_plugin)

class AnimatedSpriteInspectorPlugin extends EditorInspectorPlugin:
	func _can_handle(object: Object) -> bool:
		return object is AnimatedSprite2D

	func _parse_begin(object: Object) -> void:
		var container = preload("res://addons/animation_folder_loader/animation_loader.gd").new()
		container.sprite = object
		add_custom_control(container) 