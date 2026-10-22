import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Set up figure
fig, ax = plt.subplots(figsize=(14, 10), dpi=300)
ax.set_xlim(0, 140)
ax.set_ylim(0, 100)
ax.axis('off')

# Title
ax.text(70, 96, "Lab 08: Memory System Architecture & Block Diagram", 
        fontsize=16, fontweight='bold', ha='center', va='center', color='#1A365D')

# -------------------------------------------------------------
# Top Module Border (addressDecoderTop)
# -------------------------------------------------------------
top_box = patches.FancyBboxPatch((28, 6), 108, 86, boxstyle="round,pad=1.5", 
                                facecolor="#F7FAFC", edgecolor="#4A5568", linewidth=2, linestyle='--')
ax.add_patch(top_box)
ax.text(32, 89, "addressDecoderTop (Top Module)", fontsize=13, fontweight='bold', color="#2D3748")

# -------------------------------------------------------------
# CPU Interface (Left side)
# -------------------------------------------------------------
cpu_box = patches.FancyBboxPatch((2, 25), 20, 50, boxstyle="round,pad=1", 
                                facecolor="#EDF2F7", edgecolor="#2B6CB0", linewidth=2)
ax.add_patch(cpu_box)
ax.text(12, 68, "RISC-V CPU\nCore", fontsize=12, fontweight='bold', ha='center', va='center', color="#2B6CB0")

# CPU signals
ax.text(20, 60, "address[31:0] \u25BA", fontsize=9, ha='right', va='center', fontweight='bold')
ax.text(20, 52, "writeData[31:0] \u25BA", fontsize=9, ha='right', va='center', fontweight='bold')
ax.text(20, 44, "writeEnable \u25BA", fontsize=9, ha='right', va='center', fontweight='bold')
ax.text(20, 36, "readEnable \u25BA", fontsize=9, ha='right', va='center', fontweight='bold')
ax.text(20, 28, "\u25C4 readData[31:0]", fontsize=9, ha='right', va='center', fontweight='bold', color='#C53030')

# -------------------------------------------------------------
# Module b) Address Decoder
# -------------------------------------------------------------
dec_box = patches.FancyBboxPatch((35, 40), 24, 42, boxstyle="round,pad=1", 
                                 facecolor="#EBF8FF", edgecolor="#3182CE", linewidth=2)
ax.add_patch(dec_box)
ax.text(47, 78, "b) Address Decoder", fontsize=11, fontweight='bold', ha='center', va='center', color="#2B6CB0")
ax.text(47, 72, "AddressDecoder.v\nDecodes address[9:8]", fontsize=8, ha='center', va='center', style='italic', color="#4A5568")

# Decoder outputs labels
ax.text(58, 64, "DataMemWrite \u25BA", fontsize=8, ha='right', va='center', fontweight='bold')
ax.text(58, 56, "DataMemRead \u25BA", fontsize=8, ha='right', va='center', fontweight='bold')
ax.text(58, 48, "LEDWrite \u25BA", fontsize=8, ha='right', va='center', fontweight='bold')
ax.text(58, 42, "SwitchReadEnable \u25BA", fontsize=8, ha='right', va='center', fontweight='bold')

# -------------------------------------------------------------
# Module a) Data Memory Module
# -------------------------------------------------------------
mem_box = patches.FancyBboxPatch((70, 56), 28, 28, boxstyle="round,pad=1", 
                                 facecolor="#FEFCBF", edgecolor="#D69E2E", linewidth=2)
ax.add_patch(mem_box)
ax.text(84, 80, "a) Data Memory Module", fontsize=11, fontweight='bold', ha='center', va='center', color="#B7791F")
ax.text(84, 75, "DataMemory.v (512 x 32 RAM)", fontsize=8.5, ha='center', va='center', style='italic')
ax.text(72, 70, "\u25BA address[8:0]", fontsize=8, ha='left', va='center')
ax.text(72, 65, "\u25BA write_data[31:0]", fontsize=8, ha='left', va='center')
ax.text(72, 60, "\u25BA MemWrite, MemRead", fontsize=8, ha='left', va='center')
ax.text(96, 65, "read_data[31:0] \u25BA", fontsize=8, ha='right', va='center', fontweight='bold')

# -------------------------------------------------------------
# LEDs Peripheral Module
# -------------------------------------------------------------
led_box = patches.FancyBboxPatch((70, 34), 28, 16, boxstyle="round,pad=1", 
                                 facecolor="#FED7D7", edgecolor="#E53E3E", linewidth=2)
ax.add_patch(led_box)
ax.text(84, 46, "LED Interface (leds.v)", fontsize=10, fontweight='bold', ha='center', va='center', color="#9B2C2C")
ax.text(72, 40, "\u25BA writeData[15:0]", fontsize=8, ha='left', va='center')
ax.text(72, 36, "\u25BA LEDWrite (gating)", fontsize=8, ha='left', va='center')
ax.text(96, 38, "physical_leds[15:0] \u25BA", fontsize=8, ha='right', va='center', fontweight='bold')

