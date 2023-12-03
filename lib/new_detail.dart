import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled10/blog_create_screen.dart';
import 'package:untitled10/search_screen.dart';
import 'package:untitled10/blog_detail_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:untitled10/chat.dart';
import 'new.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:typed_data';

class Post{
  String boardTitle;
  String boardContent;
  //File? frontToBackImage;
  http.ByteStream? image;
  int likeCount;
  int commentCount;
  int postId;

  Post(this.boardTitle, this.boardContent, this.image, this.likeCount, this.commentCount, this.postId);

  Post.fromJson(Map json)
      : boardTitle = json["boardTitle"],
        boardContent = json["boardContent"],
        image = (json["image"] != null)
            ? http.ByteStream.fromBytes(base64.decode(json["image"]))
            : http.ByteStream(Stream.empty()), // Provide an empty ByteStream if image is null
        likeCount = json["likeCount"],
        commentCount = json["commentCount"],
        postId = json["postId"];

}


class BlogListScreen extends StatefulWidget {
  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  StreamController _streamController = StreamController();

  //StreamController<List<Post>> streamController = StreamController(); // 데이터를 받아들이는 스트림.
  int currentPage=0;
  int locationId = 1;
  bool isLoading = false;
  List<Post> dataList = []; // Track the data separately

  @override
  void initState() {
    super.initState();
    fetchData();
    //_scrollController.addListener(_scrollListener);
    // Fetch data when the state is initialized
    /*getTodo(locationId, currentPage).then((todos) {
      streamController.add(todos);
    });*/
  }

  Future<void> _refresh() async {
    // Implement the logic to refresh your data
    currentPage++; // Reset the page to 0 when refreshing
    //_refreshController.loadComplete();
    await fetchData();
    //setState(() {});
  }

  /*Future<void> fetchData() async {
    try {
      List<Post> todos = await getTodo(locationId, currentPage);
      streamController.add(todos);
    } catch (e) {
      print('Error: $e');
      // Handle error (show a message, retry, etc.)
    }
  }*/
  Future<void> fetchData() async {
    try {
      if (!isLoading) {
        isLoading = true;
        List<Post> todos = await getTodo(locationId, currentPage);
        dataList.addAll(todos); // Append new data to existing list
        _streamController.add(dataList.toList()); // Add the updated list to the stream
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
    }
  }
  Future<List<Post>> getTodo(int postid) async {
    String original = 'https://f42b-27-124-178-180.ngrok-free.app';
    String sub = "/board/findBoard/${postid}"; // http request를 보낼 url
    //String url = "https://ae63-203-230-231-145.ngrok-free.app//board/paging/${locationId}?page=$page"; // http request를 보낼 url
    //String url = "http://192.168.43.20:8080/board/paging/${locationId}?page=$page"; // http request를 보낼 url
    //String url = "https://jsonplaceholder.typicode.com/todos"; // http request를 보낼 url
    String url = original + sub;
    print(url);
    http.Client _client = http.Client(); // http 클라이언트 사용
    List<Post> list = [];
    try {
      print("durl?");
      final response = await _client.get(Uri.parse(url));
      print('상태 =');
      print(response.statusCode);

      if (response.statusCode == 200) {

        //final todos = json.decode(utf8.decode(response.bodyBytes));
        final todos = json.decode(utf8.decode(response.bodyBytes))["content"];
        print('s'*70);
        print(todos);
        print('Todos: $todos');
        print('a'*70);
        todos.forEach((todo) {
          print('123'*35);
          print('Processing todo: $todo');
          print("여기error");
          try {
            list.add(Post.fromJson(todo));
          } catch (e) {
            print('Error adding todo: $e');
          }
          list.add(Post.fromJson(todo)); // Remove this line
          print("error 지남");
        });
        print('여기!');
        todos.forEach((todo) => list.add(Post.fromJson(todo)));
        print('아닌가?');
        print('s'*70);
        print(todos);


      } else {
        // Handle the case where the server responded with an error.
        print("Failed to load todos. Status code: ${response.statusCode}");
        // You can throw an exception, show an error message, or handle it in any way you prefer.
        throw Exception("Failed to load todos");
      }
    } catch (e) {
      // Handle other potential errors such as network issues.
      // You can throw an exception, show an error message, or handle it in any way you prefer.
      print('catch 문');
      throw Exception("Error while fetching todos");
    } finally {
      _client.close(); // Close the client to free up resources.
    }
    return list;
  }

  Widget _buildListTile (AsyncSnapshot snapshot, int index) { // 리스트 뷰에 들어갈 타일(작은 리스트뷰)를 만든다.
    int id = snapshot.data[index].postId;
    String title = snapshot.data[index].boardTitle;
    String content = snapshot.data[index].boardContent;
    http.ByteStream image = snapshot.data[index].image;
    int likes = snapshot.data[index].likeCount;
    int comment = snapshot.data[index].commentCount;
    print('commentCount');
    print(snapshot.data[index].commentCount);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                PopupMenuButton<SampleItem>(
                  initialValue: selectedMenu,
                  // Callback that sets the selected popup menu item.
                  onSelected: (SampleItem item) {
                    if (item == SampleItem.itemOne) {
                      // 수정 선택 시의 로직 추가
                      // 수정 화면으로 이동하거나 수정하는 기능을 구현하세요.
                    } else if (item == SampleItem.itemTwo) {
                      // 삭제 선택 시의 로직 추가
                      _showDeleteConfirmationDialog(widget.postId);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemOne,
                      child: Text('수정'),
                    ),
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemTwo,
                      child: Text('삭제'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.author),
                  SizedBox(height: 10.0),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    widget.content,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 10.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      child: /*Image.file(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                      ),*/
                      Text('456'),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.black,
                        ),
                        onPressed: toggleLike,
                      ),
                      Text('$likeCount'),
                      IconButton(
                        icon: Icon(
                          isbookmark ? Icons.bookmark : Icons.bookmark_border,
                          color: isbookmark ? Colors.blue : Colors.black,
                        ),
                        onPressed: togglebookmark,
                      ),
                      Text('$bookmarkCount'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('댓글'),
                      Text(' $chatCount'),
                    ],
                  ),
                  if (mainComments.isNotEmpty)
                    ...mainComments,
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Create a new comment
                    CommentWidget newComment = CommentWidget(
                      author: 'Your Username',
                      // Replace with the actual username or author
                      content: searchController.text,
                      onCommentAdded: onCommentAdded, // Pass the callback
                    );

                    // Notify the parent widget about the new comment
                    onCommentAdded(newComment);

                    // Clear the input field
                    searchController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ScrollController _scrollController = ScrollController();


  @override
  void dispose() {
    _scrollController.dispose();
    _streamController.close(); // Close the stream controller
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Reached the end of the list, trigger custom loading function
      //_refresh();
    }
  }
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('장소이름'),
          backgroundColor: Colors.blue,
        ),



        body: Column(
          children: <Widget>[
            Flexible(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                controller: _refreshController,
                //onLoading: _refresh,
                child: StreamBuilder(
                  stream: _streamController.stream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          if (index == snapshot.data.length) {
                            //currentPage++;
                            //_refresh(); // Trigger refresh when reaching the end
                          }
                          return _buildListTile(snapshot, index);
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
