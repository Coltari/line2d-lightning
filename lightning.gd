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
@export var strandlength : int = 5
@export var strands : int = 5
@export var points : int = 10
@export var glow_intensity : float = 2.5

@onready var timer: Timer = $Timer
@onready var lines: Node2D = $Lines
@onready var button: Button = $VBoxContainer/Button
@onready var ltime: LineEdit = $VBoxContainer/time
@onready var length: LineEdit = $VBoxContainer/length
@onready var lstrands: LineEdit = $VBoxContainer/strands
@onready var lpoints: LineEdit = $VBoxContainer/points
@onready var glow: HSlider = $VBoxContainer/glow

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
	ltime.text = str(time)
	length.text = str(strandlength)
	lstrands.text = str(strands)
	lpoints.text = str(points)
	glow.value_changed.connect(glow_changed)
	button.button_down.connect(_on_button_button_down)
	ltime.text_changed.connect(value_changed.bind("time"))
	length.text_changed.connect(value_changed.bind("length"))
	lstrands.text_changed.connect(value_changed.bind("strands"))
	lpoints.text_changed.connect(value_changed.bind("points"))
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
			##create a curve for the line thickness between points as well
			var c = Curve.new()
			##sample points randomly for the length of the line from a sine wave
			var lastPoint : Vector2 = Vector2(0,0)
			l.add_point(lastPoint)
			for x in points:
				##add some variance to make the lines different
				var rand_variance : int = randi_range(5,25)
				var p : Vector2 = Vector2(sin((delta*rand_variance)+x)*(20*strandlength),cos((delta*rand_variance)+randf_range(0.75,2.0))*(20*strandlength))
				if p.x < lastPoint.x:
					p.x = lastPoint.x + (randf_range(5.0,10.0) * strandlength)
				##addpoints to curve and randomise the tangent a bit between -12 and 0
				c.add_point(Vector2(randf_range(0.0,1.0),randf_range(0.0,1.0)),randi_range(-12,0),randi_range(-12,0))
				l.width_curve = c
				##add points to line
				l.add_point(p)
				lastPoint = p

func stopemitting():
	emit = false
	for child in lines.get_children():
		child.queue_free()

func set_timer(val: float):
	if timer:
		timer.wait_time = val

func _on_button_button_down() -> void:
	emit = true

func value_changed(value : String, prop : String) -> void:
	match prop:
		"time":
			time = float(value)
		"length":
			strandlength = int(value)
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
		lines.look_at(target.position)
	if targetpicked and event is InputEventMouseMotion:
		target.position += event.relative
		lines.look_at(target.position)

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
