import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:event_project_app/event.dart'; // イベント画面に遷移
import 'package:event_project_app/adminscreen.dart';//管理者画面に遷移
import 'package:event_project_app/createuser.dart'; // 新規登録画面をインポート

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  String infoText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Text(infoText),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('ログイン'),
                  onPressed: () async {
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      UserCredential userCredential =
                          await auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      User? user = userCredential.user;

                      // 特定のメールアドレスを管理者として設定
                      if (user != null) {
                        if (user.email == 'kawamura-s2308@school.ac.jp') {
                          // 管理者の場合、FirestoreにAdminロールを設定
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'email': user.email,
                            'role': 'Admin',
                          });

                          setState(() {
                            infoText = "管理者としてログインしました！";
                          });

                          // 管理者用画面に遷移
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdminScreen()),
                          );
                        } else {
                          // 管理者でない場合、MemberとしてFirestoreに設定
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'email': user.email,
                            'role': 'Member',
                          });

                          setState(() {
                            infoText = "メンバーとしてログインしました！";
                          });

                          // イベント画面に遷移
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EventScreen()),
                          );
                        }
                      }
                    } catch (e) {
                      setState(() {
                        infoText = "ログインに失敗しました：${e.toString()}";
                      });
                    }
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('新規ユーザー登録'),
                  onPressed: () {
                    // 新規登録画面に遷移
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}