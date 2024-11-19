import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/pages/home_page.dart';
import 'package:heutebinichrichbaba/pages/ingredients_page.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  @override
  Widget build(BuildContext context) {
    final String meal = 'meal';
    final String dessert = 'dessert';
    final String cocktail = 'cocktail';
    // Calculate the available height for the cards
    final double screenHeight = MediaQuery.of(context).size.height;
    final double availableHeight = screenHeight * 0.6; // Adjust as needed
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
              Color(0xFFFFFAF0),
              Color(0xFFF0FFFF),
              Color(0xFFF0F8FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Recipe Ideas',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                  category: meal,
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.white,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 250,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(18.0),
                              ),
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/recipe_page/meal.png'),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black45, BlendMode.darken)),
                            ),
                          ),
                          const Text(
                            "Get a delicious meal recipe",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                  category: dessert,
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 250,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(18.0),
                              ),
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/recipe_page/cake.png'),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black45, BlendMode.darken)),
                            ),
                          ),
                          const Text(
                            "Tasty dessert after an amazing meal",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                  category: cocktail,
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      color: Colors.white,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 250,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(18.0),
                              ),
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/recipe_page/cocktail.png'),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                      Colors.black45, BlendMode.darken)),
                            ),
                          ),
                          const Text(
                            "Maybe clear your head with a drink",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Type your ingredients and get a recipe",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Ingredients Section with Fixed Height
                SizedBox(
                  height: availableHeight,
                  child: Row(
                    children: [
                      // Left Side: Meal Card
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Ingredients(category: meal),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              color: Colors.white,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(18.0),
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/recipe_page/meal.png'),
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black45,
                                          BlendMode.darken,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    "Cook a meal with your ingredients",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Right Side: Column with Dessert and Cocktail Cards
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            // Dessert Card
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Ingredients(category: dessert),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    color: Colors.white,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(18.0),
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/recipe_page/cake.png'),
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(
                                                Colors.black45,
                                                BlendMode.darken,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          "Make a delicious dessert with your ingredients",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Cocktail Card
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Ingredients(category: cocktail),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    color: Colors.white,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(18.0),
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/recipe_page/cocktail.png'),
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(
                                                Colors.black45,
                                                BlendMode.darken,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          "Shake a cocktail with your ingredients",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
