import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, ax = plt.subplots(figsize=(15, 9), dpi=300)
ax.set_xlim(0, 150)
ax.set_ylim(0, 100)
ax.axis('off')

# Title
ax.text(75, 96, "Vivado RTL Schematic: top_memory_system (Artix-7 xc7a35tcpg236-1)", 
        fontsize=15, fontweight='bold', ha='center', va='center', color='#1A365D')

# Top System Boundary
top_rect = patches.FancyBboxPatch((5, 5), 140, 87, boxstyle="round,pad=1", 
                                 facecolor="#FFFFFF", edgecolor="#2B6CB0", linewidth=2.5)
ax.add_patch(top_rect)
ax.text(8, 89, "top_memory_system", fontsize=12, fontweight='bold', color="#2B6CB0")

# 1. Debouncer
db_rect = patches.FancyBboxPatch((12, 60), 22, 20, boxstyle="round,pad=0.5", 
                                facecolor="#EDF2F7", edgecolor="#4A5568", linewidth=1.5)
ax.add_patch(db_rect)
ax.text(23, 73, "btn_db\n(debouncer)", fontsize=10, fontweight='bold', ha='center', va='center')
ax.text(14, 65, "pbin \u25BA", fontsize=8)
ax.text(32, 65, "\u25BA pbout", fontsize=8, ha='right')

# 2. Clock Divider
clk_rect = patches.FancyBboxPatch((12, 30), 22, 20, boxstyle="round,pad=0.5", 
                                 facecolor="#EDF2F7", edgecolor="#4A5568", linewidth=1.5)
ax.add_patch(clk_rect)
ax.text(23, 43, "ticker\n(clock_divider)", fontsize=10, fontweight='bold', ha='center', va='center')
ax.text(14, 35, "clk \u25BA", fontsize=8)
ax.text(32, 35, "\u25BA clk_out", fontsize=8, ha='right')

# 3. FSM & Controller Logic
fsm_rect = patches.FancyBboxPatch((40, 30), 25, 50, boxstyle="round,pad=0.5", 
                                 facecolor="#EBF8FF", edgecolor="#3182CE", linewidth=1.5)
ax.add_patch(fsm_rect)
ax.text(52.5, 68, "Control Unit\n& FSM Logic", fontsize=11, fontweight='bold', ha='center', va='center', color="#2B6CB0")
ax.text(42, 55, "\u25BA step_event", fontsize=8)
ax.text(42, 45, "\u25BA physical_sw", fontsize=8)
ax.text(63, 60, "cpu_addr \u25BA", fontsize=8, ha='right')
ax.text(63, 52, "cpu_wd \u25BA", fontsize=8, ha='right')
ax.text(63, 44, "read/write_en \u25BA", fontsize=8, ha='right')
ax.text(63, 36, "\u25C4 read_data", fontsize=8, ha='right')

# 4. Memory Subsystem (addressDecoderTop)
sub_rect = patches.FancyBboxPatch((72, 25), 45, 58, boxstyle="round,pad=0.8", 
                                 facecolor="#FEFCBF", edgecolor="#D69E2E", linewidth=2)
ax.add_patch(sub_rect)
ax.text(94.5, 80, "mem_subsystem (addressDecoderTop)", fontsize=11, fontweight='bold', ha='center', va='center', color="#B7791F")

# Submodules inside addressDecoderTop
ax.add_patch(patches.Rectangle((75, 57), 18, 18, facecolor="#EBF8FF", edgecolor="#3182CE", lw=1))
ax.text(84, 66, "Address\nDecoder", fontsize=8.5, ha='center', va='center', fontweight='bold')

ax.add_patch(patches.Rectangle((97, 57), 18, 18, facecolor="#FFFFF0", edgecolor="#B7791F", lw=1))
ax.text(106, 66, "Data\nMemory\n(512x32)", fontsize=8, ha='center', va='center', fontweight='bold')

ax.add_patch(patches.Rectangle((75, 32), 18, 18, facecolor="#FED7D7", edgecolor="#E53E3E", lw=1))
ax.text(84, 41, "LED\nInterface", fontsize=8.5, ha='center', va='center', fontweight='bold')

ax.add_patch(patches.Rectangle((97, 32), 18, 18, facecolor="#C6F6D5", edgecolor="#38A169", lw=1))
ax.text(106, 41, "Switch\nInterface", fontsize=8.5, ha='center', va='center', fontweight='bold')

# 5. Seven-Segment Controller
seg_rect = patches.FancyBboxPatch((122, 50), 20, 28, boxstyle="round,pad=0.5", 
                                 facecolor="#EDF2F7", edgecolor="#4A5568", linewidth=1.5)
ax.add_patch(seg_rect)
ax.text(132, 68, "seg_display\n(7-seg ctrl)", fontsize=9.5, fontweight='bold', ha='center', va='center')
ax.text(124, 58, "\u25BA opcode", fontsize=8)
ax.text(140, 60, "seg[6:0] \u25BA", fontsize=8, ha='right')
ax.text(140, 54, "an[3:0] \u25BA", fontsize=8, ha='right')

# 6. Physical Pins & Connectors
ax.annotate("", xy=(12, 70), xytext=(2, 70), arrowprops=dict(arrowstyle="->", lw=1.5))
ax.text(1, 70, "pbin (U18)", fontsize=8, ha='right', va='center', fontweight='bold')

ax.annotate("", xy=(12, 40), xytext=(2, 40), arrowprops=dict(arrowstyle="->", lw=1.5))
ax.text(1, 40, "clk (W5)", fontsize=8, ha='right', va='center', fontweight='bold')

ax.annotate("", xy=(40, 48), xytext=(2, 48), arrowprops=dict(arrowstyle="->", lw=1.5))
ax.text(1, 48, "SW[15:0]", fontsize=8, ha='right', va='center', fontweight='bold')

ax.annotate("", xy=(40, 70), xytext=(34, 70), arrowprops=dict(arrowstyle="->", lw=1.5))
ax.annotate("", xy=(40, 40), xytext=(34, 40), arrowprops=dict(arrowstyle="->", lw=1.5))

ax.annotate("", xy=(72, 65), xytext=(65, 65), arrowprops=dict(arrowstyle="->", lw=2, color="#2B6CB0"))
ax.annotate("", xy=(65, 36), xytext=(72, 36), arrowprops=dict(arrowstyle="->", lw=2, color="#C53030"))

ax.annotate("", xy=(122, 60), xytext=(65, 60), arrowprops=dict(arrowstyle="->", lw=1.5))

ax.annotate("", xy=(148, 41), xytext=(93, 41), arrowprops=dict(arrowstyle="->", lw=2, color="#E53E3E"))
ax.text(149, 41, "LED[15:0] (U16..L1)", fontsize=8, ha='left', va='center', fontweight='bold', color="#E53E3E")

ax.annotate("", xy=(148, 60), xytext=(142, 60), arrowprops=dict(arrowstyle="->", lw=1.5))
ax.text(149, 60, "seg[6:0], an[3:0]", fontsize=8, ha='left', va='center', fontweight='bold')

plt.tight_layout()
plt.savefig('lab08_rtl_schematic.png', dpi=300, bbox_inches='tight')
print("Successfully generated lab08_rtl_schematic.png")
