import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Persists non-secret Firebase profile data in Firestore.
///
/// Authentication credentials, passwords, and tokens are intentionally not
/// stored here. The document ID is the Firebase Auth UID, so profiles cannot
/// be confused with DummyJSON users.
class FirestoreProfileService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('Users');

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return <String, dynamic>{'uid': uid, ...snapshot.data()!};
  }

  Future<void> upsertProfile({
    required String uid,
    required String email,
    required String username,
    required String firstName,
    required String lastName,
    int? age,
    required String contactNo,
    String image = '',
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != uid) {
      throw StateError('A matching Firebase user must be signed in.');
    }

    final reference = _users.doc(uid);
    final existing = await reference.get();
    final data = <String, dynamic>{
      'uid': uid,
      'email': email.trim(),
      'username': username.trim(),
      'displayName': '${firstName.trim()} ${lastName.trim()}'.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'contactNo': contactNo.trim(),
      'image': image,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (age != null) data['age'] = age;
    if (!existing.exists) data['createdAt'] = FieldValue.serverTimestamp();
    await reference.set(data, SetOptions(merge: true));
  }

  Future<void> deleteProfile(String uid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != uid) {
      throw StateError('A matching Firebase user must be signed in.');
    }
    await _users.doc(uid).delete();
  }
}
