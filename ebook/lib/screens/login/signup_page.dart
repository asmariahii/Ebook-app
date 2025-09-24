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
        backgroundColor: const Color(0xFFF8F9FA), // Soft off-white background
        appBar: AppBar(
          title: Text(
            "",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: const Color.fromARGB(255, 94, 184, 100), // Teal accent
              fontSize: 26,
              fontFamily: 'Poppins',
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'images/ebook.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Welcome to NextPage! 📖",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 81, 147, 86), // Deep teal
                          fontSize: 26,
                          fontFamily: 'Poppins',
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Username
                  _buildTextField(
                    controller: _usernameController,
                    label: "Username",
                    icon: Icons.person_outline_rounded,
                    validators: [
                      RequiredValidator(errorText: "* Required"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    validators: [
                      RequiredValidator(errorText: "* Required"),
                      EmailValidator(errorText: "Please enter a valid email address"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Password
                  _buildTextField(
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock,
                    obscureText: _passwordInvisible,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordInvisible = !_passwordInvisible;
                        });
                      },
                      icon: Icon(
                        _passwordInvisible ? Icons.visibility_off : Icons.visibility,
                        color: const Color.fromARGB(255, 63, 110, 62), // Light teal
                      ),
                    ),
                    validators: [
                      RequiredValidator(errorText: "* Required"),
                      MinLengthValidator(6, errorText: "Password must be at least 6 characters."),
                      MaxLengthValidator(15, errorText: "Password must not exceed 15 characters."),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Sign up button
                  _buildElevatedButton(),
                  const SizedBox(height: 24),

                  // Go to Sign In
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SigninPage()),
                        );
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontFamily: 'Roboto',
                            ),
                        children: [
                          const TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Login here",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 63, 110, 62),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    required List<TextFieldValidator> validators,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: 1,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color.fromARGB(255, 63, 110, 62), // Light teal
            fontFamily: 'Roboto',
          ),
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 63, 110, 62)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color:  const Color.fromARGB(255, 61, 112, 64)!, // Teal border on focus
              width: 2,
            ),
          ),
        ),
        validator: MultiValidator(validators).call,
      ),
    );
  }

  Widget _buildElevatedButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 63, 110, 62), // Teal button
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          shadowColor: const Color.fromARGB(255, 63, 110, 62).withOpacity(0.4),
        ),
        child: const Text(
          "Sign up",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}