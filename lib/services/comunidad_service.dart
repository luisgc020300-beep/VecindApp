// lib/services/comunidad_service.dart
//
// Crear/unirse a una comunidad vía código, igual de simple que el join
// code de Casa en Repara -- pero aquí la escritura va directa desde el
// cliente (gobernada por firestore.rules), no por Cloud Function: un
// proyecto Spark (gratuito) no puede desplegar Cloud Functions, y no tiene
// sentido forzar el plan de pago (Blaze) para un MVP académico todavía sin
// usuarios reales. Si más adelante se necesita lógica transaccional de
// verdad (p.ej. impedir una condición de carrera creando dos códigos
// iguales a la vez), ese es el momento de pasar a Cloud Functions.
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/comunidad.dart';
import 'stream_error_logging.dart';

const _joinCodeChars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; // sin 0/O/1/I/L

class ComunidadService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> asegurarPerfilUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;
    final displayName = (user.email ?? 'Vecino').split('@').first;
    await ref.set({'displayName': displayName, 'comunidadId': null, 'createdAt': FieldValue.serverTimestamp()});
  }

  static Stream<String?> streamComunidadActivaId() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _db.collection('users').doc(uid).snapshots().map((d) => d.data()?['comunidadId'] as String?).conRegistroDeErrores();
  }

  static Stream<Comunidad> streamComunidad(String comunidadId) {
    return _db.collection('comunidades').doc(comunidadId).snapshots().where((d) => d.exists).map(Comunidad.fromDoc).conRegistroDeErrores();
  }

  static Future<String> _generarCodigoUnico() async {
    final rand = Random.secure();
    for (var intento = 0; intento < 10; intento++) {
      final codigo = List.generate(6, (_) => _joinCodeChars[rand.nextInt(_joinCodeChars.length)]).join();
      final existe = await _db.collection('joinCodes').doc(codigo).get();
      if (!existe.exists) return codigo;
    }
    throw Exception('No se pudo generar un código único.');
  }

  /// Quien crea la comunidad queda como presidente -- puede haber más de
  /// un presidente más adelante (p.ej. para relevos), pero el MVP no
  /// construye todavía esa pantalla de gestión de roles.
  static Future<String> crearComunidad({required String nombre, String? direccion}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No has iniciado sesión.');
    final userSnap = await _db.collection('users').doc(user.uid).get();
    final displayName = userSnap.data()?['displayName'] as String? ?? 'Presidente';

    final joinCode = await _generarCodigoUnico();
    final comunidadRef = _db.collection('comunidades').doc();
    final batch = _db.batch()
      ..set(comunidadRef, {
        'nombre': nombre,
        'direccion': direccion,
        'joinCode': joinCode,
        'members': {
          user.uid: {'displayName': displayName, 'rol': RolVecino.presidente.name},
        },
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..set(_db.collection('joinCodes').doc(joinCode), {'comunidadId': comunidadRef.id})
      ..set(_db.collection('users').doc(user.uid), {'comunidadId': comunidadRef.id}, SetOptions(merge: true));
    await batch.commit();
    return comunidadRef.id;
  }

  static Future<void> unirseComunidad(String joinCodeBruto) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No has iniciado sesión.');
    final joinCode = joinCodeBruto.trim().toUpperCase();
    if (joinCode.isEmpty) throw Exception('Código inválido.');

    final codeSnap = await _db.collection('joinCodes').doc(joinCode).get();
    if (!codeSnap.exists) throw Exception('No existe ninguna comunidad con ese código.');
    final comunidadId = codeSnap.data()!['comunidadId'] as String;

    final userSnap = await _db.collection('users').doc(user.uid).get();
    final displayName = userSnap.data()?['displayName'] as String? ?? 'Vecino';

    final batch = _db.batch()
      ..set(
        _db.collection('comunidades').doc(comunidadId),
        {
          'members.${user.uid}': {'displayName': displayName, 'rol': RolVecino.vecino.name},
        },
        SetOptions(merge: true),
      )
      ..set(_db.collection('users').doc(user.uid), {'comunidadId': comunidadId}, SetOptions(merge: true));
    await batch.commit();
  }
}
