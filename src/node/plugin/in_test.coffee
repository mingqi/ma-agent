report = require '../report'

module.exports = (config) ->
  interval_obj = null
  count = 0
  monitor = config.monitor
  plugin_report = null

  query = (emit) ->
    if count >  5
      console.log "" 
      # throw new Error("this is exception")
    emit({
      tag: config.tag
      record: { metric: monitor, value: count+=1 }
      })
    plugin_report('ok')

  return {
    start : (emit, cb) ->
      console.log "intest start..."
      plugin_report = report.PluginReport(emit, config.monitor)
      interval_obj = setInterval(query, config.interval * 1000, emit)
      if config.interval > 5
        cb(new Error("not support interval more than 5")) 
      else
        cb()
    
    shutdown : (cb) ->
      console.log "intest shutdonw... #{interval_obj}"
      clearInterval(interval_obj) if interval_obj
      cb()
      # cb(new Error("failed to shutdown test plugin"))
  }