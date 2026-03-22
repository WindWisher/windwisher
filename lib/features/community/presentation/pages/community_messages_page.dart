import 'package:flutter/material.dart';

class CommunityMessagesPage extends StatelessWidget {
  const CommunityMessagesPage({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat con @$username',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Placeholder de mensajeria para la fase UI-first.'),
          ],
        ),
      ),
    );
  }
}
