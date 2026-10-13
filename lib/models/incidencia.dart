// lib/models/incidencia.dart
//
// Una incidencia reportada por un vecino (avería, mantenimiento, problema
// en zona común) -- con foto opcional y estado de seguimiento. Cualquier
// vecino la reporta; el presidente es quien normalmente la mueve de estado
// (la app no lo impone todavía a nivel de reglas -- ver firestore.rules:
// de momento cualquier miembro puede cambiar el estado, igual de simple
// que el resto del MVP).
import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoIncidencia {
  abierta,
  enProgreso,
  resuelta;

  static EstadoIncidencia fromString(String? s) =>
      EstadoIncidencia.values.firstWhere((e) => e.name == s, orElse: () => EstadoIncidencia.abierta);
}

class Incidencia {
  const Incidencia({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.fotoUrl,
    this.ubicacion,
    required this.estado,
    required this.creadoPorUid,
    required this.creadoPorNombre,
    this.createdAt,
  });

  final String id;
  final String titulo;
  final String? descripcion;
  final String? fotoUrl;

  /// Texto libre -- "portal 2, garaje", "ascensor B"... no hay un catálogo
  /// cerrado de ubicaciones en el MVP.
  final String? ubicacion;
  final EstadoIncidencia estado;
  final String creadoPorUid;
  final String creadoPorNombre;
  final DateTime? createdAt;

  factory Incidencia.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Incidencia(
      id: doc.id,
      titulo: data['titulo'] as String? ?? '',
      descripcion: data['descripcion'] as String?,
      fotoUrl: data['fotoUrl'] as String?,
      ubicacion: data['ubicacion'] as String?,
      estado: EstadoIncidencia.fromString(data['estado'] as String?),
      creadoPorUid: data['creadoPorUid'] as String? ?? '',
      creadoPorNombre: data['creadoPorNombre'] as String? ?? 'Vecino',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'fotoUrl': fotoUrl,
        'ubicacion': ubicacion,
        'estado': estado.name,
        'creadoPorUid': creadoPorUid,
        'creadoPorNombre': creadoPorNombre,
      };
}

String nombreEstadoIncidencia(EstadoIncidencia e) => switch (e) {
      EstadoIncidencia.abierta => 'Abierta',
      EstadoIncidencia.enProgreso => 'En progreso',
      EstadoIncidencia.resuelta => 'Resuelta',
    };
