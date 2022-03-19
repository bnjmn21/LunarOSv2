const http = require('http');
const fs = require('fs');

const requestListener = function (req, res) {
  console.log("downloading: ",req.url)
  try {
    res.writeHead(200);
    res.end(fs.readFileSync(req.url.slice(1)));
  } catch(e) {
    res.writeHead(404);
    res.end();
  }
}

const server = http.createServer(requestListener);
server.listen(8080);
