extends Control  # `StatusDisplay` je UI prvek

@onready var status_label = get_node_or_null("VBoxContainer/MarginContainer/StatusLabel")

# Metoda pro aktualizaci statusu přehrady
func update_status(current_level: float, max_capacity: float, inflow: float, spillway_outflow: float, overflow_outflow: float, total_outflow: float):
	if status_label:
		status_label.text = (
			"Stav přehrady\n"
			+ "Hladina: %.2f / %.2f\n" % [current_level, max_capacity]
			+ "Přítok: %.2f\n" % inflow
			+ "Odtok stavidlem: %.2f\n" % spillway_outflow
			+ "Odtok přepadem: %.2f\n" % overflow_outflow
			+ "Celkový odtok: %.2f\n" % total_outflow
		)
		print("Status aktualizován:", status_label.text)
