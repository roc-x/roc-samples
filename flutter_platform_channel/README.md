## Flutter Platform Channel 使用与源码分析
### 1. 为什么要有 PlatformChannel
1、如果 Flutter 要获取设备的电量信息怎么办？</br>
2、如果 Flutter 要实时监控网络状态怎么办？</br>

由于 Flutter 特点如下：
> Flutter is Google’s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.

1、Flutter 是一个跨平台的 UI 库，专注于构建高效的 UI。</br>
2、多平台的支持，下图是 Flutter 目前支持的平台，每个平台的都有自己的平台特性。</br>

<img src="http://p0.qhimg.com/t01b3f704dcfed0e4ab.png" width="70%" height="70%" /> </br>

基于以上两点，目前 Flutter 如果要和平台相关的部分通信需要有一个通道即 PlatformChannel。

### 2. 架构图
<img src="https://flutter.dev/images/PlatformChannels.png" width="70%" height="70%" /> 

### 3. PlatformChannel 类型

- BasicMessageChannel：用于数据传递。platform 和 dart 可互相传递数据（asynchronous message passing）
- MethodChannel：用于传递方法调用。platform 和 dart 可互相调用方法（asynchronous method calls）
- EventChannel：用于数据流通信。建立连接之后，platform 发送消息，dart 接收消息（event streams）

三种类型的 channel 都定义在 `platform_channel.dart` 中，从源码中可以看到三种 channel 都用到了以下三个属性。

- `name`：String 类型，表示 channel 的名字，全局唯一（The logical channel on which communication happens）
- `codec`：MessageCodec<T> 类型，消息的编码解码器（The message codec used by this channel）
- `binaryMessenger`：BinaryMessenger类型，用于发送数据（The messenger used by this channel to send platform messages）

#### 3.1 channel name
channel 的名字，每个 Flutter 应用可能有多个 channel，但是每个 channel 必须有一个唯一的名字。

#### 3.2 codec
codec 用来对数据编码解码，以便两端可以正确读取数据。
<img src="http://p0.qhimg.com/t01d0c790e129c2c8f9.png"/> 

#### 3.3 binaryMessenger
用于发送数据

### 4. PlatformChannel 使用
#### 4.1 MethodChannel
- Dart 调用 Android 方法

method_channel_page.dart 主要代码

```dart
第一步
static const methodChannel = MethodChannel("method_channel_sample");

第二步  
Future<dynamic> getUserInfo(String method, {String userName}) async {
  return await methodChannel.invokeMethod(method, userName);
}

第三步    
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
```

MainActivity.java 主要代码

```java
private void addMethodChannel() {
    mMethodChannel = new MethodChannel(getFlutterView(), "method_channel_sample");
    mMethodChannel.setMethodCallHandler((methodCall, result) -> {

        String method = methodCall.method;

        if ("getInfo".equals(method)) {

            String userName = (String) methodCall.arguments;

            if (userName.equals("rocx")) {
                String user = "name:rocx, age:18";
                result.success(user);
            } else {
                result.success("user not found");

                invokeSayHelloMethod();
            }
        }

    });
}
```
从以上代码可以看出</br>
Dart 调用 Android 代码分三步。首先在 Dart 端定义 MethodChannel 名字为 `method_channel_sample`。然后定义`getUserInfo`方法，传入要调用的方法名和参数。最后点击按钮执行方法，获取用户信息。</br>
在 Android 端定一个 MethodChannel 名字和 Dart 端保持一致。设置 MethodCallHandler。当调用的是`getInfo`方法时，根据参数返回信息。

- Android 调用 Dart 方法

MainActivity.java 主要代码

```java
private void invokeSayHelloMethod() {
    mMethodChannel.invokeMethod("sayHello", "", new MethodChannel.Result() {
        @Override
        public void success(Object o) {

            Toast.makeText(MainActivity.this, o.toString(), Toast.LENGTH_LONG).show();
        }

        @Override
        public void error(String s, String s1, Object o) {

        }

        @Override
        public void notImplemented() {

        }
    });
}
```

method_channel_page.dart 主要代码

```dart
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
```
从代码可以看出，在 Dart 端设置 MethodCallHandler 然后在 Android 端调用即可。

#### 4.2 BasicMessageChannel
- Dart 向 Android 发送消息

basic_message_channel_page.dart 主要代码

