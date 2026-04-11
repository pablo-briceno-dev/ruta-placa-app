import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 7) buffer.write('ff'); // opacity
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

final colorsPlates = [
  hexToColor('#F57C00'), // naranja fuerte
  hexToColor('#FFD600'), // amarillo intenso (más puro)
  hexToColor('#8BC34A'), // verde lima (no rojo/verde crítico, es más claro)
  hexToColor('#00BCD4'), // cyan
  hexToColor('#2196F3'), // azul
  hexToColor('#3F51B5'), // índigo
  hexToColor('#9C27B0'), // púrpura
  hexToColor('#E91E63'), // rosa fuerte
  hexToColor('#795548'), // marrón
  hexToColor('#455A64'), // gris azulado oscuro
];

final holidayColor = hexToColor('#673AB7');
