extends Node
class_name State

# Reference to the player (injected by the StateMachine)
var player

# Called when the state is entered
func enter(_prev_state: State) -> void:
	pass

# Called when the state is exited
func exit() -> void:
	pass

# Called when input is received
func handle_input(event: InputEvent) -> void:
	pass

# Called every frame (like _process)
func update(delta: float) -> void:
	pass

# Called every physics frame (like _physics_process)
func physics_update(delta: float) -> void:
	pass
