import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventChannelPage extends StatefulWidget {
  @override
  _EventChannelPageState createState() => _EventChannelPageState();
}

class _EventChannelPageState extends State<EventChannelPage> {
  static const eventChannel = EventChannel("event_channel_sample");

  StreamSubscription _streamSubscription;

  String eventMessage = "";

  void _onEvent(Object event) {
    setState(() {
      if (_streamSubscription != null) {
        eventMessage = event.toString();
      }
    });
  }

  void _onError(Object error) {
    setState(() {
      if (_streamSubscription != null) {
        eventMessage = "error";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    eventMessage = "";
    _streamSubscription = eventChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
    _streamSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("EventChannel 使用"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(eventMessage),
            ],
          ),
        ));
  }
}
