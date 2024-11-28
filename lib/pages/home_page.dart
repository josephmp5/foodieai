import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:heutebinichrichbaba/auth/auth.dart';
import 'package:heutebinichrichbaba/pages/random_recipe.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.category});

  final String category;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Auth auth = Auth();
  String? selectedCuisine;
  final selected = BehaviorSubject<int>();
  bool isFetchingRecipe = false;
  bool showLoadingIndicator = false; // New state variable

  void signout() async {
    await auth.signOut(context);
  }

  final List<String> imageAssets = [
    'assets/spin/pizza.png',
    'assets/spin/manti.png',
    'assets/spin/sushi.png',
    'assets/spin/taco.png',
    'assets/spin/vegetables.png',
  ];

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  void startSpinAndFetchRecipe() {
    if (!isFetchingRecipe && selectedCuisine != null) {
      setState(() {
        isFetchingRecipe = true;
        // Start the wheel spinning to a random index
        final randomIndex = Random().nextInt(imageAssets.length);
        selected.add(randomIndex);
      });

      // Start fetching the recipe immediately
      var recipeFuture =
          auth.generateRecipe(selectedCuisine!, context, widget.category);

      // Wait for the recipe to be ready
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
            showLoadingIndicator = false; // Reset loading indicator
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
          showLoadingIndicator = false; // Reset loading indicator
        });
      });
    } else if (selectedCuisine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a cuisine first')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const PreferredSize(
          preferredSize: Size.fromHeight(60.0), // adjust the height as needed
          child: Text(
            'Select cuisine and click to\n Get Recipe to get your recipe',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
          ),
        ),
        centerTitle: true, // center the column
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
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                  hint: const Text(
                    "Select Cuisine",
                    style: TextStyle(color: Colors.black),
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
              const SizedBox(height: 15),
              SizedBox(
                height: 300,
                child: isFetchingRecipe
                    ? (showLoadingIndicator
                        ? const Center(child: CircularProgressIndicator())
                        : FortuneWheel(
                            selected: selected.stream,
                            onAnimationEnd: () {
                              setState(() {
                                showLoadingIndicator = true;
                              });
                            },
                            items: imageAssets
                                .map((path) => FortuneItem(
                                    child: Image.asset(path,
                                        width: 80, height: 80)))
                                .toList(),
                          ))
                    : FortuneWheel(
                        selected: selected.stream,
                        items: imageAssets
                            .map((path) => FortuneItem(
                                child:
                                    Image.asset(path, width: 80, height: 80)))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: startSpinAndFetchRecipe,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Get Recipe',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
