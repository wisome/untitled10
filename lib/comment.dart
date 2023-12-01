import 'package:flutter/material.dart';

enum SampleItem { itemOne, itemTwo, itemThree }
class CommentWidget extends StatefulWidget {
  final String author;
  final String content;
  final Function(CommentWidget) onCommentAdded; // Callback function

  List<CommentWidget> replyComments = [];

  CommentWidget({
    required this.author,
    required this.content,
    required this.onCommentAdded,
  });

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  int likeCount = 0; // Initial like count
  bool isLiked = false;
  SampleItem? selectedMenu;
  bool isReplying = false;
  TextEditingController replyController = TextEditingController();

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount = isLiked ? likeCount + 1 : likeCount - 1;
    });
  }

  void replyToComment() {
    setState(() {
      if (isReplying) {
        // Create a new reply comment
        CommentWidget newReply = CommentWidget(
          author: 'Reply Author', // Set the appropriate author
          content: replyController.text,
          onCommentAdded: widget.onCommentAdded,
        );

        // Notify the parent widget about the new reply comment
        widget.onCommentAdded(newReply);

        // Update the state
        widget.replyComments.add(newReply);

        // Clear the reply input field and exit reply mode
        replyController.text = '';
        isReplying = false;
      } else {
        isReplying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.author}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    PopupMenuButton<SampleItem>(
                      initialValue: selectedMenu,
                      onSelected: (SampleItem item) {
                        setState(() {
                          selectedMenu = item;
                        });
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<SampleItem>(
                          value: SampleItem.itemOne,
                          child: Text('Report Comment'),
                        ),
                      ],
                    ),
                  ],
                ),
                Text('${widget.content}'),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  onPressed: replyToComment,
                  child: Text('Reply'),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.black,
                      ),
                      onPressed: toggleLike,
                    ),
                    Text('$likeCount'),
                  ],
                ),
              ],
            ),
            if (isReplying)
              TextField(
                controller: replyController,
                decoration: InputDecoration(
                  hintText: 'Enter your reply here',
                ),
              ),
            if (widget.replyComments.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.replyComments.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: reply,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
