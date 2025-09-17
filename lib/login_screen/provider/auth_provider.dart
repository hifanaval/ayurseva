import 'dart:convert';

import 'package:ayurseva/constants/api_urls.dart';
import 'package:ayurseva/constants/global_variables.dart';
import 'package:ayurseva/constants/string_class.dart';
import 'package:ayurseva/home_screen/treatments_list_screen.dart';
import 'package:ayurseva/login_screen/login_screen.dart';
import 'package:ayurseva/login_screen/model/login_response_model.dart';
import 'package:ayurseva/utils/app_utils.dart';
import 'package:ayurseva/utils/shared_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  // Controllers
  final TextEditingController emailController = TextEditingController(text:'test_user');
  final TextEditingController passwordController = TextEditingController(text:'12345678');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  LoginResponseModel? loginResponseModel;

  // State variables
  bool isLoading = false;
  String? _errorMessage;

  // Getters
 
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Email regex pattern
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set error message
  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Handle login
 Future<bool> verifyLogin(BuildContext context) async {
    setLoading(true);
    notifyListeners();
    debugPrint('Entered verifyLogin function');

    try {
      final params = FormData.fromMap({
      "username": emailController.text,
      "password": passwordController.text,
    });
      debugPrint('Requesting login with params: $params');

      // Create dio instance to get response first
      final dio = Dio();
      final url = Uri.parse(ApiUrls.verifyLogin()).toString();

      // Get the response data
      final Response response = await dio.post(
        url,
        data: params,
        options: Options(
          headers: {
            "Content-Type": "application/json",
           
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data["status"] == true) {
          afterLoginMethod(
              jsonEncode(response.data), // Convert Map to JSON string
              context);
          return true;
        } else {
          setLoading(false);
          debugPrint(response.data["message"].toString());
          if (context.mounted) {
            AppUtils.showToast( context,'Failed',
                response.data["message"].toString(),  false);
          }
          return false;
        }
      } else {
        debugPrint('login request failed');
        return false;
      }
    } catch (e) {
      debugPrint('Error in verifyLogin: $e');
      
      setLoading(false);
       if (context.mounted) {
            AppUtils.showToast( context,'Failed',
                'Something went wrong',  false);
          }
      return false;
    } finally {}
  }

  afterLoginMethod(String value, BuildContext context) async {
    debugPrint('-----------------------Login Value: ${value.toString()}');
    try {
      loginResponseModel = loginResponseModelFromJson(value);
      if (loginResponseModel!.status.toString() == "true") {
        SharedUtils.setString(
            StringClass.token, loginResponseModel!.token.toString());
      
       
        authToken = loginResponseModel!.token.toString();
        
        debugPrint(
            'loginWIthPassword token----------------------: ${authToken.toString()}');
        await Future.delayed(const Duration(seconds: 2), () {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const TreatmentsListScreen()));
              Future.microtask(() {
              // AppUtils.showInSnackBarNormal('Welcome Back', context);
            });
          });
        });
        AppUtils.showToast( context,'Success',
            loginResponseModel!.message.toString(), true);
      } else {
        debugPrint(
            "login Response----${loginResponseModel!.message.toString()}");
        setLoading(false);
        AppUtils.showToast( context,'Failed',
            loginResponseModel!.message.toString(), false);
      }
    } catch (e) {
      setLoading(false);
      debugPrint(
          '-----------------------login error: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  
setLoading(bool value) {
  isLoading = value;
  notifyListeners();
}

  // Reset form
  void resetForm() {
    emailController.clear();
    passwordController.clear();
    _errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  // Check if user has valid token
  Future<bool> hasValidToken() async {
    try {
      final token = await SharedUtils.getString(StringClass.token);
      return token.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking token: $e');
      return false;
    }
  }

  // Logout function
  Future<void> logout(BuildContext context) async {
    try {
      debugPrint('Logging out user');
      
      // Clear token from shared preferences
      await SharedUtils.setString(StringClass.token, '');
      
      // Clear global token
      authToken = '';
      
      // Reset form
      resetForm();
      
      // Clear login response model
      loginResponseModel = null;
      
      debugPrint('User logged out successfully');
      
      // Navigate to login screen
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
      
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Get stored token
  Future<String> getStoredToken() async {
    try {
      return await SharedUtils.getString(StringClass.token);
    } catch (e) {
      debugPrint('Error getting stored token: $e');
      return '';
    }
  }
}
