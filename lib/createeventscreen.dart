import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // フィールドを管理するためのコントローラー
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController eventDescriptionController = TextEditingController();
  final TextEditingController eventLocationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('イベント作成'),
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
                // 入力されたデータを取得
                String eventName = eventNameController.text;
                String eventDate = eventDateController.text;
                String eventDescription = eventDescriptionController.text;
                String eventLocation = eventLocationController.text;

                if (eventName.isNotEmpty && eventDate.isNotEmpty && eventDescription.isNotEmpty && eventLocation.isNotEmpty) {
                  // Firestoreにデータを保存
                  await FirebaseFirestore.instance.collection('events').add({
                    'eventName': eventName,
                    'eventDate': eventDate,
                    'eventDescription': eventDescription,
                    'eventLocation': eventLocation,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  // 成功したら画面を閉じて戻る
                  Navigator.pop(context);
                } else {
                  // 必要なフィールドが空の場合、エラーメッセージを表示
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
