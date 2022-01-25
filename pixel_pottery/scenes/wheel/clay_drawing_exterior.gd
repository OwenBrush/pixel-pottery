extends Node2D

const LEFT = Vector2(-1,0)
const UP = Vector2(0,-1)
const RIGHT = Vector2(+1,0)
const DOWN = Vector2(0,+1)


onready var CellDrawing = get_parent()

func _draw():

#
	if CellDrawing.exterior:
		for line in CellDrawing.exterior["left"]:
			var start = Vector2(CellDrawing.exterior["left"][line][0],line)
			var end = Vector2(CellDrawing.exterior["left"][line][1],line)	
			draw_line(start,end,CellDrawing.base_color,CellDrawing.size,false)
#			draw_line(start,end,Color(0,0,1,.5),CellDrawing.size,false)
		for line in CellDrawing.exterior["right"]:
			var start = Vector2(CellDrawing.exterior["right"][line][0],line)
			var end = Vector2(CellDrawing.exterior["right"][line][1],line)	
			draw_line(start,end,CellDrawing.base_color,CellDrawing.size,false)
#			draw_line(start,end,Color(1,0,0,.5),CellDrawing.size,false)
	if CellDrawing.exterior_shade:
		for value in CellDrawing.exterior_shade.keys():
			for cell in CellDrawing.exterior_shade[value]:
				draw_line(cell,cell+RIGHT,Color(0,0,0,value),CellDrawing.size,false)	
	if CellDrawing.front_rim:
		for array in CellDrawing.front_rim:
			for line in CellDrawing.front_rim[array]:
				var start = Vector2(CellDrawing.front_rim[array][line][0],line)
				var end = Vector2(CellDrawing.front_rim[array][line][1],line)
				draw_line(start,end,CellDrawing.base_color.linear_interpolate(CellDrawing.shade_color ,CellDrawing.outline_value),CellDrawing.size,false)
