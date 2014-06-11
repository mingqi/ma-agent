http = require 'http'
zlib = require 'zlib'
module.exports = (config) -> 
  
  return {

    receive : (tag, record, time) ->
      body = JSON.stringify(record)

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

      req.on('error1', (e) ->
        console.log e
        console.log( e instanceof Error)
      )

      zlib.gzip(body, (err, result) ->
        console.log "post data #{body}"
        req.write(result);
        req.end()
      ) 
      
          
    shutdown : () ->
      console.log "upload shutdown..."          
  }