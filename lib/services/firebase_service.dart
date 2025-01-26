import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add or update user points
  Future<void> updateUserPoints(String name, int points) async {
    final userRef = _firestore.collection('users').doc(name);

    await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(userRef);

      if (snapshot.exists) {
        // Safely cast snapshot data to a map
        final data = snapshot.data() as Map<String, dynamic>;
        final currentPoints = data['points'] ?? 0;
        transaction.update(userRef, {'points': currentPoints + points});
      } else {
        // Create a new user
        transaction.set(userRef, {'name': name, 'points': points});
      }
    });
  }

  // Fetch user points
  Future<int> getUserPoints(String name) async {
    final DocumentSnapshot snapshot = await _firestore.collection('users').doc(name).get();

    // Ensure snapshot exists and data is properly cast
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data['points'] ?? 0;
    }

    return 0;
  }
}
