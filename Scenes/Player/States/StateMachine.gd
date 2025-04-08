extends Node

var current_state: State

func change_state(new_state: State):
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.player = get_parent()  # Player
	current_state.enter(current_state)
