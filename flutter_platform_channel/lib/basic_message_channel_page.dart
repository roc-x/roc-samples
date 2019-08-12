import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BasicMessageChannelPage extends StatefulWidget {
  @override
  _BasicMessageChannelPageState createState() =>
      _BasicMessageChannelPageState();
}

class _BasicMessageChannelPageState extends State<BasicMessageChannelPage> {
  static const basicMessageChannel = BasicMessageChannel(
      "basic_message_channel_sample", StandardMessageCodec());

  /// native 回复的消息
  String msgReplyFromNative = "";

  /// native 主动发过来的消息
  String msgReceiveFromNative = "";

  ///向 native 发送消息
  Future<dynamic> sayHelloToNative(String message) async {
    String reply = await basicMessageChannel.send(message);

    setState(() {
      msgReplyFromNative = reply;
    });

    return reply;
  }

  Future<dynamic> addHandler(Object result) async {
    setState(() {
      msgReceiveFromNative = result.toString();
    });
  }

  ///消息监听，接收来自 native 的消息
  void addMessageListener() {
    basicMessageChannel.setMessageHandler(addHandler);
  }

  @override
  void initState() {
    super.initState();

    addMessageListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("BasicMessageChannel 使用"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: new Text('say hello to native'),
                onPressed: () {
                  sayHelloToNative("hello");
                },
              ),
              Text(msgReplyFromNative),
              Text(msgReceiveFromNative),
            ],
          ),
        ));
  }
}
