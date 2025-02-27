extends Node2D  # 📌 Přehrada je 2D objekt

# 📦 Kapacita a stav vody
@export var max_capacity: float = 1000.0
@export var current_water_level: float = 500.0

# 🚰 Ovládání stavidla
@export var spillway_percentage: float = 0.0  # 0.0 = zavřené, 1.0 = plně otevřené
@export var spillway_flow_rate: float = 50.0  # Maximální průtok stavidlem

# 🔗 Propojení s řekami a dalšími přehradami
@export var input_river: NodePath  # Odkaz na přítok (InputRiver nebo jiná Prehrada)
@export var output_river: NodePath  # Odkaz na odtok (jiná Prehrada nebo OutputRiver)


# 🎇 Vizuální prvky
@onready var water_visual = get_node_or_null("ColorRect")
@onready var status_display = get_node_or_null("StatusDisplay")
@onready var spillway_particles = get_node_or_null("SpillwayParticles")
@onready var overflow_particles = get_node_or_null("OverflowParticles")
@onready var spin_stavidlo = get_node_or_null("StatusDisplay/VBoxContainer/SpinStavidlo") 




var input_node: Node  # 🔗 Odkaz na přítokový uzel
var output_node: Node  # 🔗 Odkaz na výstupní uzel

func receive_water(amount: float):
    current_water_level += amount
    print("🌊 Přehrada přijala vodu:", amount, "| Nová hladina:", current_water_level)

func _ready():
    input_node = get_node_or_null(input_river)
    output_node = get_node_or_null(output_river)

    spillway_flow_rate = max_capacity / 20.0  
    print("🔄 Nastaven maximální průtok stavidlem na:", spillway_flow_rate)

    # ✅ Propojení SpinBox se stavidlem
    if spin_stavidlo:
        spin_stavidlo.value = spillway_percentage * 100  # 🔄 Nastavení výchozí hodnoty
        spin_stavidlo.value_changed.connect(_on_spillway_value_changed)
        print("✅ SpinBox propojen! Výchozí hodnota:", spin_stavidlo.value)

    # Ověříme status_display
    status_display = get_node_or_null("StatusDisplay")
    if not status_display:
        status_display = find_child("StatusDisplay", true, false)  # 🔥 Hledáme ve všech dětech
        if status_display:
            print("✅ StatusDisplay nalezen pomocí find_child()!")
        else:
            print("🚨 FATÁLNÍ CHYBA: StatusDisplay nebyl nalezen!")


# Ověříme status_display

func _process(delta: float):
# 🌊 Přítok vody
var inflow = collect_water(delta)

# 🚰 Odtoky
var spillway_outflow = release_water(delta)  # Odtok stavidlem
var overflow_outflow = overflow()  # Odtok přepadem
var total_outflow = spillway_outflow + overflow_outflow  # Celkový odtok

# 🎇 Ovládání částic pro každý typ odtoku
update_particles(spillway_outflow, overflow_outflow)

# 🌊 Aktualizace vizuální hladiny vody
update_visuals()

# 📊 Aktualizace UI statusu
update_status_display(inflow, spillway_outflow, overflow_outflow, total_outflow)

# 📌 Aktualizace vizuální části přehrady
queue_redraw()

# 📌 Přijímá vodu z `InputRiver` nebo jiné `Prehrada`
func collect_water(delta: float) -> float:
if input_node and input_node.has_method("get_water_flow"):
	var inflow = input_node.get_water_flow() * delta
	print("🌊 Přijato vody:", inflow, "🌊 Před úpravou hladina:", current_water_level)
	current_water_level += inflow  # ✅ Umožníme hladině přetéct
# ✅ Umožníme hladině jít nad max_capacity
	print("🌊 Po úpravě hladina:", current_water_level, "/", max_capacity)
	return inflow
else:
	print("🚨 Chyba: Přítokový uzel není dostupný nebo neobsahuje get_water_flow()!")
return 0.0

func release_water(delta: float) -> float:
	if spillway_percentage > 0:
		var normalized_percentage = spillway_percentage / 10.0
		var outflow = spillway_flow_rate * normalized_percentage * delta
		outflow = min(outflow, current_water_level)  # ✅ Zajistíme, že neodteče víc, než máme

current_water_level -= outflow

    # ✅ Pokud je elektrárna připojená, pošleme jí vodu ze stavidla
		if hydro_node and hydro_node.has_method("receive_water"):
			 hydro_node.receive_water(outflow, true)  # ✅ `true` = voda je ze stavidla
		 else:
        # Pokud není elektrárna, pošleme vodu dál hlavním výstupem
			if main_node and main_node.has_method("receive_water"):
				main_node.receive_water(outflow, true)  

		print("🚰 Odtok stavidlem:", outflow, "| Stavidlo otevřeno na:", spillway_percentage, "/10")
    
	return outflow  # ✅ Musí být ve správném bloku
return 0.0  # ✅ Tento `return` se provede, jen pokud stavidlo není otevřené




# 📌 Přepad vody, pokud je hladina nad kapacitou
func overflow() -> float:
if current_water_level > max_capacity:
	 var excess_water = current_water_level - max_capacity
	output_node.receive_water(excess_water)  # 💧 Posíláme přepad dál
	current_water_level = max_capacity
# ✅ Přepad vždy teče hlavním výstupem
if main_node and main_node.has_method("receive_water"):
	if main_node and main_node.has_method("receive_water"):
	return excess_water
return 0.0

# 📌 Ovládání částicového efektu odtoku a přepadu
func update_particles(spillway_outflow: float, overflow_outflow: float):
if spillway_particles:
	spillway_particles.emitting = spillway_outflow > 0
if overflow_particles:
	overflow_particles.emitting = overflow_outflow > 0

# 📌 Aktualizace vizuální hladiny vody
func update_visuals():
if water_visual:
	var water_height = (current_water_level / max_capacity) * 150
	water_visual.size = Vector2(200, water_height)
	water_visual.position = Vector2(0, 150 - water_height)

# # 📌 Aktualizace UI statusu
func update_status_display(inflow, spillway_outflow, overflow_outflow, total_outflow):
if status_display:
	status_display.update_status(
		current_water_level, max_capacity, inflow, spillway_outflow, overflow_outflow, total_outflow)
		
func _on_spillway_value_changed(value: float):
spillway_percentage = value / 10  # 🔄 Převod zpět na rozsah 0.0 - 1.0
print("🎚 Stavidlo nastaveno na:", spillway_percentage)


func _on_spin_stavidlo_value_changed(value: float) -> void:
spillway_percentage = value / 10  # 🔄 Převod zpět na rozsah 0.0 - 1.0
print("🎚 Stavidlo nastaveno na:", spillway_percentage)
