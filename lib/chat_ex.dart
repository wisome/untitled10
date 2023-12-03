import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final int postId;

  ChatScreen({required this.postId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel channel;
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    print('123');
    super.initState();
    channel = IOWebSocketChannel.connect('ws://6f93-112-220-77-99.ngrok-free.app/chat/5');

    //channel = IOWebSocketChannel.connect('ws://eb88-112-220-77-99.ngrok-free.app/chat/message');
    channel.sink.add(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Display chat messages here
                  return Text(snapshot.data.toString());
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      channel.sink.add(_textController.text);
      _textController.clear();
      print("전송되고있나?");
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}


class MyHomePage extends StatelessWidget {
  final int postId = 5; // Replace with the actual postId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter WebSocket Chat'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            bool chatRoomExists = await ChatApi.doesChatRoomExist(postId);
            //chatRoomExists = true;
            //chatRoomExists = false;
            print('chatRoomExists');
            print(chatRoomExists);

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(chatRoomExists ? 'Join Chat' : 'Create Chat'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (chatRoomExists) {
                          // Navigate to the chat screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(postId: postId),
                            ),
                          );
                        } else {
                          // Add logic to create a new chat room if needed
                          // For simplicity, we'll just print a message
                          ChatApi.createChatRoom(postId);
                          print('Creating a new chat room...');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(postId: postId),
                            ),
                          );
                        }
                      },
                      child: Text('OK'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text('Open Chat'),
        ),
      ),
    );
  }
}

class ChatApi {
  static const String baseUrl = 'https://6f93-112-220-77-99.ngrok-free.app'; // Replace with your actual API base URL

  static Future<bool> doesChatRoomExist(int postId) async {
    try {
      //final response = await http.post(Uri.parse('$baseUrl/chat/room?roomId=${postId}')); //채팅방생성
      final response = await http.get(Uri.parse('$baseUrl/chat/room/enter/${postId}')); //채팅방입장

      if (response.statusCode == 200) {
        // Parse the response and check if the chat room exists
        final Map<String, dynamic> data = json.decode(response.body);
        return data['exists'] ?? false;
      } else {
        // Handle non-200 status codes
        print('Error checking chat room existence. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Handle network errors
      print('Error checking chat room existence: $e');
      return false;
    }
  }

  static Future<void> createChatRoom(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/rooms'),
        //body: {'postId': postId},
      );

      if (response.statusCode == 200) {
        // Successful response
        print('Chat room created successfully');
      } else {
        // Handle non-200 status codes
        print('Error creating chat room. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      print('catch');
      print('Error creating chat room: $e');
    }
  }
}


/*class ChatApi {
  static Future<bool> doesChatRoomExist(String postId) async {
    // Replace this with your actual API call logic
    // For demonstration purposes, we'll simulate the API call using a Future
    try {
      // Simulate an API call to check if the chat room exists
      // For example, you might use the http package to make HTTP requests
      // http.Response response = await http.get('your_backend_url/checkChatRoom?postId=$postId');

      // In this example, we simulate the response with a Future.delayed
      await Future.delayed(Duration(seconds: 2)); // Simulate API response delay

      // Replace the following logic with your actual API response handling
      // For demonstration, we assume a JSON response with a 'exists' field
      Map<String, dynamic> jsonResponse = {'exists': true}; // Replace with your API response
      bool chatRoomExists = jsonResponse['exists'];

      return chatRoomExists;
    } catch (e) {
      // Handle errors (e.g., network issues, server errors)
      print('Error checking chat room existence: $e');
      return false; // Return false in case of errors
    }
  }
  static Future<void> createChatRoom(String postId) async {
    // Replace this with your actual API call logic to create a chat room
    // For demonstration purposes, we'll simulate the API call using a Future
    try {
      // Simulate an API call to create a new chat room
      // For example, you might use the http package to make HTTP requests
      // http.Response response = await http.post('your_backend_url/createChatRoom', body: {'postId': postId});

      // In this example, we simulate the response with a Future.delayed
      await Future.delayed(Duration(seconds: 2)); // Simulate API response delay

      // Replace the following logic with your actual API response handling
      // For demonstration, we assume a successful response
      print('Chat room created successfully');
    } catch (e) {
      // Handle errors (e.g., network issues, server errors)
      print('Error creating chat room: $e');
      // You might want to throw an exception or handle the error accordingly
    }
  }
}*/