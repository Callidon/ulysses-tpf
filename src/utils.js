/* file : utils.js
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

const { Parser } = require('sparqljs')
const { compact, flatten, map } = require('lodash')

/**
 * Stringify a triple pattern
 * @param  {Object} pattern - triple pattern to stringify
 * @return {string} The stringified triple pattern
 */
function stringifyPattern (pattern) {
  return `s=${pattern.subject || '_'}&p=${pattern.predicate || '_'}&o=${pattern.object || '_'}`
}

/**
 * Encode a TPF url for a given triple pattern and page number
 * @param  {string} baseUrl  - The fragment base url
 * @param  {Object} pattern  - The triple pattern
 * @param  {integer} [pageNum=1] - The index of the requested page
 * @return {string} The url to retrieve the triple pattern with the given page
 */
function encodeTPFUrl (baseUrl, pattern, pageNum = 1) {
  const patternUrl = compact(map(pattern, (v, k) => {
    if (!v.startsWith('?')) return `${k}=${encodeURIComponent(v)}`
  })).join('&')
  return `${baseUrl}?${patternUrl}&page=${pageNum}`
}

function findPatterns (elt) {
  switch (elt.type) {
    case 'bgp':
      return elt.triples
    case 'union':
    case 'group':
      return flatten(elt.patterns.map(findPatterns))
    default:
      return []
  }
}

/**
 * Extract all triple patterns from a SPARQL query
 * @param  {string} query - A SPARQL query
 * @return {Object[]} A set of all triple patterns in the SPARQL query
 */
function extractPatterns (query) {
  const parser = new Parser()
  const parsedQuery = parser.parse(query)
  return flatten(parsedQuery.where.map(findPatterns))
}

function count (rawPage) {
  const nbTriples = rawPage.match(/hydra:totalItems "(.*)"\^\^xsd:integer;/)[1]
  if (nbTriples === undefined) return 0
  return parseInt(nbTriples)
}

module.exports = {
  encodeTPFUrl,
  stringifyPattern,
  extractPatterns,
  count
}
