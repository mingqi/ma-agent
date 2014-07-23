pg = require('pg')

con_string =  'postgres://shaomq:shaomickey1980@psql.ci8wnzfbybcq.us-east-1.rds.amazonaws.com:5432/monitorat'
con_config = 
  user: 'shaomq'
  password: 'shaomickey1980'
  host: 'psql.ci8wnzfbybcq.us-east-1.rds.amazonaws.com'
  port: 5432
  database: 'monitorat'

client = new pg.Client(con_config)
client.connect (err) ->
  if err
    return console.log err.message
  client.query 'select page_views from page_views', (err, result) ->
    if err
      console.log err
      return client.end()
    console.log result
    client.end()
