import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String email = '';
  String password = '';
  String confirmPassword = '';
  String infoText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規ユーザー登録'),
      ),
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'パスワード確認'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    confirmPassword = value;
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
                  child: const Text('新規登録'),
                  onPressed: () async {
                    if (password == confirmPassword) {
                      try {
                        final FirebaseAuth auth = FirebaseAuth.instance;
                        await auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        setState(() {
                          infoText = "登録が成功しました！";
                        });

                        // 登録後、ログイン画面に戻る
                        Navigator.pop(context);
                      } catch (e) {
                        setState(() {
                          infoText = "登録に失敗しました：${e.toString()}";
                        });
                      }
                    } else {
                      setState(() {
                        infoText = "パスワードが一致しません";
                      });
                    }
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
