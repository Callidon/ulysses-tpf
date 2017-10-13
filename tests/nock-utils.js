/* file : nock-utils.js
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

const nock = require('nock')
const _ = require('lodash')

const PREFIXES = `
  @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
  @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
  @prefix owl: <http://www.w3.org/2002/07/owl#>.
  @prefix xsd: <http://www.w3.org/2001/XMLSchema#>.
  @prefix hydra: <http://www.w3.org/ns/hydra/core#>.
  @prefix void: <http://rdfs.org/ns/void#>.
  @prefix dbp: <http://dbpedia.org/resource/>.
  @prefix dcp: <http://dcpedia.org/rdf/>.
`

const REPLY_HEADERS = {
  'content-type': 'text/turtle;charset=utf-8',
  server: 'node-nock'
}

const dullTriple = () => `dbp:Batman dcp:hasAcolyte dcp:Robin_${_.uniqueId()}.`

const getQueryUrl = (baseUrl, triple, numPage) => {
  let queryUrl = baseUrl
  const queryParams = _.compact(_.map(triple, (v, k) => {
    if (!v.startsWith('?')) return `${k}=${encodeURIComponent(v)}`
  }))
  // build query string
  if (numPage > 1 && queryParams.length > 0) { queryUrl += `?page=${numPage}&${queryParams.join('&')}` } else if (numPage > 1) { queryUrl += `?page=${numPage}` } else if (queryParams.length > 0) { queryUrl += `?${queryParams.join('&')}` }
  return queryUrl
}

const genPage = (url, triple, cardinality, numPage = 1, size = 100) => {
  const currentUrl = getQueryUrl(url, triple, numPage)
  let metadata = `
  <${url}/#dataset> hydra:member <${url}#dataset>.
  <${url}#dataset> a void:Dataset, hydra:Collection;
    void:subset <${currentUrl}>, <${url}>;
    void:uriLookupEndpoint "${url}{?subject,predicate,object}";
    hydra:search _:triplePattern.
  _:triplePattern hydra:template "${url}{?subject,predicate,object}";
    hydra:variableRepresentation hydra:ExplicitRepresentation;
    hydra:mapping _:subject, _:predicate, _:object.
  _:subject hydra:variable "subject";
    hydra:property rdf:subject.
  _:predicate hydra:variable "predicate";
    hydra:property rdf:predicate.
  _:object hydra:variable "object";
    hydra:property rdf:object.
    <${currentUrl}> a hydra:PartialCollectionView;
    <http://purl.org/dc/terms/title> "Linked Data Fragment of Random Batman facts"@en;
    <http://purl.org/dc/terms/description> "Linked Data Fragment of Random Batman facts (filled with dull content)"@en;
  `
  if (numPage > 1 && cardinality > size) { metadata += `hydra:previous <${getQueryUrl(url, triple, numPage - 1)}>;` }
  if (numPage < (cardinality / size)) { metadata += `hydra:next <${getQueryUrl(url, triple, numPage + 1)}>;` }
  metadata += `
  hydra:totalItems "${cardinality}"^^xsd:integer;
    void:triples "${cardinality}"^^xsd:integer;
    hydra:itemsPerPage "${size}"^^xsd:integer;
    hydra:first <${getQueryUrl(url, triple, 1)}>.
  `
  // console.log(PREFIXES + _.times(size, () => dullTriple()).join('\n') + '\n' + metadata);
  return PREFIXES + _.times(size, () => dullTriple()).join('\n') + '\n' + metadata
}

const mockPages = (triple, server, dataset, options = {}) => {
  const opt = _.merge({
    nbPages: 1,
    pageSize: 100,
    cardinality: 300,
    delay: 0
  }, options)
  const n = nock(server)
  return _.range(opt.nbPages).reduce((mock, numPage) => {
    const queryUrl = getQueryUrl(`/${dataset}`, triple, numPage)
    return mock.get(queryUrl)
      .delay(opt.delay)
      .reply(200, genPage(`${server}/${dataset}`, triple, opt.cardinality, numPage, opt.pageSize), REPLY_HEADERS)
  }, n)
}

module.exports = {
  mockPages,
  genPage
}
