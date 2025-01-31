import 'package:flutter/material.dart';
///import 'event.dart'; // イベント作成画面
import 'eventlistscreen.dart'; // イベント一覧画面
import 'createeventscreen.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理者画面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // イベント作成画面への遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEventScreen()),
                );
              },
              child: Text('イベント作成'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // イベント一覧画面への遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventListScreen()),
                );
              },
              child: Text('イベント一覧を見る'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 追加の管理者機能をここに実装
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('その他の管理機能が未実装です')),
                );
              },
              child: Text('その他の管理機能'),
            ),
          ],
        ),
      ),
    );
  }
}
