// test/widget_test.dart
//
// Smoke test del tema -- no monta VecindApp entero porque su StreamBuilder
// depende de FirebaseAuth.instance, que necesita Firebase.initializeApp()
// de verdad (no disponible en un test de widgets). Mismo patrón que Repara.
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindapp/theme/design_tokens.dart';

void main() {
  test('Los temas claro y oscuro de VecindApp se construyen sin errores', () {
    expect(buildVecindLightTheme(), isNotNull);
    expect(buildVecindDarkTheme(), isNotNull);
  });
}
