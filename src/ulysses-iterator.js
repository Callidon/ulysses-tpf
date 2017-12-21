/* file : ulysses-iterator.js
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

const { URL } = require('url')
const ldf = require('ldf-client')
const { TransformIterator } = require('asynciterator')
const ModelRepository = require('./model/model-repository.js')
const UlyssesFragmentsClient = require('./ulysses-fragments-client.js')
const ulyssesRequester = require('./ulysses-request.js')
const sourceSelection = require('./source-selection/source-selection.js')
const { patternContainment, stringifyPattern } = require('./utils.js')
const { isEmpty } = require('lodash')
ldf.Logger.setLevel('WARNING')

// reverse engineer triple pattern contained in the url
function urlToPattern (url, sourceSelection) {
  const searchParams = new URL(url).searchParams
  const pattern = {}
  if (searchParams.has('subject')) pattern.subject = searchParams.get('subject')
  if (searchParams.has('predicate')) pattern.predicate = searchParams.get('predicate')
  if (searchParams.has('object')) pattern.object = searchParams.get('object')
  if (isEmpty(pattern)) return pattern
  return patternContainment(pattern, sourceSelection._references)
}

/**
 * Creates an Iterator that process a SPARQL query using Ulysses adaptive load balancing
 * @author Thomas Minier
 * @param  {string} query   - The SPARQL query to evaluate
 * @param  {string[]} servers - Set of replicated TPF servers used to evaluate the query
 * @param  {Object} [config={}]  - Additional config object used to configure the TPF client
 * @return {AsyncIterator} The Iterator that evaluate the SPARQL query
 */
function ulyssesIterator (query, servers, config = {}) {
  const iterator = new TransformIterator()
  const modelRepo = new ModelRepository()
  Promise.all([modelRepo.getModel(servers), sourceSelection(query, servers)])
  .then(res => {
    const model = res[0]
    const selection = config.selection || res[1]
    if (config.recordMode) {
      model.on('updated_time', (server, execTime, realTime, url) => {
        iterator.emit('http_request', server, execTime, realTime, stringifyPattern(urlToPattern(url, selection)))
      })
    }
    config.request = ulyssesRequester(model)
    config.fragmentsClient = new UlyssesFragmentsClient(model, servers, selection, config)
    iterator.source = new ldf.SparqlIterator(query, config)
    iterator.model = model
  }).catch(error => {
    iterator.emit('error', error)
    iterator.close()
  })
  return iterator
}

module.exports = ulyssesIterator
