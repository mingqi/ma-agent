util = require '../src/node/util'
global.logger = winston = require 'winston'

options =
  ssl: false
  host: 'api.metricsat.com'
  # port: 443
  method: 'GET'
  path: '/monitor/app-01.tushucheng.com'
  headers:
    'licenseKey': 'tMe43aiHpttg3vLT0zvk'

util.rest options, (err, status, result) ->
  return console.log err if err
  console.log status
  console.log result
