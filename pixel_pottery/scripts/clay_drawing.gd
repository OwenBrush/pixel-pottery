extends Node2D

export var base_color = Color(1,1,1,1)
var shade_color = Color(0,0,0,1)
#var interior_color = Color(0,0,0,.25)
var transparency = Color(0,0,0,.25)

var interior_value = .25
var outline_value = .75
var second_outline_value = .5
var shade_array=[ .3 , .3 , .15 , .15 , .10 , .10 , .05 , .05 , .0 , .0]


const WALL_TRANSPARENCY = .5
const TWEEN_TIME = .5

const LEFT = Vector2(-1,0)
const UP = Vector2(0,-1)
const RIGHT = Vector2(+1,0)
const DOWN = Vector2(0,+1)


#var draw_cells = {}

var profile = {}
var interior = {}
var exterior = {}
var back_rim = {}
var front_rim = {}
var wall = {}
var interior_shade = {}
var exterior_shade = {}
var size = 1.00001

#func _ready():
#	GameEvents.connect("draw_clay",self,"_on_draw_clay")
#	GameEvents.connect("toggle_transparency", self, "_on_toggle_transparency")
#	Globals.drawing_position = global_position
func draw_clay(profile:Dictionary)->void:
#	profile = ClayProfiler.generate_profile(cells, animation_state)
	draw_pot(profile)

func _draw():
	pass
	if interior:
		for line in interior:
			var start = Vector2(interior[line][0],line)
			var end = Vector2(interior[line][1],line)
			draw_line(start,end,base_color.linear_interpolate(shade_color , interior_value),size,false)			
	if back_rim:	
		for array in back_rim:
			for line in back_rim[array]:
				var start = Vector2(back_rim[array][line][0],line)
				var end = Vector2(back_rim[array][line][1],line)
				draw_line(start,end,base_color.linear_interpolate(shade_color , outline_value),size,false)
	if wall:
		for cell in wall:
			draw_line(cell,cell+RIGHT,base_color,size,false)
	if interior_shade:
		for value in interior_shade.keys():
			for cell in interior_shade[value]:
				draw_line(cell,cell+RIGHT,Color(0,0,0,value),size,false)

func toggle_transparency(transparent):
	var new_modulation = $ExteriorClayDrawing.self_modulate
	if transparent:
		new_modulation.a = WALL_TRANSPARENCY
	else:
		new_modulation.a = 1
	
#	if $Tween.is_active():
#		$Tween.stop_all()
	$Tween.interpolate_property(
		$ExteriorClayDrawing,
		"self_modulate",
		$ExteriorClayDrawing.self_modulate,
		new_modulation,
		TWEEN_TIME,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT)
	$Tween.start()
	

func set_color(color):
	base_color = color


func draw_pot(new_profile):
	profile = new_profile
	interior = profile["full"]
	wall = profile["active"]
	exterior = profile["exterior"]
	front_rim = profile["front_rim"]
	back_rim = profile["back_rim"]

	_shade_cells()
	$ExteriorClayDrawing.call("update")
	update()
	
func _shade_cells():
	exterior_shade.clear()
	interior_shade.clear()
	
	for y in profile["full"].keys():
		var left = profile["full"][y][0]
		var right = profile["full"][y][1]
		for x in range (left , right+1):
			var shade_value = _determine_shade_value( x , y )
			if _is_exterior( x , y):		
				if not exterior_shade.has(shade_value):
					exterior_shade[shade_value]=[]
				exterior_shade[shade_value].append(Vector2(x,y))		
			else:
				if not interior_shade.has(shade_value):
					interior_shade[shade_value]=[]
				interior_shade[shade_value].append(Vector2(x,y))


func _is_exterior( x , y):
	if profile["exterior"]["left"].has(y):
		if x >= profile["exterior"]["left"][y][0] and x <= profile["exterior"]["left"][y][1]:
			return true
	if profile["exterior"]["right"].has(y):
		if x >= profile["exterior"]["right"][y][0] and x <= profile["exterior"]["right"][y][1]:
			return true		
	return false
	
