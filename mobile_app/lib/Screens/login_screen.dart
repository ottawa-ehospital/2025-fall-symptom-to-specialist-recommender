import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/e_hospital_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAlreadyLoggedIn();
  }

  Future<void> _checkAlreadyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("patient_id");

    if (id != null && mounted) {
      Navigator.pushReplacementNamed(context, "/dashboard");
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _error = "Please enter your email");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await EHospitalAuthService.loginWithEmail(email);

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.pushReplacementNamed(context, "/dashboard");
    } else {
      setState(() => _error = "Login failed. Email not found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),  // soft grey 
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // APP TITLE
                    Text(
                      "Smart Health Login",
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // EMAIL INPUT
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),

                    const SizedBox(height: 20),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Login"),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
