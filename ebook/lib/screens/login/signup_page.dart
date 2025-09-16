import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import '../../utils/constants/colors.dart';
import 'package:ebook/controllers/auth_controller.dart';
import 'package:ebook/models/user_model.dart';
import 'signin_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _passwordInvisible = true;

  final AuthController controller = Get.put(AuthController());

  @override
  void initState() {
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        name: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      var result = await controller.signupController(user);

      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['success'])),
        );

        // Navigate to Sign In after successful signup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SigninPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "E-Book App",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: TColors.primary,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: TColors.primary,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(Icons.menu_book, size: 80, color: TColors.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Hello! Register to explore your E-Books 📚",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),

                  // Username
                  TextFormField(
                    controller: _usernameController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: "Enter your username",
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "* Required"),
                    ]).call,
                  ),
                  const SizedBox(height: 10),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: "Enter your email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "* Required"),
                      EmailValidator(errorText: "Please enter a valid email address"),
                    ]).call,
                  ),
                  const SizedBox(height: 10),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    maxLines: 1,
                    obscureText: _passwordInvisible,
                    decoration: InputDecoration(
                      labelText: "Enter your password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordInvisible = !_passwordInvisible;
                          });
                        },
                        icon: Icon(
                          _passwordInvisible ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "* Required"),
                      MinLengthValidator(6, errorText: "Password must be at least 6 characters."),
                      MaxLengthValidator(15, errorText: "Password must not exceed 15 characters."),
                    ]).call,
                  ),
                  const SizedBox(height: 20),

                  // Sign up button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Sign up"),
                  ),
                  const SizedBox(height: 10),

                  // Go to Sign In
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SigninPage()),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: "Already have an account? "),
                            TextSpan(
                              text: "Login here",
                              style: TextStyle(
                                color: TColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
