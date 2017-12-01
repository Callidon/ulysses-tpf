/* file : ulysses-fragments-client.js
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

const { isNull, isUndefined, sample } = require('lodash')
const LRU = require('lru-cache')
const FragmentsClient = require('ldf-client/lib/triple-pattern-fragments/FragmentsClient')

/**
 * A TPF FragmentsClient which apply the adaptive Ulysses load balancing at triple pattern level.
 * @author Thomas Minier
 */
class UlyssesFragmentsClient {
  /**
   * Constructor
   * @param  {Model}  model - The model associated with the SPARQL query currently evaluated
   * @param  {string[]} servers - Set of replicated TPF servers used to evaluate the query
   * @param  {Selection} selection - Source selection used to process queries
   * @param  {Object} [config={}]  - Additional config object used to configure the TPF client
   */
  constructor (model, servers, selection, options) {
    this._model = model
    this._selection = selection
    this._options = options
    this._clients = new Map()
    this._cache = {
      set: function () {},
      has: function () { return false },
      get: function () { return undefined }
    }// new LRU({ max: 5000 })
    servers.forEach(url => {
      this._clients.set(url, new FragmentsClient(url, this._options))
      this._clients.get(url)._cache = this._cache
    })
  }

  /**
   * Same as classic FragmentsClient#getFragmentByPattern, but done using adaptive Ulysses
   * @param  {Object} pattern - Triple pattern requested
   * @param  {Object} sourcePattern -
   * @return {AsyncIterator} Iterator that evaluates the triple pattern against a TPF server
   */
  getFragmentByPattern (pattern, sourcePattern = null) {
    // recompute model, then select the submodel corresponding to the pattern
    this._model.computeModel()
    let model = this._model
    let servers = this._selection.get(pattern)
    if (!isNull(servers) && !(isUndefined(servers))) {
      if (servers.length === 1) return this._clients.get(servers[0]).getFragmentByPattern(pattern)
      model = this._model.subset(servers)
    }
    // select random target TPF server according to the cost-model
    const selectedServer = sample(model.getRNGVector())
    return this._clients.get(selectedServer).getFragmentByPattern(pattern)
  }
}

module.exports = UlyssesFragmentsClient
