os = require 'os'

PluginReport = (emit, monitorId) ->
  last_status = null
  last_message = null

  return (status, message) ->
    if last_status != status or last_message != message
      last_status = status
      last_message = message
      emit({
        tag : 'report' 
        record : {
          hostname: os.hostname()
          monitorId: monitorId, 
          status: status, 
          message: message}
        }) 
     
exports.PluginReport = PluginReport