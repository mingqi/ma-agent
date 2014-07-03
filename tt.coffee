# config = require './lib/config'
# config.remote_backup('localhost',  9090, '/var/tmp/1.json', (err, config) ->
#   if err
#     console.log err
#   else
#     console.log config
# )
us = require 'underscore'

a = {name: 'mingqi', title: 'sde'}

us.map(a, (bb) ->
  console.log "---------"
  console.log bb
  return 1
)