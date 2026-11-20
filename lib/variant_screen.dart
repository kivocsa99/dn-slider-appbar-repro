import 'package:dartnative/dartnative.dart';

/// Which parts of the real app's donation screen to copy onto the repro.
class Variant {
  const Variant({
    this.customLeading = false,
    this.signalTitle = false,
    this.gradientBody = false,
    this.rtl = false,
  });

  /// `leading: IconButton(...)` instead of the system back button.
  final bool customLeading;

  /// A title `Builder` that calls `.watch(context)` on a signal.
  final bool signalTitle;

  /// A gradient `Container` behind the body.
  final bool gradientBody;

  /// `Directionality` set to right-to-left (the Arabic app).
  final bool rtl;
}

/// Launcher with one switch per difference, then opens [VariantScreen].
class VariantLauncher extends StatefulWidget {
  const VariantLauncher({super.key});

  @override
  State<VariantLauncher> createState() => _VariantLauncherState();
}

class _VariantLauncherState extends State<VariantLauncher> {
  bool _leading = false, _title = false, _gradient = false, _rtl = false;

  Widget _row(String label, bool value, void Function(bool) set) => Row(
    children: [
      Expanded(child: Text(label)),
      Switch(value: value, onChanged: (v) => setState(() => set(v))),
    ],
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _row('Custom leading IconButton', _leading, (v) => _leading = v),
      _row('Title Builder watching a signal', _title, (v) => _title = v),
      _row('Gradient body', _gradient, (v) => _gradient = v),
      _row('Right-to-left', _rtl, (v) => _rtl = v),
      TextButton(
        onPressed: () => Navigator.push(
          context,
          PageRoute(
            builder: (_) => VariantScreen(
              Variant(
                customLeading: _leading,
                signalTitle: _title,
                gradientBody: _gradient,
                rtl: _rtl,
              ),
            ),
          ),
        ),
        child: const Text('Open variant screen'),
      ),
    ],
  );
}

final _steps = signal<List<String>>(['amount', 'review']);

/// The repro screen with the chosen real-app differences. The Scaffold and
/// AppBar never rebuild on a drag; only the body calls setState.
class VariantScreen extends StatelessWidget {
  const VariantScreen(this.variant, {super.key});

  final Variant variant;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: variant.rtl ? TextDirection.rtl : TextDirection.ltr,
    child: Scaffold(
      brightness: Brightness.light,
      backgroundColor: const Color(0xFFFCF1E9),
      appBar: AppBar(
        title: variant.signalTitle
            ? Builder(
                builder: (context) {
                  _steps.watch(context);
                  return const Text('Variant');
                },
              )
            : const Text('Variant'),
        leading: variant.customLeading
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  variant.rtl ? Icons.arrow_forward : Icons.arrow_back,
                  color: const Color(0xFF004F59),
                ),
              )
            : null,
      ),
      body: variant.gradientBody
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF6F6F6), Color(0xFFFCF1E9)],
                ),
              ),
              child: const SafeArea(child: _Body()),
            )
          : const SafeArea(child: _Body()),
    ),
  );
}

/// Same slider and every-tick TextField rewrite as the original repro.
class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  double _sliderValue = 50, _shown = 50;
  final _field = TextEditingController(text: '50');

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Drag the slider; the field is rewritten on every tick.'),
        Slider(
          value: _sliderValue,
          min: 20,
          max: 10000,
          onChanged: (v) => setState(() {
            _shown = v.roundToDouble();
            _field.text = _shown.round().toString();
          }),
          onChangeEnd: (v) => setState(() => _sliderValue = _shown),
        ),
        TextField(controller: _field),
      ],
    ),
  );
}
