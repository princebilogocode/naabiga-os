// Page IA — assistants (Claude Code, Gemini CLI, Ollama, Aider, OpenCode, Continue, Copilot)
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../services/nos_cli.dart';
import 'output_sheet.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  final _cli = NosCli();

  static const _tools = <(String, String, String, String)>[
    ('claude', 'Claude Code', 'Agent de codage Anthropic dans le terminal', 'claude'),
    ('gemini', 'Gemini CLI', 'Agent de codage Google', 'gemini'),
    ('ollama', 'Ollama', 'Modèles de langage locaux (Llama, Mistral, Qwen…)', 'ollama'),
    ('aider', 'Aider', 'Pair-programming IA sur votre dépôt Git', 'aider'),
    ('opencode', 'OpenCode', 'Agent de codage open source', 'opencode'),
    ('continue', 'Continue', 'Extension VS Code : chat et autocomplétion', 'code'),
    ('copilot', 'GitHub Copilot CLI', 'Assistant GitHub dans le terminal', 'copilot'),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Assistants IA')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList.builder(
            itemCount: _tools.length,
            itemBuilder: (context, i) {
              final (id, name, desc, exe) = _tools[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: Text(name),
                  subtitle: Text(desc),
                  trailing: FutureBuilder<bool>(
                    future: _cli.isInstalled(exe),
                    builder: (context, snap) {
                      final installed = snap.data ?? false;
                      return installed
                          ? OutlinedButton(
                              onPressed: () => showOutputSheet(context,
                                  title: 'nos ai remove $id',
                                  stream: _cli.stream(['ai', 'remove', id]),
                                  onDone: () => setState(() {})),
                              child: const Text('Désinstaller'),
                            )
                          : FilledButton(
                              onPressed: () => showOutputSheet(context,
                                  title: 'nos ai install $id',
                                  stream: _cli.stream(['ai', 'install', id]),
                                  onDone: () => setState(() {})),
                              child: const Text('Installer'),
                            );
                    },
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
