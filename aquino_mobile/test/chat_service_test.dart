import 'package:flutter_test/flutter_test.dart';
import 'package:lab_activity/services/chat_service.dart';

void main() {
  test('chat room IDs are deterministic and independent of participant order',
      () {
    expect(ChatService.roomIdFor('firebase-b', 'firebase-a'),
        'firebase-a_firebase-b');
    expect(ChatService.roomIdFor('firebase-a', 'firebase-b'),
        'firebase-a_firebase-b');
  });

  test('self-chat and missing participants are rejected', () {
    expect(() => ChatService.roomIdFor('same', 'same'), throwsFormatException);
    expect(() => ChatService.roomIdFor('', 'other'), throwsFormatException);
  });
}
