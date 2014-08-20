program = require 'commander'
path = require 'path'
fs = require 'fs'
us = require 'underscore'
Agent = require '../agent'
plugin = require '../plugin'
config = require '../config'
hoconfig = require 'hoconfig-js'
stdout = require '../plugin/out_stdout'
upload = require '../plugin/out_upload'
host = require '../plugin/in_host'
supervisor = require '../supervisor'
version = require '../version'
util = require '../util'
winston = require 'winston'

global.logger = new (winston.Logger)({exitOnError: true})

readLicenseKey = (license_key_file) ->
  if not fs.existsSync(license_key_file)
    throw new Error("license key #{license_key_file} doesn't exists!")

  content = fs.readFileSync(license_key_file, {encoding: "utf8"})
  return content.trim()
  

runAgent = (root, options, callback) -> 
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
    remote_backup_config,
    input_plugins, 
    [
      ['tsd', tsd_upload],
      ['host', host_upload]
      ['report', report_upload]
    ]
  )

  agent.start (err) ->
    return callback(err) if err
    callback(null, agent)   
  

worker = (program, options) ->
  ## this is child run
  root = program.root or '/opt/ma-agent/'
  runAgent root, options, (err, agent) ->
    if err
      logger.error err.stack
      process.exit(1) 

    supervisor.checkHeartbeat(3000)

    process.on 'SIGTERM', () ->
      agent.shutdown (err) ->
        logger.error err.stack if err
        process.exit()

     process.on 'SIGINT', () ->
      agent.shutdown (err) ->
        logger.error err.stack if err
        process.exit()

    process.on 'uncaughtException', (err) ->
      logger.error err.stack, () ->
        agent.shutdown (err) ->
          logger.error err.stack if err
          process.exit()

      ## process will exit in 3 seconds
      setTimeout(() ->
        process.exit()
      , 3000 )
        

supervisord = () ->
  script = process.argv[1]
  args = process.argv[2..]
  sup = supervisor.Supervisor(script, args, 3000)
  sup.run((err) ->
    if err
      console.log "failed to start ma-agent: #{err.message}"   
      process.exit(1)
  )


main = () ->
  program
    .version(version)
    .option('-r, --root [path]', 'application root directory')
    .option('-c, --config [path]', 'config file')
    .option('--license_key [path]', 'license key file')
    .option('-s, --supervisord', 'use supervisord mode')
    .parse(process.argv)

  options = 
    remote_host : 'api.metricsat.com'
    remote_port : 443
    buffer_size : 10000
    buffer_flush : 30
    agent_report_interval: 30

  us.extend options, hoconfig(program.config or '/etc/ma-agent/ma-agent.conf')
  license_key_file = program.license_key or '/etc/ma-agent/license_key'

  try
    license_key = readLicenseKey(license_key_file)
  catch e
    console.log "license key can't be read correctly: #{e.message}"
    process.exit(1)
  
  options.license_key = license_key

  ## init logger
  if options.log_file == 'console'
    logger.add(winston.transports.Console, {level: options.log_level, timestamp: true})
  else
    maxSize = 10 * 1024 * 1024 #10m
    if options.log_file_size
      maxSize = util.parseHumaneSize(options.log_file_size)

    maxFiles = 5
    if options.log_file_count
      maxFiles = parseInt(options.log_file_count)

    logger.add(winston.transports.File, {
      filename: options.log_file, 
      level: options.log_level, 
      timestamp: true, 
      maxsize: maxSize
      maxFiles: maxFiles
      handleExceptions: false
      json: false});

  if program.supervisord and not process.env.__supervisor_child
    supervisord()
  else
    worker(program, options)

main()