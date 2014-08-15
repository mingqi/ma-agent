logger = winston = require 'winston'
# logger.remove(winston.transports.Console)

# logger.add winston.transports.File, 
#   filename: "/tmp/tt/test.log"
#   level: 'info' 
#   timestamp:true
#   json: false
#   maxsize: 1024  * 1024
   
e = new Error("this is error")
logger.error(e)
