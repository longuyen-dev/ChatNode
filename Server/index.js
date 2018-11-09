var express = require('express')
var app = express()

var server = require('http').Server(app)
var io = require('socket.io')(server)

var userList = []
userList.push({"name": "World","id": "0001"});


server.listen(2016,function(){
  io.on('connection', function(socket){
    console.log("Have connection id: "+socket.id);
    // MARK: - server deliver name from client

    socket.on("client_send_name", function(data){
      console.log("Name: "+ data+" with id: "+ socket.id);
      var u = {"name": data[0], "id": socket.id};
      if (!containsObject(u,userList)){
        userList.push({"name": data[0], "id": socket.id});
      }

      console.log(userList);
      io.sockets.emit("server_send_listUser",{"userList":userList});
    });
    socket.on("client_send_messenget",function(data){
      console.log(data);
      io.sockets.emit("server_send_messenger", data);
    });


    socket.on("disconnect", function(){
        var index = userList.findIndex(x => x.id == socket.id);
        console.log("===> disconnect at: "+ socket.id);
        userList.splice(index,1);
        io.sockets.emit("server_send_listUser",{"userList":userList});

    });



  })//connection

})
function containsObject(obj, list) {
    var i;
    for (i = 0; i < list.length; i++) {
        if (list[i].name == obj.name && list[i].id == obj.id) {
            return true;
        }
    }

    return false;
}
