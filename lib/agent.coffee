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
  dbquery : require './plugin/in_sql'
  tail : require './plugin/in_tail'
  test : require './plugin/in_test'
}

_hashConfig = (config) ->
  pair_list = for k in us.keys(config).sort()
    k + ':' + config[k] 
  md5(JSON.stringify(pair_list.join(',')))

module.exports = Agent = (configer, inputs, outputs) -> 

  input_config_index = {}
  input_index = {}
  engine = Engine()

  for input in inputs
    engine.addInput(input)

  for [match, output] in outputs
    engine.addOutput(match, output)


  flushInput = () ->
    configer( (err, config) ->
      if err
        console.log err.stack
        return
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