const https = require('https');
const fs = require('fs');

const testHtml = `
<!DOCTYPE html>
<html>
<head>
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
    <script>
        mermaid.initialize({ startOnLoad: false });
        async function runTest(code) {
            try {
                const res = await mermaid.parse(code);
                console.log("SUCCESS");
                return true;
            } catch(e) {
                console.error("PARSE_ERROR:", e.message || e);
                return false;
            }
        }
    </script>
</head>
<body>
</body>
</html>
`;
fs.writeFileSync('test_mermaid.html', testHtml);
console.log('Written test_mermaid.html');
