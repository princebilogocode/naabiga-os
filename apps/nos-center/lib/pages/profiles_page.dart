// Page Profils — dev, bureautique, enseignement supérieur, administration
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

import '../services/nos_cli.dart';
import 'output_sheet.dart';

class ProfilesPage extends StatelessWidget {
  const ProfilesPage({super.key});

  static const _profiles = <(String, String, String, IconData)>[
    ('dev', 'Développement', 'Flutter, Android, Web, DevOps, IA. Optimisations ZRAM, Docker, Android Studio.', Icons.code),
    ('bureautique', 'Bureautique', 'LibreOffice en français, polices Office, PDF/OCR, courriel, scanner, imprimante.', Icons.description_outlined),
    ('education', 'Enseignement supérieur', 'LaTeX, Jupyter, R, Octave, GeoGebra, Zotero, Veyon, mode salle de TP.', Icons.school_outlined),
    ('administration', 'Administration', 'Poste durci, sauvegardes, antivirus, Active Directory, inventaire de parc.', Icons.account_balance_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final cli = NosCli();
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Profils d\'usage')),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Un profil installe en une fois les outils d\'un domaine et applique des optimisations dédiées. Les profils sont cumulables.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisExtent: 180,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _profiles.length,
            itemBuilder: (context, i) {
              final (id, name, desc, icon) = _profiles[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(icon, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(name, style: Theme.of(context).textTheme.titleMedium),
                      ]),
                      const SizedBox(height: 8),
                      Expanded(child: Text(desc)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () => showOutputSheet(
                            context,
                            title: 'nos profile apply $id',
                            stream: cli.stream(['profile', 'apply', id]),
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
