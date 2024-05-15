import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:heutebinichrichbaba/auth/auth.dart';
import 'package:heutebinichrichbaba/pages/random_recipe.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Auth auth = Auth();
  String? selectedCuisine;
  final selected = BehaviorSubject<int>();
  bool isFetchingRecipe = false;

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
      });

      // Keep the wheel spinning
      _keepSpinning();

      // Start fetching the recipe immediately
      var recipeFuture = auth.generateRecipe(selectedCuisine!, context);

      // Wait for the recipe to be ready
      recipeFuture.then((recipe) {
        String recipeText = recipe['recipeText']!;
        String imageUrl = recipe['imageUrl']!;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RandomRecipe(recipeText: recipeText, imageUrl: imageUrl),
          ),
        ).then((_) {
          setState(() {
            isFetchingRecipe = false; // Reset state after coming back
          });
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching recipe: $error')));
        setState(() {
          isFetchingRecipe = false;
        });
      });
    } else if (selectedCuisine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a cuisine first')));
    }
  }

  void _keepSpinning() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isFetchingRecipe) {
        selected.add(Fortune.randomInt(0, imageAssets.length));
        _keepSpinning();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Home Page'),
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
                          const BorderSide(color: Colors.white, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  hint: const Text(
                    "Select Cuisine",
                    style: TextStyle(color: Colors.white),
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
                child: FortuneWheel(
                  selected: selected.stream,
                  animateFirst: false,
                  items: imageAssets
                      .map((path) => FortuneItem(
                          child: Image.asset(path, width: 80, height: 80)))
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
                        offset: Offset(0, 3),
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
