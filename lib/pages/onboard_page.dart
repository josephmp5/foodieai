import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/auth/auth.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key});

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  void anonymousLogin() async {
    await Auth().signInAnonymously(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/gay.png'),
              fit: BoxFit.none,
            ),
          ),
          child: Center(
            child: ElevatedButton(
              onPressed: anonymousLogin,
              child: const Text('Continue'),
            ),
          ),
        ));
  }
}
