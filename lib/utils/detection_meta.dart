import 'package:amnban/models/cameraClass.dart';

/// Presentation-only derivations of a detection record.
///
/// Shared by the detection row, the inline mini table, the detail view and
/// the reports table so every screen shows the same values.
class DetectionMeta {
  const DetectionMeta._();

  /// Province of a detection — `None` / empty falls back to خوزستان.
  static String province(String? value) {
    if (value == null || value.trim().isEmpty || value == 'None') {
      return 'خوزستان';
    }
    return value;
  }

  /// City of a detection — `None` / empty falls back to اهواز.
  static String city(String? value) {
    if (value == null || value.trim().isEmpty || value == 'None') {
      return 'اهواز';
    }
    return value;
  }

  /// Car type derived from the plate itself (same rules as the legacy code).
  static String carType(String? plate) {
    final value = plate ?? '';
    if (value.contains('x')) return 'تاکسی';
    if (value.contains(RegExp(r'(?<![A-Za-z])A(?![A-Za-z])'))) return 'دولتی';
    if (value.contains('EIN')) return 'کامیون';
    return 'شخصی';
  }

  /// Direction of the camera that produced the detection.
  static String direction(String? rtPath, List<CameraClass> cameras) {
    if (rtPath == null || rtPath.isEmpty) return 'ورود';
    for (final camera in cameras) {
      if (camera.path == rtPath) {
        return (camera.gate ?? 'entre') == 'entre' ? 'ورودی' : 'خروجی';
      }
    }
    return 'ورودی';
  }

  /// Direction label for a camera itself.
  static String cameraDirection(CameraClass camera) =>
      (camera.gate ?? 'entre') == 'entre' ? 'ورودی' : 'خروجی';
}

/// Iranian provinces (used by the reports filter).
const List<String> kIranProvinces = [
  'آذربایجان شرقی',
  'آذربایجان غربی',
  'اردبیل',
  'اصفهان',
  'البرز',
  'ایلام',
  'بوشهر',
  'تهران',
  'چهارمحال و بختیاری',
  'خراسان جنوبی',
  'خراسان رضوی',
  'خراسان شمالی',
  'خوزستان',
  'زنجان',
  'سمنان',
  'سیستان و بلوچستان',
  'فارس',
  'قزوین',
  'قم',
  'کردستان',
  'کرمان',
  'کرمانشاه',
  'کهگیلویه و بویراحمد',
  'گلستان',
  'گیلان',
  'لرستان',
  'مازندران',
  'مرکزی',
  'هرمزگان',
  'همدان',
  'یزد',
];

/// Major Iranian cities (used by the reports filter).
const List<String> kIranCities = [
  'آبادان',
  'آزادان',
  'اراک',
  'اردبیل',
  'ارومیه',
  'اصفهان',
  'اهواز',
  'بندرعباس',
  'بوشهر',
  'بیرجند',
  'تبریز',
  'تهران',
  'خرم آباد',
  'رشت',
  'زاهدان',
  'زنجان',
  'ساری',
  'سمنان',
  'شیراز',
  'قزوین',
  'قم',
  'کرج',
  'کرمان',
  'کرمانشاه',
  'گرگان',
  'مشهد',
  'همدان',
  'یزد',
];