func _determine_shade_value( x , y ):
	
	
	if x == interior[y][0] or x == interior[y][1]:
		return outline_value
		
	if interior.has(y-1):
		if x < interior[y-1][0] or x > interior[y-1][1]:
			return outline_value
	else:
		return outline_value
		
	if interior.has(y+1):
		if x < interior[y+1][0] or x > interior[y+1][1]:
			return outline_value			
	else:
		return outline_value
		

	var middle_point =  abs(interior[y][0] - interior[y][1]) * .5
	var interval = abs( interior[y][0] - x)
	var distance_to_center = 1-abs(1-(interval/(middle_point)))
	
	var shade_factor =  clamp(round(shade_array.size()*distance_to_center),0,shade_array.size()-1)
	
	return shade_array[shade_factor]


func _pixel_from_draw(pixel):
	var color = base_color
	if pixel.y in front_rim["left"].keys() :
		if pixel.x >= front_rim["left"][pixel.y][0] :
			if pixel.x < front_rim["left"][pixel.y][1] :
				return color.linear_interpolate(shade_color, outline_value)
	if pixel.y in front_rim["right"].keys() :
		if pixel.x >= front_rim["right"][pixel.y][0] :
			if pixel.x < front_rim["right"][pixel.y][1] :
				return color.linear_interpolate(shade_color, outline_value)
				
	if wall.has(Vector2(pixel.x , pixel.y)):
		var shade_value = _determine_shade_value(pixel.x , pixel.y)
		return color.linear_interpolate(shade_color, shade_value)
				
	if pixel.y in back_rim["left"].keys() :
		if pixel.x >= back_rim["left"][pixel.y][0] :
			if pixel.x < back_rim["left"][pixel.y][1] :
				return color.linear_interpolate(shade_color, outline_value)
	if pixel.y in back_rim["right"].keys() :
		if pixel.x >= back_rim["right"][pixel.y][0] :
			if pixel.x < back_rim["right"][pixel.y][1] :
				return color.linear_interpolate(shade_color, outline_value)
				
#
	if pixel.y in exterior["left"].keys() :
		if pixel.x >= exterior["left"][pixel.y][0] :
			if pixel.x < exterior["left"][pixel.y][1] :
				var shade_value = _determine_shade_value(pixel.x , pixel.y)
				return color.linear_interpolate(shade_color, shade_value)

	if pixel.y in exterior["right"].keys() :
		if pixel.x >= exterior["right"][pixel.y][0] :
			if pixel.x < exterior["right"][pixel.y][1] :
				var shade_value = _determine_shade_value(pixel.x , pixel.y)
				return color.linear_interpolate(shade_color, shade_value)

	if pixel.y in interior.keys():
		if pixel.x >= interior[pixel.y][0]: 
			if pixel.x <= interior[pixel.y][1]:
				var interior_color = base_color.linear_interpolate(shade_color , interior_value)
				var shade_value = _determine_shade_value( pixel.x , pixel.y )
				return interior_color.linear_interpolate(shade_color, shade_value)
	return Color(1,1,1,0)	
						
				#frontrim
				#exterior-shade
				#exterior
				#backrim
				#interior



func generate_full_texture():
	var offset = Vector2(0,0)
	var height = - interior.keys().min() + interior.keys().max() +1
	var width = 0
	for row in interior.values():
		var row_width = abs( row[1] - row[0] )
		if row_width > width +1:
			width = row_width+1
			offset.x = row[0]
	offset.y = interior.keys().min()
	
	var img = Image.new()
	img.create(width, height , false , 5)
	img.lock()
	for y in height:
		for x in width:
			var color = _pixel_from_draw(Vector2(x + offset.x , y + offset.y) )
			img.set_pixel(x,y,color)	
	img.unlock()
	var texture = ImageTexture.new()
	texture.create_from_image(img , 0)	
	return texture
	
func generate_profile_texture():
	var offset = Vector2(0,0)
	var height = - interior.keys().min() + interior.keys().max() +1
	var width = 0
	for row in interior.values():
		var row_width = abs( row[1] - row[0] )
		if row_width > width +1:
			width = row_width+1
			offset.x = row[0]
	offset.y = interior.keys().min()
	
	var img = Image.new()
	img.create(width, height , false , 5)
	img.lock()
	for y in height:
		for x in width:
			if Vector2(x+offset.x , y + offset.y) in wall.keys():
				img.set_pixel(x,y,base_color.linear_interpolate(shade_color,outline_value))	
			else:
				img.set_pixel(x , y , Color(0,0,0,0))
	img.unlock()
	var texture = ImageTexture.new()
	texture.create_from_image(img , 0)	
	return texture



