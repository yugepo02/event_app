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
            TextField(
              controller: eventNameController,
              decoration: InputDecoration(labelText: 'イベント名'),
            ),
            TextField(
              controller: eventDateController,
              decoration: InputDecoration(labelText: '日付'),
            ),
            TextField(
              controller: eventDescriptionController,
              decoration: InputDecoration(labelText: '概要'),
            ),
            TextField(
              controller: eventLocationController,
              decoration: InputDecoration(labelText: '場所'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String eventName = eventNameController.text;
                String eventDate = eventDateController.text;
                String eventDescription = eventDescriptionController.text;
                String eventLocation = eventLocationController.text;

                if (eventName.isNotEmpty && eventDate.isNotEmpty && eventDescription.isNotEmpty && eventLocation.isNotEmpty) {
                  try {
                    // Firestoreにデータを保存
                    await FirebaseFirestore.instance.collection('events').add({
                      'eventName': eventName,
                      'eventDate': eventDate,
                      'eventDescription': eventDescription,
                      'eventLocation': eventLocation,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('イベントが保存されました')),
                    );

                    // 保存後に画面を閉じる
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('保存に失敗しました')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('すべてのフィールドを入力してください')),
                  );
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
