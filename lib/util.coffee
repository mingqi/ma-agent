http = require 'http'
zlib = require 'zlib'
us = require 'underscore'
async = require 'async'  
running = require('is-running')

exports.systemTime = systemTime = () ->
  (new Date()).getTime()

exports.wait = wait = (interval, timeout, test, callback) =>
  started_time = systemTime()
  async.whilst(
    () ->
      return !test() and (systemTime() - started_time) < timeout
  , (callback) ->
      setTimeout(callback, interval)         
  , () ->
      if test()
        callback(null, true)
      else
        callback(null, false)
    )
        
exports.kill = kill = (pid, timeout, callback) ->
  killTime = systemTime()
  try
    process.kill(pid, "SIGTERM")
  catch e
    if e.code == 'EPERM'
      return callback(new Error('no permission to kill process'))

  wait(100, timeout
  , () ->
      not running(pid) 
  , (err, not_running) ->
      if not not_running    
        process.kill(pid, "SIGKILL")
      callback() 
  )       


exports.rest = (options, body, callback) ->
  if not callback
    callback = body
    body = null

  options.headers ||= {}
  us.extend(options.headers, {'Accept-Encoding' : 'gzip'})

  if body
    us.extend(options.headers, {
      'Content-Type' : 'application/json',
      'Content-Encoding' : 'gzip'})
    if not us.isString(body)
      body = JSON.stringify(body)

  buffs = []
  request = http.request(options, (response) ->
    response.on('data', (chunk) ->
      buffs.push chunk    
    )

    response.on('end',  () ->
      buffer = Buffer.concat(buffs);
      result = null
      if buffer.length > 0
        if response.headers['content-encoding'] == 'gzip'
          zlib.gunzip(buffer, (err, result) ->
            if err
              return callback(new Error('illegal gzip content'))
            else
              try
                r = JSON.parse(result)
              catch e
                console.log response.statusCode
                callback(new Error("bad response, not JSON formant: #{result}"))      
              callback(null, response.statusCode, r) 
              
          ) 
        else
          try
            result = JSON.parse(buffer.toString())
            callback(null, response.statusCode, result) 
          catch e
            console.log response.statusCode
            callback(new Error("bad response, not JSON formant: #{buffer.toString()}"))      
    )
  )

  request.on('error', (e) ->
    callback(e)  
  )

  if body
    zlib.gzip(body, (err, result) ->
        request.write(result);
        request.end()
      )
  else
    request.end()
