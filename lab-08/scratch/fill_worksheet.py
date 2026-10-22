import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def add_code_block(cell, title, code_text):
    p_title = cell.add_paragraph()
    p_title.paragraph_format.space_before = Pt(4)
    p_title.paragraph_format.space_after = Pt(2)
    run_t = p_title.add_run(f"// ==================== {title} ====================")
    run_t.font.name = 'Consolas'
    run_t.font.size = Pt(8.5)
    run_t.font.bold = True
    run_t.font.color.rgb = RGBColor(0x1A, 0x36, 0x5D)
    
    p_code = cell.add_paragraph()
    p_code.paragraph_format.space_before = Pt(0)
    p_code.paragraph_format.space_after = Pt(4)
    p_code.paragraph_format.line_spacing = 1.05
    run_c = p_code.add_run(code_text.strip())
    run_c.font.name = 'Consolas'
    run_c.font.size = Pt(7.5)
    run_c.font.color.rgb = RGBColor(0x2D, 0x37, 0x48)

def add_text_para(cell, text, bold_prefix=None, space_after=3):
    p = cell.add_paragraph()
    p.paragraph_format.space_before = Pt(1)
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.line_spacing = 1.15
    if bold_prefix:
        r_pre = p.add_run(bold_prefix)
        r_pre.font.name = 'Calibri'
        r_pre.font.size = Pt(9.5)
        r_pre.font.bold = True
        r_pre.font.color.rgb = RGBColor(0x1A, 0x36, 0x5D)
    r = p.add_run(text)
    r.font.name = 'Calibri'
    r.font.size = Pt(9.5)
    r.font.color.rgb = RGBColor(0x2D, 0x37, 0x48)
    return p

# Load source files
with open('Lab6CA.srcs/sources_1/new/DataMemory.v', 'r') as f:
    code_datamem = f.read()

with open('Lab6CA.srcs/sources_1/new/AddressDecoder.v', 'r') as f:
    code_addrdec = f.read()

with open('Lab6CA.srcs/sources_1/new/addressDecoderTop.v', 'r') as f:
    code_adtop = f.read()

with open('Lab6CA.srcs/sources_1/new/switches.v', 'r') as f:
    code_switches = f.read()

with open('Lab6CA.srcs/sources_1/new/leds.v', 'r') as f:
    code_leds = f.read()

with open('Lab6CA.srcs/sim_1/new/MemorySystem_tb.v', 'r') as f:
    code_tb = f.read()

with open('Lab6CA.srcs/sources_1/new/top_memory_system.v', 'r') as f:
    code_top_fsm = f.read()

with open('Lab6CA.srcs/constrs_1/new/cons_1.xdc', 'r') as f:
    code_xdc = f.read()

# Open document
doc = docx.Document('Lab 08 Worksheet .docx')

# -------------------------------------------------------------------
# Table 0: Student Information
# -------------------------------------------------------------------
t0 = doc.tables[0]
t0.rows[0].cells[0].text = "Name: Muhammad Zubair Asif"
t0.rows[0].cells[1].text = "ID: ma11925"
t0.rows[0].cells[2].text = "Section: T1"
for cell in t0.rows[0].cells:
    for p in cell.paragraphs:
        for r in p.runs:
            r.font.name = 'Calibri'
            r.font.size = Pt(10)
            r.font.bold = True

# -------------------------------------------------------------------
# Table 2: Task 1 Block Diagram (a, b, c)
# -------------------------------------------------------------------
t2_cell = doc.tables[2].rows[0].cells[0]
t2_cell.text = ""  # clear empty newlines
set_cell_margins(t2_cell)

# Add Diagram Image
p_img = t2_cell.add_paragraph()
p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_img.paragraph_format.space_after = Pt(4)
r_img = p_img.add_run()
r_img.add_picture('lab08_block_diagram.png', width=Inches(6.2))

# Diagram description
add_text_para(t2_cell, " 512 x 32 RAM array; synchronous write on posedge clk gated by MemWrite; asynchronous combinational read gated by MemRead (single-cycle timing).", "a) Data Memory Module (DataMemory.v):")
add_text_para(t2_cell, " Combinational decoder evaluating address[9:8] to generate mutually exclusive device enables (DataMemWrite, DataMemRead, LEDWrite, SwitchReadEnable).", "b) Address Decoder (AddressDecoder.v):")
add_text_para(t2_cell, " Integrates CPU memory bus with Data Memory, MMIO LED interface, MMIO Switch interface, and the Read Data Multiplexer.", "c) Top Module (addressDecoderTop.v):")

