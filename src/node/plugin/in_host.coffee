version = require '../version'
os = require 'os'
util = require '../util'

# interval
module.exports = (config) ->
  interval_obj = null
  count = 0
  report = (emit) ->
    emit({
      tag: 'host',
      record: { hostname: os.hostname(), version: version }
      })

  return {
    start : (emit, cb) ->
      logger.info "agent report plugin start"
      report(emit)
      interval_obj = setInterval(report, config.interval * 1000, emit)
      cb()
    
    shutdown : (cb) ->
      logger.info "agent report plugin shutdonw"
      clearInterval(interval_obj) if interval_obj
      cb()
  }
