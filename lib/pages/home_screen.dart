import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Offerings? _offerings;
  int _tokenCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
    _fetchTokenCount();
  }

  Future<void> _fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (mounted) {
        setState(() {
          _offerings = offerings;
        });
      }
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> _fetchTokenCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          _tokenCount = userDoc['tokens'] ?? 0;
        });
      }
    }
  }

  Future<void> _presentPaywall() async {
    if (_offerings?.current == null ||
        _offerings!.current!.availablePackages.isEmpty) {
      debugPrint('No available packages or current offering is null');
      return;
    }
    final paywallResult =
        await RevenueCatUI.presentPaywallIfNeeded("30_tokens");
    debugPrint('Paywall result: $paywallResult');

    if (paywallResult == PaywallResult.purchased) {
      // Get customer info to find out which package was purchased
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.active.isNotEmpty) {
        for (var entitlement in customerInfo.entitlements.active.values) {
          final productId = entitlement.productIdentifier;
          await _updateTokenCount(productId);
        }
      }
      if (mounted) {
        _fetchTokenCount(); // Refresh token count
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Token Sales',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4FAFF),
              Color(0xFFF3F9FF),
              Color(0xFFF2F9FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Text('Current Tokens: $_tokenCount',
                  style: const TextStyle(color: Colors.black)),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _presentPaywall,
                      child: const Text('Click to Buy Tokens'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateTokenCount(String productId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      int currentTokenCount = userDoc['tokens'] ?? 0;
      int tokenIncrement;

      // Determine the token increment based on the purchased product identifier
      if (productId == "aicuisine_499_10_tokens") {
        tokenIncrement = 50;
      } else if (productId == "aicuisine_999_30_tokens") {
        tokenIncrement = 150;
      } else {
        tokenIncrement = 0; // default or handle unknown product identifier
      }

      int newTokenCount = currentTokenCount + tokenIncrement;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'tokens': newTokenCount,
      });
    }
  }
}
