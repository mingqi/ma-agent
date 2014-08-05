util = require './src/node/util'
spawn = require('child_process').spawn
exec = require('child_process').exec

# cp_opt = {
#   # env : process.env
#   # cwd : process.cwd     
#   timeout: 3000
#   killSignal: 'SIGKILL'
# }  

# child = exec('./req.rb a b c', cp_opt, (err, stdout, stderr) ->
#   return console.log err if err
#   console.log stdout
#   console.log stderr 
# )

# child.stdin.write('hello'); 
# child.stdin.end()

# util.shell "/bin/bash", ['-c', 'whoami'], null, null, (err, code, output) ->
#   return console.log err if err
#   console.log "code: #{code}"
#   console.log "output: #{output}"

# child = spawn()


f = (tsd) ->
  console.log tsd

f(
  name: 'mingqi'
  title: 'sde'
)