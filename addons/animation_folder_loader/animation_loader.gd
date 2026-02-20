@tool
extends VBoxContainer

var sprite: AnimatedSprite2D
var fps_spinbox: SpinBox

func _ready() -> void:
	# Add load folder button
	var button = Button.new()
	button.text = "Load Animation Folder"
	button.pressed.connect(_on_load_pressed)
	add_child(button)
	
	# Add horizontal container for FPS
	var fps_container = HBoxContainer.new()
	add_child(fps_container)
	
	# Add FPS label
	var fps_label = Label.new()
	fps_label.text = "Frames per second:"
	fps_container.add_child(fps_label)
	
	# Add FPS spinbox
	fps_spinbox = SpinBox.new()
	fps_spinbox.min_value = 1
	fps_spinbox.max_value = 120
	fps_spinbox.value = 24  # Default value
	fps_spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fps_container.add_child(fps_spinbox)

func _on_load_pressed() -> void:
	var dialog = EditorFileDialog.new()
	add_child(dialog)
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.title = "Select Animation Folder"
	dialog.dir_selected.connect(_on_dirs_selected)
	dialog.popup_centered_ratio(0.7)

func _on_dirs_selected(dir_path: String) -> void:
	# Create SpriteFrames if it doesn't exist
	var sprite_frames = sprite.sprite_frames
	if not sprite_frames:
		sprite_frames = SpriteFrames.new()
		sprite.sprite_frames = sprite_frames
	
	# Recursively explore directories
	explore_directory(dir_path, sprite_frames)
	
	# Cleanup
	get_child(-1).queue_free()

func explore_directory(path: String, sprite_frames: SpriteFrames) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		return
		
	# Search for files and folders
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	var has_images = false
	var image_files = []
	
	# First check if directory contains images directly
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.get_extension().to_lower() in ["png", "jpg", "jpeg"]:
				has_images = true
				image_files.append(file_name)
		file_name = dir.get_next()
	
	# If directory contains images, create an animation
	if has_images:
		# Sort images by name
		image_files.sort()
		
		# Create animation name from folder name
		var anim_name = path.get_file()
		
		# Add animation if it doesn't exist
		if not sprite_frames.has_animation(anim_name):
			sprite_frames.add_animation(anim_name)
			
		# Set FPS and disable loop
		sprite_frames.set_animation_speed(anim_name, fps_spinbox.value)
		sprite_frames.set_animation_loop(anim_name, false)
			
		# Add frames
		for img_file in image_files:
			var image_path = path.path_join(img_file)
			var texture = load(image_path)
			if texture:
				sprite_frames.add_frame(anim_name, texture)
	
	# Then explore subdirectories
	dir.list_dir_begin()
	file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			var sub_dir = path.path_join(file_name)
			explore_directory(sub_dir, sprite_frames)
		file_name = dir.get_next()
	
	dir.list_dir_end() 