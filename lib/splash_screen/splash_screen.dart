import 'package:ayurseva/constants/global_variables.dart';
import 'package:ayurseva/constants/icon_class.dart';
import 'package:ayurseva/constants/image_class.dart';
import 'package:ayurseva/home_screen/treatments_list_screen.dart';
import 'package:ayurseva/login_screen/login_screen.dart';
import 'package:ayurseva/login_screen/provider/auth_provider.dart';
import 'package:ayurseva/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create fade animation for logo
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Create scale animation for logo
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // Start animation
    _animationController.forward();
    
    // Navigate to main app after delay
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  // Navigate to next screen based on token
  void _navigateToNextScreen() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final hasToken = await authProvider.hasValidToken();
      
      if (hasToken) {
        // User has valid token, navigate to home screen
        if (mounted) {
          AppUtils.navigateTo(context, const TreatmentsListScreen());
        }
      } else {
        // No token, navigate to login screen
        if (mounted) {
          AppUtils.navigateTo(context, const LoginScreen());
        }
      }
    } catch (e) {
      // On error, default to login screen
      if (mounted) {
        AppUtils.navigateTo(context, const LoginScreen());
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:  BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageClass.splashBg),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      IconClass.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}