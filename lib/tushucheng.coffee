engine = require './engine'
upload = require './plugin/out_upload'
tail = require './plugin/in_tail'

engine.add_input(tail({
  metric : 'loadtime_detail'
  path : '/env/TomcatProd/logs/loadtime.log'
  pattern : '[^|]+\\|[^|]+\\|(?<value>[^|]+)\\|[^|]+\\|[^|]+\\|[^|]+detail\\.html'
  }))

engine.add_output('tsd', upload({
  host : 'gitlab.qiri.com'
  port : 9090 
  uri : '/tsd'
  buffer_size : 1000
  flush_interval : 30
  }))


d = require('domain').create();
d.on('error', (er) ->
    console.error('error, but oh well', er.message);
    console.error er.stack
)

d.run(() ->
  engine.start() 
)
