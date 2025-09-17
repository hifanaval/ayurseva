import 'package:ayurseva/screens/home_screen/provider/patients_data_provider.dart';
import 'package:ayurseva/screens/home_screen/treatments_list_screen.dart';
import 'package:ayurseva/screens/login_screen/login_screen.dart';
import 'package:ayurseva/screens/login_screen/provider/auth_provider.dart';
import 'package:ayurseva/screens/registration_screen/provider/branch_provider.dart';
import 'package:ayurseva/screens/registration_screen/provider/registration_provider.dart';
import 'package:ayurseva/screens/registration_screen/provider/treatment_type_provider.dart';
import 'package:ayurseva/utils/shared_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  SharedUtils.sharedPreferences = prefs;
  
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PatientsDataProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (_) => TreatmentTypeProvider()),
      ],
      child: MaterialApp(
        title: 'AyurSeva',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const LoginScreen(),
          '/treatments': (context) => const TreatmentsListScreen(),
        },
      ),
    );
  }
}