```dart
第一步
static const basicMessageChannel = BasicMessageChannel(
      "basic_message_channel_sample", StandardMessageCodec());

第二步
Future<dynamic> sayHelloToNative(String message) async {
  String reply = await basicMessageChannel.send(message);

  setState(() {
    msgReplyFromNative = reply;
  });

  return reply;
}

第三步
MaterialButton(
  color: Colors.blue,
  textColor: Colors.white,
  child: new Text('say hello to native'),
  onPressed: () {
    sayHelloToNative("hello");
  },
),

```

MainActivity.java 主要代码

```java
private void addBasicMessageChannel() {
    mBasicMessageChannel = new BasicMessageChannel<>(getFlutterView(), "basic_message_channel_sample", StandardMessageCodec.INSTANCE);
    mBasicMessageChannel.setMessageHandler((object, reply) -> {

        reply.reply("receive " + object.toString() + " from flutter");

        mBasicMessageChannel.send("native say hello to flutter");
    });
}

```

从以上代码可以看出</br>
Dart 向 Android 发送消息依然分为三步。首先在 Dart 端定义 BasicMessageChannel 名字为 `basic_message_channel_sample`。然后定义发送消息的方法`sayHelloToNative`。最后点击按钮向 Android 端发送消息。</br>
在 Android 端定一个 BasicMessageChannel 名字和 Dart 端保持一致。设置 MethodCallHandler。当收到消息时发一个回复。

- Android 向 Dart 发送消息

MainActivity.java 主要代码

```java
mBasicMessageChannel.send("native say hello to flutter");
```

basic_message_channel_page.dart 主要代码

```dart
Future<dynamic> addHandler(Object result) async {
  setState(() {
    msgReceiveFromNative = result.toString();
  });
}

void addMessageListener() {
  basicMessageChannel.setMessageHandler(addHandler);
}

@override
void initState() {
  super.initState();
  addMessageListener();
}

```
从代码可以看出，在 Dart 端设置 MessageHandler 然后在 Android 端直接发送消息即可。

#### 4.3 EventChannel
event_channel_page.dart 主要代码

```dart
第一步
static const eventChannel = EventChannel("event_channel_sample");

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
  第二步
  _streamSubscription = eventChannel
      .receiveBroadcastStream()
      .listen(_onEvent, onError: _onError);
}

```

MainActivity.java 主要代码

```java
private void addEventChannel() {
    mEventChannel = new EventChannel(getFlutterView(), "event_channel_sample");
    mEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
        @Override
        public void onListen(Object o, EventChannel.EventSink eventSink) {

            task = new TimerTask() {
                @Override
                public void run() {
                    runOnUiThread(() -> eventSink.success("i miss you " + System.currentTimeMillis()));

                }
            };
            timer = new Timer();
            timer.schedule(task, 2000, 3000);
        }

        @Override
        public void onCancel(Object o) {
            task.cancel();
            timer.cancel();
            task = null;
            timer = null;
        }
    });
}
```
Dart 接受 Android stream event。首先在 Dart 端定义 EventChannel 名字为 `event_channel_sample`。然后设置`receiveBroadcastStream`监听，当 Android 端有消息发过来会回调`_onEvent`方法。</br>
在 Android 端启动一个定时器，每隔3s向 Dart 端发送一次消息。

#### 4.4 总结
如下图，在 Dart 与 Platform 通信过程中，通过 channel name 找到对方，然后把消息通过 codec 进行编解码，最后通过 binaryMessenger 进行发送。
<img src="http://p0.qhimg.com/t01d23cfd7ce4e80077.png"/> 

### 5. 源码分析-以 MethodChannel 为例

##### 5.1 调用 MethodChannel 的 invokeMethod 方法，会调用到 binaryMessenger.send 方法。即 binaryMessenger.send 传入 channel name 和编码好的参数。
```dart
  @optionalTypeArgs
  Future<T> invokeMethod<T>(String method, [ dynamic arguments ]) async {
    assert(method != null);
    final ByteData result = await binaryMessenger.send(
      name,
      codec.encodeMethodCall(MethodCall(method, arguments)),
    );
    if (result == null) {
      throw MissingPluginException('No implementation found for method $method on channel $name');
    }
    final T typedResult = codec.decodeEnvelope(result);
    return typedResult;
  }
```

##### 5.2 binary_messenger.dart 的 send 方法会调用当前对象的 _sendPlatformMessage 方法，最终会调用 window.sendPlatformMessage 方法。
```dart
  @override
  Future<ByteData> send(String channel, ByteData message) {
    final MessageHandler handler = _mockHandlers[channel];
    if (handler != null)
      return handler(message);
    return _sendPlatformMessage(channel, message);
  }
```

