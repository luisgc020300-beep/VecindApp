// lib/screens/nuevo_aviso_sheet.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/aviso.dart';
import '../services/aviso_service.dart';
import '../widgets/app_error.dart';

Future<void> mostrarNuevoAvisoSheet(BuildContext context, {required String comunidadId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _NuevoAvisoForm(comunidadId: comunidadId),
  );
}

class _NuevoAvisoForm extends StatefulWidget {
  const _NuevoAvisoForm({required this.comunidadId});
  final String comunidadId;

  @override
  State<_NuevoAvisoForm> createState() => _NuevoAvisoFormState();
}

class _NuevoAvisoFormState extends State<_NuevoAvisoForm> {
  final _tituloCtrl = TextEditingController();
  final _cuerpoCtrl = TextEditingController();
  bool _fijado = false;
  bool _guardando = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _cuerpoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final titulo = _tituloCtrl.text.trim();
    final cuerpo = _cuerpoCtrl.text.trim();
    if (titulo.isEmpty || cuerpo.isEmpty) {
      AppError.show(context, 'Escribe un título y un mensaje.');
      return;
    }
    setState(() => _guardando = true);
    final user = FirebaseAuth.instance.currentUser;
    try {
      await AvisoService.crear(
        widget.comunidadId,
        Aviso(
          id: '',
          titulo: titulo,
          cuerpo: cuerpo,
          creadoPorUid: user?.uid ?? '',
          creadoPorNombre: user?.email?.split('@').first ?? 'Presidente',
          fijado: _fijado,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) AppError.show(context, 'No se pudo publicar el aviso.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nuevo aviso', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            TextField(controller: _tituloCtrl, decoration: const InputDecoration(labelText: 'Título (p.ej. Corte de agua el jueves)')),
            const SizedBox(height: 12),
            TextField(controller: _cuerpoCtrl, minLines: 2, maxLines: 6, decoration: const InputDecoration(labelText: 'Mensaje')),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fijar arriba'),
              subtitle: const Text('Para algo urgente, como una convocatoria de junta'),
              value: _fijado,
              onChanged: (v) => setState(() => _fijado = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: _guardando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
