extends Node


func score(cells:Array)->float:
	var a = []
	var b = []
	
	for cell in cells:
		if cell.x >= 0:
			b.append(cell)
		else:
			var x = abs(cell.x)-1
			var y = cell.y
			a.append(Vector2(x,y))
			
	var min_distances = []
	
	if len(a) > len(b):
		for cell in a:
			min_distances.append(_find_min_distance(cell, b))
	else:
		for cell in b:
			min_distances.append(_find_min_distance(cell, a))
	
	var score = 0
	for i in min_distances:
		score += i
		
	if len(min_distances) == 0:
		return -99.0

	return 1- (score/len(min_distances))
		
	
		
func _find_min_distance(a:Vector2, b_cells:Array)->float:
	var min_distance = 96
	for b in b_cells:
		var distance = a.distance_to(b)
		if distance == 0:
			return distance
		elif distance < min_distance:
			min_distance = distance
	return min_distance
		
