extends Node2D  # Přehrada je 2D objekt

# Kapacita a stav vody
@export var max_capacity: float = 1000.0
@export var current_water_level: float = 500.0

# Ovládání stavidla
@export var spillway_percentage: float = 0.0  # 0.0 = zavřené, 1.0 = plně otevřené
@export var spillway_flow_rate: float = 50.0  # Maximální průtok stavidlem

# Propojení s řekami a dalšími přehradami
@export var input_river: NodePath  # Odkaz na přítok (InputRiver nebo jiná Prehrada)
@export var output_river: NodePath  # Odkaz na odtok (jiná Prehrada nebo OutputRiver)

var input_node: Node  # Odkaz na přítokový uzel
var output_node: Node  # Odkaz na výstupní uzel

func receive_water(amount: float):
    current_water_level += amount
    print("Přehrada přijala vodu:", amount, "| Nová hladina:", current_water_level)

func _ready():
    input_node = get_node_or_null(input_river)
    output_node = get_node_or_null(output_river)

    spillway_flow_rate = max_capacity / 20.0  
    print("Nastaven maximální průtok stavidlem na:", spillway_flow_rate)

func _process(delta: float):
    var inflow = collect_water(delta)
    var spillway_outflow = release_water(delta)
    var overflow_outflow = overflow()
    var total_outflow = spillway_outflow + overflow_outflow

# Přijímá vodu z `InputRiver` nebo jiné `Prehrada`
func collect_water(delta: float) -> float:
    if input_node and input_node.has_method("get_water_flow"):
        var inflow = input_node.get_water_flow() * delta
        print("Přijato vody:", inflow, "| Před úpravou hladina:", current_water_level)
        current_water_level += inflow
        print("Po úpravě hladina:", current_water_level, "/", max_capacity)
        return inflow
    else:
        print("Chyba: Přítokový uzel není dostupný nebo neobsahuje get_water_flow()!")
    return 0.0

func release_water(delta: float) -> float:
    if spillway_percentage > 0:
        var normalized_percentage = spillway_percentage / 10.0
        var outflow = spillway_flow_rate * normalized_percentage * delta
        outflow = min(outflow, current_water_level)

        current_water_level -= outflow

        if output_node and output_node.has_method("receive_water"):
            output_node.receive_water(outflow)

        print("Odtok stavidlem:", outflow, "| Stavidlo otevřeno na:", spillway_percentage, "/10")
        return outflow
    return 0.0

# Přepad vody, pokud je hladina nad kapacitou
func overflow() -> float:
    if current_water_level > max_capacity:
        var excess_water = current_water_level - max_capacity
        if output_node and output_node.has_method("receive_water"):
            output_node.receive_water(excess_water)
        current_water_level = max_capacity
        return excess_water
    return 0.0

func _on_spillway_value_changed(value: float):
    spillway_percentage = value / 10
    print("Stavidlo nastaveno na:", spillway_percentage)

func _on_spin_stavidlo_value_changed(value: float) -> void:
    spillway_percentage = value / 10
    print("Stavidlo nastaveno na:", spillway_percentage)
