extends Node2D

@export var time : float = 10.0 :
	set(value):
		time = value
@export var strands : int = 3
@export var points : int = 5
@export var glow_intensity : float = 2.5
@export var accuracy : int = 80

@onready var button: Button = %Button
@onready var time_slider: AttributeSlider = %TimeAttributeSlider
@onready var accuracy_slider: AttributeSlider = %AccuracyAttributeSlider
@onready var strands_slider: AttributeSlider = %StrandsAttributeSlider
@onready var points_slider: AttributeSlider = %PointsAttributeSlider
@onready var glow: AttributeSlider = %GlowAttributeSlider
@onready var color_picker: ColorPicker = %ColorPicker
@onready var lightning: Node2D = $Lightning

@onready var source: Sprite2D = $Source
@onready var s_area_2d: Area2D = $Source/Area2D
@onready var target: Sprite2D = $Target
@onready var t_area_2d: Area2D = $Target/Area2D

var sourcepicked : bool = false
var targetpicked : bool = false
var lightningcolour : Color

const LIGHTNING = preload("res://Lightning.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	s_area_2d.input_event.connect(source_grabbed)
	t_area_2d.input_event.connect(target_grabbed)
	glow.value = glow_intensity
	time_slider.value = time
	accuracy_slider.value = accuracy
	strands_slider.value = strands
	points_slider.value = points
	glow.minimum = 0.0
	glow.maximum = 10.0
	glow.value_changed.connect(glow_changed)
	button.button_down.connect(_on_button_button_down)
	time_slider.value_changed.connect(value_changed.bind("time"))
	accuracy_slider.value_changed.connect(value_changed.bind("accuracy"))
	strands_slider.value_changed.connect(value_changed.bind("strands"))
	points_slider.value_changed.connect(value_changed.bind("points"))
	color_picker.connect("color_changed",colour_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_lighting()

func stopemitting() -> void:
	for child in lightning.get_children():
		lightning.end()

func _on_button_button_down() -> void:
	var l = LIGHTNING.instantiate()
	l.setup(source.global_position,target.global_position,strands,points,accuracy,glow_intensity,lightningcolour,time)
	lightning.add_child(l)
	l.hit_something.connect(hit)
	l.start()

func hit(collider : Object) -> void:
	print("hit ", collider)

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

func colour_changed(colour : Color) -> void:
	lightningcolour = colour
	
func _unhandled_input(event: InputEvent) -> void:
	if sourcepicked and event is InputEventMouseMotion:
		source.position += event.relative
	if targetpicked and event is InputEventMouseMotion:
		target.position += event.relative

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

func update_lighting() -> void:
	for child in lightning.get_children():
		child.update_source(source.position)
		child.update_target(target.position)
		child.update_strands(strands)
		child.update_points(points)
		child.update_accuracy(accuracy)
		child.update_glow(glow_intensity)
		child.update_colour(lightningcolour)
