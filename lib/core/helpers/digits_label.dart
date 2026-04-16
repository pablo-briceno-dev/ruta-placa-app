/// Muestra los dígitos de forma compacta:
/// [1,2,3,4,5] → "1·2·3·4·5"  (máx 5 dígitos)
/// [1,2,3,4,5,6,7,8,9,0] → "Todos"
/// [9,0] → "9 · 0"
String buildDigitsLabel(List<int> plates) {
  if (plates.length >= 10) return 'Todos';
  if (plates.length > 5) return '${plates.length} díg.';
  return plates.join('·');
}
