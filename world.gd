extends Node2D

@onready var level_completed = $CanvasLayer/LevelCompleted
@export var next_level: PackedScene
@onready var start_in = %StartIn
@onready var start_in_label = %StartInLabel
@onready var animation_player = $AnimationPlayer
@onready var level_time_label = %LevelTimeLabel
@onready var hearts_label = %HeartsLabel

var level_time = 0.0
var start_level_msec = 0.0
var max = 0

func _ready():
	if not next_level is PackedScene:
		level_completed.next_level_button.text = "Victory Screen"
		next_level = load('res://victory_screen.tscn')
	
	max = get_tree().get_nodes_in_group("Hearts").size()
	Events.level_completed.connect(show_level_completed)
	get_tree().paused = true
	start_in.visible = true
	LevelTransition.fade_from_black()
	animation_player.play("countdown")
	await animation_player.animation_finished
	get_tree().paused = false
	start_in.visible = false
	start_level_msec = Time.get_ticks_msec()
	
func _process(delta):
	level_time = Time.get_ticks_msec() - start_level_msec
	level_time_label.text = str(snappedf(level_time / 1000.0, 0.01), "s")
	var current_total = max - get_tree().get_nodes_in_group("Hearts").size()
	
	hearts_label.text = str(current_total, "/", max)

func retry():
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().reload_current_scene()
	

func go_to_next_level():
	if not next_level is PackedScene: return
	
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)

func show_level_completed():
	hearts_label.text = str(max, "/", max)
	level_completed.show()
	level_completed.retry_button.grab_focus()
	get_tree().paused = true

func _on_level_completed_retry():
	retry()


func _on_level_completed_next_level():
	go_to_next_level()
