import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/cocktails/cocktail_ingredients.dart';
import 'package:heutebinichrichbaba/cocktails/cocktail_recipe.dart';
import 'package:heutebinichrichbaba/pages/home_page.dart';
import 'package:heutebinichrichbaba/pages/ingredients_page.dart';
import 'package:page_transition/page_transition.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  @override
  Widget build(BuildContext context) {
    const String meal = 'meal';
    const String dessert = 'dessert';
    const String cocktail = 'cocktail';
    // Calculate the available height for the cards
    final double screenHeight = MediaQuery.of(context).size.height;
    final double availableHeight = screenHeight * 0.6; // Adjust as needed
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
                "Choose between meal, dessert \n or cocktail  and click to get a recipe"),
          ),
        ),
        backgroundColor: Colors.transparent,
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Get a random recipe',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            child: HomePage(category: meal),
                            type: PageTransitionType.rightToLeft));
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
                        PageTransition(
                            child: HomePage(category: dessert),
                            type: PageTransitionType.rightToLeft));
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
                        PageTransition(
                            child: const CocktailRecipe(category: cocktail),
                            type: PageTransitionType.rightToLeft));
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
                                PageTransition(
                                    child: Ingredients(category: meal),
                                    type: PageTransitionType.rightToLeft));
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
                                            'assets/recipe_page/chicken.png'),
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
                                      PageTransition(
                                          child: Ingredients(category: dessert),
                                          type:
                                              PageTransitionType.rightToLeft));
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
                                                  'assets/recipe_page/sufle.png'),
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
                                      PageTransition(
                                          child: const CocktailIngredients(
                                              category: cocktail),
                                          type:
                                              PageTransitionType.rightToLeft));
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
                                                  'assets/recipe_page/mojito.png'),
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
