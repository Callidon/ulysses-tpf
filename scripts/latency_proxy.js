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
const { URL } = require('url')
const HttpProxy = require('http-proxy')
const program = require('commander')

program
  .description('Deploy a reverse proxy that add latency to every HTTP call')
  .usage('<target> <port> <delay>')
  .parse(process.argv)

if (program.args.length < 2) {
  process.stderr.write('Error: invalid number of arguments.\nSee ./proxy.js -h for usage\n')
  process.exit(1)
}

const proxyConfig = {
  target: program.args[0]
}
const proxyPort = program.args[1]
let fakeDeath = false
let delay = parseInt(program.args[2])
const baseDelay = parseInt(program.args[2])

const proxy = HttpProxy.createProxyServer()
const proxyServer = http.createServer((req, res) => {
  if (fakeDeath && req.url !== '/revive') {
    setTimeout(() => {
      res.writeHead(404, { 'Content-Type': 'text/plain' })
      res.write('I\'m faking death, don\'t tell my mom!\n')
      res.end()
    }, delay)
  } else {
    const url = new URL(proxyConfig.target + req.url)
    switch (url.pathname) {
      case '/setLatency': {
        if (url.searchParams.has('value')) {
          delay = parseInt(url.searchParams.get('value'))
          process.stdout.write(`Latency of proxy running on port ${proxyPort} updated to ${delay}ms\n`)
        }
        res.writeHead(200, { 'Content-Type': 'text/plain' })
        res.write('Latency successfully updated!\n')
        res.end()
        break
      }
      case '/resetLatency': {
        delay = baseDelay
        process.stdout.write(`Latency of proxy running on port ${proxyPort} reset to ${delay}ms\n`)
        res.writeHead(200, { 'Content-Type': 'text/plain' })
        res.write('Latency successfully reset!\n')
        res.end()
        break
      }
      case '/fakeDeath': {
        fakeDeath = true
        process.stdout.write(`Proxy running on port ${proxyPort} is now faking death\n`)
        res.writeHead(200, { 'Content-Type': 'text/plain' })
        res.write('Proxy is now faking death!\n')
        res.end()
        break
      }
      case '/revive': {
        fakeDeath = false
        process.stdout.write(`Proxy running on port ${proxyPort} is back online\n`)
        res.writeHead(200, { 'Content-Type': 'text/plain' })
        res.write('Proxy is back online!\n')
        res.end()
        break
      }
      default: {
        setTimeout(() => {
          proxy.web(req, res, proxyConfig)
        }, delay)
      }
    }
  }
})

process.stdout.write(`Latency (delay: ${delay}) proxy up and running at http://localhost:${proxyPort}\n`)
proxyServer.listen(proxyPort)
