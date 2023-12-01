import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled10/blog_list_screen.dart';
import 'package:untitled10/chat_ex2.dart';
import 'simple-test.dart';
import 'new.dart';
import 'chat_ex.dart';

import 'package:untitled10/chat.dart';
void main() {
  runApp(MyApp());
}
/*void main() {
  runApp(const Example());
}*/
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home://YourScreen()
      //MyHomePage()
      BlogListScreen(),
        //home: HomePage(),
        //MyHomePage(),
      //PostCreationScreen()

    );
  }
}



/*
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> _images = [];

  void _navigateToImageUploadScreen() async {
    final File? image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageUploadScreen()),
    );

    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 업로드 예시'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _images.isEmpty
                ? Center(child: Text('이미지가 없습니다.'))
                : ListView.builder(
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Image.file(_images[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToImageUploadScreen,
        tooltip: '이미지 업로드',
        child: Icon(Icons.add),
      ),
    );
  }
}

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;

  Future _getImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }else {
        print('No image selected.');
      }
    });
  }

  void _addImage() {
    Navigator.pop(context, _image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 업로드'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('이미지를 선택하세요.')
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('갤러리에서 이미지 선택'),
            ),
            ElevatedButton(
              onPressed: _addImage,
              child: Text('추가하기'),
            ),
          ],
        ),
      ),
    );
  }
}*/

