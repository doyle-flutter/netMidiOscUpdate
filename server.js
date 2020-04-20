// 코드 정리 예정....

var app = require('express')(); 
var http = require('http').Server(app); 
var io = require('socket.io')(http); 
var osc = require('node-osc');

app.get('/', function(req, res){ 
    console.log("asd");
    res.send("hi"); 
}); 
app.get("/chat",(req,res) =>{
    res.sendFile('/Users/doylekim/wserver/index.html');
});


var oscServer = new osc.Server(44100, '0.0.0.0');

io.on('connection', function(socket){ 
    socket.on('send_message', function(msg){ 
        io.emit('receive_message', msg); 
    }); 
    // oscServer.on("message", function (msg, rinfo) {
    //     console.log(msg);
    // });
});

oscServer.on("message", function (msg, rinfo) {
    console.log(msg);
    var data;
    if(msg.length > 2){
        data = msg[2];       
    }
    else{
        data = msg[0].split('push')[1]+0;
    }
    io.emit('receive_message', {
        "name":"James",
        "message":data
    });
});


http.listen(8808, function(){ console.log('listening on :8808'); });
