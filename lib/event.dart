import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart';  // LoginPageをインポート

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EventListPage(),
    );
  }
}

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventDescriptionController = TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();

  // イベントリストをFirestoreから取得
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('events').get();
      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  // イベントタップでタスク画面に遷移
  void _navigateToTaskScreen(Map<String, dynamic> eventData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskScreen(eventData: eventData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('イベント作成'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // イベント一覧の表示
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('エラーが発生しました'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('イベントがありません'));
                }
                List<Map<String, dynamic>> events = snapshot.data!;
                return Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> event = events[index];
                      return ListTile(
                        title: Text(event['eventName']),
                        subtitle: Text(event['eventDate']),
                        onTap: () => _navigateToTaskScreen(event),
                      );
                    },
                  ),
                );
              },
            ),
            // 新規イベント作成ボタン
            ElevatedButton(
              onPressed: () {
                // 新規イベント作成画面に遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventCreateScreen()),
                );
              },
              child: Text('新規イベント作成'),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;

  TaskScreen({required this.eventData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('タスク画面')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('イベント名: ${eventData['eventName']}'),
            Text('日付: ${eventData['eventDate']}'),
            Text('場所: ${eventData['eventLocation']}'),
            Text('概要: ${eventData['eventDescription']}'),
            // タスクの表示や追加をここに実装
          ],
        ),
      ),
    );
  }
}

class EventCreateScreen extends StatelessWidget {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventDescriptionController = TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('イベント作成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: eventNameController, decoration: InputDecoration(labelText: 'イベント名')),
            TextField(controller: eventDateController, decoration: InputDecoration(labelText: '日付')),
            TextField(controller: eventDescriptionController, decoration: InputDecoration(labelText: '概要')),
            TextField(controller: eventLocationController, decoration: InputDecoration(labelText: '場所')),
            ElevatedButton(
              onPressed: () async {
                String eventName = eventNameController.text;
                String eventDate = eventDateController.text;
                String eventDescription = eventDescriptionController.text;
                String eventLocation = eventLocationController.text;

                if (eventName.isNotEmpty && eventDate.isNotEmpty && eventDescription.isNotEmpty && eventLocation.isNotEmpty) {
                  try {
                    // Firestoreに新規イベントを追加
                    await FirebaseFirestore.instance.collection('events').add({
                      'eventName': eventName,
                      'eventDate': eventDate,
                      'eventDescription': eventDescription,
                      'eventLocation': eventLocation,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('イベントが保存されました')));
                    Navigator.pop(context); // イベント作成後に戻る
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存に失敗しました')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('すべてのフィールドを入力してください')));
                }
              },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
