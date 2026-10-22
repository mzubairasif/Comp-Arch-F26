const http = require('http');
const fs = require('fs');

const server = http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    if (req.method === 'POST' && req.url === '/save-image') {
        let body = '';
        req.on('data', chunk => { body += chunk; });
        req.on('end', () => {
            try {
                const base64Data = body.replace(/^data:image\/png;base64,/, "");
                fs.writeFileSync('c:/Users/Zubi/Downloads/lab-07/block_diagram.png', base64Data, 'base64');
                console.log('Saved block_diagram.png successfully!');
                res.writeHead(200, { 'Content-Type': 'text/plain' });
                res.end('OK');
                setTimeout(() => process.exit(0), 1000);
            } catch (err) {
                console.error(err);
                res.writeHead(500);
                res.end('ERR');
            }
        });
    } else {
        res.writeHead(404);
        res.end();
    }
});

server.listen(8099, () => {
    console.log('Server listening on port 8099');
});
