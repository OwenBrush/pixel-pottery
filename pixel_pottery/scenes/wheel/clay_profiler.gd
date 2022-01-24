extends Node2D



var CURVITURE = .15

func generate_profile(active_cells:Dictionary, animation_cycle:float):
	var profile = parameters_from_cells(active_cells)
	var corners = corners_from_parameters(profile)
	var rim =  rim_from_corners(corners,animation_cycle)
	profile = fill_interior_from_rim(profile, rim, corners)
	profile = apply_curviture_to_proile(profile)
	var exterior_and_full = remove_interior_from_profile(profile, rim)
	var exposed_interior = profile_of_rim(rim)
	
	
	return{
		"full": exterior_and_full["full"],
		"active":active_cells,
		"back_rim":rim["top_rim"],
		"front_rim":rim["bottom_rim"],
		"exterior":exterior_and_full["exterior"],
		"exposed": exposed_interior
		}

func parameters_from_cells(cells:Dictionary)->Dictionary:
	var parameters = {}
	for cell in cells:
		var row = cell[1]
		var x_value = cell[0]
		if not parameters.has(row):
			parameters[row] = Vector2(x_value,x_value)
		elif x_value < parameters[row][0]:
			parameters[row][0] = cell[0]
		elif x_value > parameters[row][1]:
			parameters[row][1] = cell[0]
	return parameters


func corners_from_parameters(parameters):
	var bottom = parameters.keys().max()
	var top = parameters.keys().min()
	var left_corner = Vector2(0,0)
	var right_corner = Vector2(0,0)
	if parameters.size() > 0:
		left_corner = Vector2(parameters[bottom][0],bottom)
		right_corner = Vector2(parameters[bottom][1],bottom)


		var width = abs(left_corner[0] - right_corner[0])
		var center_point = width * .5
		var pot_center = round(left_corner[0]+center_point)
	
		for i in range(bottom,top , -1):
			var row = float(i)
			if parameters[row][0] < pot_center:
				left_corner = Vector2(parameters[row][0],row)
			if parameters[row][1] > pot_center:
				right_corner = Vector2(parameters[row][1],row)
	return {"left":left_corner,"right":right_corner}


func rim_from_corners(corners,animation):
	
	var left_corner = corners["left"]
	var right_corner = corners["right"]
	var top_rim = {"left":{},"right":{}}
	var bottom_rim = {"left":{},"right":{}}
	
	var top
	var bottom
	if left_corner[1] > right_corner[1]:
		top = round(right_corner[1] +  abs(right_corner[1] -left_corner[1])*animation)
		bottom = round(right_corner[1] +  abs(right_corner[1] -left_corner[1])*animation)
	else:  
		top = round(left_corner[1] )
		bottom = round(right_corner[1] - abs(right_corner[1] -left_corner[1])*animation)
		
	var base_width = abs(left_corner[0] - right_corner[0])
	var height_off_set = abs(round(base_width*CURVITURE*.5))

	top =  round(top-height_off_set)
#	var middle_point = left_corner[0]+ base_width*.5
#	var off_center = abs(middle_point - wheel_center) / base_width
#	print(.5 - animation * off_center )
	var split = ( left_corner[0]+ base_width * .5)
#	var split = ( left_corner[0]+ base_width * (1 - (.5 - animation * off_center ) ) ) 
#	split = split + base_width*off_center*(-.5+sin(animation*PI))
	if left_corner[1] < right_corner[1]:
		split = left_corner[0]+ base_width*animation
	elif left_corner[1] > right_corner[1]:
		split = left_corner[0]+ base_width*(animation)


	var left_point = left_corner[0]
	var right_point = right_corner[0]

	for i in range(left_corner[1],top-1,-1):		
		var key = float(i)
		var mirror_key = bottom + abs(abs(left_corner[1]) - abs(i))
		
		var y_pos 
		var height 
		
		if left_corner[1] > right_corner[1]:
			y_pos = abs(left_corner[1] - i)
			height = abs(left_corner[1]-top)
		else:
			y_pos = abs( bottom - i )	
			height = abs( bottom - top )			
		
		var v_distance
		if height == 0:
			v_distance = 0
		else:
			v_distance = abs( y_pos / height )


		var width = abs(left_point - split)
		var mod = abs(round(width*v_distance*v_distance))### test out other modifiers

		top_rim["left"][key] = Vector2(left_point,left_point + mod)
		bottom_rim["right"][mirror_key] = Vector2(right_point - mod , right_point)

		left_point += mod
		right_point -= mod

	left_point = left_corner[0]
	right_point = right_corner[0]

#	var right_height = abs(right_corner[1]-(left_corner[1]-top))

	for i in range(bottom,top-1, -1):		
		var key = float(i)
		var mirror_key = left_corner[1]+abs(abs(bottom)-abs(i))
		
		var y_pos = abs( bottom - i )	
		var height = abs( bottom - top )	
		
		var v_distance		
		if height == 0:
			v_distance = 0
		else:
			v_distance = abs( y_pos / height )

		var width = abs(right_point - split)
		var mod = abs(round(width*v_distance*v_distance))

		top_rim["right"][key] = Vector2(right_point - mod , right_point)
		bottom_rim["left"][mirror_key] = Vector2(left_point,left_point + mod)

		right_point -= mod
		left_point += mod
	return {"top_rim":top_rim,"bottom_rim":bottom_rim}


