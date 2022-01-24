class_name Prediction

var model_path : String

func _init(model_path):
	
	self.model_path = model_path
	
	pass
	
func run(batch : Array)-> Array:
	
	var w_b = load_weights_and_biases(model_path)
	var sequence = []

	if len(w_b) > 0:
		
		for i in range(len(w_b)):
			
			if 'conv2d' in w_b[i].config.name:
			
				var weights = w_b[i].weights_biases[0]
				var biases = w_b[i].weights_biases[1]
				var padding = str(w_b[i].config.padding)
				var strides = w_b[i].config.strides
				var kernel_size = w_b[i].config.kernel_size
				var activation = str(w_b[i].config.activation)
				
				var conv2d_layer = Conv2D.new(weights, biases, padding, strides, kernel_size, activation)
				if i == 0:
					sequence.append(conv2d_layer.forward(batch))
				else:
					sequence.append(conv2d_layer.forward(sequence[-1]))
			
			if 'flatten' in w_b[i].config.name:
				
				if i == 0:
					sequence.append(MathTools.flatten(batch))
				else:
					sequence.append(MathTools.flatten(sequence[-1]))
				
			if 'max_pooling2d' in w_b[i].config.name:
				
				var pool_size = w_b[i].config.pool_size
				var padding = str(w_b[i].config.padding)
				var strides = w_b[i].config.strides
				
				var maxpool2d_layer = MaxPooling2D.new(pool_size, padding, strides)
				if i == 0:
					sequence.append(maxpool2d_layer.forward(batch))
				else:
					sequence.append(maxpool2d_layer.forward(sequence[-1]))
				
			if 'dense' in w_b[i].config.name:
				
				var weights = w_b[i].weights_biases[0]
				var biases = w_b[i].weights_biases[1]
				var activation = str(w_b[i].config.activation)
				
				var dense_layer = Dense.new(weights, biases, activation)
				if i == 0:
					sequence.append(dense_layer.forward(batch))
				else:
					sequence.append(dense_layer.forward(sequence[-1]))
					
	return sequence
	
	
func load_weights_and_biases(filename : String):
	
	var data
	var w_b_out = []
	var file = File.new()
	
	if ERR_FILE_NOT_FOUND == file.open(filename, File.READ):
		print('File not found.')
		file.close()
	else:
		data = file.get_as_text()
		file.close()
		
		var json_data = JSON.parse(data).result

		for i in range(len(json_data)):
			
			var dict = {
				'config' : json_data[i].config,
				'weights_biases' : json_data[i].weights_biases
			}
			
			w_b_out.append(dict)

	return w_b_out
