events = require('events');
utile = require 'utile'
async = require 'async'

empty_cb = `function (err){}`

wrapPlugin = (type, plugin) ->
  ## avoid plugin was started more than once 
  started = false
  return {
    start : (emit, cb) ->
      cb ||= empty_cb
      if type == 'output'
        ## output only have one parameter cb
        cb = emit 

      start_cb = (err) ->
          if err
            started = false
          cb(err)
         
      if not started
        started = true

        if type == 'input'
          args = [emit, start_cb]
        else
          args = [start_cb]

        plugin.start.apply(plugin, args)
      else
        cb()
    
    shutdown : (cb) ->
      cb ||= empty_cb
      if started
        plugin.shutdown((err) ->
          if not err
            started = false
          cb(err)
        )
      else
        cb()
    } 


Engine = () ->
  inputs = []
  outputs = []
  input_track = {}
  output_track = {}
  eventEmitter = new events.EventEmitter();
  started = false

  emit = (tag, record, time) ->
    for [match, output] in outputs
      if match == tag
        setImmediate(() ->
          output.receive(tag, record, time || Date() )            
        )

    output = wrapPlugin('output', output)
    index = outputs.push([match, output]) - 1
    output_track[id] = index

  
  return {
    add_input : (input, id, cb) ->
      if not id
        id = utile.randomString(5)

      input = wrapPlugin('input',input)
      index = inputs.push(input) - 1
      input_track[id] = index

      if started
        input.start(emit, (err) ->
          cb(err, id) if cb
        )
      else
        cb(null, id) if cb

    add_output : (match, output, id, cb) ->
      if not id
        id = utile.randomString(5)

      output = wrapPlugin('output', output)
      index = outputs.push([match, output]) - 1
      output_track[id] = index

      if started
        output.start((err) ->
          cb(err, id) if cb
        )  
      else
        cb(null, id) if cb


    remove_input : (id, cb) ->
      index = input_track[id]
      input = inputs[index]
      inputs.splice(index, 1) 
      delete input_track[id]
      if started
        input.shutdown(cb)
      else
        cb() if cb
    
    remove_output : (id, cb) ->
      index = output_track[id]
      output = outputs[index]
      outputs.splice(index, 1) 
      delete output_track[id]
      if started
        output.shutdown(cb)
      else
        cb() if cb 
     
    start : (callback) ->
      started = true
      async.series([
        (callback) ->
          async.each(
            outputs.slice(0), 
            ([m, o], callback) ->
              o.start(callback) 
            ,        
            callback
            )
        ,
        (callback) ->
          async.each(
            inputs.slice(0), 
            (i, callback) ->
              i.start(emit, callback)
            , 
            callback
            )]
        ,
        (err) ->
          if err
            started = false
          callback(err)  
        )

    shutdown : (callback) ->
      started = false
        
      async.series([
        (callback) ->
          async.each(
            inputs.slice(0), 
            (i, callback) ->
              i.shutdown( callback) 
            ,        
            callback
            )

        (callback) ->
          async.each(
            outputs.slice(0), 
            ([m, o], callback) ->
              o.shutdown(callback) 
            ,        
            callback
            )
         
        ],
        (err) ->
          if err
            started = true

          callback(err) 
        )
    }

module.exports = Engine()