# Splash

[![Pub](https://img.shields.io/pub/v/splash.svg)](https://pub.dartlang.org/packages/splash)
[![GitHub Workflow Status](https://github.com/ueman/splash/workflows/build/badge.svg?branch=master)](https://github.com/ueman/splash/actions?query=workflow%3Abuild)

This package contains a few alternatives for [InkSplash.splashFactory](https://api.flutter.dev/flutter/material/InkSplash/splashFactory-constant.html)
and [InkRipple.splashFactory](https://api.flutter.dev/flutter/material/InkRipple/splashFactory-constant.html).


## List of available splash alternatives

| Example                                           | Usage  |
|-                                                  |-      |
| ![No Splash](img/no_splash.gif "No Splash")       | `NoSplash.splashFactory` | 
| ![Line Splash](img/line_splash.gif "Line Splash") | `LineSplash.splashFactory`, `LineSplash.customSplashFactory(paint: paint)` | 
| ![Path Splash](img/path_splash.gif "Path Splash") | `PathSplash.splashFactory(path)`, `PathSplash.splashFactory(path, paint: paint, clip: false)` |
| ![Wave Splash](img/wave_splash.gif "Wave Splash") | `WaveSplash.splashFactory`, `WaveSplash.customSplashFactory(strokeWidth: 30, blurStrength: 5)` |

You can find an extensive example [here](example/lib/main.dart).


## How do I use them?

```dart
final splashFactory = ...

MaterialApp(
  theme: Theme(
    splashFactory: splashFactory,
  ),
  home: Scaffold(), 
);
```