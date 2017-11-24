/* file : ulysses.js
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

const { isUndefined, sample } = require('lodash')
const { URL } = require('url')
const ldfRequester = require('ldf-client/lib/util/Request')

/**
 * Create a request function that use the adaptive ulysses load balancing
 * @author Thomas Minier
 * @param  {Model}  model - The model associated with the SPARQL query currently evaluated
 * @param  {Boolean} [recordOnly=true] - Set recordOnly to False if you want to perform load balancing at HTTP level
 * @return {function} The request function used by the TPF client to perform HTTP request
 */
function createUlyssesRequest (model, recordOnly = true) {
  return function (settings) {
    if (!recordOnly) {
      // recompute model, then select random target TPF server according to the cost-model
      model.computeModel()
      const searchParams = new URL(settings.url).search
      const selectedServer = sample(model.getRNGVector())
      settings.url = `${selectedServer}${searchParams}`
      if (!isUndefined(settings.headers)) {
        settings.headers.referer = selectedServer
      }
    }
    const url = settings.url.split('?').shift()
    const startTime = Date.now()
    const request = ldfRequester(settings)
    // update model on response
    request.on('response', () => {
      const endTime = Date.now() - startTime
      model.setResponseTime(url, endTime)
    })
    return request
  }
}

module.exports = createUlyssesRequest