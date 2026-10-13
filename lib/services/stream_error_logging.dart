// lib/services/stream_error_logging.dart
//
// Sin esto, un StreamBuilder que no comprueba snapshot.hasError convierte
// cualquier fallo (permission-denied, un índice que falta...) en una lista
// vacía silenciosa -- parece "no hay nada todavía" en vez de "algo falló",
// y nadie se entera ni en Crashlytics (mismo patrón que Repara, octubre
// 2026).
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

extension RegistraErroresDeStream<T> on Stream<T> {
  Stream<T> conRegistroDeErrores() {
    return handleError((Object error, StackTrace stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: false);
      Error.throwWithStackTrace(error, stackTrace);
    });
  }
}
