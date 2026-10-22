import matplotlib.pyplot as plt
import numpy as np

# Parse waveform.vcd
with open('waveform.vcd', 'r') as f:
    vcd_lines = f.readlines()

# Map identifiers
id_map = {}
for line in vcd_lines:
    parts = line.strip().split()
    if len(parts) >= 4 and parts[0] == '$var':
        # $var reg 1 ! clk $end
        # $var wire 32 ( readData [31:0] $end
        var_type = parts[1]
        size = parts[2]
        var_id = parts[3]
        name = parts[4]
        if name not in id_map:
            id_map[var_id] = name

# Parse values over time
time_events = []
current_time = 0
current_vals = {name: '0' for name in id_map.values()}

# Target signals in display order
target_signals = ['clk', 'rst', 'address', 'writeEnable', 'writeData', 'readEnable', 'readData', 'switches', 'leds']

timeline = []
for line in vcd_lines:
    line = line.strip()
    if not line:
        continue
    if line.startswith('#'):
        current_time = int(line[1:]) // 1000  # convert ps to ns
    elif line.startswith('b'):
        # Bus value e.g. b10101010 &
        parts = line.split()
        val = parts[0][1:]
        var_id = parts[1]
        if var_id in id_map:
            name = id_map[var_id]
            current_vals[name] = hex(int(val, 2))[2:].upper()
            timeline.append((current_time, dict(current_vals)))
    elif len(line) >= 2 and line[0] in ['0', '1', 'x', 'z']:
        val = line[0]
        var_id = line[1:]
        if var_id in id_map:
            name = id_map[var_id]
            current_vals[name] = val
            timeline.append((current_time, dict(current_vals)))

# Plotting Waveforms
fig, axes = plt.subplots(len(target_signals), 1, figsize=(14, 8), sharex=True, dpi=300)
fig.suptitle("Lab 08: Memory System Simulation Waveforms (MemorySystem_tb)", fontsize=14, fontweight='bold', y=0.98)

# Sample points from 0 to 270 ns
t_sample = np.arange(0, 270, 0.5)
sig_values = {sig: [] for sig in target_signals}

for t in t_sample:
    # Find latest values at or before t
    val_at_t = {sig: '0' for sig in target_signals}
    for event_t, vals in timeline:
        if event_t <= t:
            val_at_t.update(vals)
        else:
            break
    for sig in target_signals:
        sig_values[sig].append(val_at_t.get(sig, '0'))

for i, sig in enumerate(target_signals):
    ax = axes[i]
    vals = sig_values[sig]
    ax.set_ylabel(sig, rotation=0, labelpad=45, fontweight='bold', fontsize=9, va='center')
    ax.set_yticks([])
    ax.grid(True, linestyle=':', alpha=0.6)
    
    if sig in ['clk', 'rst', 'writeEnable', 'readEnable']:
        # Binary signal plot
        y = [1 if v == '1' else 0 for v in vals]
        ax.step(t_sample, y, where='post', color='#2B6CB0', lw=1.5)
        ax.set_ylim(-0.2, 1.2)
    else:
        # Bus signal plot (draw bus envelope with hex labels)
        ax.set_ylim(-0.2, 1.2)
        # Find transition points
        trans_t = [0]
        trans_v = [vals[0]]
        for k in range(1, len(t_sample)):
            if vals[k] != vals[k-1]:
                trans_t.append(t_sample[k])
                trans_v.append(vals[k])
        trans_t.append(t_sample[-1])
        
        for k in range(len(trans_t)-1):
            t_start = trans_t[k]
            t_end = trans_t[k+1]
            val_hex = trans_v[k]
            # Draw bus box
            ax.fill_between([t_start, t_end], [1, 1], [0, 0], color='#EDF2F7', edgecolor='#4A5568', lw=1)
            # Label
            if (t_end - t_start) > 6 and val_hex != '0':
                ax.text((t_start + t_end)/2, 0.5, f"0x{val_hex}", ha='center', va='center', fontsize=7.5, fontweight='bold', color='#2D3748')

axes[-1].set_xlabel("Time (ns)", fontsize=10, fontweight='bold')
plt.tight_layout()
plt.subplots_adjust(top=0.92, hspace=0.3)
plt.savefig('lab08_waveforms.png', dpi=300, bbox_inches='tight')
print("Successfully generated lab08_waveforms.png")
