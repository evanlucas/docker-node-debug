'use strict'

const http = require('http')
const server = http.createServer((req, res) => {
  console.log(req.method, req.url)
  req.date = new Date()
  res.writeHead(200, {
    'Content-type': 'text/plain'
  })
  res.end('10000')
})

server.listen(10000)
