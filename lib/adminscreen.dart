import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理者画面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              // ログアウト処理
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context); // ログイン画面に戻る
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // ここにユーザー招待処理を追加
                inviteUser(context);
              },
              child: const Text('新しいユーザーを招待'),
            ),
            ElevatedButton(
              onPressed: () {
                // ユーザー管理ページに遷移する場合
                manageUsers(context);
              },
              child: const Text('ユーザー管理'),
            ),
          ],
        ),
      ),
    );
  }

  void inviteUser(BuildContext context) {
    // 新しいユーザー招待処理
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新しいユーザーを招待'),
          content: const Text('招待メールを送信します。'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('閉じる'),
            ),
            TextButton(
              onPressed: () {
                // 招待メール送信処理など
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ユーザーを招待しました。')),
                );
              },
              child: const Text('招待'),
            ),
          ],
        );
      },
    );
  }

  void manageUsers(BuildContext context) {
    // ユーザー管理画面に遷移
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
    );
  }
}

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザー管理'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('登録されているユーザーはありません。'));
          }

          var users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['email']),
                subtitle: Text('ロール: ${user['role']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // ユーザー削除処理
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.id)
                        .delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ユーザーが削除されました')),
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
