// lib/screens/nueva_incidencia_screen.dart
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/comunidad.dart';
import '../models/incidencia.dart';
import '../services/incidencia_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_error.dart';
import '../widgets/ios_list.dart';

class NuevaIncidenciaScreen extends StatefulWidget {
  const NuevaIncidenciaScreen({required this.comunidad, super.key});
  final Comunidad comunidad;

  @override
  State<NuevaIncidenciaScreen> createState() => _NuevaIncidenciaScreenState();
}

class _NuevaIncidenciaScreenState extends State<NuevaIncidenciaScreen> {
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  File? _foto;
  bool _guardando = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final picker = ImagePicker();
    final foto = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(VecindSpace.s4, VecindSpace.s2, VecindSpace.s4, VecindSpace.s4),
          child: IosSection(
            rows: [
              IosRow(
                icon: Icons.photo_camera_outlined,
                iconColor: Colors.blue,
                title: 'Hacer una foto',
                onTap: () async {
                  final navigator = Navigator.of(ctx);
                  final imagen = await picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1600, maxHeight: 1600);
                  if (!ctx.mounted) return;
                  navigator.pop(imagen);
                },
              ),
              IosRow(
                icon: Icons.photo_library_outlined,
                iconColor: Colors.purple,
                title: 'Elegir de la galería',
                onTap: () async {
                  final navigator = Navigator.of(ctx);
                  final imagen = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1600, maxHeight: 1600);
                  if (!ctx.mounted) return;
                  navigator.pop(imagen);
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (foto != null) setState(() => _foto = File(foto.path));
  }

  Future<void> _guardar() async {
    final titulo = _tituloCtrl.text.trim();
    if (titulo.isEmpty) {
      AppError.show(context, 'Escribe un título para la incidencia.');
      return;
    }
    setState(() => _guardando = true);
    final user = FirebaseAuth.instance.currentUser;
    try {
      String? fotoUrl;
      if (_foto != null) {
        fotoUrl = await IncidenciaService.subirFoto(widget.comunidad.id, _foto!);
      }
      await IncidenciaService.crear(
        widget.comunidad.id,
        Incidencia(
          id: '',
          titulo: titulo,
          descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
          ubicacion: _ubicacionCtrl.text.trim().isEmpty ? null : _ubicacionCtrl.text.trim(),
          fotoUrl: fotoUrl,
          estado: EstadoIncidencia.abierta,
          creadoPorUid: user?.uid ?? '',
          creadoPorNombre: user?.email?.split('@').first ?? 'Vecino',
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) AppError.show(context, 'No se pudo guardar la incidencia.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva incidencia')),
      body: ListView(
        padding: const EdgeInsets.all(VecindSpace.s5),
        children: [
          TextField(controller: _tituloCtrl, decoration: const InputDecoration(labelText: 'Título (p.ej. Luz del portal fundida)')),
          const SizedBox(height: VecindSpace.s3),
          TextField(controller: _ubicacionCtrl, decoration: const InputDecoration(labelText: 'Ubicación (opcional)', hintText: 'p.ej. Portal 2, garaje')),
          const SizedBox(height: VecindSpace.s3),
          TextField(controller: _descripcionCtrl, minLines: 2, maxLines: 5, decoration: const InputDecoration(labelText: 'Descripción (opcional)')),
          const SizedBox(height: VecindSpace.s4),
          if (_foto != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(VecindRadius.md),
              child: Image.file(_foto!, height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
          const SizedBox(height: VecindSpace.s2),
          OutlinedButton.icon(
            onPressed: _elegirFoto,
            icon: const Icon(Icons.add_a_photo_outlined, size: 18),
            label: Text(_foto == null ? 'Añadir foto' : 'Cambiar foto'),
          ),
          const SizedBox(height: VecindSpace.s6),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: _guardando
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Reportar incidencia'),
          ),
        ],
      ),
    );
  }
}
