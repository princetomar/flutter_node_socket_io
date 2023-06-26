import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:user_status_fr/controllers/chat_controllers.dart';
import 'package:user_status_fr/models/message_model.dart';

class HomeChatScreen extends StatefulWidget {
  const HomeChatScreen({super.key});

  @override
  State<HomeChatScreen> createState() => _HomeChatScreenState();
}

class _HomeChatScreenState extends State<HomeChatScreen> {
  // Colors for the app
  Color purle = Color(0xFF6c5ce7);
  Color black = Colors.black;

  TextEditingController msgInputController = TextEditingController();
  late IO.Socket socket;
  ChatController chatController = ChatController();

  @override
  void initState() {
    // initialize the socket - by passing the url at which the server is running
    socket = IO.io(
      "http://localhost:3000",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
    setupSocketListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: Obx(
                () => ListView.builder(
                    itemCount: chatController.chatMessages.length,
                    itemBuilder: (context, index) {
                      var currentItem = chatController.chatMessages[index];
                      return MessageItem(
                        text: currentItem.message,
                        isSentByMe: currentItem.sentByMe == socket.id,
                      );
                    }),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(20),
                child: TextField(
                  cursorColor: purle,
                  controller: msgInputController,
                  style: TextStyle(
                    color: purle,
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.amber,
                    hintText: "Type Something here...",
                    hintStyle: TextStyle(
                      color: purle,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: Container(
                      decoration: BoxDecoration(
                        color: purle,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        border: Border.all(
                          color: black,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          sendMessage(msgInputController.text);
                          msgInputController.clear();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) {
    var messageJson = {
      "message": text,
      "sentByMe": socket.id,
    };
    socket.emit("message", messageJson);
    chatController.chatMessages.add(
      Message.fromJson(messageJson),
    );
  }

  void setupSocketListener() {
    socket.on('message-receive', (data) {
      print(data);
      chatController.chatMessages.add(
        Message.fromJson(data),
      );
    });
  }
}

class MessageItem extends StatelessWidget {
  final String text;
  final bool isSentByMe;
  const MessageItem({super.key, required this.text, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        height: 40,
        width: text.length * 30,
        margin: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 10,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isSentByMe ? 80 : 10,
        ),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.pinkAccent : Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              color: isSentByMe == true ? Colors.white : Colors.black,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
