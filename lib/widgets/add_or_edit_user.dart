import 'dart:convert';

import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/coustom_fieds.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class add_or_edit_user extends StatefulWidget {
  add_or_edit_user({
    required this.name,
    required this.lastName,
    required this.username,
    required this.password,
    required this.email,
    this.index,
    required this.isEdit,
    required this.role,
    required this.ucontroller,
    super.key,
  });
  userController ucontroller;
  String name;
  String lastName;
  String email;
  String username;
  String password;
  String role;
  int? index;
  bool isEdit;

  @override
  State<add_or_edit_user> createState() => _add_or_edit_userState();
}

class _add_or_edit_userState extends State<add_or_edit_user> {
  late final userController ucontroller;
  late final bool isEdit;
  late final int? index;

  @override
  void initState() {
    ucontroller = widget.ucontroller;
    isEdit = widget.isEdit;
    index = widget.index;
    // Seed the fields once on open; doing this in build() wiped the user's
    // edits on every rebuild.
    ucontroller.name.text = widget.name;
    ucontroller.lastName.text = widget.lastName;
    ucontroller.email.text = widget.email;
    ucontroller.username.text = widget.username;
    ucontroller.password.text = widget.password;
    ucontroller.accsesslvl.value = widget.role;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? "ویرایش کاربر" : "اضافه کردن کاربر",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              CoustomTextField3(
                  controller: ucontroller.name, hint: 'نام', width: 250),
              const SizedBox(height: 12),
              CoustomTextField3(
                  controller: ucontroller.lastName,
                  hint: 'نام خانوادگی',
                  width: 250),
              const SizedBox(height: 12),
              CoustomTextField3(
                  controller: ucontroller.email, hint: 'ایمیل', width: 250),
              const SizedBox(height: 12),
              CoustomTextField3(
                  controller: ucontroller.username,
                  hint: 'نام کاربری ',
                  width: 250),
              const SizedBox(height: 12),
              CoustomTextField3(
                  controller: ucontroller.password,
                  hint: 'رمز عبور',
                  width: 250),
              const SizedBox(height: 16),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Obx(() => DropdownButtonFormField<String>(
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 12.5),
                      dropdownColor: AppColors.surface,
                      isExpanded: true,
                      decoration: InputDecoration(
                          focusColor: Colors.transparent,
                          fillColor: AppColors.surfaceHigh,
                          filled: true),
                      borderRadius: BorderRadius.circular(8),
                      initialValue: (ucontroller.accsesslvl.value == 'مدیر' ||
                              ucontroller.accsesslvl.value == 'ناظر')
                          ? ucontroller.accsesslvl.value
                          : 'مدیر',
                      items: const [
                        DropdownMenuItem(value: "مدیر", child: Text("مدیر")),
                        DropdownMenuItem(value: "ناظر", child: Text("ناظر"))
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ucontroller.accsesslvl.value = value;
                        }
                      })),
                ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () async {
                  if (ucontroller.username.text.trim().isEmpty ||
                      ucontroller.password.text.isEmpty) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        const SnackBar(
                            content: Text(
                          "نام کاربری و رمز عبور لازم است",
                          textDirection: TextDirection.rtl,
                        )));
                    return;
                  }
                  try {
                    final body = {
                      "username": ucontroller.username.text.trim(),
                      "password": base64
                          .encode(utf8.encode(ucontroller.password.text)),
                      "accsesslvl": ucontroller.accsesslvl.value,
                      "email": ucontroller.email.text.trim(),
                      "nickname":
                          "${ucontroller.name.text.trim()} ${ucontroller.lastName.text.trim()}"
                    };

                    if (isEdit) {
                      final id = (index != null &&
                              index! >= 0 &&
                              index! < ucontroller.users.length)
                          ? ucontroller.users[index!].id
                          : null;
                      if (id == null || id.isEmpty) return;
                      final record = await pb
                          .collection('users')
                          .update(id, body: body)
                          .timeout(
                              const Duration(seconds: 15));
                      ScaffoldMessenger.maybeOf(context)
                          ?.showSnackBar(SnackBar(
                              content: Text(
                            "با ویرایش  شد ${record.id}",
                            textDirection: TextDirection.rtl,
                          )));
                    } else {
                      final record = await pb
                          .collection('users')
                          .create(body: body)
                          .timeout(
                              const Duration(seconds: 15));
                      ScaffoldMessenger.maybeOf(context)
                          ?.showSnackBar(SnackBar(
                              content: Text(
                            "با موفقیت ساخته شد ${record.id}",
                            textDirection: TextDirection.rtl,
                          )));
                    }

                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.maybeOf(context)
                        ?.showSnackBar(const SnackBar(
                            content: Text(
                          "خطا دوباره امتحان کنید",
                          textDirection: TextDirection.rtl,
                        )));
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text("ثبت"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
