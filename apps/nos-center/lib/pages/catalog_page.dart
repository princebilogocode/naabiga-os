// Page Outils — catalogue nos install
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../services/nos_cli.dart';
import 'output_sheet.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _cli = NosCli();
  late Future<List<CatalogEntry>> _future = _cli.catalog();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CatalogEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return snapshot.hasError
              ? Center(child: Text('${snapshot.error}'))
              : const Center(child: CircularProgressIndicator());
        }
        final entries = snapshot.data!
            .where((e) => _query.isEmpty || e.id.contains(_query) || e.description.toLowerCase().contains(_query))
            .toList();
        final categories = <String, List<CatalogEntry>>{};
        for (final e in entries) {
          categories.putIfAbsent(e.category, () => []).add(e);
        }
        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Outils'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: SearchBar(
                    hintText: 'Rechercher un outil (flutter, docker, chrome…)',
                    leading: const Icon(Icons.search),
                    onChanged: (v) => setState(() => _query = v.toLowerCase()),
                  ),
                ),
              ),
            ),
            for (final entry in categories.entries) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 360,
                    mainAxisExtent: 120,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: entry.value.length,
                  itemBuilder: (context, i) => _ToolCard(entry: entry.value[i], cli: _cli, onChanged: () {
                    setState(() => _future = _cli.catalog());
                  }),
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

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.entry, required this.cli, required this.onChanged});
  final CatalogEntry entry;
  final NosCli cli;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(entry.id, style: Theme.of(context).textTheme.titleSmall)),
                FutureBuilder<bool>(
                  future: cli.isInstalled(entry.executable),
                  builder: (context, snap) {
                    final installed = snap.data ?? false;
                    return installed
                        ? const Icon(Icons.check_circle, color: Color(0xFF198754), size: 20)
                        : IconButton(
                            tooltip: 'Installer',
                            icon: const Icon(Icons.download),
                            onPressed: () => showOutputSheet(
                              context,
                              title: 'Installation : ${entry.id}',
                              stream: cli.stream(['install', entry.id]),
                              onDone: onChanged,
                            ),
                          );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(entry.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            Text(entry.method, style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
