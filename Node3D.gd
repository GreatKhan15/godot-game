extends Node3D

@export var grid_size: int = 5
@export var spacing: float = 50.0
@export var max_size: Vector3 = Vector3(5, 30, 3)
@export var position_jitter: float = 5
@export var park_chance: float = 0.2


@export var waves: int = 30
@export var enemiesinwave: float = 14
@export var wavetimer: int = 30

@export var baseHealth: float = 100
@export var healthMultiply: float = 1.5

@export var baseEXP: float = 17
@export var expMultiply: float = 1.3

@export var ENEMYMASS = 8

var spawned: int = 0
var alive: int = 0
var currentWave :int = 1
var currentHealth
var currentEXP

var time_passed = 0.0

var rewardedExtraEXP = false

var bossRound = false
var bossSpawned = false

@onready var player = get_node("/root/Main scene/CharacterBody3D")
@onready var Canvas : CanvasLayer = get_node("/root/Main scene/CanvasLayer")
@onready var levelBar : ProgressBar = Canvas.get_node("Indicator/ProgressBar")
@onready var levelTimeCont : CenterContainer = Canvas.get_node("Indicator/CenterContainer")
@onready var levelTime : TextureProgressBar = Canvas.get_node("Indicator/CenterContainer/TextureProgressBar")
@onready var levelTimerText : Label = Canvas.get_node("Indicator/CenterContainer/Label")
@onready var levelCounter : Label = Canvas.get_node("Indicator/LevelContainer/LevelContainerLabel")

func _ready():
	randomize()
	generate_town()
	levelCounter.text = str(currentWave)
	currentHealth = baseHealth
	currentEXP = baseEXP

# Generate more complex town with different building types
func generate_town():
	for x in range(grid_size):
		for z in range(grid_size):
			if randf() < park_chance:
				continue

			var newbuilding
			var building_type = randf_range(0, 1)  # Randomly pick a building type
			
			if building_type < 0.33:
				newbuilding = preload("res://Bld1.tscn").instantiate()
				newbuilding.scale = Vector3(0.6,0.6,0.6)
			elif building_type < 0.66:
				newbuilding = preload("res://Bld2.tscn").instantiate()
				newbuilding.scale = Vector3(2,4,2)
			else:
				newbuilding = preload("res://Bld3.tscn").instantiate()
				newbuilding.scale = Vector3(20,20,20)

			# Random slight offset
			var offset_x = randf_range(-position_jitter, position_jitter)
			var offset_z = randf_range(-position_jitter, position_jitter)
			
			add_child(newbuilding)
			newbuilding.position = Vector3(x*spacing,0,z*spacing)


