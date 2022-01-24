class_name MaxPooling2D

# FORWARD ONLY MAXPOOLING2D CLASS
# Data format is always channels last = (rows, cols, channels) 


var pool_size : Array
var padding : String
var strides : Array

func _init(pool_size : Array, padding : String, strides : Array):
	
	self.pool_size = pool_size
	self.padding = padding
	self.strides = strides
	
	pass
	
func forward(batch : Array)-> Array:
	
	var pad = 0
	var width = len(batch[0].data[0])
	
	if padding == 'same':
		pad = round(((strides[0]-1)*width-strides[0]+pool_size[0])/2)
	
	var batch_padded = MathTools.zero_pad_2D(batch, pad)
 
	var pool_size_x = pool_size[0]
	var pool_size_y = pool_size[1]
	var stride_x = strides[0]
	var stride_y = strides[1]
	var n_x = 0
	var n_y = 0
	
	var output_batch = []
	
	for n in range(len(batch_padded)):
		
		var completed = false
		var r_y = []
		var r_x = []
		var max_pool = []
		var num_filters = len(batch_padded[n].data[0][0])
		max_pool.resize(num_filters)
		
		while !completed:
			
			for i in range(num_filters):
				max_pool[i] = 0.0
				
			for i in range(pool_size_x):
				for j in range(pool_size_y):
					for k in range(len(batch_padded[n].data[i + n_x * stride_x][j + n_y * stride_y])):
						var current = batch_padded[n].data[i + n_x * stride_x][j + n_y * stride_y][k]
						if current > max_pool[k]:
							max_pool[k] = current
			
			if  pool_size_y + n_y * stride_y < len(batch_padded[n].data[0]):
				r_x.append(max_pool.duplicate())
				n_y += 1
			elif pool_size_y + n_y * stride_y == len(batch_padded[n].data[0]) and pool_size_x + n_x * stride_x < len(batch_padded[n].data):
				n_y = 0
				n_x += 1
				r_x.append(max_pool.duplicate())
				r_y.append(r_x.duplicate())
				r_x.clear()
			elif pool_size_y + n_y * stride_y == len(batch_padded[n].data[0]) and pool_size_x + n_x * stride_x == len(batch_padded[n].data):
				r_x.append(max_pool.duplicate())
				r_y.append(r_x.duplicate())
				r_x.clear()
				completed = true
				
#			if pool_size_y + n_y * stride_y > len(batch_padded[n].data[0]) or pool_size_y + n_x * stride_x > len(batch_padded[n].data):
#				if len(r_y) == 0:
#					r_x.append(max_pool.duplicate())
#					r_y.append(r_x.duplicate())
#					r_x.clear()
#				completed = true
	
		output_batch.append(MathTools.list_to_tensor(r_y.duplicate()))
		r_y.clear()
		
	return output_batch
