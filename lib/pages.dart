import 'package:flutter/material.dart';
import 'package:heutebinichrichbaba/pages/home_page.dart';
import 'package:heutebinichrichbaba/pages/ingredients_page.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          const HomePage(),
          const Ingredients(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
            child: Container(
              color: const Color(0xFF4B0082),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF808080),
                labelStyle: const TextStyle(fontSize: 13),
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.black54, width: 0.0),
                  insets: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 40.0),
                ),
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.home,
                      size: MediaQuery.of(context).size.width > 600 ? 48 : 30,
                    ),
                    text: "Random Recipe",
                  ),
                  Tab(
                    icon: Icon(
                      Icons.heart_broken,
                      size: MediaQuery.of(context).size.width > 600 ? 48 : 30,
                    ),
                    text: "Ingredients Recipe",
                  ),
                ],
                controller: _tabController,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
