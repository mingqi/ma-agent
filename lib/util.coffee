http = require 'http'
zlib = require 'zlib'
us = require 'underscore'


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
                callback(new Error("bad response, not JSON formant: #{result}"))      
              callback(null, response.statusCode, r) 
              
          ) 
        else
          try
            result = JSON.parse(buffer.toString())
            callback(null, response.statusCode, result) 
          catch e
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
