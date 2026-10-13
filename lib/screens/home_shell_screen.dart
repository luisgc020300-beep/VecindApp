// lib/screens/home_shell_screen.dart
import 'package:flutter/material.dart';

import '../models/comunidad.dart';
import '../services/comunidad_service.dart';
import 'avisos_tab.dart';
import 'incidencias_tab.dart';
import 'perfil_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({required this.comunidadId, super.key});

  final String comunidadId;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _index = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) => setState(() => _index = i);
  void _cambiarPestana(int i) => _pageController.jumpToPage(i);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Comunidad>(
      stream: ComunidadService.streamComunidad(widget.comunidadId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final comunidad = snapshot.data!;
        final tabs = [
          _KeepAlivePage(child: AvisosTab(comunidad: comunidad)),
          _KeepAlivePage(child: IncidenciasTab(comunidad: comunidad)),
          _KeepAlivePage(child: PerfilScreen(comunidad: comunidad)),
        ];
        return Scaffold(
          body: PageView(controller: _pageController, onPageChanged: _onPageChanged, children: tabs),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: _cambiarPestana,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: 'Avisos'),
              BottomNavigationBarItem(icon: Icon(Icons.report_problem_outlined), activeIcon: Icon(Icons.report_problem), label: 'Incidencias'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
        );
      },
    );
  }
}

class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});
  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
