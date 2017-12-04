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
   * Get the set of replicated TPF servers
   * @return {string[]} The set of replicated TPF servers
   */
  get servers () {
    return this._servers
  }

  /**
   * Get the last recorded latencies
   * @return {Object} URLs of servers associated with their last recorded latencies
   */
  get latencies () {
    return this._times
  }

  /**
   * Get the number of triples per page per server
   * @return {Object} URLs of servers associated with their number of triples per page
   */
  get triplesPerPage () {
    return this._triplesPerPage
  }

  /**
   * Get the current weights of servers
   * @return {Object} URLs of servers associated with their current weight
   */
  get weights () {
    return this._weights
  }

  /**
   * Get capability coefficients of servers
   * @return {Object} URLs of servers associated with their capability coefficient
   */
  get coefficients () {
    return this._coefficients
  }

  /**
   * Get the sum of all coefficients
   * @return {integer} The sum of all coefficients
   */
  get sumCoefficients () {
    return this._sumCoefs
  }

  /**
   * Remove a server from the model
   * @param  {string} url - URL of the server to remove
   * @return {void}
   */
  removeServer (url) {
    const ind = this._servers.indexOf(url)
    if (ind >= 0) {
      this._servers.splice(ind, 1)
      delete this._times[url]
      delete this._triplesPerPage[url]
      this.computeModel()
    }
  }

  /**
   * Return a subset of the model for a given set of servers
   * @param {string[]} servers - Set of servers used to filter the model
   * @return {Model} A submodel
   */
  subset (servers) {
    const times = servers.map(s => this._times[s])
    const triplesPerPage = zipObject(servers, servers.map(s => this._triplesPerPage[s]))
    return new Model(servers, times, triplesPerPage)
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
   * @param {number} realTime - Real execution of the last request sent to this server (!= of time in case of failover)
   * @return {void}
   */
  setResponseTime (endpoint, time, realTime) {
    this._times[endpoint] = time
    this.emit('updated_time', endpoint, time, realTime)
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
   * @return {string[]} A randomized vector of servers URI
   */
  getRNGVector () {
    if (this._servers.length === 1) return [ this._servers[0] ]
    const vector = values(this._coefficients).map(x => x / this._sumCoefs)
    return flatten(vector.map((p, ind) => times(p * 100, constant(this._servers[ind]))))
  }
}

module.exports = Model
