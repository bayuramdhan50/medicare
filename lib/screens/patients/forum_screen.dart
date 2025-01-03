import 'package:flutter/material.dart';
import 'package:medicare/models/user_model.dart';
import 'package:medicare/widgets/custom_button.dart';

class ForumScreen extends StatefulWidget {
  final UserModel user;

  ForumScreen({required this.user});

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  // Sample forum topics
  List<String> forumTopics = [
    'What are the best tips for healthy living?',
    'How to manage stress effectively?',
    'The importance of regular medical checkups.',
    'Healthy diet plans and their impact on health.',
  ];

  // Sample comments for each forum topic
  Map<int, List<String>> comments = {
    0: ['Great tips!', 'I agree with this advice.'],
    1: ['Stress management is key!', 'Deep breathing exercises help.'],
    2: ['I need to schedule a checkup soon.'],
    3: ['I love the Mediterranean diet!'],
  };

  // Controller for the comment TextField
  TextEditingController _commentController = TextEditingController();

  // Function to add a comment
  void _addComment(int topicIndex) {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments[topicIndex]!.add(_commentController.text);
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Forum topics list
            Expanded(
              child: ListView.builder(
                itemCount: forumTopics.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Topic title
                          Text(
                            forumTopics[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Display comments
                          for (var comment in comments[index]!)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                comment,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          SizedBox(height: 8),
                          // Comment input field
                          TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              labelText: 'Write a comment...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 8),
                          CustomButton(
                            text: 'Post Comment',
                            onPressed: () {
                              _addComment(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