func fill_interior_from_rim(profile, rim, corners):
	var top_rim = rim["top_rim"]
	var bottom_rim = rim["bottom_rim"]
	
	var bottom
	if bottom_rim["left"].keys().max() < bottom_rim["right"].keys().max():
		bottom =  bottom_rim["right"].keys().max()
	else:
		bottom =  bottom_rim["left"].keys().max()
	if corners["right"][1] > bottom:
		bottom = corners["right"][1]
	
	var top 
	if top_rim["left"].keys().min() < top_rim["right"].keys().min():
		top = top_rim["left"].keys().min()
	else:
		top = top_rim["right"].keys().min()
		

	
	var left =	corners["right"][0]
	var right = corners["left"][0]
	var right_corner = corners["right"]
	
	for i in range(top,bottom+1):
		var key = float(i)
		if profile.has(key):
			left = profile[key][0]
			right = profile[key][1]
		
		if top_rim["right"].has(key):
			if top_rim["right"][key][1] > right:
				right = top_rim["right"][key][1]
		if bottom_rim["right"].has(key):
			if bottom_rim["right"][key][1] > right:
				right = bottom_rim["right"][key][1]
				
		if top_rim["left"].has(key):
			if top_rim["left"][key][0] < left:
				left = top_rim["left"][key][0]
		if bottom_rim["left"].has(key):
			if bottom_rim["left"][key][0] < left:
				left = bottom_rim["left"][key][0]
		if key < right_corner[1] and key > top_rim["right"].keys().max():
			if right < right_corner[0]:
				right = right_corner[0]
		profile[key] =  Vector2(left,right)
	return profile


func remove_interior_from_profile(profile, rim):
	var top = profile.keys().min()
	var bottom = profile.keys().max()
	
	var exterior_profile = {"left":{},"right":{}}
	for i in range ( top , bottom+1 ):
		var key = float(i)
		var split = profile[key][0] + round(abs(abs(profile[key][0]) - abs(profile[key][1]))*.5)
		var left_out = profile[key][0]
		var left_in = split
		if rim["top_rim"]["left"].has(key):

			left_in = rim["top_rim"]["left"][key][0]
		if rim["bottom_rim"]["left"].has(key):

			left_in = rim["bottom_rim"]["left"][key][0]
		if left_in != left_out:
			exterior_profile["left"][key] = Vector2(left_out,left_in)
		
		var right_in = split
		var right_out = profile[key][1]	
		if rim["top_rim"]["right"].has(key):
			right_in = rim["top_rim"]["right"][key][1]

		if rim["bottom_rim"]["right"].has(key):
			right_in = rim["bottom_rim"]["right"][key][1]

		if right_in != right_out:
			exterior_profile["right"][key] = Vector2(right_in ,right_out)
		
		if right_out > profile[key][1]:
			profile[key][1] = right_out
		if left_out < profile[key][0]:
			profile[key][0] = left_out		
		
	return {"exterior":exterior_profile,"full":profile}

func apply_curviture_to_proile(profile):
	var bottom = profile.keys().max()
	var left_corner = profile[bottom][0]
	var right_corner = profile[bottom][1]

	var base_width = abs(left_corner - right_corner)
	var depth = abs(round(base_width*CURVITURE*.5))
	for key in range(0, depth):
		var v_distance = abs( key / depth )
		var width = abs(left_corner - right_corner)
		var mod = abs(round(width*v_distance*v_distance))### test out other modifiers
		profile[bottom+key+1] = Vector2(left_corner+mod,right_corner-mod)
	return profile

func profile_of_rim(rim):
	var rim_profile = {}
	var top
	var bottom
	var top_left = rim["top_rim"]["left"]
	var top_right = rim["top_rim"]["right"]
	var bottom_left = rim["bottom_rim"]["left"]
	var bottom_right = rim["bottom_rim"]["right"]
	
	
	if top_left.keys().min() < top_right.keys().min():
		top = top_left.keys().min() 
	else:
		top = top_right.keys().min()
		
	if bottom_left.keys().max() > bottom_right.keys().max():
		bottom = bottom_left.keys().max() 
	else:
		bottom = bottom_right.keys().max() 
	
	var left = top_left[top_left.keys().min()][0]
	var right = top_right[top_right.keys().min()][1]
	
	for i in range (top, bottom):
		var key = float(i)
		if top_left.has(key):
			left = top_left[key][0]+1
		elif bottom_left.has(key):
			left =  bottom_left[key][0]+1
			
		if top_right.has(key):
			right = top_right[key][1]-1
		elif bottom_right.has(key):
			right =  bottom_right[key][1]-1
			
			
		rim_profile[key] = Vector2(left,right)
	return rim_profile
