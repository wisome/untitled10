import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled10/blog_create_screen.dart';
import 'package:untitled10/search_screen.dart';
import 'package:untitled10/blog_detail_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:untitled10/chat.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:typed_data';
import 'new.dart';
class Post{
  String boardTitle;
  String boardContent;
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
            : http.ByteStream(Stream.empty()),
        likeCount = json["likeCount"],
        commentCount = json["commentCount"],
        postId = json["postId"];
}

class BlogListScreen extends StatefulWidget {
  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {

  StreamController _streamController = StreamController.broadcast();
  int currentPage=0;
  int locationId = 1;
  bool isLoading = false;
  List<Post> dataList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _refresh() async {
    currentPage++;
    await fetchData();
  }

  Future<void> fetchData() async {
    try {
      if (!isLoading) {
        isLoading = true;
        List<Post> newTodos = await getTodo(locationId, currentPage);
        dataList.addAll(newTodos);
        _streamController.add(newTodos);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<List<Post>> getTodo(int locationId, int page) async {
    String original = 'https://f42b-27-124-178-180.ngrok-free.app';
    String sub = "/board/paging/${locationId}?page=$page";
    String url = original + sub;
    http.Client _client = http.Client();
    List<Post> list = [];
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final todos = json.decode(utf8.decode(response.bodyBytes))["content"];
        todos.forEach((todo) {
          try {
            list.add(Post.fromJson(todo));
          } catch (e) {
            print('Error adding todo: $e');
          }
        });
      } else {
        throw Exception("Failed to load todos");
      }
    } catch (e) {
      throw Exception("Error while fetching todos");
    } finally {
      _client.close();
    }
    return list;
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _streamController.close();
    super.dispose();
  }
  Widget _buildListTile (AsyncSnapshot snapshot, int index) {
    int id = snapshot.data[index].postId;
    String title = snapshot.data[index].boardTitle;
    String content = snapshot.data[index].boardContent;
    http.ByteStream image = snapshot.data[index].image;
    int likes = snapshot.data[index].likeCount;
    int comment = snapshot.data[index].commentCount;

    return Card(
      child: InkWell(
        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(
                postId: id,
                title: title,
                image: image,
                content: content,
                comments: comment,
                likes: likes,
                author: '사용자 닉네임',
              ),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: FutureBuilder<Uint8List>(
                future: snapshot.data[index].image.toBytes(),
                builder: (context, bytesSnapshot) {
                  if (bytesSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (bytesSnapshot.hasError) {
                    return Text('Error loading image');
                  } else if (!bytesSnapshot.hasData) {
                    return Text('No image data');
                  } else {
                    return Image.memory(
                      bytesSnapshot.data!,
                      width: 100,
                      height: 100,
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$title",
                            style:
                            TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "$content",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.favorite_outline),
                        SizedBox(width: 4),
                        Text('$likes'),
                        SizedBox(width: 10),
                        Icon(Icons.chat_bubble_outline),
                        SizedBox(width: 4),
                        Text('$comment'),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ScrollController _scrollController = ScrollController();



  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
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
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: '글쓰기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: '채팅',
            ),
          ],
          onTap: (int index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostCreationScreen(),
                ),
              );
            }
            else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ),
              );
            }
            else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}