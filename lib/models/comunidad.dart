// lib/models/comunidad.dart
//
// Una comunidad de vecinos. Cada miembro tiene un rol (RolVecino) guardado
// dentro del propio documento de la comunidad -- igual que Casa.members en
// Repara, evita una colección aparte solo para la membresía.
import 'package:cloud_firestore/cloud_firestore.dart';

enum RolVecino {
  vecino,
  presidente;

  static RolVecino fromString(String? s) => RolVecino.values.firstWhere((r) => r.name == s, orElse: () => RolVecino.vecino);
}

class MiembroComunidad {
  const MiembroComunidad({required this.displayName, required this.rol});

  final String displayName;
  final RolVecino rol;

  factory MiembroComunidad.fromMap(Map<String, dynamic> map) => MiembroComunidad(
        displayName: map['displayName'] as String? ?? 'Vecino',
        rol: RolVecino.fromString(map['rol'] as String?),
      );

  Map<String, dynamic> toMap() => {'displayName': displayName, 'rol': rol.name};
}

class Comunidad {
  const Comunidad({
    required this.id,
    required this.nombre,
    this.direccion,
    required this.joinCode,
    required this.members,
  });

  final String id;
  final String nombre;
  final String? direccion;
  final String joinCode;

  /// uid -> datos del miembro (nombre + rol). El presidente es quien creó
  /// la comunidad o a quien otro presidente le haya asignado el rol.
  final Map<String, MiembroComunidad> members;

  factory Comunidad.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final membersRaw = (data['members'] as Map<String, dynamic>?) ?? {};
    return Comunidad(
      id: doc.id,
      nombre: data['nombre'] as String? ?? '',
      direccion: data['direccion'] as String?,
      joinCode: data['joinCode'] as String? ?? '',
      members: membersRaw.map((uid, v) => MapEntry(uid, MiembroComunidad.fromMap((v as Map).cast<String, dynamic>()))),
    );
  }

  RolVecino? rolDe(String uid) => members[uid]?.rol;
  bool esPresidente(String uid) => rolDe(uid) == RolVecino.presidente;
}
