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

  DocumentReference<Map<String, dynamic>> _privateProfile(String uid) =>
      _users.doc(uid).collection('private').doc('profile');

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    final privateSnapshot = await _privateProfile(uid).get();
    return <String, dynamic>{
      'uid': uid,
      ...snapshot.data()!,
      if (privateSnapshot.exists && privateSnapshot.data() != null)
        ...privateSnapshot.data()!,
    };
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
    final publicData = <String, dynamic>{
      'uid': uid,
      'email': email.trim(),
      'username': username.trim(),
      'displayName': '${firstName.trim()} ${lastName.trim()}'.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'image': image,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!existing.exists) {
      publicData['createdAt'] = FieldValue.serverTimestamp();
    }
    final privateData = <String, dynamic>{
      'uid': uid,
      'contactNo': contactNo.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (age != null) privateData['age'] = age;
    await reference.set(publicData, SetOptions(merge: true));
    await _privateProfile(uid).set(privateData, SetOptions(merge: true));
  }

  Future<void> deleteProfile(String uid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || currentUser.uid != uid) {
      throw StateError('A matching Firebase user must be signed in.');
    }
    final batch = _firestore.batch();
    batch.delete(_privateProfile(uid));
    batch.delete(_users.doc(uid));
    await batch.commit();
  }
}
