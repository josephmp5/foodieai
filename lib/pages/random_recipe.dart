import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RandomRecipe extends StatelessWidget {
  final String recipeTitle;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;

  RandomRecipe({
    required this.recipeTitle,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Your Delicious Meal Is Ready',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00BFFF),
              Color(0xFF1E90FF),
              Color(0xFF00008B),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                // Image Section
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fadeInDuration: const Duration(milliseconds: 300),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Ingredients Title
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Ingredients Section (Choose one option)

                // Option 1: Horizontal Scrollable Row
                Card(
                  color: const Color(0xFF00CED1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ingredients
                          .map((ingredient) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Card(
                                  color: const Color(0xFFF0FFFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ingredient,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),

                // Option 2: Wrap Widget (Uncomment to use)
                // Wrap(
                //   spacing: 8.0,
                //   runSpacing: 4.0,
                //   alignment: WrapAlignment.center,
                //   children: ingredients.map((ingredient) => Card(
                //     color: const Color(0xFFF0FFFF),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(16),
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Text(
                //         ingredient,
                //         style: const TextStyle(color: Colors.black),
                //       ),
                //     ),
                //   )).toList(),
                // ),

                const SizedBox(height: 20),
                // Steps Title
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Steps List
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color(0xFF00CED1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: steps
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${entry.key + 1}. ${entry.value}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
