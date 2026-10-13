// lib/screens/comunidad_gate_screen.dart
//
// Decide qué pantalla mostrar tras el login: onboarding si el usuario no
// tiene ninguna comunidad todavía, o el shell principal si ya la tiene.
import 'package:flutter/material.dart';

import '../services/comunidad_service.dart';
import 'home_shell_screen.dart';
import 'onboarding_comunidad_screen.dart';

class ComunidadGateScreen extends StatelessWidget {
  const ComunidadGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: ComunidadService.streamComunidadActivaId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final comunidadId = snapshot.data;
        if (comunidadId == null) return const OnboardingComunidadScreen();
        return HomeShellScreen(comunidadId: comunidadId);
      },
    );
  }
}
