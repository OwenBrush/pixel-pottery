class_name Dense

# FORWARD ONLY DENSE CLASS 

var weights : Array
var biases : Array
var activation : String

func _init(weights : Array, biases : Array, activation : String):
	
	self.weights = weights
	self.biases = biases
	self.activation = activation

	pass
	
func forward(batch : Array)-> Array:

	var outputs = []

	var layer = MathTools.dot_mm(batch, weights)
	MathTools.ewise_mv_add(layer, biases, true)

	outputs = MathTools.map_array(layer, activation)

	return outputs

	
