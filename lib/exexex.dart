import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  final String baseUrl;
  final String postId;

  ChatScreen({required this.baseUrl, required this.postId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel channel;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    connectToWebSocket();
  }

  void connectToWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('${widget.baseUrl}/chat/${widget.postId}'),
    );
    channel.stream.listen((message) {
      // 웹소켓으로부터 메시지 수신 시 처리 로직
    });
  }

  void sendMessage(String message) {
    http.post(Uri.parse('${widget.baseUrl}/chat/message/${widget.postId}'),
        body: {'message': message}).then((response) {
      // 메시지 전송 후 처리 로직
    }).catchError((error) {
      // 에러 처리 로직
    });
    textEditingController.clear();
  }

  Future<bool> checkRoomExistence() async {
    final response =
    await http.get(Uri.parse('${widget.baseUrl}/chat/rooms'));
    if (response.statusCode == 200) {
      // 채팅방 목록에서 해당 postId의 채팅방이 있는지 확인하는 로직
      return true; // 채팅방이 존재하는 경우
    } else {
      return false; // 채팅방이 존재하지 않는 경우
    }
  }

  Future<void> createChatRoom() async {
    final response = await http.post(
      Uri.parse('${widget.baseUrl}/chat/room?roomId=${widget.postId}'),
    );
    if (response.statusCode == 200) {
      // 채팅방 생성 후 처리 로직
    } else {
      // 채팅방 생성 실패 처리 로직
    }
  }

  void enterChatRoom() {
    http.post(
      Uri.parse('${widget.baseUrl}/chat/room/enter/${widget.postId}'),
    ).then((response) {
      // 채팅방 입장 후 처리 로직
    }).catchError((error) {
      // 채팅방 입장 실패 처리 로직
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅 앱'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                // 채팅 메시지를 보여주는 UI 로직
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: '메시지 입력',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(textEditingController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  String baseUrl = 'eb88-112-220-77-99.ngrok-free.app';
  String postId = 'your_post_id';

  runApp(
    MaterialApp(
      home: FutureBuilder(
        future: checkRoomExistence(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.data == true) {
              return ChatScreen(baseUrl: baseUrl, postId: postId);
            } else {
              createChatRoom();
              return CircularProgressIndicator();
            }
          }
        },
      ),
    ),
  );
}
