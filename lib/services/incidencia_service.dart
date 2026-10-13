// lib/services/incidencia_service.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/incidencia.dart';
import 'stream_error_logging.dart';

class IncidenciaService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col(String comunidadId) =>
      _db.collection('comunidades').doc(comunidadId).collection('incidencias');

  static Stream<List<Incidencia>> streamIncidencias(String comunidadId) {
    return _col(comunidadId).orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map(Incidencia.fromDoc).toList(),
        ).conRegistroDeErrores();
  }

  static Future<String> subirFoto(String comunidadId, File archivo) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('comunidades/$comunidadId/incidencias/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(archivo);
    return ref.getDownloadURL();
  }

  static Future<void> crear(String comunidadId, Incidencia incidencia) async {
    await _col(comunidadId).add({...incidencia.toMap(), 'createdAt': FieldValue.serverTimestamp()});
  }

  static Future<void> cambiarEstado(String comunidadId, String incidenciaId, EstadoIncidencia estado) async {
    await _col(comunidadId).doc(incidenciaId).update({'estado': estado.name});
  }

  static Future<void> eliminar(String comunidadId, String incidenciaId) async {
    await _col(comunidadId).doc(incidenciaId).delete();
  }
}
