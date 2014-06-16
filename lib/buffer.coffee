# Buffer = rquire 'buffer'
# Upload = require 'upload'

# Buffer(config, Upload)

# exports = (config) ->
#   Buffer(config, Upload(config))


module.exports = (config, chunkReceiver) ->

  buffer = []

  collectBuffer = () ->
    if buffer.length > 0
      chunkReceiver(buffer)
      buffer = []

  setInterval(collectBuffer, config.flush_interval * 1000)
   
  return {
    receive : (tag, record, time) ->
      buffer.push([tag, record, time])
      if buffer.length >= config.buffer_size
        collectBuffer() 

    shutdown : () ->
      if buffer.length > 0
        collectBuffer()
  }