var Db = require('mongodb').Db,
    MongoClient = require('mongodb').MongoClient,
    Server = require('mongodb').Server

var db = new Db('tt', new Server('localhost', 27017));

db.open(function(err, db) {
  var tt = db.collection("tt");
  var cursor = tt.find()
  var c2 = cursor.limit(10)
  console.log(c2)
  c2.toArray(function  (err, docs) {
    console.log(docs)
  })

})