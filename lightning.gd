extends Node2D

@onready var period: Timer = $Period
@onready var bolts: Node2D = $Bolts
@onready var rays: Node2D = $Rays

var starting : bool = false
var ending : bool = false
var toggle : bool = false
var on : bool = false
var time : float = 0.0
var ticktimer : float = 0.0
var damagetimer : float = 0.0

var source : Vector2 
var target : Vector2
var strands : int
var points : int
var accuracy : int
var glow : float
var colour : Color
var lifetime : float
var damagetick : float

var startcount: int = 0
var endcount : int = 0

signal hit_something(collider : Object)

func setup(source : Vector2, target : Vector2, strands : int, points : int, accuracy : int, glow : float, colour : Color, _lifetime : float = -1, _damagetick : float = 1.0) -> void:
	self.global_position = source
	self.source = source
	self.target = target
	self.strands = strands
	self.points = points
	self.accuracy = accuracy
	self.glow = glow
	self.colour = colour
	if _lifetime > 0:
		toggle = false
		lifetime = _lifetime
	else:
		toggle = true
	self.damagetick = _damagetick

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	period.timeout.connect(end)
	if !toggle:
		period.wait_time = lifetime

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	if on:
		draw_lines()
		check_ray_collision()
		ticktimer += delta
		if ticktimer > 0.025:
			timer_tick()
			ticktimer = 0.0
		damagetimer += delta
		if damagetimer >= damagetick:
			damagetimer = 0.0 
	else:
		queue_free()

#on start
func start() -> void:
	starting = true
	on = true
	if !toggle:
		period.start()

func generate_points() -> Array:
	var result : Array
	##start at the beginning...
	if !ending:
		result.append(Vector2(0,0))
	##figure out how long we need to be to reach the target
	var distancetotarget : Vector2 = target-source
	##set the value for the final point, based on target position +/- variance for accuracy
	var hitpoint : Vector2 = (target - source) + Vector2(randf_range(-(100-accuracy),(100-accuracy)),randf_range(-(100-accuracy),(100-accuracy)))
	##sample points randomly for the length of the line from a wave
	for x in points:
		##divide the distance by number of points +2 for the start and end
		var increment : Vector2 = distancetotarget / (points + 2)
		##traverse to this point in the sequence, +1 for the start point offset
		var p : Vector2 = (increment * (x +1))
		##add some variance to make the lines different
		var rand_variance : float = 0.0
		#these numbers are arbitrary, tweak to see what feels good.
		if x == 1:
			if increment.x > 0:
				rand_variance = randf_range(0.0,75.0)
			else:
				rand_variance = randf_range(-75.0,0.0)
		else:
			if increment.x > 0:
				rand_variance = randf_range(-75.0,250.0)
			else:
				rand_variance = randf_range(-250.0,75.0)
		p.x += rand_variance
		#scatter the Y based on wave
		var yrand_variance : float = randi_range(5,25)
		p.y += cos((time*yrand_variance)+randf_range(0.75,2.0))*100
		##add points to line
		if starting:
			if x <= startcount:
				result.append(p)
		elif ending:
			if x >= endcount:
				result.append(p)
		else:
			result.append(p)
	if !starting:
		result.append(hitpoint)
	return result

func draw_lines() -> void:
	for child in bolts.get_children():
		child.queue_free()
	for child in rays.get_children():
		child.queue_free()
	##create line2d nodes
	for i in strands:
		var l = Line2D.new()
		bolts.add_child(l)
		##add raw colour above HDR threshold so it glows
		l.default_color = colour + Color(glow,glow,glow,1.0)
		##create a curve for adjusting the line thickness between points
		var c = Curve.new()
		for x in points:
			##addpoints to curve and randomise the tangent a bit between -12 and 0
			c.add_point(Vector2(randf_range(0.0,1.0),randf_range(0.0,1.0)),randi_range(-12,0),randi_range(-12,0))
		l.width_curve = c
		var last_point : Vector2
		var line_points = generate_points()
		for p in line_points:
			l.add_point(p)
			#if last_point not null, create ray cast
			if last_point:
				var r = RayCast2D.new()
				rays.add_child(r)
				r.position = last_point
				r.set_collide_with_areas(true)
				r.set_collide_with_bodies(true)
				r.set_target_position(p-last_point)
			last_point = p

func check_ray_collision() -> void:
	for r in rays.get_children():
		if r.is_colliding():
			hit_something.emit(r.get_collider())
			break

func timer_tick() -> void:
	if starting:
		startcount+=1
		if startcount == points:
			starting = false
	if ending:
		endcount+=1
		if endcount == points:
			ending = false
			on = false

func end() -> void:
	ending = true

func update_source(source: Vector2) -> void:
	self.source = source
	self.global_position = source

func update_target(target: Vector2) -> void:
	self.target = target

func update_strands(lines : int) -> void:
	self.strands = lines

func update_points(points : int) -> void:
	self.points = points

func update_accuracy(accuracy : int) -> void:
	self.accuracy = accuracy

func update_glow(glow : float) -> void:
	self.glow = glow

func update_colour(colour : Color) -> void:
	self.colour = colour
