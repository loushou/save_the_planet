import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savetheplanet/helpers/screen.dart';
import 'package:savetheplanet/helpers/sound.dart';
import 'package:savetheplanet/helpers/theme.dart';
import 'package:savetheplanet/scenes/game/scene.dart';
import 'package:savetheplanet/scenes/menu/scene.dart';
import 'package:savetheplanet/widgets/utils/bound_scale_factor.dart';
import 'package:savetheplanet/widgets/utils/protect_exit.dart';

class SaveThePlanetApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _SaveThePlanetAppState createState() => _SaveThePlanetAppState();
}

class _SaveThePlanetAppState extends State<SaveThePlanetApp> {
  @override
  Widget build(BuildContext context) {
    return BoundScaleFactor(
      minFactor: 1,
      maxFactor: 1,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: stpTheme,
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => const ProtectExit(child: const MenuScene()),
          '/game': (BuildContext context) => const GameScene(),
        },
        initialRoute: '/',
      ),
    );
  }

  void _updateSystemBar() {
    SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[SystemUiOverlay.bottom]);
  }

  Future<void> _onFirstFrame(Duration _) async {
    generateStars(window.physicalSize);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(_onFirstFrame);

    Timer.periodic(const Duration(seconds: 3), (Timer t) {
      _updateSystemBar();
    });
    _updateSystemBar();
  }
}
