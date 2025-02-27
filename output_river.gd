extends Node2D

@export var target_dam: NodePath  # Odkaz na cílovou přehradu
var target_node: Node  # Skutečný uzel přehrady

func _ready():
    target_node = get_node_or_null(target_dam)
    if target_node:
        print("✅ OutputRiver připojeno k:", target_node.name)
    else:
        print("⚠️ OutputRiver nemá připojenou přehradu – voda odtéká pryč.")

# 📌 Přijme vodu a rozhodne, co s ní
func receive_water(amount: float):
    if target_node and target_node.has_method("receive_water"):
        target_node.receive_water(amount)  # 💧 Pošleme vodu do přehrady
        print("💦 OutputRiver posílá vodu do:", target_node.name, "| Množství:", amount)
    else:
        print("🌊 Voda odtéká pryč! Množství:", amount)  # 🌊 Voda se "ztrácí"
