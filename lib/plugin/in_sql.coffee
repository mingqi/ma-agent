mysql  = require('mysql');

module.exports = (config) ->

  query = (emit) ->
    console.log "sql to query"
    conn = mysql.createConnection({
      host : config.host,
      port: config.port,
      user: config.user,
      password: config.password,
      database: config.database
      })
    conn.connect()
    conn.query(config.query, (err, rows,fields) ->
      if rows? and rows.length > 0
        value = rows[0][fields[0].name]
        conn.destroy()
        emit({
          tag: 'tsd',
          record: {metric: config.metric, value: value}
        })
    )

  interval_obj = null
  return {
    start : (emit, cb) ->
      console.log "sql start..."
      interval_obj = setInterval(query, config.interval * 1000, emit)
      cb()
    
    shutdown : (cb) ->
      console.log "sql shutdonw... #{interval_obj}"
      clearInterval(interval_obj) if interval_obj
      cb()
  }