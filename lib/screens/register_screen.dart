import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safepulse/utils/app_colors.dart';
import 'package:safepulse/utils/app_text_styles.dart';
import 'package:safepulse/widgets/custom_loading.dart';
import 'package:safepulse/widgets/success_page.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  void _registerUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog("All fields are required.");
      return;
    }
    if (password != confirmPassword) {
      _showErrorDialog("Passwords do not match.");
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        "uid": userId,
        "name": name,
        "email": email,
        "phoneNumber": phone,
        "emergencyContacts": [],
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("✅ User Registered: $userId");

      // Navigate to the Success Screen first
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => SuccessScreen(
                userId: userId,
                message: "Account created successfully!", // Provide a message
              ),
        ),
      );
    } catch (e) {
      _showErrorDialog("Registration failed. Please try again.");
      print("❌ Registration Error: $e");
    }

    setState(() => isLoading = false);
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.black54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeIn(
                    duration: Duration(milliseconds: 1000),
                    child: Image.asset('assets/images/logo.png', height: 150),
                  ),
                  SizedBox(height: 20),
                  FadeInUp(
                    duration: Duration(milliseconds: 1200),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      color: Colors.black,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Create an Account",
                              style: AppTextStyles.headingBlack.copyWith(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              "Full Name",
                              nameController,
                              Icons.person,
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              "Email",
                              emailController,
                              Icons.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              "Phone Number",
                              phoneController,
                              Icons.phone,
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              "Password",
                              passwordController,
                              Icons.lock,
                              obscure: true,
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              "Confirm Password",
                              confirmPasswordController,
                              Icons.lock_outline,
                              obscure: true,
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _registerUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.sosButtonColor,
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    isLoading
                                        ? CustomLoadingAnimation()
                                        : Text(
                                          "Sign Up",
                                          style: AppTextStyles.sosButtonText,
                                        ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: AppTextStyles.subHeadingBlack
                                        .copyWith(color: Colors.white70),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text(
                                      "Sign In",
                                      style: AppTextStyles.sosButtonText
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
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
