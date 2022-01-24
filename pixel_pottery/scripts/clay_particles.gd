extends Node2D



var PARTICLE_VELOCITY = 100 #velocity of animated particles after cell is destroyed
var PARTICLE_GRAVITY = 1000 #gravity of animated particles after cell is destroyed
var PARTICLE_LIFE = 1 #number of seconds particles remainin scene
onready var CELL_PARTICLE = load("res://particles/ClayParticle.tscn")

func _ready():
	GameEvents.connect("draw_clay_particles", self, '_on_draw_clay_particles' )

	
func _on_draw_clay_particles(cells_to_remove, speed):
#	print(speed)
	for cell in cells_to_remove.keys():
		var velocity = PARTICLE_VELOCITY*speed
		var x_gravity = PARTICLE_GRAVITY*speed
		var y_gravity = PARTICLE_GRAVITY*.5
		if cell[0] <= 0:
			velocity *= -1
			x_gravity *= -1
		var particle = CELL_PARTICLE.instance()
		get_parent().add_child(particle)
		particle.lifetime = PARTICLE_LIFE
		particle.position = cell
		particle.emitting = true
		particle.one_shot = true
		particle.process_material.color = Globals.clay_color
		particle.process_material.initial_velocity = velocity
		particle.process_material.gravity = Vector3(x_gravity,y_gravity,0)
