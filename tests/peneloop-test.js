/* file : peneloop-test.js
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

const Model = require('../src/model/model.js')
const peneloopRequester = require('../src/peneloop-request.js')

describe('Peneloop requester', () => {
  const servers = [ 'http://fragments.dbpedia.org/2016-04/en', 'http://fragments.dbpedia.org/2015-10/en' ]
  it('should perform an HTTP request between servers using the cost-model', done => {
    const model = new Model(servers, [ 1.0, 1.0 ], { 'http://fragments.dbpedia.org/2016-04/en': 100, 'http://fragments.dbpedia.org/2015-10/en': 100 })
    const requester = peneloopRequester(servers, model)
    const httpRequest = requester({
      url: `${servers[0]}?hello=world`,
      method: 'GET',
      timeout: 5000,
      followRedirect: true
    })
    model.on('updated_time', (server, newTime) => {
      expect(newTime).toBeGreaterThan(1)
    })
    httpRequest.on('response', () => {
      expect(model._times['http://fragments.dbpedia.org/2016-04/en'] > 1 || model._times['http://fragments.dbpedia.org/2015-10/en'] > 1).toBeTruthy()
      done()
    })
    httpRequest.on('error', done)
  })
})
