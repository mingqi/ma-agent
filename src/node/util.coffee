http = require 'http'
zlib = require 'zlib'
us = require 'underscore'
async = require 'async'  
running = require('is-running')
spawn = require('child_process').spawn
fs = require 'fs'
path = require 'path'


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


exports.shell = shell = (command, args, input, options, callback) ->
  us.extend(args, {stdio: 'pipe'})
  child = spawn(command, args, options)

  if input
    child.stdin.end(input)

  child_output = ""
  child.stdout.setEncoding('utf8')
  child.stderr.setEncoding('utf8')
  child.stdout.on 'data', (data) ->
    child_output += data
  child.stderr.on 'data', (data) ->
    child_output += data

  is_timeout = false
  child.on 'exit', (code) ->
    if not is_timeout
      return callback(null, code, child_output)
    else
      return callback(new Error("shell execute over timeout #{timeout}"))

  child_pid = child.pid

  timeout = options.timeout || 3000
  kill_timeout = options.kill_timeout || 3000
  wait 100, timeout
  , () ->
    not running(child.pid)
  , (err, not_running) ->
    if not not_running
      is_timeout = true
      kill child.pid, kill_timeout, () ->
        console.log "child shell #{child_pid} was killed because over timeout #{timeout}" 
      
  
  
  

exports.findPath = findPath = (base_dir, p) ->
  while(true)
    pp = path.join(base_dir, p)
    if fs.existsSync pp
      return pp 

    break if base_dir == '/'
    base_dir = path.dirname(base_dir)

  return null

   

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
