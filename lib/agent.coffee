Engine = require './engine'
upload = require './plugin/out_upload'
us = require 'underscore'
stdout = require './plugin/out_stdout'
hoconfig = require 'hoconfig-js'
path = require 'path'
glob = require 'glob'
fs = require 'fs'

INPUT_PLUGINS = {
  sql : require './plugin/in_sql'
  tail : require './plugin/in_tail'
}


module.exports = Agent = (options, plugin_config) -> 
  console.log options

  remote_host = options.remote_host || 'localhost'
  remote_port = options.remote_port || 9090
  buffer_size = options.buffer_size || 1000
  buffer_flush = options.buffer_flush || 3

  engine = Engine()

  engine.addOutput('tsd', upload({
    host : remote_host
    port : remote_port
    uri : '/tsd'
    buffer_size : buffer_size
    flush_interval : buffer_flush
    }))
  
  # engine.addOutput('tsd', stdout())

  config_path = plugin_config 
  if not fs.existsSync(config_path)
    throw new Error("not exists dir or file on #{config_path}")

  stat = fs.statSync(config_path) 
  if stat.isFile()
    config = hoconfig(options.config_file)
  else
    config = us.reduce(
      glob.sync(path.join(config_path, '*.conf')),
      (c, file) ->
        us.extend(c, hoconfig(file))
      , 
      {})

  for metric_name, in_conf of config
    type = in_conf.type
    plugin = INPUT_PLUGINS[type]
    if not plugin
      throw new Error("type #{type} is not supported")   

    engine.addInput(plugin(us.extend(in_conf, {metric : metric_name})))

  return {
    start : () ->
      engine.start((err) ->
        console.log "engine started"
      )
    
    shutdown : () ->
      engine.shutdown( (err) ->
        console.log "engine shutdown"
      )
  }


args = process.argv[2..]
if args.length !=2
  console.error "useage: agent <agent-config-file> <plguin-config-file>"
  process.exit(1)

agent = Agent(hoconfig(args[0]), args[1])
agent.start()