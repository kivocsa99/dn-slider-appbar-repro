# dn_slider_appbar_repro

Minimal DartNative app for two iOS behaviours of the native `Slider` and
`AppBar`. See the linked GitHub issue for the full description.

```sh
dn pub get
dn run -d <ios-simulator-id>
```

Tap **Open repro screen**, then:

1. **Slider overshoot.** Drag the slider quickly to the right, then hold your
   finger still. The number keeps changing past the finger and eases back
   while the finger is still down. Console lines are prefixed `[repro`.
2. **Back button flicker.** Switch on **Rewrite TextField every tick** and drag
   the slider. The app bar back button flickers. With the switch off it does
   not.

The `Scaffold` and `AppBar` are in a stateless widget and never rebuild. Only
the body widget calls `setState`. The `Slider.value` is changed only in
`onChangeEnd`, so the app never feeds values back during a drag.
