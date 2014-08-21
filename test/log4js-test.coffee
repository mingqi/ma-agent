log4js = require('log4js');
log4js.loadAppender('file');
log4js.loadAppender('console');

log4js.clearAppenders()
logger = log4js.getLogger('ma-agent');
logger.setLevel('info')

log4js.addAppender(log4js.appenders.file('/tmp/tt/test.log', null, 10000, 5));
log4js.addAppender(log4js.appenders.console() );

count = 0   
for i in [0...100]
  setImmediate () ->
    logger.info "test line #{count++}"
