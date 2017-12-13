#!/usr/bin/env node
/* file : gen-catalog.js
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

const { extractPatterns, stringifyPattern } = require('../src/utils.js')
const fs = require('fs')
const program = require('commander')
const { sampleSize, uniqBy } = require('lodash')

// Command line interface to generate catalog
program
  .description('Generate a Ulysses catalog')
  .usage('<query-file> <servers...> [options]')
  .option('-r, --replication <factor>', 'set the replication factor (default: 2)', 2)
  .option('-o, --output <output>', 'catalog output (default ./catalog.json)', 'catalog.json')
  .parse(process.argv)

// get query file & servers
if (program.args.length <= 1) {
  process.stderr.write('Error: you must specify a file containg SPARQL queries and at least one TPF server to use.\nSee gen-catalog.js --help for more details.\n')
  process.exit(1)
}

const queries = fs.readFileSync(program.args.shift(), 'utf-8').trim().split('\n')
const servers = program.args
const catalog = { patterns: [] }

queries.forEach(query => {
  process.stdout.write('# --------------------------------- #\n')
  process.stdout.write(`Generating catalog for query ${query}\n`)
  const patterns = extractPatterns(query)
  patterns.forEach(pattern => {
    catalog.patterns.push({
      pattern,
      servers: sampleSize(servers, program.replication)
    })
  })
})

// deduplicated patterns
catalog.patterns = uniqBy(catalog.patterns, p => stringifyPattern(p.pattern))

// output catalog
process.stdout.write('# --------------------------------- #\n')
process.stdout.write('Writing catalog to output...\n')
fs.writeFileSync(program.output, JSON.stringify(catalog, false, 2))
process.stdout.write(`Catalog generated and written into ${program.output}...\n`)
