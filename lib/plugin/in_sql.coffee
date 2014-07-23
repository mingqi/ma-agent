us = require 'underscore'
mysql = require 'mysql'
mssql = require 'mssql'
pg = require 'pg'
assert = require 'assert'
report = require '../report'
spawn = require('child_process').spawn


###
  monitor
  dbType
  host
  port
  user
  pwd
  sid // this is only for Oracle
  database
  query
###

ERR_ROWS = "query return more then one row"
ERR_COLUMNS = "there are more than one field in query's select"

_oracle = (config, callback) ->
  cp_opt = {
    detached: false
    env : process.env
    cwd : process.cwd     
    stdio: 'pipe'
    # stdio: 'inherit'
  }
  args = [
    "-cp", "./jar/ojdbc7.jar:./_class"
    "com.monitorat.agent.SQLQuery"
    "--host", config.host
    "--port", config.port
    "--user", config.user
    "--password", config.pwd
    "--database", config.database
    "--sid", config.sid
    "--query", config.query
  ]

  child_output = ""
  child = spawn('java', args, cp_opt)
  child.stdout.setEncoding('utf8')
  child.stdout.on 'data', (data) ->
    child_output += data
  
  child.on 'exit', (code) ->
    console.log "child exit with #{code}"
    console.log "child output: #{child_output}"
    switch code
      when 1    # no value
        return callback() 
      when 2    # column more than 1
        return callback(new Error(ERR_COLUMNS))
      when 3    # row more than 1
        return callback(new Error(ERR_ROWS))
      when 0
        return callback(null, child_output.trim()) 
      else
        if child_output.indexOf('ORA-01435') >=0
          return callback(new Error("database #{config.database} doesn't exists"))       
        return callback(new Error(child_output.trim()))
    

_mssql = (config, callback) ->
  conn_config =
    server: config.host
    port: parseInt(config.port)
    user: config.user
    password: config.pwd
    database: config.database

  conn = new mssql.Connection conn_config, (err) ->
    if err 
      return callback err

    req = new mssql.Request(conn)

    req.query config.query, (err, result) ->
      console.log config.query
      try
        if err
          return callback err

        console.log result
        if not result? or result.length < 1
          return callback()

        if result.length > 1
          return callback(new Error(ERR_ROWS))

        columns = us.keys result.columns
        if columns.length > 1
          return callback(new Error(ERR_COLUMNS))

        value = result[0][columns[0]]
        callback(null, value)
      finally
        conn.close()
  
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
  'postgresql' : _pg
  'mssql' : _mssql
  'oracle': _oracle


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

      intValue = parseInt(value) 
      if isNaN(intValue)
        return _report('problem', "query's result '#{value}' is not a number")
      _report('ok')
      emit({
        tag: 'tsd'
        record: {metric: config.monitor, value: intValue}
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