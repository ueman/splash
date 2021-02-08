<p align="center">
  <img src="img/splash.png" max-height="100" alt="Splash" />
</p>

<p align="center">
  <a href="https://pub.dartlang.org/packages/splash"><img src="https://img.shields.io/pub/v/splash.svg" alt="pub.dev"></a>
  <a href="https://github.com/ueman/splash/actions?query=workflow%3Abuild"><img src="https://github.com/ueman/splash/workflows/build/badge.svg?branch=master" alt="GitHub Workflow Status"></a>
  <a href="https://github.com/ueman#sponsor-me"><img src="https://img.shields.io/github/sponsors/ueman" alt="Sponsoring"></a>
  <a href="https://pub.dev/packages/splash/score"><img src="https://badges.bar/splash/likes" alt="likes"></a>
  <a href="https://pub.dev/packages/splash/score"><img src="https://badges.bar/splash/popularity" alt="popularity"></a>
  <a href="https://pub.dev/packages/splash/score"><img src="https://badges.bar/splash/pub%20points" alt="pub points"></a>
</p>

---

This package contains a few alternatives for [InkSplash.splashFactory](https://api.flutter.dev/flutter/material/InkSplash/splashFactory-constant.html)
and [InkRipple.splashFactory](https://api.flutter.dev/flutter/material/InkRipple/splashFactory-constant.html).

## List of available alternatives

| Example                                           | Usage  |
|-                                                  |-      |
| ![Wave Splash](img/wave_splash.gif "Wave Splash") | `WaveSplash.splashFactory`, `WaveSplash.customSplashFactory(strokeWidth: 30, blurStrength: 5)` |
| ![Path Splash](img/path_splash.gif "Path Splash") | `PathSplash.splashFactory(path)`, `PathSplash.splashFactory(path, paint: paint, clip: false)` |
| ![Line Splash](img/line_splash.gif "Line Splash") | `LineSplash.splashFactory`, `LineSplash.customSplashFactory(paint: paint)` | 
| ![No Splash](img/no_splash.gif "No Splash")       | `NoSplash.splashFactory` | 

You can find an extensive example [here](example/lib/main.dart).
It shows simple usages and some more advances examples.

## How do I use them?

```dart
import 'package:splash/splash.dart';

final splashFactory = ...

MaterialApp(
  theme: Theme(
    splashFactory: splashFactory,
  ),
  home: Scaffold(), 
);
```

# New features and ideas

I would really appreciate pull request with new splash factories or good looking examples in the example app. You can do it [here](https://github.com/ueman/splash).

## Author

- Jonas Uekötter [GitHub](https://github.com/ueman) [Twitter](https://twitter.com/ue_man)

## Sponsoring

I'm working on my packages on my free-time, but I don't have as much time as I would. If this package or any other package I created is helping you, please consider to [sponsor](https://github.com/ueman#sponsor-me) me. By doing so, I will prioritize your issues or your pull-requests before the others.