func _process(_delta):
	time_passed += _delta
	
	
	
	if !bossRound:
		if( spawned < enemiesinwave ):
			var enemy = RigidBody3D.new()
			enemy.set_meta("type","enemy")
			var enemyMeshinst = MeshInstance3D.new()
			
			var enemyMaterial = StandardMaterial3D.new()
			enemyMaterial.albedo_color = Color.RED
			
			var enemyMesh = BoxMesh.new()
			enemyMesh.material = enemyMaterial
			enemyMesh.size = Vector3(3,3,3)
			enemyMeshinst.mesh = enemyMesh
			
			var enemyCol = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.size = enemyMesh.size
			enemyCol.shape = box_shape
			
			enemy.transform.origin = Vector3(randf()*100, 50, randf()*100 )
			enemy.add_child(enemyCol)
			enemy.add_child(enemyMeshinst)
			enemy.mass = ENEMYMASS
			
			var hpBar = Sprite3D.new()
			hpBar.name = "hpBar"
			var hpText = GradientTexture2D.new()
			var grad = Gradient.new()
			grad.set_color(0,Color(0.8,0.2,0.2))
			grad.set_color(1,Color.RED)
			hpText.gradient = grad
			hpText.width = 300
			hpText.height = 30
			hpBar.set_meta("health",currentHealth)
			hpBar.set_meta("maxhealth",currentHealth)
			
			hpBar.texture = hpText
			hpBar.billboard = true
			enemy.add_child(hpBar)
			enemy.set_script(load("res://enemy_script.gd"))
			enemy.experience = currentEXP
			add_child(enemy)
			spawned += 1
			alive += 1
	#BossWave
	elif bossRound && !bossSpawned:
		var enemy = RigidBody3D.new()
		enemy.set_meta("type","enemy")
		var enemyMeshinst = MeshInstance3D.new()
		
		var enemyMaterial = StandardMaterial3D.new()
		enemyMaterial.albedo_color = Color(0.4,0.2,0.2)
		
		var enemyMesh = BoxMesh.new()
		enemyMesh.material = enemyMaterial
		enemyMesh.size = Vector3(40,50,40)
		enemyMeshinst.mesh = enemyMesh
		
		var enemyCol = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = enemyMesh.size
		enemyCol.shape = box_shape
		
		enemy.transform.origin = Vector3(randf()*100, 50, randf()*100 )
		enemy.add_child(enemyCol)
		enemy.add_child(enemyMeshinst)
		enemy.mass = ENEMYMASS
		
		var hpBar = Sprite3D.new()
		hpBar.name = "hpBar"
		var hpText = GradientTexture2D.new()
		var grad = Gradient.new()
		grad.set_color(0,Color(0.8,0.2,0.2))
		grad.set_color(1,Color.RED)
		hpText.gradient = grad
		hpText.width = 300
		hpText.height = 30
		hpBar.set_meta("health",currentHealth*20)
		hpBar.set_meta("maxhealth",currentHealth*20)
		
		hpBar.texture = hpText
		hpBar.billboard = true
		enemy.add_child(hpBar)
		enemy.set_script(load("res://enemy_script.gd"))
		enemy.experience = currentEXP
		add_child(enemy)
		spawned += 1
		alive += 1
		bossSpawned = true
		
	
	#Extra SP for finishing wave before 30 seconds
	if !rewardedExtraEXP && alive == 0 && time_passed < wavetimer - 1:
		rewardedExtraEXP = true
		player.addSP(3)
	
	#Go to next wave
	if time_passed >= wavetimer && alive == 0:
		time_passed = 0
		currentWave += 1
		if currentWave %2 == 0:
			bossSpawned = false
			bossRound = true
		else:
			bossRound = false
		currentHealth = currentHealth * healthMultiply
		currentEXP = currentEXP * expMultiply
		spawned = 0
		enemiesinwave =  round(enemiesinwave*1.3)
		levelCounter.text = str(currentWave)
		rewardedExtraEXP = false
	
	
	var timeLeft : int = wavetimer-time_passed
	if timeLeft >= 0:
		levelTimerText.text = str(timeLeft)
	else:
		levelTimerText.text = "Next level ready"
	var targetBar : float = (enemiesinwave - alive) * 100.0 / enemiesinwave
	levelBar.value = lerp(levelBar.value,targetBar,_delta*2)
	
	if levelBar.value + 0.5 < targetBar:
		levelBar.value += 0.5
		if targetBar - levelBar.value < 0.5 and targetBar - levelBar.value > 0:
			levelBar.value = targetBar
	if levelBar.value - 1 > targetBar:
		levelBar.value -= 1
		if levelBar.value - targetBar < 1 and levelBar.value - targetBar > 0:
			levelBar.value = targetBar
	if levelBar.value < 1 || levelBar.value == 1 && targetBar == 0:
		levelBar.value = 0
	levelTime.value = time_passed / wavetimer * 100
	
	if rewardedExtraEXP:
		if levelTimeCont.scale.x < 0.4:
			levelTimeCont.position.y -= 1
			levelTimeCont.scale.x += _delta/3
			levelTimeCont.scale.y += _delta/3
	else:
		if levelTimeCont.scale.x > 0.2:
			levelTimeCont.position.y += 1
			levelTimeCont.scale.x -= _delta/3
			levelTimeCont.scale.y -= _delta/3
	
