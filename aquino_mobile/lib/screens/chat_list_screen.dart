import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/chat_user.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: currentUser == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Chat is available only when signed in with a Firebase account.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(
                        () => _searchQuery = value.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search Firebase users',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<ChatUser>>(
                    stream: _chatService.watchUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _MessageState(
                          message:
                              'Could not load Firebase users. Create the Firestore database and publish the provided rules first.',
                          detail: snapshot.error.toString(),
                        );
                      }
                      final users = (snapshot.data ?? [])
                          .where(
                              (user) => user.searchText.contains(_searchQuery))
                          .toList();
                      if (users.isEmpty) {
                        return _MessageState(
                          message: _searchQuery.isEmpty
                              ? 'No other Firebase users are available yet.'
                              : 'No users match your search.',
                        );
                      }
                      return ListView.separated(
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.image.isEmpty
                                  ? null
                                  : NetworkImage(user.image),
                              child: user.image.isEmpty
                                  ? Text(user.displayName.isEmpty
                                      ? '?'
                                      : user.displayName[0].toUpperCase())
                                  : null,
                            ),
                            title: Text(user.displayName),
                            subtitle: Text(
                              user.username.isEmpty
                                  ? user.email
                                  : '@${user.username}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailScreen(
                                  recipient: user,
                                  currentUserId: currentUser.uid,
                                  currentUserEmail: currentUser.email ?? '',
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final String message;
  final String? detail;

  const _MessageState({required this.message, this.detail});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(
                detail!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
