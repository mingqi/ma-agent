mysql = require('mysql');

conn = mysql.createConnection({
  host : 'dev.monitorat.com'
  port: 3306,
  user: 'ma_readonly',
  password: 'ma_readonlyonly'
  })
conn.connect()
conn.query('select count(*) from tsclogdb.detail_weblogs where add_date > now() - interval 5', (err, rows,fields) ->
  if rows? and rows.length > 0
    value = rows[0][fields[0].name]
    conn.destroy()
    console.log value
)
