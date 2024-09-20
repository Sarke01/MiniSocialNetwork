import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts =
      FirebaseFirestore.instance.collection("Posts");

  Future<void> addPost(String message) {
    return posts.add({
      'UserEmail': user!.email,
      'PostMessage': message,
      'TimeStamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getPostsStream() {
    final postsStream = FirebaseFirestore.instance
        .collection('Posts')
        .orderBy('TimeStamp', descending: true)
        .snapshots();

    return postsStream;
  }

  Future<String?> getPostIdByMessage(String postMessage) async {
    try {
      var querySnapshot = await posts
          .where('PostMessage', isEqualTo: postMessage)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot
            .docs.first.id; // Vraćamo id prvog pronađenog dokumenta
      } else {
        return null; // Ako nije pronađen nijedan dokument
      }
    } catch (e) {
      print('Error getting postId by message: $e');
      return null;
    }
  }

  Future<void> deletePost(String documentId) async {
    try {
      await posts.doc(documentId).delete();
      print('Post deleted successfully');
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  Future<void> updatePost(String documentId, String newMessage) async {
    try {
      await posts.doc(documentId).update({
        'PostMessage': newMessage,
        'TimeStamp':
            Timestamp.now(), // Možete ažurirati i vreme ako je potrebno
      });
      print('Post updated successfully');
    } catch (e) {
      print('Error updating post: $e');
    }
  }
}
