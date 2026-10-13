// lib/screens/incidencia_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/comunidad.dart';
import '../models/incidencia.dart';
import '../services/incidencia_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_error.dart';

class IncidenciaDetailScreen extends StatelessWidget {
  const IncidenciaDetailScreen({required this.comunidad, required this.incidencia, super.key});

  final Comunidad comunidad;
  final Incidencia incidencia;

  Future<void> _cambiarEstado(BuildContext context, EstadoIncidencia estado) async {
    try {
      await IncidenciaService.cambiarEstado(comunidad.id, incidencia.id, estado);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) AppError.show(context, 'No se pudo actualizar el estado.');
    }
  }

  Future<void> _eliminar(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar esta incidencia?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await IncidenciaService.eliminar(comunidad.id, incidencia.id);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) AppError.show(context, 'No se pudo eliminar la incidencia.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(incidencia.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _eliminar(context))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(VecindSpace.s5),
        children: [
          if (incidencia.fotoUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(VecindRadius.md),
              child: Image.network(incidencia.fotoUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: VecindSpace.s4),
          ],
          if (incidencia.ubicacion != null) ...[
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: context.colors.inkMuted),
                const SizedBox(width: 4),
                Text(incidencia.ubicacion!, style: TextStyle(color: context.colors.inkMuted)),
              ],
            ),
            const SizedBox(height: VecindSpace.s2),
          ],
          if (incidencia.descripcion != null) ...[
            Text(incidencia.descripcion!, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: VecindSpace.s2),
          ],
          Text(
            [incidencia.creadoPorNombre, if (incidencia.createdAt != null) DateFormat('d MMMM yyyy', 'es_ES').format(incidencia.createdAt!)].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: VecindSpace.s6),
          Text('Estado', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: VecindSpace.s3),
          Wrap(
            spacing: VecindSpace.s2,
            children: EstadoIncidencia.values.map((e) {
              return ChoiceChip(
                label: Text(nombreEstadoIncidencia(e)),
                selected: incidencia.estado == e,
                onSelected: (_) => _cambiarEstado(context, e),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
