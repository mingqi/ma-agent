events = require('events');
utile = require 'utile'
async = require 'async'
us = require 'underscore'
util = require 'util'
empty_cb = `function (err){}`

global.logger = logger = winston = require 'winston'


Engine = () ->
  inputs = []
  outputs = []
  eventEmitter = new events.EventEmitter();

  started = false

  emit = (data) ->
    data.time ||= Date()
    for [match, output] in outputs
      if match == data.tag
        setImmediate(
          (o) ->
            o.write(data)
          , output
        )

  indexOfOutput = (match, output) ->
    for i in [0...outputs.length]
      [m, o] = outputs[i]
      return i if m == match and o == output
    return -1
 
  return {
    
    ## only first argument input is mandatory
    addInput : (input, cb) ->
      if inputs.indexOf(input) >= 0
        cb() 
        return 

      inputs.push(input)

      if started
        input.start(emit, cb)

      else
        cb(null) if cb

    addOutput : (match, output, cb) ->
      if indexOfOutput(match, output) >= 0
        cb()

      outputs.push([match, output])
      if started
        output.start(cb)

      else
        cb(null) if cb

    removeInput : (input, cb) ->
      index = inputs.indexOf(input)
      if index < 0
        cb() if cb
        return

      inputs.splice(index, 1) 
      if started
        input.shutdown(cb)
      else
        cb() if cb
    
    removeOutput : (match, output, cb) ->
      index = indexOfOutput(match, output)
      if index < 0
        cb() if cb
        return

      outputs.splice(index, 1) 
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

module.exports = Engine