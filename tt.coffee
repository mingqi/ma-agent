Server = require("mongo-sync").Server;

Fiber = require('fibers');

server = new Server('dev.monitorat.com');

Fiber( () ->
  console.log "aaa"
  db = server.db('tt')
  # db.auth('mingqi', 'faf')
  console.log "bbb"
  coll = db.getCollection('tt')
  console.log coll.find()
  server.close()
).run();

