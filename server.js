var app = require('express')(),
    http = require('http').Server(app),
    io = require('socket.io')(http),
    osc = require('node-osc');

app.get('/', (req, res) => res.send("hi")); 
app.get("/chat",(req,res) => res.sendFile('/Users/doylekim/wserver/index.html'));

io.on('connection', (socket) => socket.on('send_message', (msg) => io.emit('receive_message', msg)));

var oscServer = new osc.Server(44100, '0.0.0.0');
oscServer.on("message", (msg, rinfo) => {
    console.log(rinfo);
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
    return;
});

http.listen(8808, () => console.log('listening on :8808'));
