mysql  = require('mysql');

module.exports = (config) ->

  query = (emit) ->
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
        emit("tsd", {metric: config.metric, value: value})
    )

  return {
    start : (emit) ->
      setInterval(query, config.interval * 1000, emit)
    
    shutdown : () ->
      console.log "shutdonw..."
  }