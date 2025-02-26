import 'package:flutter/material.dart';

import 'constants/routes.dart';

void main() {
  runApp(
    MaterialApp(
      title: "MoonLife",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        homePageRoute: (context) => const HomePage(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HomePage"),
      ),
      body: const Text(
        "TODO: think about UI for homepage",
      ), //TODO: think about UI for homepage
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            // Placeholder, to be changed later
            icon: Icon(Icons.list_rounded),
            label: "List",
          ),
        ],
      ),
    );
  }
}
