import 'dart:convert';

import 'package:chat_app_socket/message_model.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WebSocketChannel _webSocketChannel;
  final TextEditingController _messageController = TextEditingController();
  final List<MessageModel> _messageList = [];

  @override
  void initState() {
    _webSocketChannel = IOWebSocketChannel.connect("ws://echo.websocket.org");

    // _listenToNewMessages();
    super.initState();
  }

  MessageModel getMessageModel() {
    String message = _messageController.text;
    bool isMessageSent = false;
    MessageModel messageModel = MessageModel(
      id: 'msg123${DateTime.now()}',
      text: message,
      messageType: MessageType.text,
      senderId: 'user123',
      senderName: 'John Doe',
      chatRoomId: 'room456',
      timestamp: DateTime.now(),
      status: isMessageSent ? MessageStatus.sent : MessageStatus.failed,
      reactions: {
        '👍': ['user123', 'user456']
      }, // Two users reacted with a thumbs up
    );

    return messageModel;
  }

  _convertMessageToJson(MessageModel messageModel) {
    return jsonEncode(messageModel.toJson());
  }

  _sendMessage() {
    MessageModel messageModel = getMessageModel();

    var jsonMessageModel = _convertMessageToJson(messageModel);

    if (messageModel.text.isNotEmpty) {
      try {
        _webSocketChannel.sink.add(jsonMessageModel);

        debugPrint("sent $jsonMessageModel");

        _addSentMessageToList(messageModel);
      } catch (e) {
        debugPrint("could not send message: $e");
      }
    }
  }

  _listenToNewMessages() {
    _webSocketChannel.stream.listen((newMessage) {
      // parse the message
      var convertedMessage = _convertJsonDataToModel(newMessage);
      MessageModel receivedMessage = MessageModel.fromJson(convertedMessage);

      debugPrint("new $receivedMessage");

      _addSentMessageToList(receivedMessage);
    });
  }

  _convertJsonDataToModel(String message) {
    return jsonDecode(message);
  }

  _addSentMessageToList(MessageModel message) {
    setState(() {
      _messageList.add(message);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _webSocketChannel.sink.close();
    super.dispose();
  }

  final InputBorder _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: const BorderSide(color: Colors.black12),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Chat App"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder(
                  stream: _webSocketChannel.stream,
                  builder: (context, AsyncSnapshot snapshot) {
                    return ListView.builder(
                        itemCount: _messageList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                                left: 15,
                                right: 80,
                                bottom:
                                    index == _messageList.length - 1 ? 15 : 0,
                                top: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.blueGrey,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 12),
                                child: Text(
                                  _messageList[index].text,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        });
                  }),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                hintStyle: const TextStyle(color: Colors.black),
                fillColor: Colors.white,
                hintText: "Enter Message Here...",
                border: _border,
                enabledBorder: _border,
                errorBorder: _border,
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: _sendMessage,
            tooltip: 'Send Message',
            child: const Icon(
              Icons.send,
            ),
          ),
        ],
      ),
    );
  }
}
