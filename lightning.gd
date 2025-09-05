extends Node2D

@export var emit : bool = false :
	set(value):
		emit = value
		if value:
			timer.start()
@export var time : float = 10.0 :
	set(value):
		time = value
		set_timer(value)
@export var strands : int = 3
@export var points : int = 5
@export var glow_intensity : float = 2.5
@export var accuracy : int = 80

@onready var timer: Timer = $Timer
@onready var lines: Node2D = $Lines
@onready var button: Button = %Button
@onready var time_slider: AttributeSlider = %TimeAttributeSlider
@onready var accuracy_slider: AttributeSlider = %AccuracyAttributeSlider
@onready var strands_slider: AttributeSlider = %StrandsAttributeSlider
@onready var points_slider: AttributeSlider = %PointsAttributeSlider
@onready var glow: AttributeSlider = %GlowAttributeSlider

@onready var source: Sprite2D = $Source
@onready var s_area_2d: Area2D = $Source/Area2D
@onready var target: Sprite2D = $Target
@onready var t_area_2d: Area2D = $Target/Area2D

var sourcepicked : bool = false
var targetpicked : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	s_area_2d.input_event.connect(source_grabbed)
	t_area_2d.input_event.connect(target_grabbed)
	glow.value = glow_intensity
	time_slider.value = time
	accuracy_slider.value = accuracy
	strands_slider.value = strands
	points_slider.value = points
	glow.value_changed.connect(glow_changed)
	button.button_down.connect(_on_button_button_down)
	time_slider.value_changed.connect(value_changed.bind("time"))
	accuracy_slider.value_changed.connect(value_changed.bind("accuracy"))
	strands_slider.value_changed.connect(value_changed.bind("strands"))
	points_slider.value_changed.connect(value_changed.bind("points"))
	timer.timeout.connect(stopemitting)
	timer.wait_time = time
	lines.position = source.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for c in lines.get_children():
		c.queue_free()
	if emit:
		##create line2d nodes
		for i in strands:
			var l = Line2D.new()
			lines.add_child(l)
			##add raw colour above HDR threshold so it glows
			l.default_color = Color(glow_intensity,glow_intensity,glow_intensity,1.0)
			##create a curve for adjusting the line thickness between points
			var c = Curve.new()
			##start at the beginning...
			l.add_point(Vector2(0,0))
			##figure out how long we need to be to reach the target
			var distancetotarget : Vector2 = target.global_position-source.global_position
			##set the value for the final point, based on target position +/- variance for accuracy
			var hitpoint : Vector2 = (target.global_position - source.global_position) + Vector2(randf_range(-(100-accuracy),(100-accuracy)),randf_range(-(100-accuracy),(100-accuracy)))
			##sample points randomly for the length of the line from a wave
			for x in points:
				##divide the distance by number of points +2 for the start and end
				var increment : Vector2 = distancetotarget / (points + 2)
				##traverse to this point in the sequence, +1 for the start point offset
				var p : Vector2 = (increment * (x +1))
				##add some variance to make the lines different
				var rand_variance : float = 0.0
				if x == 1:
					rand_variance = randf_range(0.0,75.0)
				else:
					rand_variance = randf_range(-75.0,250.0)
				p.x += rand_variance
				#scatter the Y based on wave
				var yrand_variance : float = randi_range(5,25)
				p.y += cos((delta*yrand_variance)+randf_range(0.75,2.0))*100
				##addpoints to curve and randomise the tangent a bit between -12 and 0
				c.add_point(Vector2(randf_range(0.0,1.0),randf_range(0.0,1.0)),randi_range(-12,0),randi_range(-12,0))
				l.width_curve = c
				##add points to line
				l.add_point(p)
			l.add_point(hitpoint)

func stopemitting() -> void:
	emit = false
	for child in lines.get_children():
		child.queue_free()

func set_timer(val: float):
	if timer:
		timer.wait_time = val

func _on_button_button_down() -> void:
	emit = true

func value_changed(value : float, prop : String) -> void:
	match prop:
		"time":
			time = float(value)
		"accuracy":
			accuracy = int(value)
		"strands":
			strands = int(value)
		"points":
			points = int(value)

func glow_changed(value : float) -> void:
	glow_intensity = value

func _unhandled_input(event: InputEvent) -> void:
	if sourcepicked and event is InputEventMouseMotion:
		source.position += event.relative
		lines.position = source.position
		#lines.look_at(target.position)
	if targetpicked and event is InputEventMouseMotion:
		target.position += event.relative
		#lines.look_at(target.position)

func source_grabbed(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		sourcepicked = true
	if event is InputEventMouseButton and not event.pressed:
		sourcepicked = false

func target_grabbed(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		targetpicked = true
	if event is InputEventMouseButton and not event.pressed:
		targetpicked = false
