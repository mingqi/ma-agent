fs = require 'fs'
hoconfig = require 'hoconfig-js'

c = fs.readFileSync('/var/tmp/t.txt')
console.log c.toString()

b = hoconfig('/etc/ma-agent/monitor.d/a.conf')
console.log b.metric11.pattern