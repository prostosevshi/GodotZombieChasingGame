extends Node3D

@onready var hit_rect = $UI/HitRect
@onready var spawns = $map/spawns
@onready var navigation_region = $map/NavigationRegion3D

@export var spawn_radius := 5.0

#var jen = load("res://Scripts/jen.gd")
var jen_scene = load("res://Scenes/jen.tscn") as PackedScene
var active_spawns = [] 
var instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_check_spawn_proximity()

# Проверяем, близко ли игрок к спавн-точке
func _check_spawn_proximity():
	var player_position = get_tree().get_root().get_node("/root/world/map/NavigationRegion3D/Player").global_position
	
	for spawn_point in spawns.get_children():
		if spawn_point in active_spawns:
			continue
			
		if player_position.distance_to(spawn_point.global_position) <= spawn_radius:
			_spawn_zombie(spawn_point)
			active_spawns.append(spawn_point)
			
func _spawn_zombie(spawn_point):
	var instance = jen_scene.instantiate()
	instance.position = spawn_point.global_position
	navigation_region.add_child(instance)
	
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = preload("res://sounds/sosal.mp3")
	audio_player.volume_db = 6
	instance.add_child(audio_player)
	
	audio_player.play()

func _on_player_player_hit() -> void:
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

#func _on_zombie_spawn_timer_timeout() -> void:
	var spawn_point = _get_random_child(spawns).global_position
	instance = jen_scene.instantiate()
	instance.position = spawn_point
	navigation_region.add_child(instance)
