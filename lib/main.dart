import 'package:aurora/signals/all.dart';
import 'package:aurora/widgets/screens/homepage.dart';
import 'package:aurora/widgets/screens/initial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:fpdart/fpdart.dart';
import 'package:signals/signals_flutter.dart';
import 'models/all.dart';
import 'package:aurora/globals/globals.dart' as globals;
import 'package:aurora/config/config.dart' as config;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  return runApp(const MyApp());
}

FEB<Color> getDominantColor(String url) async {
  final p = await PaletteGenerator.fromImageProvider(NetworkImage(url));
  final c = p.dominantColor?.color;
  return c == null ? left(BError('No color')) : right(c);
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext c) {
    return MaterialApp(
      scaffoldMessengerKey: globals.snackbarKey,
      theme: config.AppTheme.light,
      darkTheme: config.AppTheme.dark,
      themeMode: theme$.watch(c),
      debugShowCheckedModeBanner: false,
      home: SignUpPromo(
        // isDarkMode: isDarkMode.value,
        // onThemeChanged: (c) => {isDarkMode.value = !isDarkMode.value},
      ),
    );
  }
}