```dart
  Future<ByteData> _sendPlatformMessage(String channel, ByteData message) {
    final Completer<ByteData> completer = Completer<ByteData>();
    // ui.window is accessed directly instead of using ServicesBinding.instance.window
    // because this method might be invoked before any binding is initialized.
    // This issue was reported in #27541. It is not ideal to statically access
    // ui.window because the Window may be dependency injected elsewhere with
    // a different instance. However, static access at this location seems to be
    // the least bad option.
    ui.window.sendPlatformMessage(channel, message, (ByteData reply) {
      try {
        completer.complete(reply);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context: ErrorDescription('during a platform message response callback'),
        ));
      }
    });
    return completer.future;
  }
```

##### 5.3 在 window.dart 中又调用了 native 方法 _sendPlatformMessage。
```dart
  void sendPlatformMessage(String name,
                           ByteData data,
                           PlatformMessageResponseCallback callback) {
    final String error =
        _sendPlatformMessage(name, _zonedPlatformMessageResponseCallback(callback), data);
    if (error != null)
      throw Exception(error);
  }
```

```dart
  String _sendPlatformMessage(String name,
                              PlatformMessageResponseCallback callback,
                              ByteData data) native 'Window_sendPlatformMessage';
```
##### 5.4 接下来进入 engine 中的 window.cc，可以看到最终调用的是 dart_state->window()->client()->HandlePlatformMessage。
```c++
void Window::RegisterNatives(tonic::DartLibraryNatives* natives) {
  natives->Register({
      {"Window_defaultRouteName", DefaultRouteName, 1, true},
      {"Window_scheduleFrame", ScheduleFrame, 1, true},
      {"Window_sendPlatformMessage", _SendPlatformMessage, 4, true},
      {"Window_respondToPlatformMessage", _RespondToPlatformMessage, 3, true},
      {"Window_render", Render, 2, true},
      {"Window_updateSemantics", UpdateSemantics, 2, true},
      {"Window_setIsolateDebugName", SetIsolateDebugName, 2, true},
      {"Window_reportUnhandledException", ReportUnhandledException, 2, true},
      {"Window_setNeedsReportTimings", SetNeedsReportTimings, 2, true},
  });
}
```

```c++
void _SendPlatformMessage(Dart_NativeArguments args) {
  tonic::DartCallStatic(&SendPlatformMessage, args);
}
```

```c++
Dart_Handle SendPlatformMessage(Dart_Handle window,
                                const std::string& name,
                                Dart_Handle callback,
                                Dart_Handle data_handle) {
  UIDartState* dart_state = UIDartState::Current();

  if (!dart_state->window()) {
    return tonic::ToDart(
        "Platform messages can only be sent from the main isolate");
  }

  fml::RefPtr<PlatformMessageResponse> response;
  if (!Dart_IsNull(callback)) {
    response = fml::MakeRefCounted<PlatformMessageResponseDart>(
        tonic::DartPersistentValue(dart_state, callback),
        dart_state->GetTaskRunners().GetUITaskRunner());
  }
  if (Dart_IsNull(data_handle)) {
    dart_state->window()->client()->HandlePlatformMessage(
        fml::MakeRefCounted<PlatformMessage>(name, response));
  } else {
    tonic::DartByteData data(data_handle);
    const uint8_t* buffer = static_cast<const uint8_t*>(data.data());
    dart_state->window()->client()->HandlePlatformMessage(
        fml::MakeRefCounted<PlatformMessage>(
            name, std::vector<uint8_t>(buffer, buffer + data.length_in_bytes()),
            response));
  }

  return Dart_Null();
}
```

