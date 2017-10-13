/* file : formulas.js
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

/**
 * Compute the limit for a given virtual fragment of a triple pattern
 * @param  {int} totalTriples - The cardinality of this triple pattern
 * @param  {int} index        - The index of the virtual fragment
 * @param  {int} nbVirtuals   - The total number of virtual fragments
 * @param  {int} coef         - The coefficient form the cost model associated with this fragment
 * @param  {int} sumCoefs     - The sum of all coefficients of the cost model
 * @return {int} The limit value for this virtual fragment
 */
const computeLimit = (totalTriples, index, nbVirtuals, coef, sumCoefs) => {
  if (index === nbVirtuals) return -1
  return computeOffset(totalTriples, index, nbVirtuals, coef, sumCoefs) + Math.floor(totalTriples * (coef[index - 1] / sumCoefs))
}

/**
 * Compute the offset for a given virtual fragment of a triple pattern
 * @param  {int} totalTriples - The cardinality of this triple pattern
 * @param  {int} index        - The index of the virtual fragment
 * @param  {int} nbVirtuals   - The total number of virtual fragments
 * @param  {int} coef         - The coefficient form the cost model associated with this fragment
 * @param  {int} sumCoefs     - The sum of all coefficients of the cost model
 * @return {int} The offset value for this virtual fragment
 */
const computeOffset = (totalTriples, index, nbVirtuals, coef, sumCoefs) => {
  if (index <= 1) return 0
  return computeLimit(totalTriples, index - 1, nbVirtuals, coef, sumCoefs)
}

/**
 * Compute offset, limit and first page values for a given virtual triple pattern
 * @param  {int} totalTriples   - The cardinality of this triple pattern
 * @param  {int} triplesPerPage - Triples served per page
 * @param  {int} virtualIndex   - The index of the virtual fragment
 * @param  {int} nbVirtuals     - The total number of virtual fragments
 * @param  {int} coef           - The coefficient form the cost model associated with this fragment
 * @param  {int} sumCoefs       - The sum of all coefficients of the cost model
 * @return {Object} The corresponding virtual triple pattern
 */
const computeVTP = (totalTriples, triplesPerPage, virtualIndex, nbVirtuals, coef, sumCoefs) => {
  const o = computeOffset(totalTriples, virtualIndex, nbVirtuals, coef, sumCoefs)
  const firstPage = Math.trunc(o / triplesPerPage) + 1
  let offset = 0
  if (firstPage > 1) { offset = o - ((firstPage - 1) * triplesPerPage) }
  let limit = -1
  if (totalTriples >= triplesPerPage && virtualIndex < nbVirtuals) {
    limit = computeLimit(totalTriples, virtualIndex, nbVirtuals, coef, sumCoefs) - o
  }
  return {
    offset,
    limit,
    firstPage
  }
}

module.exports = {
  computeLimit,
  computeOffset,
  computeVTP
}