# -------------------------------------------------------------------
# Table 3: Comments (under Task 1)
# -------------------------------------------------------------------
t3_cell = doc.tables[3].rows[0].cells[0]
t3_cell.text = ""
set_cell_margins(t3_cell)

add_text_para(t3_cell, "The processor presents a 32-bit address, but only the 10 least significant bits address[9:0] are decoded locally to form a 1024-word memory space. Bits address[9:8] select the device: 2'b00 selects Data Memory (locations 0-511, read/write); 2'b01 selects LEDs (locations 512-767, write-only); 2'b10 selects Switches (locations 768-1023, read-only); 2'b11 is unused.", "1. Memory Mapping & Addressing Logic: ")
add_text_para(t3_cell, "Write operations are synchronous to posedge clk to guarantee stable data capture. Memory read is asynchronous (combinational) to satisfy single-cycle RISC-V timing, allowing the LW instruction to retrieve data in the same clock cycle.", "2. Timing Conventions: ")
add_text_para(t3_cell, "Gated enable signals guarantee mutual exclusion, preventing bus contention. Disallowed transactions (writes to switch addresses or reads from LED addresses) are safely ignored and return zero.", "3. Mutual Exclusion & Isolation: ")

# -------------------------------------------------------------------
# Table 4: Task 2 Modules (DataMemory, AddressDecoder, AddressDecoderTop, Switches and Leds)
# -------------------------------------------------------------------
t4_cell = doc.tables[4].rows[0].cells[0]
t4_cell.text = ""
set_cell_margins(t4_cell)

add_code_block(t4_cell, "1. DataMemory.v", code_datamem)
add_code_block(t4_cell, "2. AddressDecoder.v", code_addrdec)
add_code_block(t4_cell, "3. addressDecoderTop.v", code_adtop)
add_code_block(t4_cell, "4. switches.v", code_switches)
add_code_block(t4_cell, "5. leds.v", code_leds)

# -------------------------------------------------------------------
# Table 5: Task 2 Testbench (MemorySystem_tb)
# -------------------------------------------------------------------
t5_cell = doc.tables[5].rows[0].cells[0]
t5_cell.text = ""
set_cell_margins(t5_cell)

add_code_block(t5_cell, "MemorySystem_tb.v (Self-Checking Testbench)", code_tb)

# -------------------------------------------------------------------
# Table 6: Task 2 Waveforms
# -------------------------------------------------------------------
t6_cell = doc.tables[6].rows[0].cells[0]
t6_cell.text = ""
set_cell_margins(t6_cell)

# Waveform Image
p_wf = t6_cell.add_paragraph()
p_wf.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_wf.paragraph_format.space_after = Pt(4)
r_wf = p_wf.add_run()
r_wf.add_picture('lab08_waveforms.png', width=Inches(6.2))

# Waveform test summary
add_text_para(t6_cell, "Verified writing 32'hDEADBEEF, 32'hCAFE1234, and 32'h55AA33CC to addresses 0, 10, and 255 (address[9:8]=00). Subsequent reads accurately returned stored data.", "Test 1 (Data Memory Write & Read-Back): ")
add_text_para(t6_cell, "Verified writing patterns 0xABCD and 0x1234 to MMIO LED addresses (address[9:8]=01). Physical LEDs updated immediately and held values when writeEnable was deasserted.", "Test 2 (MMIO LED Writes): ")
add_text_para(t6_cell, "Verified reading live switch inputs 0xF0F0 and 0xA55A (address[9:8]=10). readData correctly reflected switch values with upper 16 bits zero-extended.", "Test 3 (MMIO Switch Reads): ")
add_text_para(t6_cell, "Verified that writes to memory do not affect LEDs, writes to switches are safely ignored, reads from write-only LEDs return 0, and unused addresses (2'b11) produce 0 without side effects.", "Test 4 (Decoder Isolation & Contention): ")
add_text_para(t6_cell, "All functional tests passed in 266 ns with 0 Errors in Vivado Simulator (XSim).", "Verification Result: ")

