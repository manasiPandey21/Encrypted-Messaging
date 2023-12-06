import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';
import 'package:whisper/Provider/auth.dart';
import 'package:whisper/Screens/Auth/login.dart';
import 'package:whisper/Screens/ChatScreen/chat_screen.dart';
import 'package:whisper/Screens/Common/landingpage.dart';

class MyOtp extends StatefulWidget {
  String phone;
  MyOtp(this.phone, {super.key});

  @override
  State<MyOtp> createState() => _MyOtpState();
}

class _MyOtpState extends State<MyOtp> {
  bool? islogintrue;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var code1 = "";
  late Timer _timer;
  int _seconds = 60;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _timer.cancel();
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Verification Code",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text("Enter the OTP sent to ${widget.phone}"),
                const SizedBox(height: 20),
                OtpTextField(
                  numberOfFields: 6,
                  borderColor: const Color(0xFF512DA8),
                  showFieldAsBox: true,
                  onCodeChanged: (String code) {
                    code1 = code;
                  },
                  onSubmit: (String verificationCode) async {
                    final provider = Provider.of<Auth>(context, listen: false);
                    islogintrue =
                        await Provider.of<Auth>(context, listen: false)
                            .submitOTP(verificationCode);

                    Auth.setUid();

                    var isuser = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(Auth.uid)
                        .get();

                    if (islogintrue == true) {
                      if (isuser.exists) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ));
                      }
                       else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LandingPage(),
                          ),
                        );
                      }
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 60),
                Text("Resend in 00:${_seconds.toString().padLeft(2, '0')}sec"),
                const SizedBox(height: 40),
                const Row(
                  children: [
                    Icon(
                      Icons.check_box,
                      color: Color(0xFF512DA8),
                    ),
                    Expanded(
                      child: FittedBox(
                        child: Text(
                          "I agree to Whisper's Terms & Conditions & Privacy Policy",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