> [window.cc 源码](https://github.com/flutter/engine/blob/master/lib/ui/window/window.cc)

##### 5.5 我们进入 window.h 中找到 client 其实是 WindowClient。
```c++
  WindowClient* client() const { return client_; }
```

> [window.h 源码](https://github.com/flutter/engine/blob/master/lib/ui/window/window.h)

##### 5.6 在 runtime_controller.h 中可以看到 RuntimeController 是 WindowClient 的实际实现，调用的是 RuntimeController 的 HandlePlatformMessage 方法。
```c++
class RuntimeController final : public WindowClient {

...
  // |WindowClient|
  void HandlePlatformMessage(fml::RefPtr<PlatformMessage> message) override;
...
}
```

> [runtime_controller.h 源码](https://github.com/flutter/engine/blob/78a8ca0f62b04fa49030ecdd2d91726c0639401f/runtime/runtime_controller.h)

##### 5.7 在 runtime_controller.cc 中，HandlePlatformMessage 调用了 client_ 的 HandlePlatformMessage 方法，client_ 实际是代理对象 RuntimeDelegate。
```c++
void RuntimeController::HandlePlatformMessage(
    fml::RefPtr<PlatformMessage> message) {
  client_.HandlePlatformMessage(std::move(message));
}
```

```c++
RuntimeDelegate& p_client
```

> [runtime_controller.cc 源码](https://github.com/flutter/engine/blob/78a8ca0f62b04fa49030ecdd2d91726c0639401f/runtime/runtime_controller.cc)

##### 5.8 engine.h 是 RuntimeDelegate 的具体实现类。
```c++
class Engine final : public RuntimeDelegate {
...
  // |RuntimeDelegate|
  void HandlePlatformMessage(fml::RefPtr<PlatformMessage> message) override;
...  
}  
```

> [engine.h 源码](https://github.com/flutter/engine/blob/78a8ca0f62b04fa49030ecdd2d91726c0639401f/shell/common/engine.h)

##### 5.9 engine.cc 中调用了 delegate_ 的 OnEngineHandlePlatformMessage 方法。
```c++
void Engine::HandlePlatformMessage(fml::RefPtr<PlatformMessage> message) {
  if (message->channel() == kAssetChannel) {
    HandleAssetPlatformMessage(std::move(message));
  } else {
    delegate_.OnEngineHandlePlatformMessage(std::move(message));
  }
}
```

> [engine.cc 源码](https://github.com/flutter/engine/blob/78a8ca0f62b04fa49030ecdd2d91726c0639401f/shell/common/engine.cc)

##### 5.10 shell.h 是 Engine 的代理。
```c++
  // |Engine::Delegate|
  void OnEngineHandlePlatformMessage(
      fml::RefPtr<PlatformMessage> message) override;
```

> [shell.h 源码](https://github.com/flutter/engine/blob/ed8e35c4cfe12f836133944c968e00ca52593d43/shell/common/shell.h)

##### 5.11 调用流程又进入了 shell.cc 的 HandleEngineSkiaMessage 方法，把消费放到 TaskRunner 中。
```c++
// |Engine::Delegate|
void Shell::OnEngineHandlePlatformMessage(
    fml::RefPtr<PlatformMessage> message) {
  FML_DCHECK(is_setup_);
  FML_DCHECK(task_runners_.GetUITaskRunner()->RunsTasksOnCurrentThread());

  if (message->channel() == kSkiaChannel) {
    HandleEngineSkiaMessage(std::move(message));
    return;
  }

  task_runners_.GetPlatformTaskRunner()->PostTask(
      [view = platform_view_->GetWeakPtr(), message = std::move(message)]() {
        if (view) {
          view->HandlePlatformMessage(std::move(message));
        }
      });
}
```

> [shell.cc 源码](https://github.com/flutter/engine/blob/ed8e35c4cfe12f836133944c968e00ca52593d43/shell/common/shell.cc)

##### 5.12 当 task 执行是会调用 platform_view_android.h 的 HandlePlatformMessage 方法。
```c++
class PlatformViewAndroid final : public PlatformView {
...
  // |PlatformView|
  void HandlePlatformMessage(
      fml::RefPtr<flutter::PlatformMessage> message) override;
...
}
```

> [platform_view_android.h 源码](https://github.com/flutter/engine/blob/56052c70afcbdff2d39d2af279fcc52666122dbf/shell/platform/android/platform_view_android.h) 

##### 5.13 在 platform_view_android.cc 的 HandlePlatformMessage 中，开始通过 jni 调用 java 端的方法，java_channel 即要找的 channel。
```c++
// |PlatformView|
void PlatformViewAndroid::HandlePlatformMessage(
    fml::RefPtr<flutter::PlatformMessage> message) {
  JNIEnv* env = fml::jni::AttachCurrentThread();
  fml::jni::ScopedJavaLocalRef<jobject> view = java_object_.get(env);
  if (view.is_null())
    return;

  int response_id = 0;
  if (auto response = message->response()) {
    response_id = next_response_id_++;
    pending_responses_[response_id] = response;
  }
  auto java_channel = fml::jni::StringToJavaString(env, message->channel());
  if (message->hasData()) {
    fml::jni::ScopedJavaLocalRef<jbyteArray> message_array(
        env, env->NewByteArray(message->data().size()));
    env->SetByteArrayRegion(
        message_array.obj(), 0, message->data().size(),
        reinterpret_cast<const jbyte*>(message->data().data()));
    message = nullptr;

    // This call can re-enter in InvokePlatformMessageXxxResponseCallback.
    FlutterViewHandlePlatformMessage(env, view.obj(), java_channel.obj(),
                                     message_array.obj(), response_id);
  } else {
    message = nullptr;

    // This call can re-enter in InvokePlatformMessageXxxResponseCallback.
    FlutterViewHandlePlatformMessage(env, view.obj(), java_channel.obj(),
                                     nullptr, response_id);
  }
}
```

> [platform_view_android.cc 源码](https://github.com/flutter/engine/blob/56052c70afcbdff2d39d2af279fcc52666122dbf/shell/platform/android/platform_view_android.cc)

##### 5.14 在 platform_view_android_jni.cc 中可以看到 g_handle_platform_message_method 就是 FindClass("io/flutter/embedding/engine/FlutterJNI") 类的 handlePlatformMessage 方法。至此 engine 代码执行结束。
```c++
static jmethodID g_handle_platform_message_method = nullptr;
void FlutterViewHandlePlatformMessage(JNIEnv* env,
                                      jobject obj,
                                      jstring channel,
                                      jobject message,
                                      jint responseId) {
  env->CallVoidMethod(obj, g_handle_platform_message_method, channel, message,
                      responseId);
  FML_CHECK(CheckException(env));
}
```

```c++
  g_handle_platform_message_method =
      env->GetMethodID(g_flutter_jni_class->obj(), "handlePlatformMessage",
                       "(Ljava/lang/String;[BI)V");
```

```c++
  g_flutter_jni_class = new fml::jni::ScopedJavaGlobalRef<jclass>(
      env, env->FindClass("io/flutter/embedding/engine/FlutterJNI"));
  if (g_flutter_jni_class->is_null()) {
    FML_LOG(ERROR) << "Failed to find FlutterJNI Class.";
    return false;
  }
```

> [platform_view_android_jni.cc 源码](https://github.com/flutter/engine/blob/ed8e35c4cfe12f836133944c968e00ca52593d43/shell/platform/android/platform_view_android_jni.cc)

##### 5.15 在 FlutterJNI 中调用了 this.platformMessageHandler.handleMessageFromDart 方法。也就是 DartMessenger 的 handleMessageFromDart 方法。
```java
    private void handlePlatformMessage(@NonNull String channel, byte[] message, int replyId) {
        if (this.platformMessageHandler != null) {
            this.platformMessageHandler.handleMessageFromDart(channel, message, replyId);
        }

    }
```

##### 5.16 DartMessenger 中 messageHandlers 通过 channel 名找到对应的 handler 进行处理，这个 handler 就是我们在 java 代码里通过 channel 设置的，整个调用流程完成。
```java
    public void handleMessageFromDart(@NonNull String channel, @Nullable byte[] message, int replyId) {
        Log.v("DartMessenger", "Received message from Dart over channel '" + channel + "'");
        BinaryMessageHandler handler = (BinaryMessageHandler)this.messageHandlers.get(channel);
        if (handler != null) {
            try {
                Log.v("DartMessenger", "Deferring to registered handler to process message.");
                ByteBuffer buffer = message == null ? null : ByteBuffer.wrap(message);
                handler.onMessage(buffer, new DartMessenger.Reply(this.flutterJNI, replyId));
            } catch (Exception var6) {
                Log.e("DartMessenger", "Uncaught exception in binary message listener", var6);
                this.flutterJNI.invokePlatformMessageEmptyResponseCallback(replyId);
            }
        } else {
            Log.v("DartMessenger", "No registered handler for message. Responding to Dart with empty reply message.");
            this.flutterJNI.invokePlatformMessageEmptyResponseCallback(replyId);
        }

    }

```
### Demo 地址
[flutter_platform_channel 使用](https://github.com/roc-x/roc-samples/tree/master/flutter_platform_channel)

### 参考资源
[Writing custom platform-specific code](https://flutter.dev/docs/development/platform-integration/platform-channels)</br>
[platform channel 官方示例](https://github.com/flutter/flutter/tree/master/examples/platform_channel)</br>
[深入理解Flutter Platform Channel](https://www.yuque.com/xytech/flutter/fu7h25)