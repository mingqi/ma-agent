http = require 'http'
zlib = require 'zlib'
buffer = require '../buffer'


Upload = (config) ->

  return {
    start : (cb) ->
      cb()    

    shutdown : (cb) ->
      cb()

    writeChunk : (chunk) ->
      body = []
      for [tag, record, time] in chunk
        body.push(record)

      options = {
        host: config.host
        port: config.port
        method: 'POST'
        path: config.uri
        headers : {
          'Content-Type' : 'application/json'
          'Content-Encoding' : 'gzip'
        }
      }

      req = http.request(options, (res) ->
        res.setEncoding('utf8');
        res.on('data', (chunk) -> 
          console.log "post status is " + res.statusCode
        ) 
      )

      console.log("there are #{body.length} record ready for send")
      zlib.gzip(JSON.stringify(body), (err, result) ->
        req.write(result);
        req.end() 
      )
     
  }


module.exports = (config) -> 
  buffer(config, Upload(config))
