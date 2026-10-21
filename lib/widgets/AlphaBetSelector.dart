import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bottom sheet that lets the user pick the letter of a plate.
class Alphabetselector extends StatelessWidget {
  ScrollController scrollController;
  Alphabetselector({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'انتخاب حرف پلاک',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: plateAlphabet.length,
              itemBuilder: (context, index) {
                final letter = plateAlphabet.values.toList()[index];

                return GestureDetector(
                  onTap: () {
                    Get.find<reportController>().persianalhpabet.value = letter;
                    Get.find<reportController>().engishalphabet.value =
                        plateAlphabet.keys.toList()[index];

                    Get.find<knowPersonController>().persianAlhpabet.value =
                        letter;
                    Get.find<knowPersonController>().engishAlphabet.value =
                        plateAlphabet.keys.toList()[index];

                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
