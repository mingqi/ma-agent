util = require('../util')
report = require '../report'

module.exports = (config) ->

  interval = parseInt(config.interval) || 20
  plugin_report = null

  run = (emit) ->
    args = [
      'ma-agent'
      '-c', config.command
    ]
    util.shell '/bin/su', args, null, null, (err, code, output) ->
      if code != 0
        return plugin_report('problem', "failed to run command, exit with code #{code}: #{output}")

      floatValue = parseFloat(output) 
      if isNaN(floatValue)
        return plugin_report('problem', "command's output is not a number")

      plugin_report('ok')
      util.emitTSD(emit, config.monitor, floatValue)

  interval_obj = null

  return {
    start : (emit, cb) ->
      logger.info "script plugin starting ..."
      plugin_report = report.PluginReport(emit, config.monitor)
      run(emit)
      interval_obj = setInterval(run, interval * 1000, emit)
      cb()
    
    shutdown : (cb) ->
      logger.info "script plugin shutdown ... "
      clearInterval(interval_obj) if interval_obj
      cb()
  }
