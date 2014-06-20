# Buffer = rquire 'buffer'
# Upload = require 'upload'

# Buffer(config, Upload)

# exports = (config) ->
#   Buffer(config, Upload(config))


module.exports = (config, output) ->

  buffer = []

  collectBuffer = () ->
    if buffer.length > 0
      chunkReceiver(buffer)
      buffer = []

  intervalObj = null 

  return {

    start : (cb) ->
      output.start((err) ->
        if not err
          intervalObj = setInterval(collectBuffer, config.flush_interval * 1000)
        cb(err)
      )

    write : (tag, record, time) ->
      buffer.push([tag, record, time])
      if buffer.length >= config.buffer_size
        collectBuffer() 

    shutdown : (cb) ->
      if buffer.length > 0
        collectBuffer()

      if intervalObj
        clearInterval(intervalObj)

      output.shutdown(cb)
  }