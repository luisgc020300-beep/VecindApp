// lib/screens/avisos_tab.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/aviso.dart';
import '../models/comunidad.dart';
import '../services/aviso_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_error.dart';
import 'nuevo_aviso_sheet.dart';

class AvisosTab extends StatelessWidget {
  const AvisosTab({required this.comunidad, super.key});

  final Comunidad comunidad;

  Future<void> _eliminar(BuildContext context, Aviso aviso) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar este aviso?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await AvisoService.eliminar(comunidad.id, aviso.id);
    } catch (e) {
      if (context.mounted) AppError.show(context, 'No se pudo eliminar el aviso.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final esPresidente = comunidad.esPresidente(uid);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              comunidad.nombre.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: context.colors.inkMuted),
            ),
            const Text('Avisos'),
          ],
        ),
      ),
      floatingActionButton: esPresidente
          ? FloatingActionButton.extended(
              onPressed: () => mostrarNuevoAvisoSheet(context, comunidadId: comunidad.id),
              icon: const Icon(Icons.add),
              label: const Text('Aviso'),
            )
          : null,
      body: StreamBuilder<List<Aviso>>(
        stream: AvisoService.streamAvisos(comunidad.id),
        builder: (context, snapshot) {
          final avisos = snapshot.data ?? [];
          if (avisos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: context.colors.brandTint, shape: BoxShape.circle),
                      child: Icon(Icons.campaign_outlined, size: 32, color: context.colors.brand),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      esPresidente ? 'Todavía no has publicado ningún aviso.' : 'Todavía no hay avisos en tu comunidad.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.inkMuted),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            children: avisos.map((a) => _AvisoCard(aviso: a, puedeEliminar: esPresidente, onEliminar: () => _eliminar(context, a))).toList(),
          );
        },
      ),
    );
  }
}

class _AvisoCard extends StatelessWidget {
  const _AvisoCard({required this.aviso, required this.puedeEliminar, required this.onEliminar});

  final Aviso aviso;
  final bool puedeEliminar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: aviso.fijado ? context.colors.warning.withValues(alpha: 0.12) : context.colors.brandTint,
                borderRadius: BorderRadius.circular(VecindRadius.sm),
              ),
              child: Icon(
                aviso.fijado ? Icons.push_pin_outlined : Icons.campaign_outlined,
                size: 20,
                color: aviso.fijado ? context.colors.warning : context.colors.brand,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aviso.titulo, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(aviso.cuerpo, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  Text(
                    [aviso.creadoPorNombre, if (aviso.createdAt != null) DateFormat('d MMM yyyy', 'es_ES').format(aviso.createdAt!)].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (puedeEliminar)
              IconButton(icon: Icon(Icons.delete_outline, size: 20, color: context.colors.inkMuted), onPressed: onEliminar),
          ],
        ),
      ),
    );
  }
}
