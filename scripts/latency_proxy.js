#!/usr/bin/env node
/* file : load_proxy.js
MIT License

Copyright (c) 2017 Thomas Minier

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
'use strict'

const http = require('http')
const HttpProxy = require('http-proxy')
const program = require('commander')

program
  .description('deploy a reverse proxy that add latency to every HTTP call')
  .usage('<target> <delay>')
  .option('-p, --port <port>', 'the port on which the reverse proxy will be running (default http://localhost:3000)', 3000)
  .parse(process.argv)

if (program.args.length < 2) {
  process.stderr.write('Error: invalid number of arguments.\nSee ./proxy.js -h for usage\n')
  process.exit(1)
}

const proxyConfig = {
  target: program.args[0]
}

const delay = parseInt(program.args[1]) || 30

const proxy = HttpProxy.createProxyServer()
const proxyServer = http.createServer((req, res) => {
  setTimeout(() => {
    proxy.web(req, res, proxyConfig)
  }, delay)
})

process.stdout.write(`Latency (delay: ${delay}) proxy up and running at http://localhost:${program.port}\n`)
proxyServer.listen(program.port)
