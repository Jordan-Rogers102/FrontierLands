extends State

func enter(_prev_state: State) -> void:
	player.anim_player.play("idle")

func physics_update(delta: float) -> void:
	var input = Input.get_vector("left", "right", "up", "down")
	if input.length() > 0:
		player.state_machine.change_state(player.move_state)
	elif Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.state_machine.change_state(player.jump_state)

	# Apply gravity
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta
	player.move_and_slide()
