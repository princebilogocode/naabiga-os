// Modèle du rapport JSON de N-OS Doctor
// SPDX-License-Identifier: GPL-3.0-or-later

enum CheckStatus { ok, warn, fail }

class DoctorCheck {
  DoctorCheck({
    required this.id,
    required this.label,
    required this.category,
    required this.status,
    required this.message,
    required this.hint,
    required this.repaired,
  });

  factory DoctorCheck.fromJson(Map<String, dynamic> json) => DoctorCheck(
        id: json['id'] as String,
        label: json['label'] as String,
        category: json['category'] as String,
        status: switch (json['status'] as String) {
          'ok' => CheckStatus.ok,
          'warn' => CheckStatus.warn,
          _ => CheckStatus.fail,
        },
        message: json['message'] as String? ?? '',
        hint: json['hint'] as String? ?? '',
        repaired: json['repaired'] as bool? ?? false,
      );

  final String id;
  final String label;
  final String category;
  final CheckStatus status;
  final String message;
  final String hint;
  final bool repaired;
}

class DoctorReport {
  DoctorReport({
    required this.nosVersion,
    required this.system,
    required this.date,
    required this.ok,
    required this.warn,
    required this.fail,
    required this.checks,
  });

  factory DoctorReport.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;
    return DoctorReport(
      nosVersion: json['nos_version'] as String? ?? '',
      system: json['system'] as String? ?? '',
      date: json['date'] as String? ?? '',
      ok: summary['ok'] as int,
      warn: summary['warn'] as int,
      fail: summary['fail'] as int,
      checks: (json['checks'] as List<dynamic>)
          .map((c) => DoctorCheck.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  final String nosVersion;
  final String system;
  final String date;
  final int ok;
  final int warn;
  final int fail;
  final List<DoctorCheck> checks;

  int get total => checks.length;

  Map<String, List<DoctorCheck>> get byCategory {
    final map = <String, List<DoctorCheck>>{};
    for (final c in checks) {
      map.putIfAbsent(c.category, () => []).add(c);
    }
    return map;
  }
}
