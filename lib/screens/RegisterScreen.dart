import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:misconductmobile/variables.dart';
import 'package:misconductmobile/screens/LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  static const primaryColor = Color(0xFF2E7D32);
  static const String allowedSpecialCharacters = r'!@#$%^&*()_+=-`~?/<>,.:;[]{}|';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Map<String, bool> _getPasswordValidation(String password) {
    if (password.isEmpty) {
      return {
        'length': false,
        'uppercase': false,
        'lowercase': false,
        'number': false,
        'special_char': false, 
        'no_spaces': false,
      };
    }

    final specialCharRegExp = RegExp(r'[' + RegExp.escape(allowedSpecialCharacters) + r']');

    return {
      'length': password.length >= 8 && password.length <= 20,
      'uppercase': password.contains(RegExp(r'[A-Z]')),
      'lowercase': password.contains(RegExp(r'[a-z]')),
      'number': password.contains(RegExp(r'[0-9]')),
      'special_char': password.contains(specialCharRegExp), 
      'no_spaces': !password.contains(' '),
    };
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    final validation = _getPasswordValidation(value);
    
    final allValid = validation.values.every((isValid) => isValid);

    if (!allValid) {
        return "Password does not meet all security requirements.";
    }

    return null;
  }
  // ===============================================

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('$baseUrl/register');

    final body = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'password_confirmation': _confirmPasswordController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registration successful! Please login.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "${error['message'] ?? 'Registration failed'}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    bool isConfirmPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: labelText.toLowerCase().contains('email')
          ? TextInputType.emailAddress
          : TextInputType.text,
      onChanged: isPassword ? (value) => setState(() {}) : null,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.green[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword || isConfirmPassword
            ? IconButton(
                icon: Icon(
                  (isPassword
                          ? _isPasswordObscure
                          : _isConfirmPasswordObscure)
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    if (isPassword) {
                      _isPasswordObscure = !_isPasswordObscure;
                    } else if (isConfirmPassword) {
                      _isConfirmPasswordObscure =
                          !_isConfirmPasswordObscure;
                    }
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildPasswordChecklist(String password) {
    final validation = _getPasswordValidation(password);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChecklistItem(
            '8 – 20 characters',
            validation['length']!,
          ),
          _buildChecklistItem(
            'At least one capital letter (A to Z)',
            validation['uppercase']!,
          ),
          _buildChecklistItem(
            'At least one lowercase letter (a to z)',
            validation['lowercase']!,
          ),
          _buildChecklistItem(
            'At least one number (0 to 9)',
            validation['number']!,
          ),
          _buildChecklistItem(
            'At least one special character (e.g., !@#\$...)',
            validation['special_char']!,
          ),
          _buildChecklistItem(
            'No spaces',
            validation['no_spaces']!,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: isValid ? primaryColor : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.black87 : Colors.grey,
              fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  // ===============================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BG.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 32),
                  width: width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create Your Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Register to start reporting incidents.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),

                      _buildTextField(
                        controller: _nameController,
                        labelText: "Full Name",
                        icon: Icons.person,
                        validator: (value) =>
                            value!.isEmpty ? "Full Name is required" : null,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _emailController,
                        labelText: "Email",
                        icon: Icons.email,
                        validator: (value) =>
                            value!.isEmpty ? "Email is required" : null,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _passwordController,
                        labelText: "Password",
                        icon: Icons.lock,
                        obscureText: _isPasswordObscure,
                        isPassword: true,
                        validator: _validatePassword,
                      ),
                      
                      _buildPasswordChecklist(_passwordController.text),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _confirmPasswordController,
                        labelText: "Confirm Password",
                        icon: Icons.lock_open,
                        obscureText: _isConfirmPasswordObscure,
                        isConfirmPassword: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Confirmation is required";
                          }
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryColor),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),

                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(
                                  text: "Already have an account? "),
                              TextSpan(
                                text: "Login here",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
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
        ),
      ),
    );
  }
}