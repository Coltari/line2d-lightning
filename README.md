# line2d-lightning

![lightning](https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExZ2JpdTNnejB5bTY2ajl5ZW9maG1hamVuanltN2VtanM1bHczeGl3YiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/4Yq3ZpvUl73CJegpvT/giphy.gif)

quick demo for creating lightning effect using Line2D Node.

Feel free to use as you see fit.

## Usage

Lightning.tscn and lightning.gd are the key parts.

you can drop this scene into another project and instantiate it followed by a setup() then start() method call.

e.g.

	const LIGHTNING = preload("res://Lightning.tscn")
	
	var l = LIGHTNING.instantiate()
	l.setup(source.global_position,target.global_position,strands,points,accuracy,glow_intensity,lightningcolour,time)
	add_child(l)
	l.start()

time is an optional parameter, if you don't pass it, the lightning will continue until you call end() on it

if you want to change values at runtime, there are update methods available. 

In this project, we store the UI values in variables and then in _process we push changes to the lightning instances like so:

	func update_lighting() -> void:
		for child in lightning.get_children():
			child.update_source(source.position)
			child.update_target(target.position)
			child.update_strands(strands)
			child.update_points(points)
			child.update_accuracy(accuracy)
			child.update_glow(glow_intensity)
			child.update_colour(lightningcolour)
