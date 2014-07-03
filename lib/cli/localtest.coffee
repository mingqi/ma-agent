Agent = require '../agent'
config = require '../config'
hoconfig = require 'hoconfig-js'
stdout = require '../plugin/out_stdout'

args = process.argv[2..]
if args.length !=2
  console.error "useage: agent <agent-config-file> <plguin-config-file>"
  process.exit(1)

agentconfig = args[0]
pluginconfig = args[1]


agent = Agent(
  ((cb) -> 
    # config.local(pluginconfig, cb)
    config.remote('localhost', 9090, cb)
  ), 
  [], 
  [['tsd', stdout()]], 
  hoconfig(agentconfig))

agent.start()
