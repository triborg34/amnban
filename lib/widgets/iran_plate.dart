import 'package:flutter/material.dart';

import '../models/databaseEntry.dart';
import '../theme/app_colors.dart';
import '../utils/converFunctions.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Iranian style number-plate widget.
///
/// Visual order (left → right) follows the reference DIESPI screenshots:
/// `[IR IRAN strip] [2 digits] [letter] [3 digits] [ایران + 2 digits]`
///
/// Arvand (free zone) plates are rendered as a plain white plate with the
/// same blue strip and the digits split in two groups.
class IranPlate extends StatelessWidget {
  const IranPlate({
    super.key,
    required this.plate,
    this.isArvand = false,
    this.height = 40,
    this.showIranLabel = true,
    this.highlight = false,
  });

  final String plate;
  final bool isArvand;
  final double height;
  final bool showIranLabel;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final raw = plate.trim();
    if (raw.isEmpty) {
      return _EmptyPlate(height: height);
    }

    final fontSize = (height * 0.34).clamp(9.0, 22.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.plateBorder, width: 1.2),
      ),
      child: Directionality(
        // The plate itself is a fixed physical layout, always left to right.
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IranStrip(height: height),
            if (isArvand)
              ..._arvandSegments(raw, fontSize)
            else
              ..._normalSegments(raw, fontSize, showIranLabel),
          ],
        ),
      ),
    );
  }

  List<Widget> _normalSegments(String raw, double fontSize, bool iranLabel) {
    final tokenized = tokenizePlate(raw, alphabetP2);
    if (tokenized.length < 8) {
      return [_text(tokenized.toPersianDigit(), fontSize)];
    }
    final two = tokenized.substring(0, 2);
    final letter = tokenized.substring(2, 3);
    final three = tokenized.substring(3, 6);
    final iran = tokenized.substring(6, 8);

    return [
      _text(two.toPersianDigit(), fontSize),
      _text(letter, fontSize, wide: true),
      _text(three.toPersianDigit(), fontSize),
      _iranBox(iran.toPersianDigit(), fontSize, iranLabel),
    ];
  }

  List<Widget> _arvandSegments(String raw, double fontSize) {
    final digits = raw.replaceAll(RegExp(r'[^0-9۰-۹]'), '');
    if (digits.length <= 5) {
      return [_text(digits.toPersianDigit(), fontSize)];
    }
    final head = digits.substring(0, digits.length - 2);
    final tail = digits.substring(digits.length - 2);
    return [
      _text(head.toPersianDigit(), fontSize),
      _text(tail.toPersianDigit(), fontSize),
    ];
  }

  Widget _text(String value, double fontSize, {bool wide = false}) {
    return Container(
      constraints: BoxConstraints(minWidth: wide ? 26 : 22),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      child: Text(
        value,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.1,
          fontWeight: FontWeight.w600,
          color: AppColors.plateBorder,
        ),
      ),
    );
  }

  Widget _iranBox(String value, double fontSize, bool showLabel) {
    return Container(
      constraints: const BoxConstraints(minWidth: 34),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.plateBorder, width: 1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLabel)
            Text(
              'ایران',
              style: TextStyle(
                fontSize: fontSize * 0.55,
                height: 1.1,
                color: AppColors.plateBorder,
              ),
            ),
          Text(
            value,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: AppColors.plateBorder,
            ),
          ),
        ],
      ),
    );
  }
}

/// The blue "IR IRAN" band on the left side of every Iranian plate.
class _IranStrip extends StatelessWidget {
  const _IranStrip({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: height,
      color: AppColors.plateBlue,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              child: Image.asset(
                'assets/images/iranFlag.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          const Text(
            'IR',
            style: TextStyle(
              fontSize: 8,
              height: 1.05,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'IRAN',
            style: TextStyle(
              fontSize: 8,
              height: 1.05,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlate extends StatelessWidget {
  const _EmptyPlate({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 90,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        '-',
        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
      ),
    );
  }
}

/// Convenience wrapper that picks the right flavour for the entry type.
class EntryPlate extends StatelessWidget {
  const EntryPlate({
    super.key,
    required this.entry,
    this.height = 40,
    this.showIranLabel = true,
  });

  final databaseClass entry;
  final double height;
  final bool showIranLabel;

  @override
  Widget build(BuildContext context) {
    return IranPlate(
      plate: entry.plateNum ?? '',
      isArvand: entry.isarvand == 'arvand',
      height: height,
      showIranLabel: showIranLabel,
    );
  }
}
