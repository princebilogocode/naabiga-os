// Feuille affichant la sortie d'une commande nos en temps réel
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

Future<void> showOutputSheet(
  BuildContext context, {
  required String title,
  required Stream<String> stream,
  VoidCallback? onDone,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _OutputSheet(title: title, stream: stream),
  );
  onDone?.call();
}

class _OutputSheet extends StatefulWidget {
  const _OutputSheet({required this.title, required this.stream});
  final String title;
  final Stream<String> stream;

  @override
  State<_OutputSheet> createState() => _OutputSheetState();
}

class _OutputSheetState extends State<_OutputSheet> {
  final _lines = <String>[];
  final _scroll = ScrollController();
  bool _done = false;

  @override
  void initState() {
    super.initState();
    widget.stream.listen(
      (line) {
        setState(() => _lines.add(line));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
        });
      },
      onDone: () => setState(() => _done = true),
      onError: (Object e) => setState(() {
        _lines.add('✘ $e');
        _done = true;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title),
            trailing: _done
                ? FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))
                : const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                controller: _scroll,
                itemCount: _lines.length,
                itemBuilder: (context, i) => Text(
                  _lines[i],
                  style: const TextStyle(fontFamily: 'JetBrains Mono', color: Color(0xFFF5F5F5), fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
