import 'package:dartnative/dartnative.dart';

import 'dartnative_plugin_registrant.dart';

void main() {
  DartNativePluginRegistrant.registerAll();
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    brightness: Brightness.light,
    appBar: AppBar(title: const Text('Repro')),
    backgroundColor: const Color(0xFFFFFFFF),
    body: Center(
      child: TextButton(
        onPressed: () =>
            Navigator.push(context, PageRoute(builder: (_) => const Repro())),
        child: const Text('Open repro screen'),
      ),
    ),
  );
}

/// Two behaviours on one pushed screen (native AppBar with a back button).
/// The Scaffold and AppBar are in a stateless widget and never rebuild; only
/// [_Body] calls setState.
///
/// 1. SLIDER OVERSHOOT. Drag the slider, then hold your finger still. The
///    value reported by onChanged keeps moving past the finger and eases back
///    while the finger is down. The slider's `value` is only updated in
///    onChangeEnd, so the app never feeds values back during the drag.
/// 2. BACK BUTTON FLICKER. Turn on "Rewrite TextField every tick" and drag:
///    the AppBar back button flickers.
class Repro extends StatelessWidget {
  const Repro({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    brightness: Brightness.light,
    appBar: AppBar(title: const Text('Slider repro')),
    backgroundColor: const Color(0xFFFFFFFF),
    body: const SafeArea(
      child: Padding(padding: EdgeInsets.all(16), child: _Body()),
    ),
  );
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  static const _min = 20.0, _max = 10000.0;

  double _sliderValue = 50; // handed to the Slider; changed only on release
  double _shown = 50; // follows onChanged
  bool _rewriteField = false;
  final _field = TextEditingController(text: '50');
  final _log = <String>[];

  void _note(String line) {
    final stamp = DateTime.now().millisecondsSinceEpoch % 100000;
    // ignore: avoid_print
    print('[repro $stamp] $line');
    _log.add(line);
    if (_log.length > 6) _log.removeAt(0);
  }

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _shown.round().toString(),
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
      ),
      Slider(
        value: _sliderValue,
        min: _min,
        max: _max,
        onChangeStart: (v) => setState(() => _note('START $v')),
        onChanged: (v) => setState(() {
          _shown = v.roundToDouble();
          if (_rewriteField) _field.text = _shown.round().toString();
          _note('CHANGED $v');
        }),
        onChangeEnd: (v) => setState(() {
          _sliderValue = _shown;
          _field.text = _shown.round().toString();
          _note('END $v');
        }),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          const Expanded(child: Text('Rewrite TextField every tick')),
          Switch(
            value: _rewriteField,
            onChanged: (v) => setState(() => _rewriteField = v),
          ),
        ],
      ),
      TextField(controller: _field),
      const SizedBox(height: 12),
      for (final line in _log) Text(line),
    ],
  );
}
