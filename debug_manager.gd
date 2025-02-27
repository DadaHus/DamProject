extends Node

# 📝 Přepínač pro zapnutí/vypnutí debug výpisů
@export var enable_debug: bool = true

# 🎨 Debug pro ColorRect (vykreslování vody)
func debug_colorrect(height, position):
    if enable_debug:
        print("🎨 ColorRect update -> Height:", height, " Position:", position)

# 🌊 Debug pro vodní toky
func debug_waterflow(inflow, spillway_outflow, overflow_outflow, total_outflow):
    if enable_debug:
        print("🌊 Voda | Přítok:", inflow, "| Stavidlo:", spillway_outflow, "| Přepad:", overflow_outflow, "| Celkový odtok:", total_outflow)

# 🚰 Debug pro stavidlo
func debug_spillway(outflow, spillway_percentage):
    if enable_debug:
        print("🚰 Odtok stavidlem:", outflow, "| Stavidlo otevřeno na:", spillway_percentage, "/10")

# 🛠 Debug pro chybové hlášky
func debug_error(message):
    if enable_debug:
        print("🚨 CHYBA:", message)
