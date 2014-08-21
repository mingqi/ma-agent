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
- buffer_flush
- buffer_size
- retry_times
- retry_interval

###

async = require 'async'
assert = require 'assert'

retry = (times, wait_sec, task, cb) ->
  did = 0 
  async.retry(times,
    (cb) ->
      task((err) ->
        did += 1
        logger.debug "#{did} times to do task"
        if not err
          cb()
        else
          timeout_secs = wait_sec * (2 ** (did - 1) )
          logger.debug "failed to do task, next will wait #{timeout_secs} seconds"
          setTimeout(
            () ->
              cb(err) 
            , 
            1000 * timeout_secs
            ))
    ,
    cb)

module.exports = (config, output) ->
  buffer_size = parseInt(config.buffer_size)
  buffer_flush = parseInt(config.buffer_flush)
  assert.ok(buffer_size, "option buffer_size is required for buffered output plugin")  
  assert.ok(buffer_flush, "option buffer_flush is required for buffered output plugin")  

  retry_times = parseInt(config.retry_times) || 5
  retry_interval = parseInt(config.retry_interval) || 10

  console.log "retry_times= #{retry_times}"

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
          intervalObj = setInterval(collectBuffer, buffer_flush * 1000)
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