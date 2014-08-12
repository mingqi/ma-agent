us = require 'underscore'
mysql = require 'mysql'
mssql = require 'mssql'
pg = require 'pg'
assert = require 'assert'
report = require '../report'
shell = require('../util').shell
util = require '../util'
path = require 'path'
glob = require 'glob'
mongoshell = require '../mongoshell'

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

_mongo = (config, callback) ->
  mongoshell config, config.query, (err, result) ->

    return callback(err) if err
    switch 
      when us.isArray(result)
        if result.length > 1
          return callback(new Error(ERR_ROWS)) 
        row = result[0]

      when us.isObject(result)
        row = result

      when us.isString(result) or us.isNumber(result)
        return callback(null, result)
      else
        return callback(new Error("query result '#{result}' is not acceptable value"))
      

    if not us.isObject(row)
      return callback(new Error("query result '#{row}' is not acceptable value"))

    if row._id?
      delete row._id 

    keys = us.keys(row)
    if keys.length > 1
      return callback(new Error(ERR_COLUMNS))

    callback(null, row[keys[0]])

_oracle = (config, callback) ->
  opts = {
    timeout : 5000
  }

  jar_path = util.findPath( __dirname, 'lib/ma-agent.jar')
  return callback(new Error("can't find out ma-agent.jar")) if not jar_path  
  jar_path = path.dirname(jar_path)
  cp = glob.sync("#{jar_path}/*.jar").join(':')
   
  args = [
    "-cp", cp
    "com.monitorat.agent.SQLQuery"
    "--host", config.host
    "--port", config.port
    "--user", config.user
    "--database", config.database
    "--sid", config.sid
    "--query", config.query
  ]

  java_path = util.findPath __dirname, 'jre/bin/java'
  if not java_path
    java_path = 'java'

  shell_input = """
    password: #{config.pwd}
    afaf
  """
  shell java_path, args, shell_input, opts, (err, code, child_output) ->
    if err
      return logger.error err 
    logger.info "child exit with #{code}: #{child_output}"
    switch code
      when 11    # no value
        return callback() 
      when 12    # column more than 1
        return callback(new Error(ERR_COLUMNS))
      when 13    # row more than 1
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
      try
        if err
          return callback err

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
  'mongo' : _mongo


present = (config, properties) ->
  for p in properties
    assert.ok(config[p], "#{p} is required for sql plugin")

module.exports = (config) ->
  present(config, ['monitor', 'host', 'port', 'query', 'dbType'])
  port = parseInt(config.port)
  assert.ok(port, "port must be a number: #{config.port}")
  assert.ok(parseInt(config.interval), "interval must be number: #{config.interval}") if config.interval
  interval = parseInt(config.interval) || 20

  _report = null
  query = (emit) ->
    q = DATABASE_MAPPING[config.dbType] 
    q(config, (err, value) ->
      if err
        return _report('problem', err.message)

      floatValue = parseFloat(value) 
      if isNaN(floatValue)
        return _report('problem', "query's result '#{value}' is not a number")
      _report('ok')
      util.emitTSD(emit, config.monitor, floatValue)
    )

  interval_obj = null
  return {
    start : (emit, cb) ->
      logger.info "sql plugin start..."
      _report = report.PluginReport(emit, config.monitor)
      query(emit)
      interval_obj = setInterval(query, interval * 1000, emit)
      cb()
    
    shutdown : (cb) ->
      logger.info "sql plugin shutdonw... "
      clearInterval(interval_obj) if interval_obj
      cb()
  }
