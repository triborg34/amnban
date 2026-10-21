import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/screens/details_screen.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/iran_plate.dart';
import 'package:amnban/widgets/status_chip.dart';
import 'package:flutter/material.dart';

import 'package:persian_number_utility/persian_number_utility.dart';

/// Shared "today's plates" list dialog (was duplicated in
/// home_sceen.dart and details_screen.dart).
Future<dynamic> showAmarDialog(
  BuildContext context,
  List<databaseClass> data,
  knowPersonController kcontroller,
) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 460),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppSectionTitle(
                    title: 'لیست پلاک های امروز',
                    icon: Icons.list_alt_outlined,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: data.isEmpty
                        ? const AppEmptyState(message: 'رکوردی وجود ندارد')
                        : ListView.separated(
                            itemCount: data.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final entry = data[index];
                              final person =
                                  kcontroller.personFor(entry.plateNum);
                              return InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  final plate = entry.plateNum ?? '';
                                  if (plate.isEmpty) return;
                                  try {
                                    final record = await pb
                                        .collection('database')
                                        .getFullList(
                                          filter:
                                              'plateNum="${pbEscape(plate)}"',
                                        )
                                        .timeout(const Duration(seconds: 15));

                                    if (!context.mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Detailedscreen(
                                          rec: record,
                                          selectedModel: entry,
                                          index: index,
                                          kcontroller: kcontroller,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    appLog('amar detail fetch failed', e);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 96,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: EntryPlate(
                                              entry: entry, height: 32),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 96,
                                        child: Text(
                                          (entry.eDate ?? '')
                                              .toString()
                                              .toPersianDate(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          (entry.eTime ?? '-')
                                              .toString()
                                              .toPersianDigit(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          person?.name ?? '-',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      StatusChip(
                                        status: statusForEntry(
                                            entry, kcontroller),
                                        dense: true,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
