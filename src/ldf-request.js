// Fork of the original LDF Request.js file, by Thomas Minier
// @license MIT ©2016 Ruben Verborgh, Ghent University - imec
const EventEmitter = require('events').EventEmitter
const _ = require('lodash')
const url = require('url')
const http = require('follow-redirects').http
const https = require('follow-redirects').https
const zlib = require('zlib')

// Try to keep connections open, and set a maximum number of connections per server
const AGENT_SETTINGS = { keepAlive: true, maxSockets: 5 }
const AGENTS = {
  http: new http.Agent(AGENT_SETTINGS),
  https: new https.Agent(AGENT_SETTINGS)
}

// Decode encoded streams with these decoders
const DECODERS = { gzip: zlib.createGunzip, deflate: zlib.createInflate }

// Creates an HTTP request with the given settings
function createRequest (settings) {
  // Parse the request URL
  if (settings.url) {
    _.assign(settings, url.parse(settings.url))
  }

  // Emit the response through a proxy
  let request
  const requestProxy = new EventEmitter()
  const requester = settings.protocol === 'http:' ? http : https
  settings.agents = AGENTS
  if (_.isUndefined(settings.requestStartTime)) {
    settings.requestStartTime = Date.now()
  }
  request = requester.request(settings, function (response) {
    const realTime = Date.now() - settings.requestStartTime
    if (response.statusCode !== 200) {
      requestProxy.emit('error', 'ERROR 404', settings.url)
      request.abort()
    } else {
      response = decode(response)
      response.setEncoding('utf8')
      response.pause() // exit flow mode
      requestProxy.emit('response', response, realTime)
    }
  })
  // catch errors
  request.on('error', err => {
    requestProxy.emit('error', err, settings.url)
    request.abort()
  })
  request.end()
  requestProxy.abort = function () { request.abort() }
  return requestProxy
}

// Returns a decompressed stream from the HTTP response
function decode (response) {
  const encoding = response.headers['content-encoding']
  if (encoding) {
    if (encoding in DECODERS) {
      // Decode the stream
      const decoded = DECODERS[encoding]()
      response.pipe(decoded)
      // Copy response properties
      decoded.statusCode = response.statusCode
      decoded.headers = response.headers
      return decoded
    }
    // Error when no suitable decoder found
    setImmediate(function () {
      response.emit('error', new Error('Unsupported encoding: ' + encoding))
    })
  }
  return response
}

module.exports = createRequest
