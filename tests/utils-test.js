/* file : utils-test.js
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

const { patternContainment } = require('../src/utils.js')

describe('Utils', () => {
  describe('#patternContainment', () => {
    it('should find pattern containment', () => {
      const references = [
        {
          subject: '?s',
          predicate: 'http:/example.org/predicate',
          object: '?o'
        }
      ]

      const patterns = [
        {
          pattern: {
            subject: '?s',
            predicate: 'http:/example.org/predicate',
            object: '?o'
          },
          match: references[0]
        },
        {
          pattern: {
            subject: 'http://example.org/subject',
            predicate: 'http:/example.org/predicate',
            object: '?o'
          },
          match: references[0]
        },
        {
          pattern: {
            subject: '?s',
            predicate: 'http:/example.org/predicate',
            object: 'http://example.org/object'
          },
          match: references[0]
        },
        {
          pattern: {
            subject: 'http://example.org/subject',
            predicate: 'http:/example.org/predicate',
            object: 'http://example.org/object'
          },
          match: references[0]
        }
      ]

      patterns.forEach(elt => {
        expect(patternContainment(elt.pattern, references)).toBe(elt.match)
      })
    })
  })
})
