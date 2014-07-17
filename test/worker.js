// setTimeout(function () {
//   console.log("workering..."+process.pid)
// }, 2000)
setInterval(function () {
  console.log("workering..."+process.pid)
}, 1000)

// process.send({name : 'mingqi'})

process.on('message', function  (msg) {
  console.log("this is child "+process.pid+", received msg from parent:"+msg)
})

process.on('message', function  (msg) {
  console.log("this is child "+process.pid+", received msg from parent:"+msg)
})
