Engine = require './engine'
upload = require './plugin/out_upload'
md5 = require 'MD5'
us = require 'underscore'
fs = require 'fs'
stdout = require './plugin/out_stdout'

INPUT_PLUGINS = {
  sql : require './plugin/in_sql'
}

_hashConfig = (config) ->
  pair_list = for k in us.keys(config).sort()
    k + ':' + config[k] 
  md5(JSON.stringify(pair_list.join(',')))


module.exports = Agent = (options) ->
  config_flush = options.config_flush
  remote_host = options.remote_host
  remote_port = options.remote_port
  buffer_size = options.buffer_size || 1000
  buffer_flush = options.buffer_flush || 30
  cache_file = options.cache_file

  engine = Engine()
  configInterval = null

  # engine.addOutput('tsd', upload({
  #   host : remote_host
  #   port : remote_port
  #   uri : '/tsd'
  #   buffer_size : buffer_size
  #   flush_interval : buffer_flush
  #   }))

  engine.addOutput('tsd', stdout())

  flushInput = (configs) ->
    config_index = us.object(us.map(configs, _hashConfig),configs)
    new_ids = us.keys(config_index)
    running_ids = engine.inputIds()

    console.log new_ids
    console.log running_ids
    for id in us.difference(running_ids, new_ids)
      engine.removeInput(id) 
     
    for id in us.difference(new_ids, running_ids)
      config = config_index[id]
      continue if not INPUT_PLUGINS[config.type]
      engine.addInput(INPUT_PLUGINS[config.type](config), id)


  flushFromFile =  () ->
    console.log "flush from file"
    file = cache_file
    file_content = fs.readFileSync(file)      
    configs = JSON.parse(file_content)
    flushInput(configs)

  # flushFromRemote = () ->
  #   file = options.cache_file
  #   config_content = .....
  #   configs = JSON.parse(config_content) 
  #   flushInput(configs)
  #   fs.writeFileSync(file)

  d = require('domain').create();
  d.on('error', (er) ->
      console.error('error, but oh well', er.message);
      console.error er.stack
  )

  return {
    start : () ->
      engine.start((err) ->
        configInterval = setInterval(flushFromFile, config_flush * 1000)  
      )
    
    shutdown : () ->
      clearInterval(configInterval)
      engine.shutdown()
  }

agent = Agent({
  config_flush : 10
  cache_file : '/Users/mingqi/monitorat/ma-agent/test/agent.json'
  })
agent.start()
