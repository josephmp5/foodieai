import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/constants.dart';
import 'package:heutebinichrichbaba/pages.dart';
import 'package:heutebinichrichbaba/main.dart';
import 'package:heutebinichrichbaba/pages/onboard_page.dart';
import 'package:heutebinichrichbaba/utils.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

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
          'tokens': 2,
        });

        await MyApp.navigatorKey.currentState?.pushReplacement(PageTransition(
          child: const Pages(),
          type: PageTransitionType.rightToLeft,
        ));
      } else {
        const Center(
          child: Text("Error during sign-in."),
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<Map<String, dynamic>> generateRecipe(
      String cuisine, BuildContext context, String category) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in.");

    var docRef = _db.collection('users').doc(user.uid);
    var doc = await docRef.get();

    if (doc.exists) {
      int tokens = doc.data()?['tokens'] ?? 0;
      if (tokens <= 0) {
        showSnackBar(context, 'No tokens left. Please buy more tokens.');
        return {};
      }

      // Deduct one token
      await docRef.update({
        'tokens': FieldValue.increment(-1),
      });

      // Generate the recipe (title, ingredients, steps) in one API call
      var recipeData = await _fetchRecipeDetailsFromAPI(cuisine, category);

      // Extract data
      String recipeName = recipeData['title'];
      List<String> ingredients = List<String>.from(recipeData['ingredients']);
      List<String> steps = List<String>.from(recipeData['steps']);

      return {
        'recipeName': recipeName,
        'ingredients': ingredients,
        'steps': steps,
        // 'imageUrl' will be updated later when ready
      };
    } else {
      throw Exception('User document not found');
    }
  }

  Future<Map<String, dynamic>> _fetchRecipeDetailsFromAPI(
      String cuisine, String category) async {
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${Constants.uri}',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini-2024-07-18',
        'temperature': 0.7,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful assistant that outputs data in strict JSON format.'
          },
          {
            'role': 'user',
            'content':
                'Generate a simple recipe in English for a $category dish in $cuisine cuisine. The recipe should be entirely in English. Include a title, ingredients, and steps. Output the result strictly in JSON format with keys "title", "ingredients", and "steps". Do not include any extra text or explanations.'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      String content =
          json.decode(response.body)['choices'][0]['message']['content'];

      print('Raw API Response: $content');

      Map<String, dynamic> recipeData = {};

      String sanitizedContent = content.replaceAll(RegExp(r'[^\x20-\x7E]'), '');

      // JSON Parsing with Error Handling
      try {
        final jsonString =
            RegExp(r'\{.*\}', dotAll: true).stringMatch(sanitizedContent);
        if (jsonString != null) {
          recipeData = json.decode(jsonString);
        } else {
          throw Exception('No JSON object found in the response.');
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Failed to parse recipe details. Please try again.');
      }

      return recipeData;
    } else {
      throw Exception('Failed to fetch recipe details: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> generateRecipewithIngredients(String cuisine,
      String ingredientsInput, BuildContext context, String category) async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in.");

    var docRef = _db.collection('users').doc(user.uid);
    var doc = await docRef.get();

    if (doc.exists) {
      int tokens = doc.data()?['tokens'] ?? 0;
      if (tokens <= 0) {
        showSnackBar(context, 'No tokens left. Please buy more tokens.');
        return {};
      }

      // Deduct one token
      await docRef.update({
        'tokens': FieldValue.increment(-1),
      });

      // Generate the recipe with ingredients in one API call
      var recipeData = await _fetchRecipeWithIngredientsDetailsFromAPI(
          cuisine, ingredientsInput, category);

      // Extract data
      String recipeName = recipeData['title'];
      List<String> ingredients = List<String>.from(recipeData['ingredients']);
      List<String> steps = List<String>.from(recipeData['steps']);

      return {
        'recipeName': recipeName,
        'ingredients': ingredients,
        'steps': steps,
        // 'imageUrl' will be updated later when ready
      };
    } else {
      throw Exception('User document not found');
    }
  }

  Future<Map<String, dynamic>> _fetchRecipeWithIngredientsDetailsFromAPI(
      String cuisine, String ingredients, String category) async {
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${Constants.uri}',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini-2024-07-18',
        'temperature': 0.7,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful assistant that outputs data in strict JSON format.'
          },
          {
            'role': 'user',
            'content':
                'Generate a simple **in English** for a $category recipe in $cuisine cuisine using these ingredients: $ingredients. Include a title, ingredients, and steps. Output the result strictly in JSON format with keys "title", "ingredients", and "steps". Do not include any extra text or explanations.'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      String content =
          json.decode(response.body)['choices'][0]['message']['content'];

      print('Raw API Response: $content');

      Map<String, dynamic> recipeData = {};

      String sanitizedContent = content.replaceAll(RegExp(r'[^\x20-\x7E]'), '');

      // JSON Parsing with Error Handling
      try {
        final jsonString =
            RegExp(r'\{.*\}', dotAll: true).stringMatch(sanitizedContent);
        if (jsonString != null) {
          recipeData = json.decode(jsonString);
        } else {
          throw Exception('No JSON object found in the response.');
        }
      } catch (e) {
        const SnackBar(
          content: Text(
            'Service is currently unavailable. Please try again later.',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      return recipeData;
    } else {
      throw Exception('Failed to fetch recipe details: ${response.body}');
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
          'model': "dall-e-3",
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
          'quality': "standard",
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'][0]['url'];
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
      throw Exception('Failed to sign out: $e');
    }
  }
}
