import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Offerings? _offerings;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      setState(() {
        _offerings = offerings;
      });
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Sales'),
      ),
      body: _offerings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _offerings!.current?.availablePackages.length ?? 0,
              itemBuilder: (context, index) {
                Package package = _offerings!.current!.availablePackages[index];
                return ListTile(
                  title: Text(package.storeProduct.title),
                  subtitle: Text(package.storeProduct.description),
                  trailing: Text(package.storeProduct.priceString),
                  onTap: () => _purchasePackage(package),
                );
              },
            ),
    );
  }

  Future<void> _purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      // Handle successful purchase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase successful!')),
      );
      // Update Firebase tokens count
      await _updateTokenCount();
    } catch (e) {
      // Handle purchase error
      if (e is PlatformException &&
          PurchasesErrorHelper.getErrorCode(e) ==
              PurchasesErrorCode.purchaseCancelledError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase cancelled')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
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
      int newTokenCount =
          currentTokenCount + 10; // Adjust the token increment as necessary

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'tokens': newTokenCount,
      });
    }
  }
}
