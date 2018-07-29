tool
extends EditorPlugin

# Add our custom node type

func _enter_tree():
    # Initialization of the plugin goes here
	add_custom_type("Water2D", "Node2D", preload("test.gd"), preload("Water2dIcon.png"))

# Remove the custom node type

func _exit_tree():
    # Clean-up of the plugin goes here
    remove_custom_type("Water2D")