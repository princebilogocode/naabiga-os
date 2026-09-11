// Page SDK — versions de Flutter, Java, Node.js, Android SDK
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../services/nos_cli.dart';
import 'output_sheet.dart';

class SdkPage extends StatefulWidget {
  const SdkPage({super.key});

  @override
  State<SdkPage> createState() => _SdkPageState();
}

class _SdkPageState extends State<SdkPage> {
  final _cli = NosCli();
  late Future<String> _future = _cli.text(['sdk', 'list']);

  static const _presets = <(String, String, String)>[
    ('flutter', 'stable', 'Flutter stable (inclut Dart)'),
    ('flutter', 'beta', 'Flutter beta'),
    ('java', '17', 'Java 17 LTS (Temurin)'),
    ('java', '21', 'Java 21 LTS (Temurin)'),
    ('node', 'lts', 'Node.js LTS'),
    ('android', 'latest', 'Android SDK (cmdline-tools, platform-tools, API 34)'),
  ];

  void _refresh() => setState(() => _future = _cli.text(['sdk', 'list']));

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('SDK'),
          actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<String>(
                  future: _future,
                  builder: (context, snap) => SelectableText(
                    snap.data ?? 'Chargement…',
                    style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          sliver: SliverToBoxAdapter(child: Text('Installer', style: Theme.of(context).textTheme.titleMedium)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList.builder(
            itemCount: _presets.length,
            itemBuilder: (context, i) {
              final (sdk, version, label) = _presets[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(label),
                  subtitle: Text('nos sdk install $sdk $version'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => showOutputSheet(context,
                            title: 'nos sdk use $sdk $version',
                            stream: _cli.stream(['sdk', 'use', sdk, version]),
                            onDone: _refresh),
                        child: const Text('Activer'),
                      ),
                      FilledButton(
                        onPressed: () => showOutputSheet(context,
                            title: 'nos sdk install $sdk $version',
                            stream: _cli.stream(['sdk', 'install', sdk, version]),
                            onDone: _refresh),
                        child: const Text('Installer'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
