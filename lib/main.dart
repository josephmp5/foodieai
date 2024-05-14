import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/pages.dart';
import 'package:heutebinichrichbaba/pages/home_page.dart';
import 'package:heutebinichrichbaba/pages/onboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Check if the user is signed in
            if (snapshot.hasData && snapshot.data != null) {
              // Ensure the user is not null
              String userId = snapshot.data!.uid;
              return const Pages();
              // Navigate to the HomePage if signed in
            }
            return const OnBoardPage(); // Otherwise, show the SignUp page
          }
          return const Scaffold(
              body: Center(
                  child:
                      CircularProgressIndicator())); // Show loading screen while waiting
        },
      ),
    );
  }
}
