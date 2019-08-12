import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodChannelPage extends StatefulWidget {
  @override
  _MethodChannelPageState createState() => _MethodChannelPageState();
}

class _MethodChannelPageState extends State<MethodChannelPage> {
  static const methodChannel = MethodChannel("method_channel_sample");

  String messageFromNative = "";

  /// 调用 native 方法
  Future<dynamic> getUserInfo(String method, {String userName}) async {
    return await methodChannel.invokeMethod(method, userName);
  }

  /// native 调用 flutter 方法
  Future<dynamic> addHandler(MethodCall call) async {
    switch (call.method) {
      case "sayHello":
        return "Hello from Flutter";
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    methodChannel.setMethodCallHandler(addHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("MethodChannel 使用"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: new Text('获取 rocx 用户信息'),
                onPressed: () {
                  getUserInfo("getInfo", userName: "rocx")
                    ..then((result) {
                      setState(() {
                        messageFromNative = result;
                      });
                    });
                },
              ),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: new Text('获取 snow 用户信息'),
                onPressed: () {
                  getUserInfo("getInfo", userName: "snow")
                    ..then((result) {
                      setState(() {
                        messageFromNative = result;
                      });
                    });
                },
              ),
              Text(messageFromNative),
            ],
          ),
        ));
  }
}
