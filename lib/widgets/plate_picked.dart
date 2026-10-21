import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Preview of the plate the user is building in the "انتخاب" dialog.
class PlatePicked extends StatelessWidget {
  const PlatePicked({
    super.key,
    required this.rcontroller,
  });

  final reportController rcontroller;

  @override
  Widget build(BuildContext context) {
    // TextEditingControllers don't trigger Obx — listen to them explicitly
    // so the preview updates while typing (previously stale until update()).
    return ListenableBuilder(
      listenable: Listenable.merge([
        rcontroller.firstTwoDigit,
        rcontroller.threeDigit,
        rcontroller.lastTwoDigit,
      ]),
      builder: (context, _) => Obx(() => _body()),
    );
  }

  Widget _body() {
    final complete = rcontroller.firstTwoDigit.text.length != 0 &&
        rcontroller.threeDigit.text.length != 0 &&
        rcontroller.lastTwoDigit.text.length != 0;

    return Container(
      height: 42,
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: complete
            ? Text(
                convertToPersianString(
                    rcontroller.pickerPlate.value, alphabetP2),
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _segment(
                    rcontroller.firstTwoDigit.text.isEmpty
                        ? '-'
                        : rcontroller.firstTwoDigit.text,
                  ),
                  const SizedBox(width: 6),
                  _segment(rcontroller.persianalhpabet.value),
                  const SizedBox(width: 6),
                  _segment(
                    rcontroller.threeDigit.text.isEmpty
                        ? '-'
                        : rcontroller.threeDigit.text,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '/',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _segment(
                    rcontroller.lastTwoDigit.text.isEmpty
                        ? '-'
                        : rcontroller.lastTwoDigit.text,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _segment(String value) {
    return Container(
      height: 28,
      width: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
