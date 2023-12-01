import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:untitled10/blog_list_screen.dart';

class BlogPost {
  final String boardTitle;
  final String boardContent;
  final String author;
  final int commentCount;
  final int likeCount;
  final File? imageUrl; // Nullable imageUrl to store the image URL
  final int postId;

  BlogPost({
    required this.boardTitle,
    required this.boardContent,
    required this.author,
    required this.commentCount,
    required this.likeCount,
    required this.postId,
    required this.imageUrl

  });
  // Add a constructor for JSON serialization
  BlogPost.fromJson(Map<String, dynamic> json)
      : boardTitle = json['boardTitle'],
        boardContent = json['boardContent'],
        author = json['author'],
        commentCount = json['commentCount'],
        likeCount = json['likeCount'],
        postId = json['postId'],
        imageUrl = json['imageUrl'] != null ? File(json['imageUrl']) : null;

  // Add a method to convert the object to JSON
  Map<String, dynamic> toJson() => {
    'boardTitle': boardTitle,
    'boardContent': boardContent,
    'boardWriter': author,
    'commentCount': commentCount,
    'likecount': likeCount,
    'postId': postId,
    'frontToBackImage': imageUrl?.path, // Convert File to path string
  };
}

class BlogCreateScreen extends StatefulWidget {
  @override
  _BlogCreateScreenState createState() => _BlogCreateScreenState();
}

class _BlogCreateScreenState extends State<BlogCreateScreen> {
  int locationId=1;
  String authToken = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IuygleyerOuvvCIsImlhdCI6MTcwMDIyNjQ1MCwiZXhwIjoxNzAwMjI4MjUwfQ.OWfPNrZDD7ljWU12sqTaX64fKQW8mJoIKQ_Br0tdNGA';
  Future<void> sendNewPostToBackendWithLocation(BlogPost newPost) async {
    print('7'*70);
    print(newPost.postId);
    print(newPost.boardTitle);
    print(newPost.likeCount);
    print(newPost.author);
    print(newPost.imageUrl);
    print(newPost.boardContent);
    print(newPost.commentCount);
    print('8'*70);

    final response = await http.post(
      Uri.parse('https://bb8e-112-220-77-99.ngrok-free.app/user/board/save/${locationId}'),
      //String url = "https://8c10-203-230-231-144.ngrok-free.app/board/paging/${locationId}?page=$page"; // http request를 보낼 url

    headers: {'Content-Type': 'application/json',
      'Authorization': authToken,},
      body: json.encode({
        ...newPost.toJson(),
      }),
    );
    print(response.statusCode);
    var request = http.MultipartRequest('boardDto', Uri.parse('https://bb8e-112-220-77-99.ngrok-free.app/user/board/save/$locationId'))
      //..headers['Content-Type'] = 'application/json'
      ..headers['Authorization'] = authToken
      ..files.add(http.MultipartFile.fromString(
        'boardDto', // Using 'board' as the field name for the board file (title and content)
        json.encode({
          'boardTitle': newPost.boardTitle,
          'boardContent': newPost.boardContent,
          'boardWriter': newPost.author,
          'commentCount': newPost.commentCount.toString(),
          'likecount': newPost.likeCount.toString(),
          'postId': newPost.postId.toString(),
        }),
      ))
      ..files.add(await http.MultipartFile.fromPath(
        'file', // Using 'dfg' as the field name for the image file
        newPost.imageUrl!.path,
      ));

    if (newPost.imageUrl != null) {
      print("들어옴");
      var file = await http.MultipartFile.fromPath('file', newPost.imageUrl!.path);
      print(file);
      request.files.add(file);
    }
    print("보내는거");
    print(request.files);
    if (response.statusCode == 200) {
      // 글 작성 성공
      print('글 작성 성공');
      //Navigator.pop(BlogListScreen());
      MaterialApp(
        home: BlogListScreen(),
        //home: HomePage(),

      );
    }
    else{
      // 글 작성 실패
      print('글 작성 실패 - ${response.statusCode}');
      Navigator.pop(context);
      throw Exception('Failed to create a new blog post');
    }
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  File? imageUrl; // Store the selected image URL

  Future pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imageUrl = File(pickedFile.path); // Store the selected image path
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 글 등록'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                //labelText: '제목',
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 10),
            if (imageUrl != null)
              Image.file(
                imageUrl!,
                width: 200,
                height: 200,
              ),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('이미지 선택'),
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent, // 버튼 색을 투명하게 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 10,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async{
                print('*'*70);
                String title = titleController.text;
                String content = contentController.text;

                // Create a new BlogPost with the image URL
                BlogPost newPost = BlogPost(
                  boardTitle: title,
                  boardContent: content,
                  author: 'Author',
                  likeCount: 1,
                  commentCount: 1,
                  postId: 1,
                  imageUrl: imageUrl,

                );

                print('-*'*70);
                await sendNewPostToBackendWithLocation(newPost);
                print('-'*70);
                Navigator.pop(context, newPost);
              },
              child: Text('등록하기'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
