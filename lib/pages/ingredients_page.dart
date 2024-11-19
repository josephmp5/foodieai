import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/auth/auth.dart';
import 'package:heutebinichrichbaba/pages/random_recipe.dart';

class Ingredients extends StatefulWidget {
  Ingredients({Key? key, required this.category}) : super(key: key);
  final String category;

  @override
  State<Ingredients> createState() => _IngredientsState();
}

class _IngredientsState extends State<Ingredients> {
  final Auth auth = Auth();
  String? selectedCuisine;
  String ingredientsInput = '';
  bool isFetchingRecipe = false;

  void fetchRecipeWithIngredients() {
    if (!isFetchingRecipe &&
        selectedCuisine != null &&
        ingredientsInput.isNotEmpty) {
      setState(() {
        isFetchingRecipe = true;
      });

      var recipeFuture = auth.generateRecipewithIngredients(
          selectedCuisine!, ingredientsInput, context, widget.category);

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
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching recipe: $error')));
        setState(() {
          isFetchingRecipe = false;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a cuisine and enter ingredients')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Ingredients')),
      body: Stack(
        children: [
          // Main UI
          SingleChildScrollView(
            child: Column(
              children: [
                // Dropdown for cuisine selection
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Select Cuisine',
                    ),
                    value: selectedCuisine,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCuisine = newValue;
                      });
                    },
                    items: <String>[
                      'Italian',
                      'French',
                      'Thai',
                      'Chinese',
                      'Turkish',
                      'Indian',
                      'Mexican',
                      'Japanese',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(child: Text(value)),
                      );
                    }).toList(),
                  ),
                ),
                // TextField for ingredients input
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      ingredientsInput = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter ingredients separated by commas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: fetchRecipeWithIngredients,
                  child: const Text('Get Recipe'),
                ),
              ],
            ),
          ),
          // Loading Indicator
          if (isFetchingRecipe)
            Container(
              color:
                  Colors.black.withOpacity(0.5), // Semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
