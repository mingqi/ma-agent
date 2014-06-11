events = require('events');
Engine = () ->
  
  inputs = []  
  outputs = []

  eventEmitter = new events.EventEmitter();

  emit = (tag, record, time) ->
    for [match, output] in outputs
      if match == tag
        setImmediate(() ->
          output.receive(tag, record, time || Date() )            
        )     
  
  return {
    add_input : (input) ->
      inputs.push input

    add_output : (match, output) ->
      outputs.push [match, output]

    start : () ->
      for i in inputs
        i.start(emit)

    shutdown : () ->
      for i in inputs
        i.shutdown()

      for o in outputs
        o.shutdown() 

    } 

module.exports = Engine()