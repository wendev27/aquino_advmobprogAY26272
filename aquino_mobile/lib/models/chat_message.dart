import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String receiverEmail;
  final String text;
  final DateTime? timestamp;
  final String status;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.receiverEmail,
    required this.text,
    required this.timestamp,
    required this.status,
  });

  factory ChatMessage.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    final rawTimestamp = data['timestamp'];
    return ChatMessage(
      id: document.id,
      senderId: '${data['senderId'] ?? ''}',
      senderEmail: '${data['senderEmail'] ?? ''}',
      receiverId: '${data['receiverId'] ?? ''}',
      receiverEmail: '${data['receiverEmail'] ?? ''}',
      text: '${data['text'] ?? ''}',
      timestamp: rawTimestamp is Timestamp ? rawTimestamp.toDate() : null,
      status: '${data['status'] ?? 'sent'}',
    );
  }
}
