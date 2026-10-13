// lib/screens/perfil_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/comunidad.dart';
import '../theme/design_tokens.dart';
import '../widgets/ios_list.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({required this.comunidad, super.key});

  final Comunidad comunidad;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final yo = comunidad.members[uid];
    final esPresidente = comunidad.esPresidente(uid);
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          IosSection(
            header: 'Tu comunidad',
            rows: [
              IosRow(icon: Icons.apartment_outlined, iconColor: context.colors.brand, title: comunidad.nombre, subtitle: comunidad.direccion, showChevron: false),
              IosRow(
                icon: Icons.badge_outlined,
                iconColor: Colors.teal,
                title: yo?.displayName ?? 'Tú',
                subtitle: esPresidente ? 'Presidente' : 'Vecino',
                showChevron: false,
              ),
              if (esPresidente)
                IosRow(
                  icon: Icons.key_outlined,
                  iconColor: Colors.purple,
                  title: 'Código para invitar vecinos',
                  subtitle: comunidad.joinCode,
                  showChevron: false,
                ),
            ],
          ),
          IosSection(
            rows: [
              IosRow(
                icon: Icons.logout_outlined,
                iconColor: context.colors.error,
                title: 'Cerrar sesión',
                titleColor: context.colors.error,
                showChevron: false,
                onTap: () => FirebaseAuth.instance.signOut(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
