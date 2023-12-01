import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class YourData {
  String title;
  List<int> imageBytes;

  YourData({required this.title, required this.imageBytes});

  factory YourData.fromJson(Map<String, dynamic> json) {
    return YourData(
      title: json['boardTitle'],
      imageBytes: (json['image'] != null) ? List<int>.from(json['image']) : [], // Handle null case
    );
  }
}

class YourScreen extends StatefulWidget {
  @override
  _YourScreenState createState() => _YourScreenState();
}

class _YourScreenState extends State<YourScreen> {
  late List<YourData> dataFromBackend;

  @override
  void initState() {
    super.initState();
    dataFromBackend = []; // Provide a default empty list
    fetchDataFromBackend();
  }

  Future<void> fetchDataFromBackend() async {
    final response = await http.get(Uri.parse('https://f42b-27-124-178-180.ngrok-free.app/board/paging/1?page=0'));
    print(response.statusCode);

    if (response.statusCode == 200) {
      print("여기");
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData.containsKey('content')) {
        final List<dynamic> dataList = jsonData['content'];
        print("Data List: $dataList");

        setState(() {
          dataFromBackend = dataList.map((data) => YourData.fromJson(data)).toList();
        });

        print("Data From Backend: $dataFromBackend");
      } else {
        print("No 'content' key found in JSON response.");
      }
      print("지나옴");
    } else {
      throw Exception('Failed to load data from the backend');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your App'),
      ),
      body: dataFromBackend.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: dataFromBackend.length,
        itemBuilder: (context, index) {
          var currentData = dataFromBackend[index];

          // Decode byte array to image
          Uint8List bytes = Uint8List.fromList(currentData.imageBytes);
          String base64String = base64Encode(bytes);
          Image image = Image.memory(base64Decode(base64String));

          return ListTile(
            title: Text(currentData.title),
            leading: Container(
              width: 50,
              height: 50,
              child: image,
            ),
          );
        },
      ),
    );
  }
}
