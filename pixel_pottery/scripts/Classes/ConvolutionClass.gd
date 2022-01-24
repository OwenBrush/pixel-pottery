class_name Conv2D

# FORWARD ONLY CONVOLUTION CLASS
# Data format is always channels last = (rows, cols, channels) 


var weights : Array
var biases : Array
var padding : String
var strides : Array
var kernel_size : Array
var activation: String

func _init(weights : Array, biases : Array, padding : String, strides : Array, kernel_size : Array, activation : String):
	
	self.weights = weights
	self.biases = biases
	self.padding = padding
	self.strides = strides
	self.kernel_size = kernel_size
	self.activation = activation
	
	pass
	
func forward(batch : Array)-> Array:
	
	var pad = 0
	var width = len(batch[0].data[0])
	
	if padding == 'same':
		pad = round(((strides[0]-1)*width-strides[0]+kernel_size[0])/2)
	
	var batch_padded = MathTools.zero_pad_2D(batch, pad)
 
	var patch_size_x = kernel_size[0]
	var patch_size_y = kernel_size[1]
	var stride_x = strides[0]
	var stride_y = strides[1]
	var n_x = 0
	var n_y = 0
	
	var output_batch = []
	
	for n in range(len(batch_padded)):
		
		var output = []
		var completed = false
		
		var r_y = []
		var r_x = []
		var sub_sum = []
			
		var num_filters = len(weights[0][0][0])
		for i in range(num_filters):
			sub_sum.append(0.0)
		
		while !completed:
			
			for i in range(num_filters):
				sub_sum[i] = 0.0
			
			for i in range(patch_size_x):
				for j in range(patch_size_y):
					for k in range(len(batch_padded[n].data[i + n_x * stride_x][j + n_y * stride_y])):
						for u in range(len(weights[i][j][k])):
							sub_sum[u] += batch_padded[n].data[i + n_x * stride_x][j + n_y * stride_y][k] *  weights[i][j][k][u]
						
			if  patch_size_y + n_y * stride_y < len(batch_padded[n].data[0]):
				r_x.append(sub_sum.duplicate())
				n_y += 1
			elif patch_size_y + n_y * stride_y == len(batch_padded[n].data[0]) and patch_size_x + n_x * stride_x < len(batch_padded[n].data):
				n_y = 0
				n_x += 1
				r_x.append(sub_sum.duplicate())
				r_y.append(r_x.duplicate())
				r_x.clear()
			elif patch_size_y + n_y * stride_y == len(batch_padded[n].data[0]) and patch_size_x + n_x * stride_x == len(batch_padded[n].data):
				r_x.append(sub_sum.duplicate())
				r_y.append(r_x.duplicate())
				r_x.clear()
				completed = true
		
		for i in range(len(r_y)):
			for j in range(len(r_y[i])):
				for k in range(len(r_y[i][j])):
					r_y[i][j][k] = r_y[i][j][k] + biases[k]

		output_batch.append(MathTools.map_tensor(MathTools.list_to_tensor(r_y.duplicate()), activation))
		r_y.clear()
	
	return output_batch
	
