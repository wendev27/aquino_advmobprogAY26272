import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String uid;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String image;

  const ChatUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.image = '',
  });

  factory ChatUser.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    return ChatUser(
      uid: '${data['uid'] ?? document.id}',
      email: '${data['email'] ?? ''}',
      username: '${data['username'] ?? ''}',
      firstName: '${data['firstName'] ?? ''}',
      lastName: '${data['lastName'] ?? ''}',
      image: '${data['image'] ?? ''}',
    );
  }

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? (username.isEmpty ? email : username) : name;
  }

  String get searchText => '$displayName $username $email'.trim().toLowerCase();
}
