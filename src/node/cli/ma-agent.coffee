#!/usr/local/ma-agent/node/bin/node

us = require 'underscore'
Agent = require '../agent'
plugin = require '../plugin'
config = require '../config'
hoconfig = require 'hoconfig-js'
stdout = require '../plugin/out_stdout'
upload = require '../plugin/out_upload'
host = require '../plugin/in_host'
program = require 'commander'
path = require 'path'
supervisor = require '../supervisor'
version = require '../version'

agent = null
run = (callback) -> 
  config_file = program.config or '/etc/ma-agent/ma-agent.conf'
  root = program.root or '/opt/ma-agent/'
  options = hoconfig(config_file)

  remote_config = (callback) ->
    config.remote({
      host: options.remote_host, 
      port: options.remote_port, 
      license_key: options.license_key
      }, callback)

  remote_backup_config = (callback) ->
    config.backup(
      remote_config,
      path.join(root, 'var/remote_backup_config.json')
      callback)

  local = (callback) ->
    config.local('/etc/ma-agent/monitor.d', callback)

  merged_config = (callback) ->
    config.merge(remote_backup_config, local, callback)
    

  input_plugins = []
  local (err, config) ->
    return callback(err)  if err
    for in_config in config
      in_plugin = plugin.plugin(in_config.type)
      if not in_plugin
        return callback(new Error("#{in_config.type} is not supported plugin type"))
      try
        input_plugins.push(in_plugin(in_config))
      catch e
        return callback(new Error("failed to initialize input config '#{in_config.monitor}': #{e.message}"))
  input_plugins.push host({interval: 10}) 

  tsd_upload = upload({
    remote_host : options.remote_host
    remote_port : options.remote_port
    buffer_size : options.buffer_size || 1000
    buffer_flush : options.buffer_flush || 30
    license_key: options.license_key
    uri: '/tsd'
    })

  host_upload = upload({
    remote_host : options.remote_host
    remote_port : options.remote_port
    buffer_size : 1000
    buffer_flush : 1
    license_key: options.license_key
    uri: '/host'
    })

  report_upload = upload({
    remote_host : options.remote_host
    remote_port : options.remote_port
    buffer_size : 1000
    buffer_flush : 1
    license_key: options.license_key
    uri: '/report'
    })

  agent = Agent(
    merged_config,
    [], 
    [
      ['tsd', tsd_upload],
      ['tsd', stdout()],
      ['host', host_upload]
      ['host', stdout()],
      ['report', report_upload]
      ['report', stdout()],
    ]
  )

  agent.start(callback)

supervisord = () ->
  script = process.argv[1]
  args = process.argv[2..]
  sup = supervisor.Supervisor(script, args, 3000)
  sup.run((err) ->
    if err
      console.log "failed to start ma-agent: #{err.message}"   
      process.exit(1)
  )


program
  .version(version)
  .option('-r, --root [path]', 'application root directory')
  .option('-c, --config [path]', 'config file')
  .option('-s, --supervisord', 'use supervisord mode')
  .parse(process.argv)
  
if program.supervisord and not process.env.__supervisor_child
  supervisord()
else
  run (err) ->
    if err
      console.log err.stack
      process.exit(1) 
    supervisor.checkHeartbeat(3000)

    process.on 'SIGTERM', () ->
      agent.shutdown (err) ->
        console.log "ffffffffffff"
        console.log err.stack if err
        process.exit()

     process.on 'SIGINT', () ->
      agent.shutdown (err) ->
        console.log err.stack if err
        process.exit()
      