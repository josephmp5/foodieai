import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RandomRecipe extends StatelessWidget {
  final String recipeTitle;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;

  const RandomRecipe({
    Key? key,
    required this.recipeTitle,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use NestedScrollView for coordinated scrolling
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // SliverAppBar with the image
            SliverAppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              expandedHeight: 300.0,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.error)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.white,
          child: Stack(
            children: [
              // Main content with padding to overlap the SliverAppBar
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Curved container
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recipe Title
                            Center(
                              child: Text(
                                recipeTitle,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFCD5C5C)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Ingredients Title
                            const Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Ingredients List using Wrap
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: ingredients
                                  .map((ingredient) => Chip(
                                        label: Text(
                                          ingredient,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                        backgroundColor:
                                            const Color(0xFFF0FFFF),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                            // Steps Title
                            const Text(
                              'Steps',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Steps List
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: steps.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    '${index + 1}. ${steps[index]}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Positioned curved container to overlay on the SliverAppBar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
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
