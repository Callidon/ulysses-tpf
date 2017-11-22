/* file : source-selection.js
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

const request = require('request')
const Selection = require('./selection.js')
const { count, encodeTPFUrl, extractPatterns } = require('../utils.js')

const HTTP_CLIENT = request.forever({
  timeout: 1000,
  minSockets: 10
})

const DEFAULT_HEADERS = {
  accept: 'application/trig;q=1.0,application/n-quads;q=0.7,text/turtle;q=0.6,application/n-triples;q=0.3,text/n3;q=0.2',
  'accept-charset': 'utf-8',
  'user-agent': 'Ulysses Triple Pattern Fragments Client/1.0'
}

/**
 * Perform a Source Selection
 * WARNING: this source selectiopn does not support fragmentation.
 * If several sources are relevant for the same
 * @param  {string} query   - SPARQL query used to perform the source selection
 * @param  {string[]} servers - Set of servers used to perform the source selection
 * @return {Promise} A Promise fullfilled with the corresponding {@link Selection}
 */
async function sourceSelection (query, servers) {
  const selection = new Selection()
  const patterns = extractPatterns(query)
  const patternsToEndpoints = await Promise.all(patterns.map(async function (pattern) {
    const relevants = await Promise.all(servers.map(server => {
      return new Promise((resolve, reject) => {
        const options = {
          url: encodeTPFUrl(server, pattern, 1),
          headers: DEFAULT_HEADERS,
          encoding: 'utf-8',
          gzip: true
        }
        HTTP_CLIENT.get(options, (err, res, body) => {
          if (err) {
            reject(err)
          } else {
            resolve({server, relevant: count(body) > 0})
          }
        })
      })
    }))
    return {
      pattern,
      relevantServers: relevants.filter(elt => elt.relevant).map(elt => elt.server)
    }
  }))
  patternsToEndpoints.forEach(elt => {
    selection.set(elt.pattern, elt.relevantServers)
  })
  return selection
}

module.exports = sourceSelection
