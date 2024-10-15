import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/pages.dart';
import 'package:heutebinichrichbaba/pages/onboard_page.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _checkAndRequestReview();
  runApp(const MyApp());
}

final InAppReview _inAppReview = InAppReview.instance;
Future<void> _checkAndRequestReview() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if the user has already reviewed the app
  bool hasReviewed = prefs.getBool('has_reviewed') ?? false;

  if (!hasReviewed) {
    int launchCount = prefs.getInt('launch_count') ?? 0;
    bool firstLaunch = prefs.getBool('first_launch') ?? true;

    // If it's the first launch, prompt for review
    if (firstLaunch) {
      await _showReviewRequest();
      // Mark first launch as done
      await prefs.setBool('first_launch', false);
      return;
    }

    // Increment launch count
    launchCount += 1;
    await prefs.setInt('launch_count', launchCount);

    // Show review request every 5 launches after the initial prompt
    if (launchCount >= 5) {
      await _showReviewRequest();
      // Reset launch count or adjust as needed
      await prefs.setInt('launch_count', 0);
    }
  }
}

Future<void> _showReviewRequest() async {
  if (await _inAppReview.isAvailable()) {
    _inAppReview.requestReview();
    // Mark as reviewed
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_reviewed', true);
  }
}

Future<void> _configureSDK() async {
  await Purchases.setLogLevel(LogLevel.debug);

  PurchasesConfiguration? configuration;

  if (Platform.isAndroid) {
    // Add your Android configuration here
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration("appl_kzujFWKeddPFNeQPSbmrlwhSeRc");
  }

  if (configuration != null) {
    await Purchases.configure(configuration);

    final paywallResult =
        await RevenueCatUI.presentPaywallIfNeeded("30_tokens");
    debugPrint('Paywall result: $paywallResult');

    if (paywallResult == PaywallResult.purchased) {
      await _updateTokenCount();
    }
  }
}

Future<void> _updateTokenCount() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    int currentTokenCount = userDoc['tokens'] ?? 0;
    int tokenIncrement;

    // Retrieve customer info to check what was purchased
    final customerInfo = await Purchases.getCustomerInfo();

    // Assuming you want to check all active entitlements (like in `HomeScreen`)
    if (customerInfo.entitlements.active.isNotEmpty) {
      for (var entitlement in customerInfo.entitlements.active.values) {
        final productId = entitlement.productIdentifier;

        // Use the same logic as in HomeScreen for assigning token amounts
        if (productId == "aicuisine_499_10_tokens") {
          tokenIncrement = 20;
        } else if (productId == "aicuisine_999_30_tokens") {
          tokenIncrement = 75;
        } else {
          tokenIncrement = 0; // default or handle unknown product identifier
        }

        // Update token count
        int newTokenCount = currentTokenCount + tokenIncrement;

        // Update Firestore with the new token count
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'tokens': newTokenCount,
        });
      }
    }
  }
}

Future<void> _configureSDKIfNeeded() async {
  // Ensure user is signed in before showing the paywall
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await _configureSDK();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
              _configureSDKIfNeeded();
              return const Pages(); // Navigate to the HomePage if signed in
            }
            return const OnBoardPage(); // Otherwise, show the OnBoard page
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ); // Show loading screen while waiting
        },
      ),
    );
  }
}
