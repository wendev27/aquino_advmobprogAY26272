import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message.dart';
import '../models/chat_user.dart';

/// Firestore access for the Firebase-only user directory and private chats.
class ChatService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static String roomIdFor(String firstUid, String secondUid) {
    final first = firstUid.trim();
    final second = secondUid.trim();
    if (first.isEmpty || second.isEmpty) {
      throw const FormatException('Both chat participants are required.');
    }
    if (first == second) {
      throw const FormatException('You cannot start a chat with yourself.');
    }
    final participants = [first, second]..sort();
    return '${participants[0]}_${participants[1]}';
  }

  Stream<List<ChatUser>> watchUsers() {
    final currentUser = _requireFirebaseUser();
    final users = _firestore.collection('Users');
    return _watchUsers(users, currentUser.uid);
  }

  Stream<List<ChatUser>> _watchUsers(
    CollectionReference<Map<String, dynamic>> users,
    String currentUid,
  ) async* {
    // Fetch once so the list can render even if the web listener takes time
    // to establish. The snapshots stream then keeps it live.
    final initialSnapshot =
        await users.get().timeout(const Duration(seconds: 10));
    yield _mapUsers(initialSnapshot, currentUid);

    await for (final snapshot in users.snapshots()) {
      yield _mapUsers(snapshot, currentUid);
    }
  }

  List<ChatUser> _mapUsers(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    String currentUid,
  ) {
    final users = snapshot.docs
        .map(ChatUser.fromDocument)
        .where((user) => user.uid != currentUid)
        .where((user) => user.email.isNotEmpty)
        .toList();
    users.sort((a, b) => a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        ));
    return users;
  }

  Future<String?> findUidByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return null;
    final snapshot = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  Stream<List<ChatMessage>> watchMessages(String recipientUid) {
    final currentUser = _requireFirebaseUser();
    final roomId = roomIdFor(currentUser.uid, recipientUid);
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs.map(ChatMessage.fromDocument).toList();
      messages.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return a.timestamp!.compareTo(b.timestamp!);
      });
      return messages;
    });
  }

  Future<void> sendMessage({
    required String recipientUid,
    required String recipientEmail,
    required String text,
  }) async {
    final currentUser = _requireFirebaseUser();
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw const FormatException('Message cannot be empty.');
    }
    if (trimmedText.length > 2000) {
      throw const FormatException('Message must be 2,000 characters or less.');
    }
    final roomId = roomIdFor(currentUser.uid, recipientUid);
    final room = _firestore.collection('chat_rooms').doc(roomId);
    final existingRoom = await room.get();
    final participants = [currentUser.uid, recipientUid]..sort();
    final participantEmails = <String, String>{
      currentUser.uid: currentUser.email ?? '',
      recipientUid: recipientEmail.trim(),
    };
    final roomData = <String, dynamic>{
      'participants': participants,
      'participantEmails': participantEmails,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!existingRoom.exists) {
      roomData['createdAt'] = FieldValue.serverTimestamp();
    }
    await room.set(roomData, SetOptions(merge: true));

    await room.collection('messages').add({
      'senderId': currentUser.uid,
      'senderEmail': currentUser.email ?? '',
      'receiverId': recipientUid,
      'receiverEmail': recipientEmail.trim(),
      'text': trimmedText,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent',
    });
  }

  User _requireFirebaseUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Chat requires a signed-in Firebase account.');
    }
    return user;
  }
}
