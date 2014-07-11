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

# util.rest(
#   {
#     host: 'localhost'
#     port: 9090
#     method: 'GET'
#     path: '/monitor/mingqi-mac'
#     headers : {
#       'licenseKey' : 'lzyJanDTLW4yQ4nNKd3t'
#     }  
#   }
# , (err, status, result) ->
#   console.log err
#   console.log status
#   console.log result 
# )

os = require 'os'
VError = require('verror');

util.rest(
  {
    host: 'localhost'
    port: 9090
    method: 'GET'
    path: /monitor/+os.hostname()
    headers : {
      'licenseKey' : 'lzyJanDTLW4yQ4nNKd3t'
    }    
  }
, (err, status, result) ->
    console.log "----------"
    console.log err
    console.log status
    console.log result
    # if err
    #   return cb(VError(err, "failed to call remote service grab montior list"))       
    # if status != 200
    #   return cb(new Error("call /montor return error status #{status}"))
    # try
    #   config = JSON.parse(result)
    # catch e
    #   return cb(new VError(e, "wrong json format remote return"))
    # cb(null, config)
)
