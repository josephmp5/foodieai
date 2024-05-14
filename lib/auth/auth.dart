import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/constants.dart';
import 'package:heutebinichrichbaba/pages/home_page.dart';
import 'package:heutebinichrichbaba/main.dart';
import 'package:heutebinichrichbaba/pages/random_recipe.dart';
import 'package:http/http.dart' as http;

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  Future<String> generateRecipe(String cuisine, BuildContext context) async {
    try {
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
        return recipeText;
      } else {
        // Handle different statuses or API specific errors
        throw Exception('Failed to fetch recipe: ${response.body}');
      }
    } catch (e) {
      // Handle unexpected errors
      throw Exception('Failed to connect to the API: $e');
    }
  }

  Future<String> generateRecipewithIngredients(
      String cuisine, String ingredients, BuildContext context) async {
    try {
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
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RandomRecipe(recipeText: recipeText)),
        );
        return recipeText;
      } else {
        // Handle different statuses or API specific errors
        throw Exception('Failed to fetch recipe: ${response.body}');
      }
    } catch (e) {
      // Handle unexpected errors
      throw Exception('Failed to connect to the API: $e');
    }
  }
}
