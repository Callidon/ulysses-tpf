/* file : source-selection-test.js
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

const sourceSelection = require('../src/source-selection/source-selection.js')

describe('Sourceselection', () => {
  it('should perform a source selection', done => {
    const servers = [ 'http://fragments.dbpedia.org/2016-04/en', 'http://fragments.mementodepot.org/scigraph' ]
    const query = 'SELECT * WHERE { ?s ?p ?o . <http://www.springernature.com/scigraph/ontologies/core/Affiliation> ?p1 ?o1. }'
    sourceSelection(query, servers).then(selection => {
      expect(selection.get({
        subject: '?s',
        predicate: '?p',
        object: '?o'
      })).toEqual(servers)
      expect(selection.get({
        subject: 'http://www.springernature.com/scigraph/ontologies/core/Affiliation',
        predicate: '?p1',
        object: '?o1'
      })).toEqual(servers.slice(1))
      done()
    })
  })
})
