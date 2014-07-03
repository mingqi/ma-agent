Engine = require './engine'
upload = require './plugin/out_upload'
us = require 'underscore'
stdout = require './plugin/out_stdout'
hoconfig = require 'hoconfig-js'
path = require 'path'
glob = require 'glob'
fs = require 'fs'
md5 = require 'MD5'

INPUT_PLUGINS = {
  sql : require './plugin/in_sql'
  tail : require './plugin/in_tail'
  test : require './plugin/in_test'
}

_hashConfig = (config) ->
  pair_list = for k in us.keys(config).sort()
    k + ':' + config[k] 
  md5(JSON.stringify(pair_list.join(',')))

module.exports = Agent = (configer, inputs, outputs, options) -> 
  remote_host = options.remote_host || 'localhost'
  remote_port = options.remote_port || 9090
  buffer_size = options.buffer_size || 1000
  buffer_flush = options.buffer_flush || 3

  input_config_index = {}
  input_index = {}
  engine = Engine()

  for input in inputs
    engine.addInput(input)

  for [match, output] in outputs
    engine.addOutput(match, output)

  # engine.addOutput('tsd', upload({
  #   host : remote_host
  #   port : remote_port
  #   uri : '/tsd'
  #   buffer_size : buffer_size
  #   flush_interval : buffer_flush
  #   }))
  
  # engine.addOutput('tsd', stdout())

  flushInput = () ->
    configer( (err, config) ->
      target = {}
      for in_conf in config
        target[_hashConfig(in_conf)] = in_conf

      to_add = us.difference(us.keys(target), us.keys(input_config_index))
      to_remove = us.difference(us.keys(input_config_index), us.keys(target))

      for remove_index in to_remove
        input = input_index[remove_index]
        engine.removeInput(input)
        delete input_index[remove_index]
        delete input_config_index[remove_index]

      for add_index in to_add
        in_conf = target[add_index]
        type = in_conf.type
        plugin = INPUT_PLUGINS[type]
        if not plugin
          throw new Error("type #{type} is not supported")
        input = plugin(in_conf)
        engine.addInput(input, (err) ->
          if not err
            input_index[add_index] = input
            input_config_index[add_index] = in_conf
        )
    )


  return {
    start : () ->
      engine.start((err) ->
        flushInput()
        console.log "engine started"

        setInterval(flushInput, 2000)
      )
    
    shutdown : () ->
      engine.shutdown( (err) ->
        console.log "engine shutdown"
      )
  }


