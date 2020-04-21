import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:tonic/tonic.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  SocketIO socketIO;
  List messages;

  FlutterMidi fMid;

  double get keyWidth => 80 + (80 * _widthRatio);
  double _widthRatio = 0.0;

  @override
  initState() {
    messages = List();
    fMid = new FlutterMidi()
      ..unmute();
    
    rootBundle.load("assets/Piano.sf2").then((sf2) {
      fMid.prepare(sf2: sf2, name: "Piano.sf2");
    });

    socketIO = SocketIOManager().createSocketIO(
      'http://127.0.01:8808',
      '/',
    )
      ..init()
      ..subscribe('receive_message', (jsonData) async{
        await Future.microtask(() async => await json.decode(jsonData))
          .then((data){
            this.setState(() => messages.add(data));
            return data;
          })
          .then((data){
            if(data['message']==null){
              fMid.unmute();
            }
            else{
              final int _midi = data['message'].runtimeType != int
                ? int.parse(data['message'])
                : data['message'];
              fMid.playMidiNote(midi: _midi);
              fMid.unmute();
            }
            return;
          });
      })
      ..connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Pocket Piano',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Play ${messages.isEmpty
              ? ""
              : messages[messages.length-1]['message']}"
          ),
        ),
        body: ListView.builder(
          itemCount: 7,
          controller: ScrollController(
            initialScrollOffset: 1500.0
          ),
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            final int i = index * 12;
            return SafeArea(
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildKey(24 + i, false),
                      _buildKey(26 + i, false),
                      _buildKey(28 + i, false),
                      _buildKey(29 + i, false),
                      _buildKey(31 + i, false),
                      _buildKey(33 + i, false),
                      _buildKey(35 + i, false),
                    ]
                  ),
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 100,
                    top: 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(width: keyWidth * .5),
                        _buildKey(25 + i, true),
                        _buildKey(27 + i, true),
                        Container(width: keyWidth),
                        _buildKey(30 + i, true),
                        _buildKey(32 + i, true),
                        _buildKey(34 + i, true),
                        Container(width: keyWidth * .5),
                      ]
                    )
                  ),
                ]
              ),
            );
          },
        )
      ),
    );
  }

  Widget _buildKey(int midi, bool accidental) {
    final pitchName = Pitch.fromMidiNumber(midi).toString();
    final pianoKey = Stack(
      children: <Widget>[
        Semantics(
          button: true,
          hint: pitchName,
          child: Material(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0)
            ),
            color: accidental ? Colors.black : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0)
              ),
              highlightColor: Colors.grey,
              onTap: (){},
              onTapDown: (_) => fMid.playMidiNote(midi: midi),
            )
          )
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 20.0,
          child: Text(
            pitchName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: !accidental ? Colors.black : Colors.white
            )
          )
        ),
      ],
    );
    if (accidental) {
      return Container(
        width: keyWidth,
        margin: EdgeInsets.symmetric(horizontal: 2.0),
        padding: EdgeInsets.symmetric(horizontal: keyWidth * .1),
        child: Material(
          elevation: 6.0,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0)
          ),
          shadowColor: Color(0x802196F3),
          child: pianoKey
        )
      );
    }
    return Container(
      width: keyWidth,
      child: pianoKey,
      margin: EdgeInsets.symmetric(horizontal: 2.0)
    );
  }
}
