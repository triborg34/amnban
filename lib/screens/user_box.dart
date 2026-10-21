import 'dart:convert';

import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/add_or_edit_user.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Users list (accounts + access level).
class UserBox extends StatelessWidget {
  UserBox({
    required this.ucontroller,
    required this.scontroller,
    super.key,
  });

  userController ucontroller;
  settingController scontroller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ElevatedButton.icon(
            onPressed: () async {
              await showAdaptiveDialog(
                context: context,
                builder: (context) => add_or_edit_user(
                  email: '',
                  isEdit: false,
                  lastName: '',
                  name: '',
                  password: '',
                  role: 'مدیر',
                  username: '',
                  ucontroller: ucontroller,
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text("اضافه کردن"),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final users = ucontroller.users;
          if (users.isEmpty) {
            return const AppEmptyState(
              message: 'کاربری ثبت نشده است',
              icon: Icons.person_outline,
              compact: true,
            );
          }
          return SizedBox(
            height: 280,
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 5),
              itemBuilder: (context, index) => _userRow(context, index),
            ),
          );
        }),
      ],
    );
  }

  Widget _userRow(BuildContext context, int index) {
    final user = ucontroller.users[index];

    Widget cell(String value, IconData? icon) => Expanded(
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${index + 1}'.toPersianDigit(),
              style: AppTheme.numeric(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(flex: 3, child: cell(user.nickname ?? '-', null)),
          Expanded(flex: 3, child: cell(user.email ?? '-', Icons.mail_outline)),
          Expanded(flex: 2, child: cell(user.username ?? '-', null)),
          Expanded(
            flex: 2,
            child: cell(
              user.accsesslvl ?? '-',
              Icons.admin_panel_settings_outlined,
            ),
          ),
          IconButton(
            onPressed: () => _edit(context, index),
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'ویرایش',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: () => _delete(index),
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppColors.danger),
            tooltip: 'حذف',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, int index) async {
    final user = ucontroller.users[index];
    String passwordPlain = '';
    try {
      final stored = user.password;
      if (stored != null && stored.isNotEmpty) {
        passwordPlain = utf8.decode(base64.decode(stored));
      }
    } catch (e) {
      appLog('user password decode failed', e);
    }
    final nameSplit = (user.nickname ?? '').split(' ');
    if (!context.mounted) return;
    await showAdaptiveDialog(
      context: context,
      builder: (context) => add_or_edit_user(
        name: nameSplit.isNotEmpty ? nameSplit[0] : '',
        lastName: nameSplit.length > 1 ? nameSplit.sublist(1).join(' ') : '',
        username: user.username ?? '',
        password: passwordPlain,
        email: user.email ?? '',
        isEdit: true,
        role: user.accsesslvl ?? 'مدیر',
        index: index,
        ucontroller: ucontroller,
      ),
    );
  }

  Future<void> _delete(int index) async {
    final user = ucontroller.users[index];
    final id = user.id;
    if (id == null || id.isEmpty) return;
    try {
      await pb
          .collection('users')
          .delete(id)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      appLog('delete user failed', e);
    }
  }
}
