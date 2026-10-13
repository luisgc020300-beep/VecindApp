// lib/services/aviso_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/aviso.dart';
import 'stream_error_logging.dart';

class AvisoService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col(String comunidadId) =>
      _db.collection('comunidades').doc(comunidadId).collection('avisos');

  /// Fijados primero, luego por fecha descendente -- un aviso fijado no
  /// debe desaparecer bajo avisos más recientes pero menos importantes.
  static Stream<List<Aviso>> streamAvisos(String comunidadId) {
    return _col(comunidadId).orderBy('fijado', descending: true).orderBy('createdAt', descending: true).snapshots().map(
          (s) => s.docs.map(Aviso.fromDoc).toList(),
        ).conRegistroDeErrores();
  }

  static Future<void> crear(String comunidadId, Aviso aviso) async {
    await _col(comunidadId).add({...aviso.toMap(), 'createdAt': FieldValue.serverTimestamp()});
  }

  static Future<void> eliminar(String comunidadId, String avisoId) async {
    await _col(comunidadId).doc(avisoId).delete();
  }
}
