/* file : model.js
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

const EventEmitter = require('events')
const formulas = require('./formulas.js')
const { constant, flatten, mapValues, times, values, zipObject } = require('lodash')

/**
 * Model represents an instance produced by the cost model.
 * It can be accessed, updated and recomputed during execution.
 * @author Thomas Minier
 */
class Model extends EventEmitter {
  /**
   * Constructor
   * @param  {string[]} servers           - Set of TPF servers used to process the query
   * @param  {number[]} times             - Initial reponse times of each TPF server
   * @param  {Object[]} triplesPerPage    - Triples served per page per endpoint
   * @param  {boolean}  [preCompute=true] - Wheter the model should be precompiled after creation or not
   */
  constructor (servers, times, triplesPerPage, preCompute = true) {
    super()
    this._servers = servers
    this._times = zipObject(servers, times)
    this._triplesPerPage = Object.assign({}, triplesPerPage)
    this._weights = {}
    this._minWeight = Infinity
    this._coefficients = {}
    this._sumCoefs = 0
    if (preCompute) this.computeModel()
  }

  /**
   * Get the weight for a specific endpoint
   * @param  {string} endpoint - The endpoint
   * @return {number} The weight of the endpoint
   */
  getWeight (endpoint) {
    if (!(endpoint in this._weights)) throw new Error('Cannot get the weight of an unknow endpoint/TPF server')
    return this._weights[endpoint]
  }

  /**
   * Get the coefficient for a specific endpoint
   * @param  {string} endpoint - The endpoint
   * @return {int} The coefficient of the endpoint
   */
  getCoefficient (endpoint) {
    if (!(endpoint in this._coefficients)) throw new Error('Cannot get the coefficient of an unknow endpoint/TPF server')
    return this._coefficients[endpoint]
  }

  /**
   * Set the reponse time for an endpoint
   * @param {string} endpoint - The endpoint
   * @param {number} time     - The new reponse time of the endpoint
   * @return {void}
   */
  setResponseTime (endpoint, time) {
    this._times[endpoint] = time
    this.emit('updated_time', endpoint, time)
  }

  /**
   * (Re)Compute the model using the current response times
   * @return {void}
   */
  computeModel () {
    this._weights = mapValues(this._times, (t, e) => this._triplesPerPage[e] / t)
    this._minWeight = Math.min(...values(this._weights))
    this._coefficients = mapValues(this._weights, w => Math.floor(w / this._minWeight))
    this._sumCoefs = values(this._coefficients).reduce((acc, x) => acc + x, 0)
  }

  /**
   * Compute offset, limit and first page values for a given virtual triple pattern
   * @param  {int} totalTriples   - The cardinality of this triple pattern
   * @param  {int} triplesPerPage - Triples served per page
   * @param  {int} virtualIndex   - The index of the virtual fragment
   * @param  {int} sumCoefs       - The sum of all coefficients of the cost model
   * @return {Object} The corresponding virtual triple pattern
   */
  computeVTP (totalTriples, triplesPerPage, virtualIndex) {
    return formulas.computeVTP(totalTriples, triplesPerPage, virtualIndex, this._servers.length, values(this._coefficients), this._sumCoefs)
  }

  /**
   * Get the randomized vector used by the probabilistic implementation of PeNeLoop
   * @return {string[]} A randmoized vector of servers URI
   */
  getRNGVector () {
    const vector = values(this._coefficients).map(x => x / this._sumCoefs)
    return flatten(vector.map((p, ind) => times(p * 100, constant(this._servers[ind]))))
  }
}

module.exports = Model
