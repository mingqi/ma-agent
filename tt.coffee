Tail = require('./lib/tail').Tail

dirty = require 'dirty'
db = dirty('/var/tmp/dirty.db')
db.on('load', () ->
  console.log "db.on load"
  console.log db.get('mingqi')
)
console.log "----------"
console.log db.get('mingqi')

# db.set('mingqi', 'aaa')

# db.on('drain', () ->
#   console.log "db.on drain"
# )