import 'package:flutter/material.dart';
import 'package:task_8/Home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(Icons.chat_bubble, size: 100, color: Colors.black),
          Center(
            child: Text(
              "welcome to app screen",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            icon: Icon(Icons.navigate_next, color: Colors.black, size: 40),
          ),
        ],
      ),
    );
  }
}
