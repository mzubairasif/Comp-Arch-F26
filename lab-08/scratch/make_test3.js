const fs = require('fs');

const testDiagram = `flowchart TD
    subgraph RegisterFile ["32x32 Register File (reg_file / RegisterFile)"]
        subgraph Ports ["Port Interface"]
            CLK["clk (System Clock)"]
            RST["rst / reset"]
            WE["reg_write / WriteEnable"]
            RD_ADDR["rd (5-bit address)"]
            WD["write_data (32-bit data)"]
            RS1["rs1 (5-bit address)"]
            RS2["rs2 (5-bit address)"]
        end

        subgraph Core ["Storage Array and Logic"]
            DEC["5-to-32 Write Decoder (rd != 0 and reg_write)"]
            REGS["32 x 32-Bit Registers (x0 hardwired 0, x1..x31)"]
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
        OP["op_code (3-bit)"]
        ALU_CORE["ALU Logic Slices and Shifters (ADD, SUB, AND, OR, XOR, SLL, SRL)"]
        RES["result (32-bit)"]
        ZERO["zero flag (1 if result == 0)"]
        CARRY["carry_out"]

        OP --> ALU_CORE
        ALU_CORE --> RES
        ALU_CORE --> ZERO
        ALU_CORE --> CARRY
    end

    subgraph Feedback ["Datapath / FSM Feedback"]
        FSM["Hardware FSM / Control Unit"]
    end

    MUX1 -->|read_1 32-bit| ALU_CORE
    MUX2 -->|read_2 32-bit| ALU_CORE
    RES -->|Writeback Datapath| WD
    ZERO -->|Branch Condition / Status| FSM
`;

const html = `<!DOCTYPE html>
<html>
<head>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
</head>
<body>
    <h1>Mermaid Test</h1>
    <div id="output"></div>
    <div id="diagram"></div>
    <script>
        window.addEventListener('DOMContentLoaded', async () => {
            mermaid.initialize({ startOnLoad: false });
            const code = ${JSON.stringify(testDiagram)};
            try {
                const parseRes = await mermaid.parse(code);
                const renderRes = await mermaid.render('renderedSvg', code);
                document.getElementById('output').innerText = "SUCCESS: " + (renderRes.svg ? "RENDERED_SVG_OK" : "NO_SVG");
                document.getElementById('diagram').innerHTML = renderRes.svg;
            } catch (err) {
                document.getElementById('output').innerText = "ERROR: " + (err.str || err.message || JSON.stringify(err));
            }
        });
    </script>
</body>
</html>`;

fs.writeFileSync('c:/Users/Zubi/Downloads/lab-07/scratch/test_parse3.html', html);
console.log('test_parse3.html created');
