import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/my_drawer.dart';
import 'package:social_media_app/components/my_list_tile.dart';
import 'package:social_media_app/components/my_post_button.dart';
import 'package:social_media_app/components/my_textfield.dart';
import 'package:social_media_app/database/firestore.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  final TextEditingController filterController = TextEditingController();
  String filterText = '';

  void postMessage() {
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }

    newPostController.clear();
  }

  Future<String?> getPostIdByMessage(message) {
    return database.getPostIdByMessage(message);
  }

  void deleteMessage(String message) async {
    String? postId = await getPostIdByMessage(message);
    if (postId != null) {
      await database.deletePost(postId);
    } else {
      print('Post not found');
    }
  }

  void editMessage(String oldMessage, String newMessage) async {
    String? postId = await getPostIdByMessage(oldMessage);
    if (postId != null) {
      await database.updatePost(postId, newMessage);
    } else {
      print('Post not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text("W A L L"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextfield(
                    hintText: "Say something...",
                    obscureText: false,
                    controller: newPostController,
                  ),
                ),
                PostButton(onTap: postMessage),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextField(
              controller: filterController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: "Filter posts...",
              ),
              onChanged: (text) {
                setState(() {
                  filterText = text;
                });
              },
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Expanded(
            child: StreamBuilder(
              stream: database.getPostsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final posts = snapshot.data!.docs;

                if (snapshot.data == null || posts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text("No Posts...Post something"),
                    ),
                  );
                }

                final filteredPosts = posts.where((post) {
                  final postMessage = post['PostMessage'] as String;
                  return postMessage
                      .toLowerCase()
                      .contains(filterText.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];

                    String message = post['PostMessage'];
                    String userEmail = post['UserEmail'];
                    Timestamp timestamp = post['TimeStamp'];

                    return MyListTile(
                      title: message,
                      subtitle: userEmail,
                      onDelete: deleteMessage,
                      onEdit: (newMessage) {
                        editMessage(message, newMessage);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
