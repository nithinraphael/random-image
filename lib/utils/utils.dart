import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:aurora/models/all.dart';

FEB<Color> getDominantColor(String url) async {
  final p = await PaletteGenerator.fromImageProvider(NetworkImage(url));
  final c = p.dominantColor?.color;
  return c == null ? left(BError('No color')) : right(c);
}
