/* file : peneloop-iterator.js
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

const ldf = require('ldf-client')
const { TransformIterator } = require('asynciterator')
const ModelRepository = require('./model/model-repository.js')
const PeneloopFragmentsClient = require('./peneloop-fragments-client.js')
const peneloopRequester = require('./peneloop-request.js')
const sourceSelection = require('./source-selection/source-selection.js')
ldf.Logger.setLevel('WARNING')

/**
 * Creates an Iterator that process a SPARQL query using Peneloop adaptive load balancing
 * @author Thomas Minier
 * @param  {string} query   - The SPARQL query to evaluate
 * @param  {string[]} servers - Set of replicated TPF servers used to evaluate the query
 * @param  {Object} [config={}]  - Additional config object used to configure the TPF client
 * @return {AsyncIterator} The Iterator that evaluate the SPARQL query
 */
function peneloopIterator (query, servers, config = {}) {
  const iterator = new TransformIterator()
  const modelRepo = new ModelRepository()
  Promise.all([modelRepo.getModel(servers), sourceSelection(query, servers)])
  .then(res => {
    const model = res[0]
    const selection = res[1]
    config.request = peneloopRequester(model)
    config.fragmentsClient = new PeneloopFragmentsClient(model, servers, selection, config)
    iterator.source = new ldf.SparqlIterator(query, config)
  }).catch(error => {
    iterator.emit('error', error)
    iterator.close()
  })
  return iterator
}

module.exports = peneloopIterator
