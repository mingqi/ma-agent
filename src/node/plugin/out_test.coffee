http = require 'http'
zlib = require 'zlib'
buffer = require '../buffer'


Upload = (config) ->

  return {
    name : 'upload'
    
    start : (cb) ->
      console.log "output test started"
      cb()    

    shutdown : (cb) ->
      cb()

    writeChunk : (chunk, cb) ->
      records = chunk.map((data) ->
        data.record.count
      )
      console.log "write chunk #{records}"
      cb("fffffffff")
  }


module.exports = (config) -> 
  buffer(config, Upload(config))
