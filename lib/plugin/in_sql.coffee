mysql = require 'mysql'
pg = require 'pg'
assert = require 'assert'
report = require '../report'

###
  monitor
  dbType
  host
  port
  user
  pwd
  database
  query
###

_mysql = (config, callback) ->
  conn = mysql.createConnection({
    host : config.host,
    port: parseInt(config.port),
    user: config.user,
    password: config.pwd,
    database: config.database
  })
  conn.query(config.query, (err, rows, fields) ->
    try
      if err
        # _report("problem", err.message)
        return callback(err)

      if not rows? or rows.length <=0
        return callback(null, null)

      if rows.length > 1
        return callback(new Error('query return more then one row'))

      if fields.length > 1
        return callback(new Error("there are more than one field in query's select")) 

      value = rows[0][fields[0].name]
      callback(null, value)
    finally 
      conn.destroy()      
  )

_pg = (config, callback) ->
  con_config = 
    user: config.user
    password: config.pwd
    host: config.host
    port: parseInt(config.port)
    database: config.database
  client = new pg.Client(con_config)
  client.connect (err) ->
    if err
      return callback(err)

    client.query config.query, (err, result) ->
      try
        if err
          return callback(err)
        if result.rowCount < 1
          return callback()
        if result.rowCount > 1
          return callback(new Error('query return more then one row'))
        if result.fields.length > 1
          return callback(new Error("there are more than one field in query's select")) 
        value = result.rows[0][result.fields[0].name]
        callback(null, value) 
      finally 
        client.end()
      


DATABASE_MAPPING = 
  'mysql' : _mysql
  'pg' : _pg


present = (config, properties) ->
  for p in properties
    assert.ok(config[p], "#{p} is required for sql plugin")

module.exports = (config) ->
  present(config, ['monitor', 'host', 'port', 'query', 'dbType'])
  port = parseInt(config.port)
  assert.ok(port, "port must be a number: #{config.port}")
  assert.ok(parseInt(config.interval), "interval must be number: #{config.interval}") if config.interval
  interval = parseInt(config.interval) || 10

  _report = null
  query = (emit) ->
    q = DATABASE_MAPPING[config.dbType] 
    q(config, (err, value) ->
      if err
        return _report('problem', err.message)

      _report('ok')
      emit({
        tag: 'tsd'
        record: {metric: config.monitor, value: value}
      })
    )

  interval_obj = null
  return {
    start : (emit, cb) ->
      console.log "sql start..."
      _report = report.PluginReport(emit, config.monitor)
      query(emit)
      interval_obj = setInterval(query, interval * 1000, emit)
      cb()
    
    shutdown : (cb) ->
      console.log "sql shutdonw... #{interval_obj}"
      clearInterval(interval_obj) if interval_obj
      cb()

    problem : () ->
      return null; 
  }