Engine = require './engine'
sql = require './plugin/in_sql'
in_test = require './plugin/in_test'
upload = require './plugin/out_upload'
stdout = require './plugin/out_stdout'

buffer_test = require './plugin/out_buffer_test'
tail = require './plugin/in_tail'

engine = Engine()
engine.addInput(sql({
  host: 'dev.monitorat.com'
  port: 3306
  user: 'ma_readonly'
  password: 'ma_readonlyonly'
  database: 'tsclogdb'
  interval: 1
  metric: 'detail_weblogs'
  query: 'select count(*) from detail_weblogs where add_date > now() - interval 5 minute'
  }))

# engine.add_outout('tsd', upload('/tsd', 'tsd'))
# engine.add_input(in_test({interval : 1}))
# engine.add_input(tail({
#   metric : 'loadtime_detail'
#   path : '/var/tmp/test.log'
#   pattern : '[^|]+\\|[^|]+\\|(?<value>[^|]+)\\|[^|]+\\|[^|]+\\|[^|]+detail\\.html'
#   }))

# engine.add_output('tsd', upload({
#   host : 'localhost'
#   port : 9090 
#   uri : '/tsd'
#   buffer_size : 1000
#   flush_interval : 3
#   }))

engine.addOutput('tsd', stdout())

engine.start((err) ->
  console.log err    
