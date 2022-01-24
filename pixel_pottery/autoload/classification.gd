extends Node


func identify_pot(cells, model):
	var matrix = _active_cells_to_matrix(cells)
	
	var width = Globals.IMAGE_SIZE
	var height = Globals.IMAGE_SIZE
	# Convert cell matrix into tensor for model
	var img_tensor_1 = Tensor.new(width, height, 1)
	var data_index = 0
	for x in range(width):
		for y in range(height):
			img_tensor_1.set_item(y, x, 0, matrix[x][y])
			
	var batch = [img_tensor_1]
	var results = Prediction.new(model).run(batch)[-1][-1]
	var classification = results.find(results.max())
	return classification
	
func _active_cells_to_matrix(cells):
	var size = Globals.IMAGE_SIZE
	
	var matrix = []
	for x in size:
		matrix.append([])
		matrix[x]=[]        
		for y in size:
			matrix[x].append([])
			matrix[x][y]=0
	
	for x in size:
		for y in size:
			var v =  not Vector2(x,-y)+Globals.IMAGE_OFFSET in cells
			matrix[x][size-y-1] = v
	return matrix

	
	
#
#
##func identify_pot():
##	var image_path = "res://test.png"
##	var img = Image.new()
##	img.load(image_path)
##	img.lock()
##
##	# Build image tensor with rows = height, cols = width, channels = 3
##	var img_tensor_1 = Tensor.new(img.get_height(), img.get_width(), 1)
##	var data_index = 0
##	for i in range(img.get_height()):
##		for j in range(img.get_width()):
##			img_tensor_1.set_item(i, j, 1, img.get_data()[data_index])
##			data_index += 1
##
##	img.unlock()
##
##	var batch = [img_tensor_1]
##
##	return Prediction.new('res://neural_net//model.json').run(batch)[-1]
#
#func example_1():
#
#	# XOR inference. Weights & biases are loaded from model-1.json
#
#	var batch = [[0, 0], [0, 1], [1, 0], [1, 1]]
#
#	return Prediction.new('res://data//model-1.json').run(batch)[-1]
#
#func example_2():
#
#	# Runs an image tensor over the sequence
#	# Conv2D -> MaxPooling2D -> Flatten -> Dense
#	# and shows the result. Weights & biases are loaded from model-2.json
#
#	var image_path = "res://images/randomimage1.png"
#	var img = Image.new()
#	img.load(image_path)
#	img.lock()
#
#	# Build image tensor with rows = height, cols = width, channels = 3
#	var img_tensor_1 = Tensor.new(img.get_height(), img.get_width(), 3)
#	var data_index = 0
#	for i in range(img.get_height()):
#		for j in range(img.get_width()):
#			for k in range(3):
#				img_tensor_1.set_item(i, j, k, img.get_data()[data_index])
#				data_index += 1
#
#	img.unlock()
#
#	var batch = [img_tensor_1]
#
#	return Prediction.new('res://data//model-2.json').run(batch)[-1]
#

	
