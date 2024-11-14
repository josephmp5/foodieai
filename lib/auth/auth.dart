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
          'tokens': 25,
        });

        await MyApp.navigatorKey.currentState?.pushReplacement(PageTransition(
          child: const HomePage(),
          type: PageTransitionType.rightToLeft,
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

  Future<Map<String, dynamic>> generateRecipe(
      String cuisine, BuildContext context) async {
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

      // Step 1: Generate the recipe title first
      String recipeTitle = await _fetchRecipeTitleFromAPI(cuisine);

      // Step 2: Start generating detailed recipe and image concurrently
      var recipeTask = _fetchRecipeDetailsFromAPI(recipeTitle);
      var imageTask = generateImage(recipeTitle);

      // Await both tasks to complete concurrently
      var recipeData = await recipeTask;
      var imageUrl = await imageTask;

      // Extract data
      String recipeName = recipeData['title'];
      List<String> ingredients = List<String>.from(recipeData['ingredients']);
      List<String> steps = List<String>.from(recipeData['steps']);

      return {
        'recipeName': recipeName,
        'ingredients': ingredients,
        'steps': steps,
        'imageUrl': imageUrl
      };
    } else {
      throw Exception('User document not found');
    }
  }

  Future<String> _fetchRecipeTitleFromAPI(String cuisine) async {
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${Constants.uri}',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini-2024-07-18',
        'max_tokens': 15, // Short max tokens to generate only a title
        'temperature': 0.8,
        'messages': [
          {
            'role': 'user',
            'content':
                'Generate a short title for a recipe in this Cuisine: $cuisine.'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to fetch recipe title: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> _fetchRecipeDetailsFromAPI(String title) async {
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${Constants.uri}',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini-2024-07-18',
        'temperature': 0.2,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful assistant that outputs data in strict JSON format.'
          },
          {
            'role': 'user',
            'content':
                'Generate a simple recipe for: $title. Include ingredients and steps. Output the result strictly in JSON format with keys "title", "ingredients", and "steps". Do not include any extra text or explanations.'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      String content =
          json.decode(response.body)['choices'][0]['message']['content'];

      Map<String, dynamic> recipeData;

      // JSON Parsing with Error Handling
      try {
        recipeData = json.decode(content);
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Failed to parse recipe details. Please try again.');
      }

      return recipeData;
    } else {
      throw Exception('Failed to fetch recipe details: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> generateRecipewithIngredients(
      String cuisine, String ingredientsInput, BuildContext context) async {
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

      // Step 1: Generate the recipe title with ingredients first
      String recipeTitle = await _fetchRecipeWithIngredientsTitleFromAPI(
          cuisine, ingredientsInput);

      // Step 2: Start generating detailed recipe and image concurrently
      var recipeTask = _fetchRecipeWithIngredientsDetailsFromAPI(
          recipeTitle, ingredientsInput);
      var imageTask = generateImage(recipeTitle);

      // Await both tasks to complete concurrently
      var recipeData = await recipeTask;
      var imageUrl = await imageTask;

      // Extract data
      String recipeName = recipeData['title'];
      List<String> ingredients = List<String>.from(recipeData['ingredients']);
      List<String> steps = List<String>.from(recipeData['steps']);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RandomRecipe(
            recipeTitle: recipeName,
            ingredients: ingredients,
            steps: steps,
            imageUrl: imageUrl,
          ),
        ),
      );

      return {
        'recipeTitle': recipeName,
        'ingredients': ingredients,
        'steps': steps,
        'imageUrl': imageUrl
      };
    } else {
      throw Exception('User document not found');
    }
  }

  Future<String> _fetchRecipeWithIngredientsTitleFromAPI(
      String cuisine, String ingredients) async {
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${Constants.uri}',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini-2024-07-18',
        'max_tokens': 15, // Short max tokens to generate only a title
        'temperature': 0.5,
        'messages': [
          {
            'role': 'user',
            'content':
                'Generate a short title for a recipe with this Cuisine: $cuisine and using these ingredients: $ingredients.'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to fetch recipe title: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> _fetchRecipeWithIngredientsDetailsFromAPI(
      String title, String ingredients) async {
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${Constants.uri}',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini-2024-07-18',
        'temperature': 0.2,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful assistant that outputs data in strict JSON format.'
          },
          {
            'role': 'user',
            'content':
                'Generate a simple recipe for: $title using these ingredients: $ingredients. Include steps. Output the result strictly in JSON format with keys "title", "ingredients", and "steps". Do not include any extra text or explanations.'
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      String content =
          json.decode(response.body)['choices'][0]['message']['content'];

      Map<String, dynamic> recipeData;

      // JSON Parsing with Error Handling
      try {
        recipeData = json.decode(content);
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Failed to parse recipe details. Please try again.');
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
      throw Exception('Failed to signout: $e');
    }
  }
}
