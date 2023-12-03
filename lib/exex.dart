import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:web_socket_channel/stomp.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Chat App',
      home: ChatScreen(),
    );
  }
}
String baseUrl = 'https://17c1-211-224-31-97.ngrok-free.app';
class ChatScreen extends StatelessWidget {
  final String baseUrl = 'https://17c1-211-224-31-97.ngrok-free.app';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Chat Room'),
      ),
      body: ChatRoom(),
    );
  }
}

class ChatRoom extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final roomIdController = useTextEditingController();
    //final channel = IOWebSocketChannel.connect('ws://6f93-112-220-77-99.ngrok-free.app/chat/${roomIdController}');

    return Column(
      children: [
        TextField(
          controller: roomIdController,
          decoration: InputDecoration(
            labelText: 'Enter Room ID',
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final roomId = roomIdController.text;
            final roomExists = await checkIfRoomExists(roomId);
            if (!roomExists) {
              await createChatRoom(roomId);
            }

            enterChatRoom(context, roomId);
          },
          child: Text('Enter Chat Room'),
        ),
        /*StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(snapshot.hasData ? '${snapshot.data}' : ''),
            );
          },
        ),*/
      ],
    );
  }

  Future<bool> checkIfRoomExists(String roomId) async {
    final response = await http.post(Uri.parse('$baseUrl/chat/room?roomId=$roomId'));

    return response.statusCode == 200;
  }

  Future<void> createChatRoom(String roomId) async {
    final response = await http.post(Uri.parse('$baseUrl/chat/rooms'), body: {'roomId': roomId});

    if (response.statusCode != 200) {
      throw Exception('Failed to create chat room');
    }
  }

  void enterChatRoom(BuildContext context, String roomId) {
    // Implement navigation to the chat room
    // You can use Navigator.push to navigate to the chat room page
    print('입장');
    //final channel = IOWebSocketChannel.connect('ws://6f93-112-220-77-99.ngrok-free.app/chat/$roomId');

    // Example using MaterialPageRoute:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(baseUrl: baseUrl, roomId: roomId),
      ),
    );
  }
}

class ChatRoomPage extends StatefulWidget {
  final String baseUrl;
  final String roomId;

  ChatRoomPage({required this.baseUrl, required this.roomId});

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  //late WebSocketChannel channel;
  late WebSocketChannel connectionChannel;
  late WebSocketChannel messageChannel;
  final TextEditingController messageController = TextEditingController();
  late List<String> chatMessages;
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  void showConnectionSuccessSnackBar() {
    showSnackBar('*'*70);
    showSnackBar('WebSocket connection established successfully!');
  }
  void showMessageSentSnackBar() {
    showSnackBar('*'*80);
    showSnackBar('Message sent successfully!');
  }
  @override
  void initState() {
    super.initState();
    // Connect to the WebSocket when the page is created
    //channel = IOWebSocketChannel.connect('ws://7c1d-112-220-77-99.ngrok-free.app/connection');
    connectionChannel = IOWebSocketChannel.connect('ws://17c1-211-224-31-97.ngrok-free.app/connection');

    // Initialize chatMessages list
    chatMessages = [];

    // Connect to the WebSocket for messages
    messageChannel = IOWebSocketChannel.connect('ws://17c1-211-224-31-97.ngrok-free.app/app/chat/message');


    // Listen for incoming messages from the server
    /*channel.stream.listen((message) {
      print('Received message: $message');
      // Handle the incoming message, e.g., update the UI with the new message
      setState(() {
        chatMessages.add(message);
      });
    });*/
    messageChannel.stream.listen((message) {
      print('Received message: $message');
      // Handle the incoming message, e.g., update the UI with the new message
      setState(() {
        chatMessages.add(message);
        showMessageSentSnackBar(); // Show snackbar for successful message sending
      });
    });
  }

  /*void sendMessage() {
    // ... (unchanged)

    // Clear the message input field
    messageController.clear();
  }*/
  /*void sendMessage() {
    final message = messageController.text.trim();

    if (message.isNotEmpty) {
      final messageData = {
        'roomId': widget.roomId,
        'nickname': 'YourNickname', // Replace with the actual nickname logic
        'time': DateTime.now().toIso8601String(),
        'message': message,
      };

      // Send the message to the server
      channel.sink.add(jsonEncode(messageData));
      print('보냄아마');
      // Clear the message input field
      messageController.clear();
    }
  }*/
  void sendMessage() async {

    final message = messageController.text.trim();

    if (message.isNotEmpty) {
      final messageData = {
        'roomId': widget.roomId,
        'nickname': 'YourNickname', // Replace with the actual nickname logic
        'time': DateTime.now().toIso8601String(),
        'message': message,
      };
      messageChannel.sink.add(jsonEncode(messageData));
      print('Message sent to WebSocket server');
      showMessageSentSnackBar(); // Show snackbar for successful message sending
      // Clear the message input field
      messageController.clear();
      // Send the message to the server through WebSocket
      /*channel.sink.add(jsonEncode(messageData));
      print('Message sent to WebSocket server');


      // Clear the message input field
      messageController.clear();*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room: ${widget.roomId}'),
      ),
      body: Column(
        children: [
          // Removed StreamBuilder from here
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(chatMessages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: () => sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Close the WebSocket connection when the page is disposed
    //channel.sink.close();
    connectionChannel.sink.close();
    messageChannel.sink.close();
    super.dispose();
  }
}
