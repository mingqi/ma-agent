mysql = require 'mysql'
assert = require 'assert'
report = require '../report'
console.log report

###
  metric
  host
  port
  user
  pwd
  database
  query
###

present = (config, properties) ->
  for p in properties
    assert.ok(config[p], "#{p} is required for sql plugin")

module.exports = (config) ->
  present(config, ['metric', 'host', 'port', 'user', 'pwd', 'database', 'query'])
  port = parseInt(config.port)
  assert.ok(port, "port must be a number: #{config.port}")
  assert.ok(parseInt(config.interval), "interval must be number: #{config.interval}") if config.interval
  interval = parseInt(config.interval) || 10

  _report = null
  query = (emit) ->
    console.log "sql to query"
    conn = mysql.createConnection({
      host : config.host,
      port: port,
      user: config.user,
      password: config.pwd,
      database: config.database
    })
    conn.query(config.query, (err, rows,fields) ->
      try
        if err
          _report("problem", err.message)
        else
          _report("ok")
          if rows? and rows.length > 0
            value = rows[0][fields[0].name]
            emit({
              tag: 'tsd',
              record: {metric: config.metric, value: value}
            })
      finally 
        conn.destroy()      
    )

  interval_obj = null
  return {
    start : (emit, cb) ->
      console.log "sql start..."
      _report = report.PluginReport(emit, config.metric)
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