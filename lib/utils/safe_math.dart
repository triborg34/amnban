/// Safe math helpers.
///
/// The ANPR backend occasionally returns values that are `Infinity` or
/// `NaN` (a division by zero on the server, an empty numeric column, …).
/// Calling `toInt()`, `round()` or `toStringAsFixed()` on such a value throws
/// `Unsupported operation: Infinity`, so every conversion goes through these
/// helpers instead.
library;

/// Safe division — returns `0.0` when the divisor is zero or not finite.
double safeRatio(num a, num b) =>
    (b == 0 || !b.isFinite) ? 0.0 : a / b;

/// Safe conversion to `int` — non finite values become `0`.
int safeInt(num v) => (v.isFinite) ? v.toInt() : 0;

/// Safe percentage — `a` as a percentage of `b`.
double safePercent(num a, num b) => safeRatio(a, b) * 100;

/// Safe fixed-point string — never throws, never prints `Infinity`/`NaN`.
String safeFixed(
  num value, {
  int digits = 1,
  String fallback = '۰',
}) {
  if (!value.isFinite) return fallback;
  return value.toStringAsFixed(digits);
}

/// Safe percentage text, e.g. `۶۲.۳٪`.
///
/// When the total is missing the [fallback] (`-`) is returned instead of a
/// misleading `0٪`.
String safePercentText(
  num value,
  num total, {
  int digits = 1,
  String fallback = '-',
}) {
  if (!value.isFinite || !total.isFinite || total == 0) return fallback;
  final percent = safePercent(value, total);
  if (!percent.isFinite) return fallback;
  return '${percent.toStringAsFixed(digits)}٪';
}
