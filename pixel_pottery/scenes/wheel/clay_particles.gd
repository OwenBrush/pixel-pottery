extends Node2D



var PARTICLE_VELOCITY = 10 #velocity of animated particles after cell is destroyed
var PARTICLE_GRAVITY = 200 #gravity of animated particles after cell is destroyed
var PARTICLE_LIFE = 0.75 #number of seconds particles remainin scene

export(PackedScene) onready var _cell_particle 

func draw_particles(cells_to_remove, speed):
	if not cells_to_remove:
		return
	for cell in cells_to_remove.keys():
		var velocity = PARTICLE_VELOCITY*speed
		var x_gravity = PARTICLE_GRAVITY*speed
		var y_gravity = PARTICLE_GRAVITY*.5
		if cell[0] <= 0:
			velocity *= -1
			x_gravity *= -1
		var particle = _cell_particle.instance()
		add_child(particle)
		particle.lifetime = PARTICLE_LIFE
		particle.position = cell
		particle.emitting = true
		particle.one_shot = true
		particle.process_material.color = Globals.clay_color.darkened(0.2)
		particle.process_material.initial_velocity = velocity
		particle.process_material.gravity = Vector3(x_gravity,y_gravity,0)
