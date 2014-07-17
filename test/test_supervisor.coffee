supervisor = require '../_lib/supervisor'

# s = Supervisor('./worker.js', [], 3000, 2000)
# s.run((err) ->
#   console.log err
# )

run = () ->
  setInterval(() ->
    console.log "running"
  , 1000 
  )

  supervisor.checkHeartbeat(3000)


supervisord = () ->
  console.log process.pid
  script = process.argv[1]
  args = process.argv[2..]
  sup = supervisor.Supervisor(script, args, 3000)
  sup.run((err) ->
    console.log err
  )

if not process.env.__supervisor_child
  supervisord()
else
  run()

# fork = require('child_process').fork

# child = fork('./worker.js')

# setTimeout(() ->
#   child.send('aaabbb')
# )
# child.on('message', (data) ->
#   console.log "get data from child #{data}"
# )

