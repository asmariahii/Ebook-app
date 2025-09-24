import 'package:ebook/screens/login/signup_page.dart';
import 'package:ebook/screens/login/signin_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[100]!,
                Colors.green[400]!,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background with geometric shapes
              Positioned.fill(
                child: AnimatedBackground(),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with fade-in animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                        child: FadeInImage(
                          image: const AssetImage('/images/ebook.png'),
                          placeholder: const AssetImage('/images/ebook.png'),
                          height: 150,
                          fit: BoxFit.contain,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.error_outline,
                              size: 80,
                              color: Colors.red,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Headline text with fade-in animation
                      FadeInText(
                        text: "Welcome to NextPage",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInText(
                        text: "Your Next Reading Adventure",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 50),
                      // Sign Up button with animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignupPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 170, 236, 172),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 8,
                            shadowColor: Colors.green[900]!.withOpacity(0.5),
                          ),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Color.fromARGB(255, 7, 88, 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Sign In link
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SigninPage()),
                          );
                        },
                        child: FadeInText(
                          text: "Already have an account? Sign In",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: const Color.fromARGB(255, 15, 93, 44),
                            decoration: TextDecoration.underline,
                          ),
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
    );
  }
}

// Custom widget for fade-in text animation
class FadeInText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const FadeInText({required this.text, required this.style, super.key});

  @override
  _FadeInTextState createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Text(
        widget.text,
        style: widget.style,
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Custom widget for animated background with geometric shapes
class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            for (int i = 0; i < 5; i++)
              Positioned(
                left: _animation.value * 200 + (i * 100),
                top: _animation.value * 300 + (i * 50),
                child: Transform.rotate(
                  angle: _animation.value * 2 * 3.14,
                  child: Container(
                    width: 20 + (i * 10),
                    height: 20 + (i * 10),
                    decoration: BoxDecoration(
                      color: Colors.green[200]!.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}