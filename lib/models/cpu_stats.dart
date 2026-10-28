// lib/models/cpu_stats.dart
class CpuStats {
  final double load;
  final List<double> perCore;
  final int cores;
  final int? freqMhz;
  final double ramPercent;
  final String model;

  const CpuStats({
    required this.load,
    required this.perCore,
    required this.cores,
    required this.freqMhz,
    required this.ramPercent,
    required this.model,
  });

  factory CpuStats.fromJson(Map<String, dynamic> json) {
    return CpuStats(
      load: (json['load'] as num).toDouble(),
      perCore: (json['per_core'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
      cores: json['cores'] as int,
      freqMhz: json['freq_mhz'] as int?,
      ramPercent: (json['ram_percent'] as num).toDouble(),
      model: json['model'] as String? ?? '',
    );
  }
}