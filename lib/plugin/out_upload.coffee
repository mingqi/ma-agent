http = require 'http'
zlib = require 'zlib'
buffer = require '../buffer'
VError = require('verror');

###
remote_host
remote_port
license_key

# buffer config
....

###

Upload = (config) ->
  remote_host = config.remote_host
  remote_port = config.remote_port
  remote_uri = config.uri

  return {
    name : 'upload'
    
    start : (cb) ->
      console.log "upload started"
      cb()    

    shutdown : (cb) ->
      cb()

    writeChunk : (chunk, cb) ->
      body = []
      for {tag, record, time} in chunk
        body.push(record)

      options = {
        host: remote_host
        port: remote_port
        method: 'POST'
        path: remote_uri
        headers : {
          'Content-Type' : 'application/json'
          'Content-Encoding' : 'gzip'
          'licenseKey' : config.license_key
        }
      }

      req = http.request(options, (res) ->
        res.setEncoding('utf8');
        res.on('data', (chunk) -> 
          if res.statusCode != 200
            cb(new Error("upload service return error response, status=#{res.statusCode}"))
          console.log "post status is " + res.statusCode
        ) 
      )

      req.on('error', (e) ->
        cb(new VError(e, "failed to send data to #{remote_host}:#{remote_port}"))
      )

      console.log("there are #{body.length} record ready for send ")
      zlib.gzip(JSON.stringify(body), (err, result) ->
        req.write(result);
        req.end() 
      )
     
  }


module.exports = (config) -> 
  buffer(config, Upload(config))
