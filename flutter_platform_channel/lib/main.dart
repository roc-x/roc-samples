import 'package:flutter/material.dart';

import 'basic_message_channel_page.dart';
import 'event_channel_page.dart';
import 'method_channel_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Native 通信',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter to Native'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              minWidth: 200,
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('MethodChannel'),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (BuildContext context) {
                  return MethodChannelPage();
                }));
              },
            ),
            MaterialButton(
              minWidth: 200,
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('EventChannel'),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (BuildContext context) {
                  return EventChannelPage();
                }));
              },
            ),
            MaterialButton(
              minWidth: 200,
              color: Colors.blue,
              textColor: Colors.white,
              child: Text('BasicMessageChannel'),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (BuildContext context) {
                  return BasicMessageChannelPage();
                }));
              },
            ),
          ],
        ),
      ),
    );
  }
}
