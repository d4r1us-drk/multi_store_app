import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_store_app/models/favorite_model.dart';

class FavoriteController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference> addToFavorites(FavoriteModel favorite) async {
    try {
      return await _firestore.collection('favorites').add(favorite.toMap());
    } catch (e) {
      throw Exception("Failed to add favorite: $e");
    }
  }

  Future<void> removeFromFavorites(String favoriteId) async {
    try {
      await _firestore.collection('favorites').doc(favoriteId).delete();
    } catch (e) {
      throw Exception("Failed to remove favorite: $e");
    }
  }

  Stream<List<FavoriteModel>> getUserFavorites(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FavoriteModel.fromMap(doc.data());
      }).toList();
    });
  }
}
