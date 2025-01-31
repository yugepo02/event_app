import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('イベント一覧'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('データの読み込み中にエラーが発生しました'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('表示するイベントがありません'),
            );
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final eventData = event.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(eventData['name'] ?? 'イベント名なし'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('日程: ${eventData['date']?.toDate()?.toString().split(' ')[0] ?? '未設定'}'),
                      Text('場所: ${eventData['location'] ?? '未設定'}'),
                      Text('概要: ${eventData['description'] ?? '未設定'}'),
                    ],
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // 詳細画面へ遷移（詳細画面がある場合）
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(eventId: event.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  EventDetailScreen({required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('イベント詳細'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('データの読み込み中にエラーが発生しました'),
            );
          }

          final eventData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('イベント名: ${eventData['name'] ?? '未設定'}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('日程: ${eventData['date']?.toDate()?.toString().split(' ')[0] ?? '未設定'}'),
                Text('場所: ${eventData['location'] ?? '未設定'}'),
                SizedBox(height: 8),
                Text('概要:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(eventData['description'] ?? '未設定'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // マネージャーを追加する機能
                    addManager(context, eventId);
                  },
                  child: Text('マネージャーを追加'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void addManager(BuildContext context, String eventId) async {
    final managerEmail = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('マネージャーを追加'),
        content: TextField(
          decoration: InputDecoration(labelText: 'メールアドレスを入力'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
      ),
    );

    if (managerEmail != null && managerEmail.isNotEmpty) {
      await FirebaseFirestore.instance.collection('events').doc(eventId).update({
        'managers': FieldValue.arrayUnion([managerEmail]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('マネージャーを追加しました')),
      );
    }
  }
}


