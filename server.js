import http from "http";

const port = process.env.PORT || 3000;

http.createServer((req, res) => {
  res.writeHead(200);
  res.end("wireproxy running");
}).listen(port, () => {
  console.log("Server running on port " + port);
});
