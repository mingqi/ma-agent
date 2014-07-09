us = require 'underscore'
Agent = require '../agent'
config = require '../config'
hoconfig = require 'hoconfig-js'
stdout = require '../plugin/out_stdout'
upload = require '../plugin/out_upload'
host = require '../plugin/in_host'


args = process.argv[2..]
if args.length !=1
  console.error "useage: agent <agent-config-file>"
  process.exit(1)

agentconfig = hoconfig(args[0])
default_options = {
  remote_host : 'localhost'
  remote_port : 9090
  buffer_size : 1000
  buffer_flush : 3
}

out_upload = upload(us.extend(default_options, agentconfig, {uri: '/tsd'}))
out_host = upload(us.extend(default_options, agentconfig, {
  uri: '/host'
  buffer_size: 10
  buffer_flush: 1}))

agent = Agent(
  ((cb) -> 
    config.remote('localhost', 9090, agentconfig.license_key, cb)
  ), 
  [host({interval: agentconfig.agent_report_interval})], 
  [
    ['tsd', out_upload],
    ['host', stdout()],
    ['host', out_host]
  ]
)


agent.start()
