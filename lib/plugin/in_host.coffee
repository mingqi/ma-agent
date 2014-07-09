version = require '../version'
os = require 'os'

# interval
module.exports = (config) ->
  interval_obj = null
  count = 0
  metric = config.metric
  report = (emit) ->
      emit({
        tag: 'host',
        record: { hostname: os.hostname(), version: version }
        })

  return {
    start : (emit, cb) ->
      console.log "in_agent start..."
      interval_obj = setInterval(report, config.interval * 1000, emit)
      cb()
    
    shutdown : (cb) ->
      console.log "intest shutdonw... #{interval_obj}"
      clearInterval(interval_obj) if interval_obj
      cb(new Error('has error when shutdown in_test'))
  }
