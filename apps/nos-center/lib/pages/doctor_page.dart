// Page Doctor : état de l'environnement de développement
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../models/doctor_report.dart';
import '../services/nos_cli.dart';
import '../theme.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  final _cli = NosCli();
  Future<DoctorReport>? _future;
  bool _repairing = false;

  @override
  void initState() {
    super.initState();
    _future = _cli.doctor();
  }

  void _refresh() => setState(() => _future = _cli.doctor());

  Future<void> _repairAll() async {
    setState(() => _repairing = true);
    try {
      final report = await _cli.repair();
      setState(() => _future = Future.value(report));
    } finally {
      if (mounted) setState(() => _repairing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DoctorReport>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(message: '${snapshot.error}', onRetry: _refresh);
        }
        final report = snapshot.data!;
        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('N-OS Doctor'),
              actions: [
                IconButton(
                  tooltip: 'Relancer',
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FilledButton.icon(
                    onPressed: _repairing || (report.fail == 0 && report.warn == 0) ? null : _repairAll,
                    icon: _repairing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.build),
                    label: const Text('Réparer'),
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Pill(color: NosColors.green, label: '${report.ok} OK'),
                    _Pill(color: NosColors.gold, label: '${report.warn} avertissement(s)', dark: true),
                    _Pill(color: NosColors.red, label: '${report.fail} échec(s)'),
                    Chip(label: Text('${report.system} · N-OS ${report.nosVersion}')),
                  ],
                ),
              ),
            ),
            for (final entry in report.byCategory.entries) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(entry.key, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: NosColors.gold)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.builder(
                  itemCount: entry.value.length,
                  itemBuilder: (context, i) => _CheckTile(check: entry.value[i], onRepaired: _refresh),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      },
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({required this.check, required this.onRepaired});
  final DoctorCheck check;
  final VoidCallback onRepaired;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (check.status) {
      CheckStatus.ok => (Icons.check_circle, NosColors.green),
      CheckStatus.warn => (Icons.warning_amber_rounded, NosColors.gold),
      CheckStatus.fail => (Icons.cancel, NosColors.red),
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(check.label),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(check.message),
            if (check.status != CheckStatus.ok && check.hint.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('→ ${check.hint}', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
              ),
          ],
        ),
        trailing: check.repaired ? const Chip(label: Text('réparé')) : null,
        isThreeLine: check.status != CheckStatus.ok && check.hint.isNotEmpty,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.color, required this.label, this.dark = false});
  final Color color;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: dark ? NosColors.black : NosColors.white, fontWeight: FontWeight.w600)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: NosColors.red),
          const SizedBox(height: 12),
          Text('Impossible de lancer la CLI nos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