# -------------------------------------------------------------
# Switches Peripheral Module
# -------------------------------------------------------------
sw_box = patches.FancyBboxPatch((70, 12), 28, 16, boxstyle="round,pad=1", 
                                facecolor="#C6F6D5", edgecolor="#38A169", linewidth=2)
ax.add_patch(sw_box)
ax.text(84, 24, "Switch Interface (switches.v)", fontsize=10, fontweight='bold', ha='center', va='center', color="#22543D")
ax.text(72, 18, "\u25BA physical_sw[15:0]", fontsize=8, ha='left', va='center')
ax.text(96, 18, "switch_data[31:0] \u25BA", fontsize=8, ha='right', va='center', fontweight='bold')

# -------------------------------------------------------------
# Read Multiplexer
# -------------------------------------------------------------
mux_pts = [[108, 25], [116, 32], [116, 72], [108, 79]]
mux_poly = patches.Polygon(mux_pts, closed=True, facecolor="#E2E8F0", edgecolor="#4A5568", linewidth=2)
ax.add_patch(mux_poly)
ax.text(112, 52, "Read\nMUX", fontsize=9, fontweight='bold', ha='center', va='center')

# -------------------------------------------------------------
# Signal Arrows & Connections
# -------------------------------------------------------------
# CPU address[9:8] to Decoder
ax.annotate("", xy=(35, 60), xytext=(22, 60),
            arrowprops=dict(arrowstyle="->", color="#2B6CB0", lw=2))
ax.text(28, 62, "address[9:8]", fontsize=7.5, ha='center', color="#2B6CB0", fontweight='bold')

# CPU read/write enables to Decoder
ax.annotate("", xy=(35, 46), xytext=(22, 46),
            arrowprops=dict(arrowstyle="->", color="#4A5568", lw=1.5))

# Address bus to Data Memory
ax.annotate("", xy=(70, 70), xytext=(25, 70),
            arrowprops=dict(arrowstyle="->", color="#D69E2E", lw=1.5))
ax.plot([25, 25], [60, 70], color="#D69E2E", lw=1.5)
ax.text(48, 71, "address[8:0]", fontsize=7.5, color="#B7791F", fontweight='bold')

# writeData to Data Memory and LEDs
ax.annotate("", xy=(70, 65), xytext=(26, 65),
            arrowprops=dict(arrowstyle="->", color="#4A5568", lw=1.5))
ax.plot([26, 26], [52, 65], color="#4A5568", lw=1.5)
ax.annotate("", xy=(70, 40), xytext=(26, 40),
            arrowprops=dict(arrowstyle="->", color="#4A5568", lw=1.5))
ax.plot([26, 26], [40, 52], color="#4A5568", lw=1.5)

# Decoder enables to Data Memory
ax.annotate("", xy=(70, 60), xytext=(59, 60),
            arrowprops=dict(arrowstyle="->", color="#3182CE", lw=1.5))

# Decoder LEDWrite to LEDs
ax.annotate("", xy=(70, 36), xytext=(59, 48),
            arrowprops=dict(arrowstyle="->", color="#E53E3E", lw=1.5))

# Decoder SwitchReadEnable to MUX select
ax.annotate("", xy=(112, 23), xytext=(59, 42),
            arrowprops=dict(arrowstyle="->", color="#38A169", lw=1.2, linestyle='--'))
ax.text(80, 28, "Device Select (address[9:8])", fontsize=7.5, color="#4A5568", style='italic')

# Memory read_data to MUX
ax.annotate("", xy=(108, 65), xytext=(98, 65),
            arrowprops=dict(arrowstyle="->", color="#D69E2E", lw=2))

# Switch data to MUX
ax.annotate("", xy=(108, 35), xytext=(98, 18),
            arrowprops=dict(arrowstyle="->", color="#38A169", lw=2))

# MUX output to CPU readData
ax.annotate("", xy=(22, 28), xytext=(116, 52),
            arrowprops=dict(arrowstyle="->", color="#C53030", lw=2))
ax.text(60, 4, "\u25C4 readData[31:0] (from DataMemory or Switches)", fontsize=9, fontweight='bold', color="#C53030")

# Physical IO Ports on Right
ax.text(128, 38, "\u25BA 16 LEDs", fontsize=10, fontweight='bold', color="#E53E3E")
ax.annotate("", xy=(126, 38), xytext=(98, 38),
            arrowprops=dict(arrowstyle="->", color="#E53E3E", lw=2))

ax.text(128, 18, "\u25C4 16 Switches", fontsize=10, fontweight='bold', color="#38A169")
ax.annotate("", xy=(70, 18), xytext=(126, 18),
            arrowprops=dict(arrowstyle="->", color="#38A169", lw=2))

plt.tight_layout()
plt.savefig('lab08_block_diagram.png', dpi=300, bbox_inches='tight')
print("Successfully generated lab08_block_diagram.png")