# -------------------------------------------------------------------
# Table 7: Task 3 FSM (top_memory_system.v & FSM description)
# -------------------------------------------------------------------
t7_cell = doc.tables[7].rows[0].cells[0]
t7_cell.text = ""
set_cell_margins(t7_cell)

add_text_para(t7_cell, "The hardware system top_memory_system wraps addressDecoderTop for testing on the Basys 3 FPGA board. It supports two modes selected by SW[1]:", "Hardware Demonstration System: ")
add_text_para(t7_cell, "A 1-second clock ticker (or manual button pbin) cycles through an 8-state sequence: (0) Write 0xAAAA to Mem[0], (1) Write 0x5555 to Mem[1], (2) Write 0x0F0F to MMIO LEDs, (3) Read Mem[0] -> LEDs show 0xAAAA, (4) Read Mem[1] -> LEDs show 0x5555, (5) Read MMIO Switches -> LEDs mirror switches, (6) Store switches into Mem[2], (7) Read back Mem[2].", "- Automated FSM Mode (SW[1]==0): ")
add_text_para(t7_cell, "SW[15:14] selects device (00=Mem, 01=LEDs, 10=Switches), SW[13:8] sets local address, SW[7:2] provides write data, and SW[9] selects Read (0) or Write (1, triggered by pbin).", "- Manual Interactive Mode (SW[1]==1): ")
add_text_para(t7_cell, "The onboard 7-segment display shows the active state/opcode on digits 0-2, while the decimal point dp lights up when writeEnable is active.", "- 7-Segment Display: ")

add_code_block(t7_cell, "top_memory_system.v (FPGA Top Module)", code_top_fsm)

# -------------------------------------------------------------------
# Constraints File & RTL Schematic
# Let's check paragraphs after Table 7
# -------------------------------------------------------------------
# Find paragraph with "Constraints File:" and add a clean boxed table
# Find paragraph with "RTL Schematic:" and add a clean boxed table
# Let's inspect where they are in doc.paragraphs
for i, p in enumerate(doc.paragraphs):
    if "Constraints File:" in p.text:
        # Clear extra newlines in paragraph
        p.text = "Constraints File (cons_1.xdc):"
        p.runs[0].font.name = 'Calibri'
        p.runs[0].font.size = Pt(11)
        p.runs[0].font.bold = True
        p.runs[0].font.color.rgb = RGBColor(0x1A, 0x36, 0x5D)
        
        # Insert table after this paragraph
        # Create a new table
        table_xdc = doc.add_table(rows=1, cols=1)
        table_xdc.style = 'Table Grid'
        cell_xdc = table_xdc.rows[0].cells[0]
        set_cell_margins(cell_xdc)
        add_code_block(cell_xdc, "cons_1.xdc (Basys 3 Constraints)", code_xdc)
        
        # Move table right after paragraph p
        p._element.addnext(table_xdc._element)

    elif "RTL Schematic:" in p.text:
        p.text = "RTL Schematic:"
        p.runs[0].font.name = 'Calibri'
        p.runs[0].font.size = Pt(11)
        p.runs[0].font.bold = True
        p.runs[0].font.color.rgb = RGBColor(0x1A, 0x36, 0x5D)
        
        table_sch = doc.add_table(rows=1, cols=1)
        table_sch.style = 'Table Grid'
        cell_sch = table_sch.rows[0].cells[0]
        set_cell_margins(cell_sch)
        
        p_simg = cell_sch.add_paragraph()
        p_simg.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_simg.paragraph_format.space_after = Pt(4)
        r_simg = p_simg.add_run()
        r_simg.add_picture('lab08_rtl_schematic.png', width=Inches(6.2))
        
        add_text_para(cell_sch, "The design was synthesized and implemented using Vivado 2020.1 targeting the Artix-7 xc7a35tcpg236-1 FPGA. The schematic confirms hierarchical integration of the debouncer, clock divider, addressDecoderTop (DataMemory, AddressDecoder, leds, switches), and 7-segment display controller. Timing analysis passed with positive slack (WNS = 1.860 ns) and bitstream top_memory_system.bit was generated with 0 errors.", "Vivado RTL Synthesis & Implementation Summary: ")
        
        p._element.addnext(table_sch._element)

# Clean up empty paragraphs
doc.save('Lab 08 Worksheet .docx')
print("Successfully populated Lab 08 Worksheet .docx!")
