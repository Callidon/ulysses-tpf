#!/usr/bin/env node
/* file : ulysses-tpf.js
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

const fs = require('fs')
const path = require('path')
const program = require('commander')
const { isUndefined } = require('lodash')
const Selection = require('../src/source-selection/selection.js')
const UlyssesIterator = require('../src/ulysses-iterator.js')

// Command line interface to execute queries
program
  .description('Execute a SPARQL query against several servers using adaptive Ulysses')
  .usage('<servers...> [options]')
  .option('-q, --query <query>', 'evaluates the given SPARQL query')
  .option('-f, --file <file>', 'evaluates the SPARQL query in the given file')
  .option('-t, --timeout <timeout>', 'set SPARQL query timeout in milliseconds (default: 30mn)', 30 * 60 * 1000)
  .option('-m, --measure <output>', 'measure the query execution time (in seconds) & append it to a file', null)
  .option('-s, --silent', 'do not perform any measurement on execution time ', true)
  .option('-r, --record', 'enable record mode, which output enhanced data in CSV for data analysis')
  .option('-c, --catalog <json-file>', 'pass a custom catalog contained in a JSON file')
  .parse(process.argv)

// get servers
if (program.args.length <= 0) {
  process.stderr.write('Error: you must specify at least one TPF server to use.\nSee ulysses-tpf.js --help for more details.\n')
  process.exit(1)
}

const servers = program.args
const configFile = path.join(__dirname, '../node_modules/ldf-client/config-default.json')
const config = JSON.parse(fs.readFileSync(configFile, { encoding: 'utf8' }))
config.recordMode = program.record
config.noCache = true
// read catalog from file if specified
if (!isUndefined(program.catalog)) {
  const catalog = JSON.parse(fs.readFileSync(program.catalog, { encoding: 'utf8' }))
  const selection = new Selection()
  catalog.patterns.forEach(config => {
    selection.set(config.pattern, config.servers)
  })
  config.selection = selection
}

// fetch SPARQL query to execute
let query = null
let timeout = null
if (program.query) {
  query = program.query
} else if (program.file && fs.existsSync(program.file)) {
  query = fs.readFileSync(program.file, 'utf-8')
} else {
  process.stderr.write('Error: you must specify a SPARQL query to execute.\nSee ulysses-tpf --help for more details.\n')
  process.exit(1)
}

const iterator = UlyssesIterator(query, servers, config)
iterator.on('error', error => {
  process.stderr.write('ERROR: An error occurred during query execution.\n')
  process.stderr.write(error.stack)
})

iterator.on('end', () => {
  clearTimeout(timeout)
  if (!program.silent) {
    const endTime = Date.now()
    const time = endTime - startTime
    if (program.measure) {
      fs.appendFileSync(program.measure, time / 1000)
    }
  }
})

const startTime = Date.now()

// output CSV headers in record mode
if (program.record) {
  iterator.on('http_request', (url, time, realTime, strPattern) => {
    const timestamp = Date.now() - startTime
    process.stdout.write(`"${url}",${timestamp},${time},${realTime},"${strPattern}"\n`)
  })
}

iterator.on('data', data => {
  if (!program.record) {
    process.stdout.write(`${JSON.stringify(data)}\n`)
  }
})

// set query timeout
timeout = setTimeout(() => {
  iterator.close()
  process.stderr.write(`TIMEOUT EXCEEDED ${program.timeout}: shutting down query processing...\n`)
}, program.timeout)
