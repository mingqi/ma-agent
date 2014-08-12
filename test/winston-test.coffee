logger = winston = require 'winston'
logger.remove(winston.transports.Console)

logger.add winston.transports.File, 
  filename: "/tmp/tt/test.log"
  level: 'info' 
  timestamp:true
  json: false
  maxsize: 1024  * 1024
   

for i in [0...100000] 
  # console.log "aa"
  setImmediate () ->
    logger.info "this is test"
