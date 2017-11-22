/* file : selection.js
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

const { patternContainment, stringifyPattern } = require('../utils.js')

/**
 * A Selection gives, for a triple pattern, the list of all relevant servers
 * @author Thomas Minier
 */
class Selection {
  constructor () {
    this._selection = new Map()
    this._references = []
  }

  set (pattern, servers) {
    this._references.push(pattern)
    this._selection.set(stringifyPattern(pattern), servers)
  }

  get (pattern) {
    // try to find containment first
    const refPattern = patternContainment(pattern, this._references)
    if (refPattern === null) return null
    return this._selection.get(stringifyPattern(refPattern))
  }
}

module.exports = Selection
