### 
This module is for help developer to build up buffer feature's output plugin

--- How to use ---
Buffer = rquire 'buffer'
buffered_plugin = Buffer(config, output_plugin) 

output_plguin should be a plugin instance with three methods:
1. start
2. shutdown
3. writeChunk(chunk)
    the chunk is the array of [tag, record, time]

config can below options:
- flush_interval
- buffer_size
- retry_times
- retry_interval

###

async = require 'async'

retry = (times, wait_sec, task, cb) ->
  did = 0 
  async.retry(times,
    (cb) ->
      task((err) ->
        did += 1
        if not err
          cb()
        else
          setTimeout(
            () ->
              cb(err) 
            , 
            1000 * wait_sec * (2 ** (did - 1) )
            ))
    ,
    cb)

module.exports = (config, output) ->
  buffer_size = config.buffer_size
  flush_interval = config.flush_interval
  retry_times = config.retry_times || 1
  retry_interval = config.retry_interval || 1 

  buffer = []
  collectBuffer = () ->
    if buffer.length > 0
      do(buffer) ->
        retry(
          retry_times, 
          retry_interval, 
          (cb) ->
            output.writeChunk(buffer, cb)
          ,
          (err) ->
            logger.error err.message if err
        )

      buffer = []

  intervalObj = null 

  return {

    start : (cb) ->
      output.start((err) ->
        if not err
          intervalObj = setInterval(collectBuffer, flush_interval * 1000)
        cb(err)
      )

    write : (data) ->
      buffer.push(data)
      if buffer.length >= buffer_size
        collectBuffer() 

    shutdown : (cb) ->
      if buffer.length > 0
        collectBuffer()

      if intervalObj
        clearInterval(intervalObj)

      output.shutdown(cb)
  }