import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/auth/auth.dart';

class Ingredients extends StatefulWidget {
  const Ingredients({super.key});

  @override
  State<Ingredients> createState() => _IngredientsState();
}

class _IngredientsState extends State<Ingredients> {
  final Auth auth = Auth();
  String? selectedCuisine;
  bool isLoading = false; // Added loading state
  TextEditingController ingredientsController = TextEditingController();

  void recipe() async {
    if (selectedCuisine != null) {
      setState(() {
        isLoading = true; // Start loading before the API call
      });

      await auth.generateRecipewithIngredients(
          selectedCuisine!, ingredientsController.text, context);
      setState(() {
        isLoading = false; // Stop loading after the API call
      });
    } else if (selectedCuisine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a cuisine'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const PreferredSize(
                        preferredSize:
                            Size.fromWidth(60.0), // adjust the height as needed
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Select cuisine',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontSize: 20),
                            ),
                            Text(
                              'put ingredients that you have',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 20),
                            ),
                            Text(
                              'and generate a recipe',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2),
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
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: SizedBox(
                            height: 100,
                            child: TextField(
                              maxLines: null, // Set this
                              expands: true, // and this
                              keyboardType: TextInputType.multiline,
                              controller: ingredientsController,
                              decoration: InputDecoration(
                                labelText: 'Enter Ingredients',
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        onTap: recipe,
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
        ));
  }
}
