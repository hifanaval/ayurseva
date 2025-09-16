import 'package:flutter/material.dart';
import 'splash_screen/splash_screen.dart';

void main() {
  print('Main: Starting AyurSeva application');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('MyApp: Building main application widget');
    return MaterialApp(
      title: 'AyurSeva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('HomePage: Building home page');
    return Scaffold(
      appBar: AppBar(
        title: const Text('AyurSeva'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to AyurSeva',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Your Ayurvedic Health Companion',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}


