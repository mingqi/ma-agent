engine = require './engine'
sql = require './sql'
# tail = require './tail'
upload = require './upload'
stdout = require './stdout'


engine.add_input(sql({
  host: 'dev.monitorat.com'
  port: 3306
  user: 'ma_readonly'
  password: 'ma_readonlyonly'
  database: 'tsclogdb'
  interval: 10
  metric: 'detail_weblogs'
  query: 'select count(*) from detail_weblogs where add_date > now() - interval 5 minute'
  }))
# engine.reg_input(tail)

# engine.add_outout('tsd', upload('/tsd', 'tsd'))
engine.add_output('tsd', upload({
  host : 'localhost'
  port : 9090 
  uri : '/tsd'}))
# engine.add_output('tsd', stdout())

d = require('domain').create();
d.on('error', (er) ->
    console.error('error, but oh well', er.message);
    console.error er.stack
)

d.run(() ->
  engine.start() 
)
