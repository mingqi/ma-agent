Engine = require './engine'
plugin = require './plugin'
upload = require './plugin/out_upload'
us = require 'underscore'
stdout = require './plugin/out_stdout'
hoconfig = require 'hoconfig-js'
path = require 'path'
glob = require 'glob'
fs = require 'fs'
md5 = require 'MD5'
async = require 'async'
VError = require('verror');

_hashConfig = (config) ->

  pair_list = for k in us.keys(config).sort()
    k + ':' + config[k] 
  md5(JSON.stringify(pair_list.join(',')))

module.exports = Agent = (configer, inputs, outputs) -> 

  running_inputs = {}
  engine = Engine()

  for input in inputs
    engine.addInput(input)

  for [match, output] in outputs
    engine.addOutput(match, output)

  refreshInput = () ->
    configer (err, config) ->
      if err
        logger.error err.stack
        return

      fresh_inputs = {}
      for in_conf in config
        fresh_inputs[_hashConfig(in_conf)] = in_conf

      to_add = us.difference(us.keys(fresh_inputs), us.keys(running_inputs))
      to_remove = us.difference(us.keys(running_inputs), us.keys(fresh_inputs))

      async.series [
        (callback) ->
          # it's will be serious problem if failed to shutdown
          # a plugin. That will result in duplicate plugin running.
          # So throw a exception to force process to restart 
          async.each to_remove
          , (input_hash, callback) ->
              engine.removeInput running_inputs[input_hash], (err) ->
                delete running_inputs[input_hash] if not err
                err = new VError(err, "failed to shutdown running input plugin") if err
                callback(err)
          , (err) ->
              throw err if err
              callback() 
        
        (callback) ->
          # the start plugin is difference with shutdown. any failure should NOT 
          # impact other plugin. So we ignore all error related to individual plugin
          async.each to_add
          , (input_hash, callback) ->
              in_conf = fresh_inputs[input_hash]
              type = in_conf.type
              in_plugin = plugin.plugin(type)
              if not in_plugin
                ## ignore this error to prevent from impact other plugins
                logger.error "type #{type} is not supported"
                return callback()
              try
                input = in_plugin(in_conf)
              catch e
                ## ignore this error to prevent from impact other plugins
                logger.error e.stack
                return callback()
              
              engine.addInput input, (err) ->
                if err
                  logger.error err if err
                else
                  running_inputs[input_hash] = input

                callback()
        ]
      , (err) ->
          logger.error err if err
                  

  return {
    start : (callback) ->
      engine.start((err) ->
        return callback(err) if err
        refreshInput()
        logger.info "engine started"
        setInterval(refreshInput, 2000)
        callback()
      )
    
    shutdown : (callback) ->
      engine.shutdown(callback)
  }