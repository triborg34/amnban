import 'dart:convert';

import 'package:amnban/models/userClass.dart';
import 'package:amnban/screens/main_screen.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModernLoginPage extends StatefulWidget {
  const ModernLoginPage({super.key});

  @override
  _ModernLoginPageState createState() => _ModernLoginPageState();
}

class _ModernLoginPageState extends State<ModernLoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _isLoggingIn = false;
  final FocusNode _keyboardFocusNode = FocusNode();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  userController ucontroller = Get.find<userController>();

  /// Best-effort base64 decode: returns null for plain/corrupt passwords
  /// instead of throwing FormatException.
  String? _decodePassword(String? stored) {
    if (stored == null || stored.isEmpty) return null;
    try {
      return utf8.decode(base64.decode(stored));
    } catch (_) {
      return null;
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      String username = await getRememberMe();
      if (username.isEmpty) return;
      if (!mounted) return;
      // Users may not be loaded yet — wait briefly rather than failing.
      if (ucontroller.users.isEmpty) {
        try {
          await ucontroller.ensureLoaded().timeout(const Duration(seconds: 10));
        } catch (_) {}
      }
      if (!mounted) return;
      var matches = ucontroller.users.where(
        (element) => element.username == username,
      );
      if (matches.isNotEmpty) {
        userClass user = matches.first;
        if (user.rememberme == true) {
          role = user.accsesslvl ?? '';
          email = user.email ?? '';
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainScreen()),
          );
        }
      }
    } catch (_) {
      // Auto-login must never crash the login screen.
    }
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _checkLoginStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            _login();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade900,
                Colors.black,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/mainlogo2.png',
                      width: 200,
                      height: 200,
                    ),
                    Text(
                      "سامانه پایش خودکار پلاک\n Automatic Numberplate Recognition",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    SizedBox(
                      height: 500,
                      width: 500,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Logo or App Name
                                Text(
                                  'ورود',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Username TextField
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person,
                                        color: Colors.purple),
                                    hintText: 'نام کاربری',
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors.purple, width: 2),
                                    ),
                                    hintStyle: TextStyle(color: Colors.white54),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'لطفا نام کاربری خود را وارد کنید';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Password TextField
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.lock, color: Colors.purple),
                                    hintText: 'رمز عبور',
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha:0.1),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors.purple, width: 2),
                                    ),
                                    hintStyle: TextStyle(color: Colors.white54),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'لطفا رمز عبور خود را وارد کنید';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),

                                // Remember Me Checkbox
                                Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      activeColor: Colors.purple,
                                      checkColor: Colors.white,
                                      side: BorderSide(color: Colors.white54),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                    ),
                                    Text(
                                      'مرا به یاد داشته باش',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                                const SizedBox(height: 30),

                                // Login Button
                                ElevatedButton(
                                  autofocus: false,
                                  onPressed: () async {
                                   
                                    await _login();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'ورود',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 800,
                      height: 600,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/ban.jpg',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _login() async {
    if (_isLoggingIn) return;
    if (_formKey.currentState!.validate()) {
      _isLoggingIn = true;
      try {
        var matches = ucontroller.users.where(
          (element) => element.username == _usernameController.text,
        );
        if (matches.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('رمز عبور یا نام کاربری اشتباه',
                    textDirection: TextDirection.rtl)),
          );
          return;
        }
        userClass user = matches.first;
        if (_rememberMe) {
          try {
            saveRememberMe(true, user.username ?? _usernameController.text);
            if (user.id != null) {
              await pb
                  .collection('users')
                  .update(user.id!, body: {"rememberme": _rememberMe}).timeout(
                      const Duration(seconds: 10));
            }
          } catch (_) {
            // Remember-me persistence must not block login.
          }
        }
        // Login logic here

        final stored = _decodePassword(user.password);
        if (stored != null && stored == _passwordController.text) {
          role = user.accsesslvl ?? '';
          email = user.email ?? '';
          // offAll so back button can't return to the login screen.
          Get.offAll(() => MainScreen());
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('رمز عبور یا نام کاربری اشتباه',
                    textDirection: TextDirection.rtl)),
          );
        }
      } finally {
        _isLoggingIn = false;
      }
    }
  }

  void saveRememberMe(bool value, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
    await prefs.setString('username', username);
  }

  Future<String> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? ''; // default to false
  }
}
