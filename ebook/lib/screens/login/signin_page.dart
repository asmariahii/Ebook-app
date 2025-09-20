import 'package:ebook/screens/admin_page.dart';
import 'package:ebook/screens/home/route_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/instance_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants/colors.dart';
import 'package:ebook/controllers/auth_controller.dart';
import 'package:ebook/models/user_model.dart';
import '../nav_pages/nav_home_page.dart';
import 'signup_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _passwordInvisible = true;

  final AuthController controller = Get.put(AuthController());
  late SharedPreferences prefs;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    initSharedPref();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        email: _emailController.text,
        password: _passwordController.text,
      );

      var result = await controller.signinController(user);

      if (result['status'] == true) {
        String token = result['token'];
        await prefs.setString('authToken', token); // Ensure token is saved

        // Get the role after login
        String? role = await AuthController.instance.getUserRole();

        // Navigate based on role
        if (role == 'admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => AdminDashboard()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => RoutePages(token: token)),
            (route) => false,
          );
        }
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
          title: Text("E-Book App", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: TColors.primary,
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
                    child: Icon(Icons.menu_book, size: 70, color: TColors.primary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Welcome back! Glad to see you 📖",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Enter your email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: TColors.lightGrey,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Email is required"),
                      EmailValidator(errorText: "Enter a valid email"),
                    ]).call,
                  ),
                  const SizedBox(height: 10),

                  // Password
                  TextFormField(
                    controller: _passwordController,
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
                      filled: true,
                      fillColor: TColors.lightGrey,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Password is required"),
                      MinLengthValidator(6, errorText: "Password must be at least 6 characters"),
                    ]).call,
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        // Forgot password logic
                      },
                      child: const Text("Forgot password?"),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Sign in button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Sign in"),
                  ),
                  const SizedBox(height: 10),

                  // Go to register
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: "Register",
                              style: TextStyle(color: TColors.primary, fontWeight: FontWeight.bold),
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