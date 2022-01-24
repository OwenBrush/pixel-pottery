class_name Tensor

# BASIC TENSOR CLASS WITH SETTER AND GETTER
# ALL TENSOR ELEMENTS ARE INITIALIZED WITH ZEROS BY DEFAULT

var rows : int
var cols : int
var channels : int
var data : Array

func _init(rows : int, cols : int, channels: int):
	
	self.rows = rows
	self.cols = cols
	self.channels = channels
	
	for i in range(rows):
		self.data.append([])
		for j in range(cols):
			self.data[i].append([])
			for k in range(channels):
				self.data[i][j].append(0.0)
	
	pass

func set_item(row : int, col : int, channel: int, value: float):
	
	self.data[row][col][channel] = float(value)
	
	pass
	
func get_item(row: int, col: int, channel: int)-> float:
	
	return self.data[row][col][channel]
