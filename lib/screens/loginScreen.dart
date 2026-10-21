import 'dart:convert';

import 'package:amnban/models/userClass.dart';
import 'package:amnban/screens/main_screen.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Login screen — cream card on the deep teal background of the reference.
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
      backgroundColor: AppColors.loginBackground,
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.loginBackground, Color(0xFF223A3D)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.loginCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.loginCardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 720;
                        final brand = _brand();
                        final form = _form();

                        if (!wide) {
                          return Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                brand,
                                const SizedBox(height: 22),
                                form,
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(28),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // RTL: the first child is rendered on the right,
                              // so the form comes first and the brand second.
                              SizedBox(width: 300, child: form),
                              const SizedBox(width: 36),
                              SizedBox(width: 280, child: brand),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'ممانعت از دسترسی غیرمجاز به سامانه کنترل شده توسط: شرکت دیسپی',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const DiespiEmblem(size: 120),
        const SizedBox(height: 16),
        const DiespiWordmark(fontSize: 30),
        const SizedBox(height: 10),
        const Text(
          'سامانه پایش خودکار پلاک',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ورود به سامانه',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.sidebar,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'پنل مدیریت پارکینگ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          _label('نام کاربری'),
          TextFormField(
            controller: _usernameController,
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'نام کاربری',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'لطفا نام کاربری خود را وارد کنید';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _label('رمز عبور'),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'رمز عبور',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'لطفا رمز عبور خود را وارد کنید';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                  side: const BorderSide(color: AppColors.textMuted),
                  onChanged: (bool? value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'مرا به یاد داشته باش',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            autofocus: false,
            onPressed: _isLoggingIn ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoggingIn
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'ورود',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
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
