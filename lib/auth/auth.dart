import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/constants.dart';
import 'package:heutebinichrichbaba/pages/home_page.dart';
import 'package:heutebinichrichbaba/main.dart';
import 'package:heutebinichrichbaba/pages/onboard_page.dart';
import 'package:heutebinichrichbaba/pages/random_recipe.dart';
import 'package:heutebinichrichbaba/utils.dart';
import 'package:http/http.dart' as http;

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> signInAnonymously({required BuildContext context}) async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          'uid': user.uid,
        });

        await MyApp.navigatorKey.currentState
            ?.pushReplacement(MaterialPageRoute(
          builder: (context) => const HomePage(),
        ));
      } else {
        const Center(
          child: Text("error when making it "),
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<Map<String, String>> generateRecipe(
      String cuisine, BuildContext context) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in.");

    var docRef = _db.collection('dailyUsage').doc(user.uid);
    var doc = await docRef.get();
    DateTime today = DateTime.now();

    if (doc.exists && _isToday(doc.data()?['lastRequest'].toDate())) {
      int count = doc.data()?['count'] ?? 0;
      if (count >= 10) {
        showSnackBar(context,
            'Daily limit reached. Please buy tokens to get more recipes.');
        return {};
      }
    }

    await docRef.set({
      'count': FieldValue.increment(1),
      'lastRequest': Timestamp.fromDate(today),
    }, SetOptions(merge: true));

    return _fetchRecipeFromAPI(
        cuisine); // Assume this handles the API call and extracts data properly.
  }

  bool _isToday(DateTime? lastRequestDate) {
    return lastRequestDate != null &&
        lastRequestDate.year == DateTime.now().year &&
        lastRequestDate.month == DateTime.now().month &&
        lastRequestDate.day == DateTime.now().day;
  }

  Future<Map<String, String>> _fetchRecipeFromAPI(String cuisine) async {
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Constants.uri}',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo-0125',
        'messages': [
          {
            'role': 'user',
            'content':
                'Generate a random recipe with this Cuisine: $cuisine. and list ingredients and steps.'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      String recipeText =
          json.decode(response.body)['choices'][0]['message']['content'];
      // Assume more processing and image generation here
      String recipeName = recipeText.split('\n')[0];
      // Generate the image using the recipe name
      String imageUrl = await generateImage(recipeName);
      return {
        'recipeName': recipeName,
        'recipeText': recipeText,
        'imageUrl': imageUrl
      };
    } else {
      throw Exception('Failed to fetch recipe: ${response.body}');
    }
  }

  Future<Map<String, String>> generateRecipewithIngredients(
      String cuisine, String ingredients, BuildContext context) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in.");

    var docRef = _db.collection('dailyUsage').doc(user.uid);
    var doc = await docRef.get();
    DateTime today = DateTime.now();

    if (doc.exists && _isToday(doc.data()?['lastRequest'].toDate())) {
      int count = doc.data()?['count'] ?? 0;
      if (count >= 10) {
        showSnackBar(context,
            'Daily limit reached. Please buy tokens to get more recipes.');
        return {};
      }
    }

    await docRef.set({
      'count': FieldValue.increment(1),
      'lastRequest': Timestamp.fromDate(today),
    }, SetOptions(merge: true));

    return _fetchRecipeWithIngredientsFromAPI(cuisine, ingredients,
        context); // Assume this handles the API call and extracts data properly.
  }

  Future<Map<String, String>> _fetchRecipeWithIngredientsFromAPI(
      String cuisine, String ingredients, BuildContext context) async {
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Constants.uri}',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo-0125',
        'messages': [
          {
            'role': 'user',
            'content':
                'Generate a recipe with this Cuisine: $cuisine and with only these ingredients: $ingredients and list steps.'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      String recipeText =
          json.decode(response.body)['choices'][0]['message']['content'];
      // Extract the recipe name (assuming it's the first line)
      String recipeName = recipeText.split('\n')[0];
      // Generate the image using the recipe name
      String imageUrl = await generateImage(recipeName);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RandomRecipe(recipeText: recipeText, imageUrl: imageUrl),
        ),
      );

      return {'recipeText': recipeText, 'imageUrl': imageUrl};
    } else {
      throw Exception('Failed to fetch recipe: ${response.body}');
    }
  }

  Future<String> generateImage(String prompt) async {
    try {
      var response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.uri}',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );

      if (response.statusCode == 200) {
        String imageUrl = json.decode(response.body)['data'][0]['url'];
        return imageUrl;
      } else {
        throw Exception('Failed to generate image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the API: $e');
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnBoardPage()),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to signout: $e');
    }
  }
}
