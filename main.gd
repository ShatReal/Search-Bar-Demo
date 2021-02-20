extends MarginContainer


const IconClass := preload("res://icon.tscn")

var names:PoolStringArray = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?".replace(",", "").replace(".", "").split(" ")
var icons: Array = []

onready var grid := $VBoxContainer/ScrollContainer/CenterContainer/GridContainer


class DistanceSorter:
	static func sort_dist(a, b):
		return a[0] < b[0]


func _ready():
	# Godot doesn't have static variables so I need to instance a class to
	# access the number of frames.
	var sprite := IconClass.instance().get_child(0).get_child(0)
	for y in range(sprite.vframes):
		for x in range(sprite.hframes):
			var cur_icon := IconClass.instance()
			var cur_sprite := cur_icon.get_child(0).get_child(0)
			cur_sprite.frame_coords.y = y
			cur_sprite.frame_coords.x = x
			cur_icon.get_child(1).text = names[y*sprite.hframes + x]
			grid.add_child(cur_icon)
			icons.append(cur_icon)
	sprite.queue_free()


static func _levenshtein_distance(str1:String, str2:String)->int:
	str1 = str1.to_lower()
	str2 = str2.to_lower()
	var m:int = len(str1)
	var n:int = len(str2)
	var d: Array = []
	for i in range(1, m+1):
		d.append([i])
	d.insert(0, range(0, n+1))
	for j in range(1, n+1):
		for i in range(1, m+1):
			var substitution_cost: int
			if str1[i-1] == str2[j-1]:
				substitution_cost = 0
			else:
				substitution_cost = 1
			d[i].insert(j, min(min(
				d[i-1][j]+1,
				d[i][j-1]+1),
				d[i-1][j-1]+substitution_cost))
	return d[-1][-1]


func _on_LineEdit_text_changed(new_text):
	for child in grid.get_children():
		grid.remove_child(child)
		
	if new_text == "":
		for icon in icons:
			grid.add_child(icon)
	else:
		var order := []
		for i in range(icons.size()):
			var dist := _levenshtein_distance(new_text, icons[i].get_child(1).text)
			order.append([dist, i])
		order.sort_custom(DistanceSorter, "sort_dist")
		for i in range(order.size()):
			grid.add_child(icons[order[i][1]])
