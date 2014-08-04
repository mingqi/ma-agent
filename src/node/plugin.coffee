in_tail = require './plugin/in_tail'

log = (config) ->
  config.posfile = '/opt/ma-agent/var/log.pos'
  in_tail(config)

INPUT_PLUGINS = {
  dbquery : require './plugin/in_sql'
  log : log
  test : require './plugin/in_test'
  script : require './plugin/in_script'
}

exports.plugin = (type) ->
  return INPUT_PLUGINS[type]
