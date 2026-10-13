// lib/models/aviso.dart
//
// Un aviso/comunicado de la comunidad -- lo publica el presidente, lo lee
// cualquier vecino. Sin aprobación ni flujo de dos pasos: es un canal de
// difusión, no una negociación (a diferencia de las incidencias, que sí
// tienen estado).
import 'package:cloud_firestore/cloud_firestore.dart';

class Aviso {
  const Aviso({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.creadoPorUid,
    required this.creadoPorNombre,
    this.fijado = false,
    this.createdAt,
  });

  final String id;
  final String titulo;
  final String cuerpo;
  final String creadoPorUid;
  final String creadoPorNombre;

  /// Los avisos fijados salen primero en la lista -- para una convocatoria
  /// de junta o algo urgente que no debe perderse entre avisos más nuevos.
  final bool fijado;
  final DateTime? createdAt;

  factory Aviso.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Aviso(
      id: doc.id,
      titulo: data['titulo'] as String? ?? '',
      cuerpo: data['cuerpo'] as String? ?? '',
      creadoPorUid: data['creadoPorUid'] as String? ?? '',
      creadoPorNombre: data['creadoPorNombre'] as String? ?? 'Presidente',
      fijado: data['fijado'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'cuerpo': cuerpo,
        'creadoPorUid': creadoPorUid,
        'creadoPorNombre': creadoPorNombre,
        'fijado': fijado,
      };
}
