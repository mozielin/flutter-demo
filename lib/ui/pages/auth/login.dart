import 'package:flutter/material.dart';
import 'package:hws_app/ui/shared/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.toggleView}) : super(key: key);
  final Function toggleView;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //final AuthService _auth = AuthService();
  String email = '';
  String password = '';
  String error = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RyanTodo'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => widget.toggleView(),
            icon: Icon(Icons.person),
            label: Text(
              '註冊',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              primary: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: '請輸入Email'),
                validator: (val) => val!.isEmpty ? '請輸入email!' : null,
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: '請輸入密碼'),
                validator: (val) => val!.length < 6 ? '請輸入6位數密碼!' : null,
                obscureText: true,
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  login();
                  // if (_formKey.currentState!.validate()) {
                  //   debugPrint('email:$email');
                  //   debugPrint('password:$password');
                  //   // dynamic result =
                  //   // await _auth.signInWithEmailAndPass(email, password);
                  //   // debugPrint("$result");
                  //   if (result == null) {
                  //     setState(() {
                  //       error = 'Could not sign in with those credentials';
                  //     });
                  //   }
                  // }
                },
                child: Text(
                  '登入',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                '$error',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

