Deamonize = require '../daemonize'
d = Deamonize({
  script: require.resolve('./ma-agent.js')
  args: ['-s']
  pidFile: "/var/tmp/ma-agent.pid"
  outFile: "/var/tmp/ma-agent.log"
  errFile: "/var/tmp/ma-agent.log"
  stopTimeout: 3000
  startTimeout: 3000
})


help = () ->
  console.log "usage: ma-agent start|stop|restart"
  process.exit(1)
  
args = process.argv[2..]

if args.length != 1
  help()

switch args[0]
  when 'start'
    d.start((err) ->
      exit_code = if err then 1 else 0
      process.exit(exit_code)
    )
  when 'stop'
    d.stop((err) ->
      exit_code = if err then 1 else 0
      process.exit(exit_code)
    )
 
  when 'restart' 
    d.restart((err) ->
      exit_code = if err then 1 else 0
      process.exit(exit_code)
    )

  else
    help()