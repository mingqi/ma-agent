# pg = require('pg')

# con_string =  'postgres://shaomq:shaomickey1980@psql.ci8wnzfbybcq.us-east-1.rds.amazonaws.com:5432/monitorat'
# con_config = 
#   user: 'shaomq'
#   password: 'shaomickey1980'
#   host: 'psql.ci8wnzfbybcq.us-east-1.rds.amazonaws.com'
#   port: 5432
#   database: 'monitorat'

# client = new pg.Client(con_config)
# client.connect (err) ->
#   if err
#     return console.log err.message
#   client.query 'select page_views from page_views', (err, result) ->
#     if err
#       console.log err
#       return client.end()
#     console.log result
#     client.end()

mssql = require 'mssql'
util = require 'util'
us = require 'underscore'
config =
  user: 'shaomq'
  password: 'shaomickey1980'
  server: 'mssql3.ci8wnzfbybcq.us-east-1.rds.amazonaws.com'
  port: 1433
  database: 'monitorat'   

conn = new mssql.Connection config, (err) ->
  if err 
    return console.log err

  req = new mssql.Request(conn)

  req.query 'select page_views as nn from page_views', (err, recordset) ->
    columns = us.keys recordset.columns
    console.log recordset[0][columns[0]]
    conn.close()
  