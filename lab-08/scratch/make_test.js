const fs = require('fs');

const originalDiagram = `flowchart TD
    subgraph RegisterFile ["32x32 Register File (reg_file / RegisterFile)"]
        direction TB
        subgraph Ports ["Port Interface"]
            CLK["clk (System Clock)"]
            RST["rst / reset"]
            WE["reg_write / WriteEnable"]
            RD_ADDR["rd[4:0]"]
            WD["write_data[31:0]"]
            RS1["rs1[4:0]"]
            RS2["rs2[4:0]"]
        end

        subgraph Core ["Storage Array & Logic"]
            DEC["5-to-32 Write Decoder<br/>(rd != 0 && reg_write)"]
            REGS["32 x 32-Bit Registers<br/>[x0 hardwired 0, x1..x31]"]
            MUX1["32-to-1 MUX (rs1)"]
            MUX2["32-to-1 MUX (rs2)"]
        end

        RD_ADDR --> DEC
        WE --> DEC
        CLK --> REGS
        RST --> REGS
        WD --> REGS
        DEC -->|Write Strobe| REGS
        REGS --> MUX1
        REGS --> MUX2
        RS1 --> MUX1
        RS2 --> MUX2
    end

    subgraph ALU ["32-Bit ALU (ALU_32bit)"]
        OP["op_code[2:0]"]
        ALU_CORE["ALU Logic Slices & Shifters<br/>(ADD, SUB, AND, OR, XOR, SLL, SRL)"]
        RES["result[31:0]"]
        ZERO["zero flag (Zero == 1 if result == 0)"]
        CARRY["carry_out"]
    end

    MUX1 -->|read_1 [31:0]| ALU_CORE
    MUX2 -->|read_2 [31:0]| ALU_CORE
    OP --> ALU_CORE
    ALU_CORE --> RES
    ALU_CORE --> ZERO
    ALU_CORE --> CARRY

    subgraph Feedback ["Datapath / FSM Feedback"]
        FSM["Hardware FSM / Control Unit"]
        RES -->|Writeback Datapath| WD
        ZERO -->|Branch Condition / Status| FSM
    end`;

const html = `<!DOCTYPE html>
<html>
<head>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
</head>
<body>
    <h1>Mermaid Test</h1>
    <div id="output"></div>
    <script>
        window.addEventListener('DOMContentLoaded', async () => {
            mermaid.initialize({ startOnLoad: false });
            const code = ${JSON.stringify(originalDiagram)};
            try {
                await mermaid.parse(code);
                document.getElementById('output').innerText = "ORIGINAL_PARSED_SUCCESSFULLY";
            } catch (err) {
                document.getElementById('output').innerText = "ORIGINAL_PARSE_ERROR: " + (err.str || err.message || JSON.stringify(err));
            }
        });
    </script>
</body>
</html>`;

fs.writeFileSync('c:/Users/Zubi/Downloads/lab-07/scratch/test_parse.html', html);
console.log('test_parse.html created');
