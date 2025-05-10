import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/search/domain/search_repo.dart';

class FirebaseSearchRepo implements SearchRepo {
  @override
  Future<List<ProfileUser?>> searchUsers(String query) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection("users")
          .get();
          
      return result.docs 
          .map((doc) => ProfileUser.fromJson(doc.data()))
          .where((user) => user.name.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }
}