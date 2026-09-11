import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nos_center/models/doctor_report.dart';

void main() {
  test('DoctorReport parse la sortie de nos doctor --json', () {
    const raw = '''
{
  "tool": "nos-doctor",
  "nos_version": "1.0.0-alpha.1",
  "system": "Naabiga OS 1.0.0-alpha.1 (Bobo)",
  "date": "2026-09-11T10:00:00Z",
  "summary": {"ok": 1, "warn": 1, "fail": 0, "total": 2},
  "checks": [
    {"id": "git", "label": "Git", "category": "Base", "status": "ok", "message": "git 2.43", "hint": "", "repaired": false},
    {"id": "java", "label": "Java JDK", "category": "Android & Flutter", "status": "warn", "message": "JAVA_HOME non défini", "hint": "nos sdk use java 17", "repaired": false}
  ]
}
''';
    final report = DoctorReport.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(report.total, 2);
    expect(report.ok, 1);
    expect(report.warn, 1);
    expect(report.checks.first.status, CheckStatus.ok);
    expect(report.checks.last.status, CheckStatus.warn);
    expect(report.byCategory.keys, containsAll(['Base', 'Android & Flutter']));
  });
}
