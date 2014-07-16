# supervisor = require './lib/supervisor'

# sup = supervisor.Supervisor(require.resolve('./lib/worker'), 3)
# sup.run()

# Daemonize = require './lib/daemonize'

# d = Daemonize({
#   script: require.resolve('./test')
#   outFile: '/var/tmp/tt/tt.out'
#   errFile: '/var/tmp/tt/tt.err'
#   pidFile : '/var/tmp/tt/tt.pid'#   detached: true
#   stopTimeout: 3
#   })

# action = process.argv[2]
# switch action
#   when "start"
#     d.start()
#   when "stop"
#     d.stop((err) ->
#       console.log "success stop"    
#     )

#   when "restart"
#     d.restart()

# spawn = require('child_process').spawn

# child = spawn(process.execPath, ['./test.js'], {detached: true, stdio: ['ignore',out, err]}) 
# console.log child.pid
# console.log "aaaaaaaa"


# setTimeout(() ->
#   child.unref()
# , 3000
# )

util = require './lib/util'

hasFile = false
setTimeout(() ->
  hasFile = true
, 2000
)


util.wait(100, 3000, () ->
  hasFile
, (err, done) ->
  console.log "aaaaaaa"
  console.log done
)