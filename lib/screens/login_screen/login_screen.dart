import 'package:ayurseva/components/custom_button.dart';
import 'package:ayurseva/components/custom_textfield.dart';
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/icon_class.dart';
import 'package:ayurseva/constants/image_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:ayurseva/screens/login_screen/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Background image covering 40% and extending behind form
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImageClass.loginBg),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  // Top section with logo (40% of screen)
                  Expanded(
                    flex: 3,
                    child: Center(
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
                  ),

                  // Bottom section with form (60% of screen)
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ColorClass.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: authProvider.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // Title
                              Text(
                                'Login Or Register To Book Your Appointments',
                                style: TextStyleClass.poppinsSemiBold(
                                  24,
                                  ColorClass.black,
                                ),
                                textAlign: TextAlign.start,
                              ),

                              const SizedBox(height: 32),

                              // Email Field
                              CustomTextFormField(
                                controller: authProvider.emailController,
                                hintText: 'Enter your email',
                                labelText: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                validator: authProvider.validateEmail,
                              ),

                              const SizedBox(height: 24),

                              // Password Field
                              CustomTextFormField(
                                controller: authProvider.passwordController,
                                hintText: 'Enter password',
                                labelText: 'Password',
                                isPassword: true,
                                validator: authProvider.validatePassword,
                              ),

                              const SizedBox(height: 32),

                              // Login Button
                              CustomButton(
                                text: 'Login',
                                onPressed: () async {
                                  authProvider.verifyLogin(context);
                                },
                                isLoading: authProvider.isLoading,
                              ),

                              const SizedBox(height: 24),

                              // Terms and Conditions
                              Center(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text:
                                        'By creating or logging into an account you are agreeing with our ',
                                    style: TextStyleClass.bodySmall(
                                      ColorClass.black.withValues(alpha: 0.7),
                                    ),
                                    children: [
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            'Terms and Conditions',
                                            style: TextStyleClass.buttonSmall(
                                              ColorClass.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            'Privacy Policy',
                                            style: TextStyleClass.buttonSmall(
                                              ColorClass.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),

                              // Extra padding at bottom for keyboard
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
