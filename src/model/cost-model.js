/* file : cost-model.js
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

const { zipObject } = require('lodash')

/**
 * Compute the cost model using a list of servers and their respective reponse times
 * @param  {string[]} servers - The servers of the model
 * @param  {number[]} times     - The reponse time of each endpoint
 * @param  {Object} metadata    - The metadata about the query associated with this cost model
 * @param  {Object} metadata.nbTriples   - The number of triples per pattern of the query
 * @param  {int} metadata.triplesPerPage - The number of triples per page
 * @return {Object} The coefficient of the cost model for each endpoint and the sum of all coefficients
 */
const computeModel = (servers, times, metadata = {}) => {
  const weights = times.map(t => 1 / t)
  const minWeight = Math.min(...weights)
  const coefs = weights.map(w => Math.floor(w / minWeight))
  return {
    servers,
    coefficients: zipObject(servers, coefs),
    sumCoefs: coefs.reduce((acc, c) => acc + c, 0),
    nbTriples: metadata.nbTriples || {},
    triplesPerPage: metadata.triplesPerPage || -1
  }
}

module.exports = computeModel
