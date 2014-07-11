# mysql = require('mysql');

# conn = mysql.createConnection({
#   host : 'dev.monitorat.com'
#   port: 3306,
#   user: 'ma_readonly',
#   password: 'mmma_readonlyonly'
#   })

# conn.query('select count(*faf) from tsclogdb.detail_weblogs where add_date > now() - interval 5 minute', (err, rows,fields) ->
#   if rows? and rows.length > 0
#     value = rows[0][fields[0].name]
#     console.log value
#   conn.destroy()
# )

util = require './lib/util'

util.rest(
  {
    host: 'localhost'
    port: 9090
    method: 'GET'
    path: '/aconfig/mingqi-mac'
    headers : {
      'licenseKey' : 'lzyJanDTLW4yQ4nNKd3t'
    }  
  }
# , {name:'mingqi', title:'sde'}
, (err, status, result) ->
  console.log err
  console.log status
  console.log result 
)