// Pont entre N-OS Center et la CLI `nos`
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import '../models/doctor_report.dart';

class NosCli {
  NosCli({this.executable = 'nos'});

  /// Chemin de la CLI. En développement : NOS_BIN=/chemin/vers/apps/nos-cli/bin/nos
  final String executable;

  String get _bin => Platform.environment['NOS_BIN'] ?? executable;

  Future<ProcessResult> _run(List<String> args) =>
      Process.run(_bin, args, environment: {'NO_COLOR': '1'});

  Future<DoctorReport> doctor({String? only}) async {
    final args = ['doctor', '--json', '--no-fail'];
    if (only != null) args.addAll(['--check', only]);
    final result = await _run(args);
    if (result.exitCode != 0) {
      throw NosCliException('nos doctor a échoué : ${result.stderr}');
    }
    return DoctorReport.fromJson(
      jsonDecode(result.stdout as String) as Map<String, dynamic>,
    );
  }

  Future<DoctorReport> repair({String? only}) async {
    final args = ['doctor', '--repair', '--json', '--no-fail'];
    if (only != null) args.addAll(['--check', only]);
    final result = await _run(args);
    return DoctorReport.fromJson(
      jsonDecode(result.stdout as String) as Map<String, dynamic>,
    );
  }

  /// Lit le catalogue TSV (id, catégorie, description, méthode, spec, exécutable).
  Future<List<CatalogEntry>> catalog() async {
    final candidates = [
      Platform.environment['NOS_CATALOG'],
      '/usr/share/nos/catalog.tsv',
      '${Directory.current.path}/../nos-cli/share/catalog.tsv',
    ].whereType<String>();
    for (final path in candidates) {
      final file = File(path);
      if (await file.exists()) {
        final lines = await file.readAsLines();
        return lines
            .where((l) => l.isNotEmpty && !l.startsWith('#'))
            .map((l) => l.split('\t'))
            .where((c) => c.length >= 6)
            .map(CatalogEntry.fromColumns)
            .toList();
      }
    }
    throw NosCliException('catalog.tsv introuvable');
  }

  Future<bool> isInstalled(String executable) async {
    final result = await Process.run('which', [executable]);
    return result.exitCode == 0;
  }

  /// Lance une commande longue (install, sdk, ai) et diffuse la sortie.
  Stream<String> stream(List<String> args) async* {
    final process = await Process.start(_bin, args, environment: {'NO_COLOR': '1'});
    await for (final line in process.stdout.transform(utf8.decoder).transform(const LineSplitter())) {
      yield line;
    }
    await for (final line in process.stderr.transform(utf8.decoder).transform(const LineSplitter())) {
      yield line;
    }
    final code = await process.exitCode;
    yield code == 0 ? '✔ Terminé.' : '✘ Échec (code $code).';
  }

  Future<String> text(List<String> args) async {
    final result = await _run(args);
    return '${result.stdout}${result.stderr}';
  }
}

class NosCliException implements Exception {
  NosCliException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CatalogEntry {
  CatalogEntry({
    required this.id,
    required this.category,
    required this.description,
    required this.method,
    required this.spec,
    required this.executable,
  });

  factory CatalogEntry.fromColumns(List<String> c) => CatalogEntry(
        id: c[0],
        category: c[1],
        description: c[2],
        method: c[3],
        spec: c[4],
        executable: c[5],
      );

  final String id;
  final String category;
  final String description;
  final String method;
  final String spec;
  final String executable;
}
