buffer = require '../buffer'

module.exports = (config) ->
  buffer(config, (chunk) ->
    console.log "------------------"
    console.log chunk  
  )