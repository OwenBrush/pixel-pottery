class_name MathTools

# Barebones Linear Algebra library with a few additions of my own.
# Original project: https://github.com/higgs-bosoff/godot-linalg

# Initialise a vector
static func init_v(n: int, v0: float=0.0)->Array:
	var ans = []
	ans.resize(n)
	
	for i in range(n):
		ans[i] = v0
			
	return ans

# Initialise a matrix
static func init_m(m: int, n: int, m0: float=0.0)->Array:
	var ans = []
	ans.resize(m)
	
	for i in range(m):
		var row = []
		row.resize(n)
		for j in range(n):
			row[j] = m0
		ans[i] = row
	
	return ans
	
# Dot product: matrix times matrix
static func dot_mm(M: Array, M2: Array)->Array:
	var m = len(M)
	var n = len(M2[0])
	var nn = len(M2)
	var ans = init_m(m, n)
	
	for i in range(m):
		var row = M[i]
		var rowout = ans[i]
		for j in range(n):
			var tot = 0.0
			for k in range(nn):
				tot += row[k]*M2[k][j]
			rowout[j] = tot
		
	return ans
	
	# Dot product: vector times vector
static func dot_vv(v: Array, v2: Array)->float:
	var n = len(v)
	var ans = 0.0
	
	for i in range(n):
		ans += v[i]*v2[i]
	
	return ans
	
	# Element-wise: vector plus vector
static func ewise_vv_add(v: Array, v2: Array, in_place: bool=false)->Array:
	
	var n = len(v)
	var ans
	if in_place:
		ans = v
	else:
		ans = init_v(n)
	
	for i in range(n):
		ans[i] = v[i]+v2[i]
	
	return ans
	
static func transpose(M: Array)->Array:
	var ans = []
	var m = len(M)
	var n = len(M[0])
	ans.resize(n)

	for i in range(n):
		ans[i] = []
		for j in range(m):
			ans[i].append(M[j][i])

	return ans
	
# Add vector element-wise to each matrix inside a list
static func ewise_mv_add(M: Array, v: Array, in_place: bool=false)->Array:
	
	var m = len(M)
	var n = len(M[0])
	var ans
	if in_place:
		ans = M
	else:
		ans = init_m(m, n)
	
	for i in range(m):
		var row1 = M[i]
		var rowout = ans[i]
		for j in range(len(v)):
			rowout[j] = row1[j] + v[j]
			
	return ans

# Map matrix elements using the provided activation function
static func map_array(M: Array, activation : String)->Array:
	
	var ans
	var m = len(M)
	var n = len(M[0])
	ans = init_m(m, n)
		
	for i in range(m):
		var sum = 0.0
		for j in range(n):
			sum += exp(M[i][j])
		for j in range(n):
			var element_copy = M[i][j]
			if activation == 'sigmoid':
				ans[i][j] = sigmoid(element_copy)
			elif activation == 'relu':
				ans[i][j] = relu(element_copy)
			elif activation == 'tanh':
				ans[i][j] = tanh(element_copy)
			elif activation == 'softmax':
				ans[i][j] = exp(element_copy) / sum	
			elif activation == 'linear':
				ans[i][j] = element_copy
	
	return ans
	
# Applies padding to the height and weight of an image Tensor batch
static func zero_pad_2D(batch : Array, pad : int)-> Array:
	
	var output = []
	
	for x in range(len(batch)):
	
		var t = Tensor.new(batch[x].rows + pad, batch[x].cols + pad, batch[x].channels)
		
		for i in range(batch[x].rows):
			for j in range(batch[x].cols):
				for k in range(batch[x].channels):
					t.set_item(i, j, k, batch[x].data[i][j][k])
		
		output.append(t)
	
	return output

# Flattens a batch of Tensors 
static func flatten(batch : Array)-> Array:
	
	var outputs = []
	
	for i in range(len(batch)):
		var v = []
		for x in range(len(batch[i].data)):
			for y in range(len(batch[i].data[x])):
				for z in range(len(batch[i].data[x][y])):
					v.append(batch[i].data[x][y][z])
		outputs.append(v)
	
	return outputs

# Converts an Array of Vectors into a Tensor object
static func list_to_tensor(list : Array)-> Tensor:
	
	var rows = len(list)
	var cols = len(list[0])
	var channels = len(list[0][0])
	
	var output = Tensor.new(rows, cols, channels)
	
	for i in range(rows):
		for j in range(cols):
			for k in range(channels):
				output.data[i][j][k] = list[i][j][k]
	
	return output
	
# Map Tensor elements using the provided activation function
static func map_tensor(t : Tensor, activation: String)->Tensor:
	
	var output = Tensor.new(t.rows, t.cols, t.channels)
	
	for i in range(t.rows):
		for j in range(t.cols):
			for k in range(t.channels):
				if activation == 'sigmoid':
					output.data[i][j][k] = sigmoid(t.data[i][j][k])
				elif activation == 'relu':
					output.data[i][j][k] = relu(t.data[i][j][k])
				elif activation == 'tanh':
					output.data[i][j][k] = tan_h(t.data[i][j][k])
				elif activation == 'linear':
					output.data[i][j][k] = t.data[i][j][k]
	
	return output 
	

static func tan_h(x):
	if typeof(x) == TYPE_REAL:
		return tanh(x)
	if typeof(x) == TYPE_ARRAY:
		for i in range(len(x)):
			x[i] = tanh(x[i])
		return x

static func sigmoid(x):
	if typeof(x) == TYPE_REAL:
		return 1.0 / (1.0 + exp(-x))
	if typeof(x) == TYPE_ARRAY:
		for i in range(len(x)):
			x[i] = 1.0 / (1.0 + exp(-x[i]))
		return x

		
static func relu(x):
	if typeof(x) == TYPE_REAL:
		if x > 0.0:
			return x
		else: 
			return 0.0 
	if typeof(x) == TYPE_ARRAY:
		for i in range(len(x)):
			if x[i] > 0.0:
				x[i] = x
			else:
				x[i] = 0.0
		return x



