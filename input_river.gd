extends Node

@export var flow_rate: float = 30.0  # Základní hodnota průtoku
@export_enum("static", "random", "weather") var flow_mode: String = "static"  # Výběr módu průtoku
@export var min_flow: float = 10.0  # Minimální průtok
@export var max_flow: float = 50.0  # Maximální průtok
@export var output_target: NodePath  # Cíl, kam řeka posílá vodu (např. `Prehrada` nebo `OutputRiver`)
@export var flow_delay: float = 1.0  # Prodleva v sekundách, než voda dorazí k dalšímu uzlu

var target_node: Node  # Odkaz na cílový uzel
var water_timer: Timer  # Timer pro odesílání vody

func _ready():
	# Uložíme si `output_target`, aby se nemusel hledat při každém snímku
	target_node = get_node_or_null(output_target)

	# Vytvoříme a nastavíme `Timer` pro odesílání vody
	water_timer = Timer.new()
	water_timer.wait_time = flow_delay
	water_timer.one_shot = false  # Bude běžet opakovaně
	water_timer.timeout.connect(_on_water_timer_timeout)
	add_child(water_timer)
	water_timer.start()  # Spustíme pravidelné odesílání vody

func _physics_process(delta: float):
	flow_rate = calculate_flow()  # Dynamicky aktualizujeme průtok

# Vrací aktuální průtok vody
func get_water_flow() -> float:
	return flow_rate

# Vypočítá průtok podle módu (`static`, `random`, `weather`)
func calculate_flow() -> float:
	match flow_mode:
		"static":
			return flow_rate  # Statická hodnota (ručně nastavená)
		"random":
			return randf_range(min_flow, max_flow)  # Náhodný průtok
		"weather":
			return calculate_weather_flow()  # Simulace průtoku podle počasí
		_:
			return flow_rate  # Fallback na statickou hodnotu

# Simulace průtoku podle počasí (budoucí implementace)
func calculate_weather_flow() -> float:
	return (sin(Time.get_ticks_msec() / 10000.0) + 1.0) * (max_flow - min_flow) / 2.0 + min_flow

# Odesílání vody na základě timeru (zabráníme spouštění při každém snímku)
func _on_water_timer_timeout():
	if target_node and target_node.has_method("receive_water"):  # Ověříme, že umí přijímat vodu
		var water_amount = flow_rate * water_timer.wait_time  
		target_node.receive_water(water_amount)  
		print("Posílám vodu do:", target_node.name, "| Množství:", water_amount, "| Interval:", water_timer.wait_time, "s")

# Aktualizace `output_target` během hry (když změníme cíl)
func update_target(new_target: NodePath):
	output_target = new_target
	target_node = get_node_or_null(output_target)
	print("Cíl toku aktualizován:", target_node.name if target_node else "Neplatný cíl")
