import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_audit_supplier/admin_qc/halaman_utama_aqc.dart';
import 'package:monitoring_audit_supplier/manager_qc/halaman_utama_mqc.dart';
import 'package:monitoring_audit_supplier/staff_qa/halaman_utama_sqa.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  bool _isLoading = false;

  void _startLoading() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });
  }

  bool visible = false;
  bool _isObscure = true;
  final _formkey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {});
    });
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(
      seconds: 2,
    ),
    vsync: this,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color.fromARGB(40, 216, 60, 60),
                Color.fromARGB(42, 99, 127, 134),
                Color.fromARGB(72, 197, 189, 147),
                Color.fromARGB(53, 128, 212, 205),
                Color.fromARGB(255, 198, 236, 233),
                Color.fromARGB(118, 69, 87, 81),
                Color.fromARGB(139, 45, 218, 122),
                Color.fromARGB(162, 141, 212, 200),
              ],
              // Gradient from https://learnui.design/tools/gradient-generator.html
              tileMode: TileMode.mirror,
            ),
          ),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Hero(
                      tag: 'wima-logo',
                      child: Image.asset(
                        'assets/images/wima-logo.png',
                        width: 200,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 890),
                    child: Hero(
                      tag: 'gesits-logo',
                      child: Image.asset(
                        'assets/images/gesits-logo.png',
                        width: 160,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: 50,
                  bottom: 35,
                  left: 400,
                  right: 400,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 15.0,
                            left: 15.0,
                            right: 15.0,
                          ),
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          "Monitoring Pengelolaan Supplier",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Form(
                        key: _formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                top: 5,
                                left: 10,
                              ),
                              child: const Text(
                                "Email",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: emailController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Email tidak boleh kosong!";
                                  }
                                  if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                      .hasMatch(value)) {
                                    return ("Masukkan email yang valid!");
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  emailController.text = value!;
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  prefixIcon: Icon(
                                    Icons.alternate_email,
                                  ),
                                  hintText: "Masukkan Email",
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 5,
                                left: 10,
                              ),
                              child: const Text(
                                "Password",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                obscureText: _isObscure,
                                controller: passwordController,
                                validator: (value) {
                                  RegExp regex = RegExp(r'^.{6,}$');
                                  if (value!.isEmpty) {
                                    return "Password tidak boleh kosong!";
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return ("Minimal 6 karakter!");
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  passwordController.text = value!;
                                },
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                  prefixIcon: const Icon(
                                    Icons.key,
                                  ),
                                  hintText: "Masukkan Password",
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
              Container(
                margin: const EdgeInsets.only(
                  left: 500,
                  right: 500,
                ),
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.login),
                  label: Text(
                    _isLoading ? 'Loading...' : 'Login',
                    style: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      signIn(
                        emailController.text,
                        passwordController.text,
                      );
                      route();
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(fixedSize: const Size(200, 50)),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get("role") == "Admin QC") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HalamanUtamaAQC(),
            ),
          );
        } else if (documentSnapshot.get("role") == "Manager QC") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HalamanUtamaMQC(),
            ),
          );
        } else if (documentSnapshot.get("role") == "Staff QA") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HalamanUtamaSQA(),
            ),
          );
        }
      } else {
        if (kDebugMode) {
          print('Document does not exist on the database');
        }
      }
    });
  }

  void signIn(String mail, String pwd) async {
    try {
      _startLoading();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: pwd,
      );
      _isLoading;
      route();
    } on FirebaseAuthException catch (e) {
      _isLoading;
      if (e.code == 'user-not-found') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Email tidak terdaftar!",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
        if (kDebugMode) {
          print('No user found for that email.');
        }
      } else if (e.code == 'wrong-password') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Password salah!",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
        if (kDebugMode) {
          print('Wrong password provided for that user.');
        }
      }
    }
  }
}
