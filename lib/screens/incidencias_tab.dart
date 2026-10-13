// lib/screens/incidencias_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/comunidad.dart';
import '../models/incidencia.dart';
import '../services/incidencia_service.dart';
import '../theme/design_tokens.dart';
import 'incidencia_detail_screen.dart';
import 'nueva_incidencia_screen.dart';

class IncidenciasTab extends StatelessWidget {
  const IncidenciasTab({required this.comunidad, super.key});

  final Comunidad comunidad;

  @override
  Widget build(BuildContext context) {
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
            const Text('Incidencias'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NuevaIncidenciaScreen(comunidad: comunidad))),
        icon: const Icon(Icons.add),
        label: const Text('Incidencia'),
      ),
      body: StreamBuilder<List<Incidencia>>(
        stream: IncidenciaService.streamIncidencias(comunidad.id),
        builder: (context, snapshot) {
          final incidencias = snapshot.data ?? [];
          if (incidencias.isEmpty) {
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
                      child: Icon(Icons.report_problem_outlined, size: 32, color: context.colors.brand),
                    ),
                    const SizedBox(height: 16),
                    Text('Todavía no hay incidencias reportadas.', textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkMuted)),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            children: incidencias.map((i) => _IncidenciaCard(comunidad: comunidad, incidencia: i)).toList(),
          );
        },
      ),
    );
  }
}

class _IncidenciaCard extends StatelessWidget {
  const _IncidenciaCard({required this.comunidad, required this.incidencia});

  final Comunidad comunidad;
  final Incidencia incidencia;

  (Color, IconData) get _estiloEstado => switch (incidencia.estado) {
        EstadoIncidencia.abierta => (Colors.orange, Icons.radio_button_unchecked),
        EstadoIncidencia.enProgreso => (Colors.blue, Icons.autorenew),
        EstadoIncidencia.resuelta => (Colors.green, Icons.check_circle_outline),
      };

  @override
  Widget build(BuildContext context) {
    final (color, icono) = _estiloEstado;
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(VecindRadius.md),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IncidenciaDetailScreen(comunidad: comunidad, incidencia: incidencia))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(VecindRadius.sm)),
                child: incidencia.fotoUrl != null
                    ? Image.network(incidencia.fotoUrl!, fit: BoxFit.cover)
                    : Icon(Icons.report_problem_outlined, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(incidencia.titulo, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      [if (incidencia.ubicacion != null) incidencia.ubicacion!, if (incidencia.createdAt != null) DateFormat('d MMM', 'es_ES').format(incidencia.createdAt!)].join(' · '),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(icono, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(nombreEstadoIncidencia(incidencia.estado), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
