# netMidiOscUpdate
UPDATE NetMIDI & OCS
OSC 신호 송수신 추가

stack  
nodejs(express) : socket.io, node-osc  
flutter : flutter_socket_io, flutter_midi

서버 : index.js
제어 1번 (앱) : sendPiano.dart  
제어 2번 (웹) : index.html  
제어 3번 (앱 OSCSurface setting) : osc0.jpeg -> osc1.jpeg  
제어 4번 (앱 touchOSC setting) : tosc0.jpeg -> tosc1.jpeg  
  
재생 앱 : playPiano.dart
