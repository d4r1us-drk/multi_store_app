import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_store_app/views/main_screen.dart';
import 'package:multi_store_app/views/authentication_screens/register_screen.dart';
import 'package:multi_store_app/views/authentication_screens/forgot_password_screen.dart';
import 'package:multi_store_app/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final authController = AuthController();

  bool _isLoading = false;
  bool _isObscure = true;

  late String email;
  late String password;

  @override
  void initState() {
    super.initState();

    // Use authStateChanges to listen to the user's login status
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // If a user is logged in, navigate to the MainScreen
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ));
        });
      }
    });
  }

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var response = await authController.loginUser(email, password);

      if (response == "success") {
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return const MainScreen();
            },
          ));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged in Successfully')));
        }).whenComplete(() {
          _formKey.currentState!.reset();
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Login Failed: $response')));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Image.asset(
                    'assets/images/Illustration.png',
                    width: 250,
                    height: 250,
                  ),
                  const SizedBox(height: 40.0),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType
                        .emailAddress, // Ensure the right input type
                    autocorrect:
                        false, // Disable autocorrect to avoid unwanted modes
                    enableSuggestions:
                        false, // Disable suggestions to avoid handwriting
                    decoration: InputDecoration(
                      labelText: 'Enter your email',
                      hintText: 'user@example.com',
                      prefixIcon: const Icon(Icons.mail),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    obscureText: _isObscure,
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  // Forgot Password Navigation
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ));
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            backgroundColor: Colors.black,
                          ),
                          onPressed: _isLoading ? null : loginUser,
                          child: Text(
                            'Login',
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const RegisterScreen();
                            },
                          ));
                        },
                        child: Text(
                          'Register here',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
