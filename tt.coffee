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

# os = require 'os'
# VError = require('verror');
# config = require './lib/config'

# config.remote({host:'localhost', port:9090, licence_key: 'lzyJanDTLW4yQ4nNKd3t'},
#   (err, config) ->
#     console.log err
#     console.log config
# )

config = require './lib/config'

c1 = (callback) ->
  config.remote({
    host: 'localhost'
    port: 9090
    licence_key: 'lzyJanDTLW4yQ4nNKd3t'
    }, callback)

c2 = (callback) ->
  config.local('./conf/test', callback)


config.merge(c1, c2, (err, config) ->
  console.log err
  console.log config
)


# t = (args...) ->
#   console.log args

# t(1,2,3,4)
  
