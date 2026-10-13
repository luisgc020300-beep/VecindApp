// lib/screens/onboarding_comunidad_screen.dart
//
// Un único paso: crear una comunidad nueva (quedas como presidente) o
// unirte a una existente con un código de 6 caracteres (quedas como
// vecino). Mismo patrón que onboarding_casa_screen.dart en Repara.
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/comunidad_service.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_error.dart';

class OnboardingComunidadScreen extends StatefulWidget {
  const OnboardingComunidadScreen({super.key});

  @override
  State<OnboardingComunidadScreen> createState() => _OnboardingComunidadScreenState();
}

class _OnboardingComunidadScreenState extends State<OnboardingComunidadScreen> {
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  bool _cargando = false;
  bool _unirse = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      AppError.show(context, 'Escribe un nombre para la comunidad.');
      return;
    }
    setState(() => _cargando = true);
    try {
      await ComunidadService.crearComunidad(nombre: nombre, direccion: _direccionCtrl.text.trim().isEmpty ? null : _direccionCtrl.text.trim());
    } catch (e) {
      if (mounted) AppError.show(context, 'No se pudo crear la comunidad. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _unirseAComunidad() async {
    final codigo = _codigoCtrl.text.trim();
    if (codigo.isEmpty) {
      AppError.show(context, 'Escribe el código de la comunidad.');
      return;
    }
    setState(() => _cargando = true);
    try {
      await ComunidadService.unirseComunidad(codigo);
    } catch (e) {
      if (mounted) AppError.show(context, 'Código no válido o la comunidad ya no existe.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VecindApp'),
        actions: [
          TextButton(onPressed: () => FirebaseAuth.instance.signOut(), child: const Text('Cerrar sesión')),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(VecindSpace.s6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: context.colors.brandTint, shape: BoxShape.circle),
                    child: Icon(Icons.apartment_outlined, size: 30, color: context.colors.brand),
                  ),
                ),
                const SizedBox(height: VecindSpace.s6),
                Text(
                  _unirse ? '¿Cuál es el código de tu comunidad?' : '¿Cómo se llama tu comunidad?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: VecindSpace.s2),
                Text(
                  _unirse
                      ? 'Pídeselo al presidente o a quien ya esté dado de alta.'
                      : 'Por ejemplo: "C/ Pedro Antonio de Alarcón 23" o el nombre con el que la conocéis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.colors.inkMuted),
                ),
                const SizedBox(height: VecindSpace.s6),
                if (_unirse)
                  TextField(
                    controller: _codigoCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'Código de comunidad', prefixIcon: Icon(Icons.key_outlined)),
                  )
                else ...[
                  TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre de la comunidad', prefixIcon: Icon(Icons.edit_outlined))),
                  const SizedBox(height: VecindSpace.s3),
                  TextField(controller: _direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección (opcional)', prefixIcon: Icon(Icons.location_on_outlined))),
                ],
                const SizedBox(height: VecindSpace.s5),
                FilledButton(
                  onPressed: _cargando ? null : (_unirse ? _unirseAComunidad : _crear),
                  child: _cargando
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_unirse ? 'Unirme' : 'Crear comunidad'),
                ),
                const SizedBox(height: VecindSpace.s2),
                TextButton(
                  onPressed: _cargando ? null : () => setState(() => _unirse = !_unirse),
                  child: Text(_unirse ? 'Prefiero crear una comunidad nueva' : 'Ya tengo un código para unirme'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
