import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/auth/auth.dart';
import 'package:heutebinichrichbaba/pages/random_recipe.dart';

class CocktailRecipe extends StatefulWidget {
  const CocktailRecipe({super.key, required this.category});
  final String category;

  @override
  State<CocktailRecipe> createState() => _CocktailRecipeState();
}

class _CocktailRecipeState extends State<CocktailRecipe> {
  @override
  Widget build(BuildContext context) {
    final Auth auth = Auth();
    bool isFetchingRecipe = false;
    void fetchCocktailRecipe() {
      if (!isFetchingRecipe) {
        setState(() {
          isFetchingRecipe = true;
        });

        var recipeFuture =
            auth.generateRecipe('any countries', context, widget.category);

        recipeFuture.then((recipe) {
          // Create a GlobalKey for RandomRecipeState
          final randomRecipeKey = GlobalKey<RandomRecipeState>();

          // Navigate to RandomRecipe page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RandomRecipe(
                key: randomRecipeKey,
                recipeTitle: recipe['recipeName']!,
                ingredients: recipe['ingredients']!,
                steps: recipe['steps']!,
                imageUrl: null, // Initially, no image URL
              ),
            ),
          ).then((_) {
            setState(() {
              isFetchingRecipe = false; // Reset state after coming back
            });
          });

          // Start generating the image
          var imageTask = auth.generateImage(recipe['recipeName']!);

          // Update the image when it's ready
          imageTask.then((imageUrl) {
            randomRecipeKey.currentState?.updateImage(imageUrl);
          }).catchError((error) {
            // Handle image generation errors if necessary
            print('Error generating image: $error');
          });
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cocktail Recipe'),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: fetchCocktailRecipe,
              child: const Text('Get Cocktail Recipe'),
            ),
          ),
          if (isFetchingRecipe)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
