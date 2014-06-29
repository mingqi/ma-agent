Tail = require('./lib/tail').Tail

t = new Tail('/var/tmp/test.log', {start: 0})
t.on('line', (line)->
  console.log line
)