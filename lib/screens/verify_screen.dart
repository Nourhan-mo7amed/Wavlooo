import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chat/screens/home_screen.dart';
import '../components/Orange_Circle.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyScreen extends StatefulWidget {
  final String email;

  const VerifyScreen({super.key, required this.email});

  @override
  State<VerifyScreen> createState() => VerifyScreenState();
}

class VerifyScreenState extends State<VerifyScreen> {
  String otp = '';
  TextEditingController otpController = TextEditingController();

  Future<void> verifyOtpFromApi() async {
    final url = Uri.parse(
      "https://wavlo.azurewebsites.net/api/auth/validate-otp",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: '{"email": "${widget.email}", "otp": "$otp"}',
    );

    print("🔐 Sent OTP: $otp for ${widget.email}");
    print("📡 Response: ${response.statusCode} - ${response.body}");
    if (response.statusCode == 200) {
      try {
        final responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('token')) {
          final token = responseJson['token'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(token: token)),
          );
        } else if (response.body.contains("OTP Verified Successfully")) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ OTP Verified Successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Unexpected Response")),
          );
        }
      } catch (e) {
        print("Error decoding response: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to process response")),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to verify OTP")));
    }
  }

  void resetOtp() {
    setState(() {
      otp = '';
      otpController.clear();
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const OrangeCircleDecoration(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ListView(
              children: [
                const SizedBox(height: 80),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Verification Code",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffF37C50),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "We have sent the verification code to your email address",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                PinCodeTextField(
                  appContext: context,
                  controller: otpController,
                  length: 6,
                  obscureText: true,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  cursorColor: const Color(0xffF37C50),
                  textStyle: const TextStyle(fontSize: 20),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(20),
                    fieldHeight: 65,
                    fieldWidth: 45,
                    inactiveColor: Colors.grey,
                    inactiveFillColor: Color(0xffF37C50).withOpacity(0.08),
                    selectedColor: Color(0xffF37C50),
                    selectedFillColor: Colors.white,
                    activeFillColor: Colors.white,
                  ),
                  onCompleted: (value) {
                    setState(() {
                      otp = value;
                    });
                  },
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    otp = otpController.text.trim();
                    print("🚀 OTP entered: $otp");

                    if (otp.length == 6) {
                      verifyOtpFromApi();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid 6-digit OTP"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF37C50),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: resetOtp,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Didn't receive code? ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: "Resend",
                            style: TextStyle(
                              color: Color(0xffF37C50),
                              fontSize: 16,
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
        ],
      ),
    );
  }
}
