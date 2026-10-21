import 'package:amnban/screens/general_setting.dart';
import 'package:amnban/screens/user_box.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Settings screen with three collapsible sections.
class SettingScreen extends StatelessWidget {
  SettingScreen({
    super.key,
  });

  userController ucontroller = Get.find<userController>();
  settingController scontroller = Get.find<settingController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _section(
            title: 'کاربران',
            icon: Icons.group_rounded,
            isOpen: scontroller.isUsers,
            onTap: () =>
                scontroller.isUsers.value = !scontroller.isUsers.value,
            child: UserBox(
              scontroller: scontroller,
              ucontroller: ucontroller,
            ),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'عمومی',
            icon: Icons.tune_rounded,
            isOpen: scontroller.isGeneral,
            onTap: () =>
                scontroller.isGeneral.value = !scontroller.isGeneral.value,
            child: GeneralSetting(scontroller: scontroller),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'درباره',
            icon: Icons.info_outline_rounded,
            isOpen: scontroller.isInfo,
            onTap: () =>
                scontroller.isInfo.value = !scontroller.isInfo.value,
            child: const InfoBox(),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required RxBool isOpen,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            child: Obx(
              () => Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                color: isOpen.value
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isOpen.value
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isOpen.value
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: isOpen.value ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                child: child,
              ),
              crossFadeState: isOpen.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
              firstCurve: Curves.decelerate,
              secondCurve: Curves.decelerate,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyValueRow(
            keyString: "BuilDNumber", valueString: "SN/1404717"),
        const Divider(color: AppColors.border),
        KeyValueRow(keyString: "UpdateNo", valueString: "14040828"),
        const Divider(color: AppColors.border),
        KeyValueRow(
            keyString: "Last Update",
            valueString:
                "${now.year}/${now.month}/${now.day}"),
        const Divider(color: AppColors.border),
        KeyValueRow(
            keyString: "Train Model Serial", valueString: "YOLOV5M100300"),
        const Divider(color: AppColors.border),
      ],
    );
  }
}

class KeyValueRow extends StatelessWidget {
  late String keyString;
  late String valueString;
  KeyValueRow({required this.keyString, required this.valueString});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(
              keyString + " : ",
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'arial',
              ),
            ),
          ),
          Expanded(
            child: Text(
              valueString,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: "arial",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
