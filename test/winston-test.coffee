logger = winston = require 'winston'
# logger.remove(winston.transports.Console)

logger.add winston.transports.File, 
  filename: "/tmp/tt/test.log"
  level: 'info' 
  timestamp:true
  json: false
  maxsize: 100
  maxFiles: 1

count = 0   
for i in [0...100000]
  setImmediate () ->
    logger.info "test line #{count++}"
