// N-OS Center — centre logiciel graphique de Naabiga OS
// Copyright (C) 2026 ICONEDOR — Burkina Faso
// SPDX-License-Identifier: GPL-3.0-or-later
//
// L'application est une interface au-dessus de la CLI `nos` :
//   - Doctor  : `nos doctor --json`
//   - Outils  : catalogue `catalog.tsv` + `nos install <id>`
//   - SDK     : `nos sdk list` / `nos sdk install|use`
//   - IA      : `nos ai list` / `nos ai install`

import 'package:flutter/material.dart';

import 'pages/ai_page.dart';
import 'pages/catalog_page.dart';
import 'pages/doctor_page.dart';
import 'pages/profiles_page.dart';
import 'pages/sdk_page.dart';
import 'theme.dart';

void main() {
  runApp(const NosCenterApp());
}

class NosCenterApp extends StatelessWidget {
  const NosCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'N-OS Center',
      debugShowCheckedModeBanner: false,
      theme: NosTheme.light(),
      darkTheme: NosTheme.dark(),
      themeMode: ThemeMode.system,
      home: const NosCenterHome(),
    );
  }
}

class NosCenterHome extends StatefulWidget {
  const NosCenterHome({super.key});

  @override
  State<NosCenterHome> createState() => _NosCenterHomeState();
}

class _NosCenterHomeState extends State<NosCenterHome> {
  int _index = 0;

  static const _destinations = <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.health_and_safety_outlined),
      selectedIcon: Icon(Icons.health_and_safety),
      label: Text('Doctor'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.apps_outlined),
      selectedIcon: Icon(Icons.apps),
      label: Text('Outils'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.layers_outlined),
      selectedIcon: Icon(Icons.layers),
      label: Text('SDK'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome),
      label: Text('IA'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.workspaces_outlined),
      selectedIcon: Icon(Icons.workspaces),
      label: Text('Profils'),
    ),
  ];

  static const _pages = <Widget>[
    DoctorPage(),
    CatalogPage(),
    SdkPage(),
    AiPage(),
    ProfilesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Image.asset('assets/logo.png', width: 48, height: 48),
                  const SizedBox(height: 8),
                  Text('N-OS', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            destinations: _destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _pages[_index]),
        ],
      ),
    );
  }
}
