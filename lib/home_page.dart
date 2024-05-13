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
      isFetchingRecipe = true;
      selected.add(Fortune.randomInt(0, imageAssets.length));

      Future.delayed(Duration(seconds: 1), () {
        auth.generateRecipe(selectedCuisine!, context).then((recipeText) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RandomRecipe(recipeText: recipeText),
            ),
          ).then((_) {
            isFetchingRecipe = false;
          });
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error fetching recipe: $error')));
          isFetchingRecipe = false;
        });
      });
    } else if (selectedCuisine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a cuisine first')));
    }
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
              DropdownButtonFormField<String>(
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
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 300,
                child: FortuneWheel(
                  selected: selected.stream,
                  animateFirst: false,
                  items: imageAssets
                      .map((path) => FortuneItem(
                          child: Image.asset(path, width: 50, height: 50)))
                      .toList(),
                  onAnimationEnd: () {},
                ),
              ),
              GestureDetector(
                onTap: startSpinAndFetchRecipe,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Get Recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
