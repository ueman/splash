# Splash

This package contains a few alternatives for [InkSplash.splashFactory](https://api.flutter.dev/flutter/material/InkSplash/splashFactory-constant.html)
and [InkRipple.splashFactory](https://api.flutter.dev/flutter/material/InkRipple/splashFactory-constant.html).

You can find an extensive example [here](/example/lib/main.dart).

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

## List of available splash alternatives

| Name | Usage  | Use case |
|-     |-      |-         |
| NoSplash | `NoSplash.splashFactory` | You can use this class if you don't want a ripple splash effect |
| LineSplash | `LineSplash.splashFactory` Optionally you can provide a paint to customize its appearance. | Draws a line instead of circle |
| PathSplash | `PathSplash.splashFactory(path)` Optionally you can provide a paint to customize its appearance. | Animates a path |